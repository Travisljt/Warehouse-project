#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== WMS 系统服务启动脚本 ==="
echo "项目根目录: ${PROJECT_ROOT}"
echo ""

# 停止现有服务进程的函数
stop_existing_services() {
    echo "🔄 停止现有服务进程..."

    # 停止后端服务
    if pgrep -f "system-auth.*jar\|system-gateway.*jar\|spring-boot:run" > /dev/null; then
        echo "  📌 停止后端服务..."
        pkill -f "system-auth.*jar\|system-gateway.*jar\|spring-boot:run" || true
        sleep 3
    fi

    # 停止前端服务
    if pgrep -f "vite" > /dev/null; then
        echo "  🎨 停止前端服务..."
        pkill -f "vite" || true
        sleep 2
    fi

    # 等待端口释放
    echo "  ⏳ 等待端口释放..."
    local max_attempts=15
    local attempt=1
    while (( attempt <= max_attempts )); do
        local ports_in_use=0
        for port in 5173 9000 9001; do
            if lsof -i :${port} >/dev/null 2>&1; then
                ((ports_in_use++))
            fi
        done
        if (( ports_in_use == 0 )); then
            echo "  ✅ 所有端口已释放"
            break
        fi
        echo "  ⏳ 等待端口释放... (${attempt}/${max_attempts})"
        sleep 1
        ((attempt++))
    done

    if (( attempt > max_attempts )); then
        echo "  ⚠️  警告: 部分端口可能仍被占用"
    fi
}

# 启动后端服务
start_backend_services() {
    echo ""
    echo "🚀 启动后端服务..."

    cd "${PROJECT_ROOT}/backend"
    log_dir="${PROJECT_ROOT}/backend/logs"
    mkdir -p "$log_dir"

    echo "  🔧 启动认证服务..."
    # 暂时注释掉认证服务，因为存在兼容性问题
    # mvn -pl system/system-auth spring-boot:run > "${log_dir}/system-auth.log" 2>&1 &
    # AUTH_PID=$!
    echo "    ⚠️  认证服务暂时跳过（兼容性问题）"
    AUTH_PID=""

    echo "  🌐 启动网关服务..."
    mvn -pl system/system-gateway spring-boot:run > "${log_dir}/system-gateway.log" 2>&1 &
    GATEWAY_PID=$!

    # 等待服务启动
    sleep 8

    # 检查服务状态
    echo ""
    echo "📊 后端服务状态检查:"

    if [[ -n "${AUTH_PID:-}" ]] && kill -0 ${AUTH_PID} 2>/dev/null; then
        if curl -s http://localhost:9001/actuator/health 2>/dev/null | grep -q '"status":"UP"'; then
            echo "  ✅ system-auth (PID: ${AUTH_PID}) - 运行正常"
        else
            echo "  ❌ system-auth (PID: ${AUTH_PID}) - 健康检查失败"
        fi
    else
        echo "  ⚠️  system-auth - 暂时跳过（兼容性问题）"
    fi

    if kill -0 ${GATEWAY_PID} 2>/dev/null; then
        if curl -s http://localhost:9000/actuator/health 2>/dev/null | grep -q '"status":"UP"'; then
            echo "  ✅ system-gateway (PID: ${GATEWAY_PID}) - 运行正常"
        else
            echo "  ❌ system-gateway (PID: ${GATEWAY_PID}) - 健康检查失败"
        fi
    else
        echo "  ❌ system-gateway - 进程未运行"
    fi

    cd "${PROJECT_ROOT}"
}

# 启动前端服务
start_frontend_service() {
    echo ""
    echo "🎨 启动前端服务..."

    cd "${PROJECT_ROOT}/frontend/wms-portal"

    echo "  🚀 启动 Vue 开发服务器..."
    pnpm dev > "${PROJECT_ROOT}/frontend-dev.log" 2>&1 &
    FRONTEND_PID=$!

    # 等待前端启动
    sleep 5

    echo ""
    echo "📊 前端服务状态检查:"

    if kill -0 ${FRONTEND_PID} 2>/dev/null; then
        if curl -s http://localhost:5173 2>/dev/null | grep -q "<!DOCTYPE html>"; then
            echo "  ✅ 前端服务 (PID: ${FRONTEND_PID}) - 运行正常"
        else
            echo "  ❌ 前端服务 (PID: ${FRONTEND_PID}) - 页面加载失败"
        fi
    else
        echo "  ❌ 前端服务 - 进程未运行"
    fi

    cd "${PROJECT_ROOT}"
}

# 主执行流程
main() {
    stop_existing_services
    start_backend_services
    start_frontend_service

    echo ""
    echo "🎉 所有服务启动完成！"
    echo ""
    echo "📋 服务访问地址:"
    echo "  🎨 前端界面: http://localhost:5173"
    echo "  🌐 API网关:   http://localhost:9000"
    echo "  🔧 认证服务: http://localhost:9001"
    echo ""
    echo "📝 日志文件位置:"
    echo "  后端日志: ${PROJECT_ROOT}/backend/logs/"
    echo "  前端日志: ${PROJECT_ROOT}/frontend-dev.log"
    echo ""
    echo "⚡ 按 Ctrl+C 停止所有服务"

    # 保存进程ID到文件
    echo "${AUTH_PID:-} ${GATEWAY_PID:-} ${FRONTEND_PID:-}" > "${PROJECT_ROOT}/.service-pids"

    # 等待服务运行
    cleanup() {
        echo ""
        echo "🛑 正在停止所有服务..."
        [[ -n "${AUTH_PID:-}" ]] && kill ${AUTH_PID} 2>/dev/null || true
        [[ -n "${GATEWAY_PID:-}" ]] && kill ${GATEWAY_PID} 2>/dev/null || true
        [[ -n "${FRONTEND_PID:-}" ]] && kill ${FRONTEND_PID} 2>/dev/null || true
        rm -f "${PROJECT_ROOT}/.service-pids"
        echo "✅ 所有服务已停止"
        exit 0
    }

    trap cleanup INT TERM

    # 保持脚本运行
    while true; do
        sleep 1

        # 检查进程是否还在运行
        local running_count=0
        for pid in ${AUTH_PID:-} ${GATEWAY_PID:-} ${FRONTEND_PID:-}; do
            if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
                ((running_count++))
            fi
        done

        if (( running_count == 0 )); then
            echo "⚠️  所有服务进程已退出"
            break
        fi
    done

    rm -f "${PROJECT_ROOT}/.service-pids"
}

main "$@"
