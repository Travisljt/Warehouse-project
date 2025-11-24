#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log_dir="${PROJECT_ROOT}/logs"
mkdir -p "$log_dir"

# 停止现有服务进程的函数
stop_existing_services() {
    echo "[run-services] 停止现有服务进程..."

    # 停止 system-auth 服务
    if pgrep -f "system-auth.*jar" > /dev/null; then
        echo "[run-services] 停止 system-auth 服务..."
        pkill -f "system-auth.*jar" || true
        sleep 2
    fi

    # 停止 system-gateway 服务
    if pgrep -f "system-gateway.*jar" > /dev/null; then
        echo "[run-services] 停止 system-gateway 服务..."
        pkill -f "system-gateway.*jar" || true
        sleep 2
    fi

    # 停止 Maven Spring Boot 进程
    if pgrep -f "spring-boot:run" > /dev/null; then
        echo "[run-services] 停止 Maven Spring Boot 进程..."
        pkill -f "spring-boot:run" || true
        sleep 2
    fi

    # 等待端口释放
    local max_attempts=10
    local attempt=1
    while (( attempt <= max_attempts )); do
        if ! (lsof -i :9000 >/dev/null 2>&1 || lsof -i :9001 >/dev/null 2>&1); then
            echo "[run-services] 端口已释放"
            break
        fi
        echo "[run-services] 等待端口释放... (${attempt}/${max_attempts})"
        sleep 1
        ((attempt++))
    done

    if (( attempt > max_attempts )); then
        echo "[run-services] 警告: 端口可能仍被占用"
    fi
}

# 停止现有服务
stop_existing_services

echo "[run-services] 启动 system-auth 与 system-gateway，可按 Ctrl+C 停止"

echo "[run-services] 启动认证服务..."
mvn -pl system/system-auth spring-boot:run > "${log_dir}/system-auth.log" 2>&1 &
AUTH_PID=$!
echo "[run-services] system-auth(pid=${AUTH_PID}) 正在启动，日志: ${log_dir}/system-auth.log"

echo "[run-services] 启动网关服务..."
mvn -pl system/system-gateway spring-boot:run > "${log_dir}/system-gateway.log" 2>&1 &
GATEWAY_PID=$!
echo "[run-services] system-gateway(pid=${GATEWAY_PID}) 正在启动，日志: ${log_dir}/system-gateway.log"

# 等待一段时间让服务启动
sleep 5

# 检查服务状态
echo "[run-services] 检查服务启动状态..."
if kill -0 ${AUTH_PID} 2>/dev/null; then
    echo "[run-services] ✅ system-auth 服务运行正常"
else
    echo "[run-services] ❌ system-auth 服务启动失败，请检查日志: ${log_dir}/system-auth.log"
fi

if kill -0 ${GATEWAY_PID} 2>/dev/null; then
    echo "[run-services] ✅ system-gateway 服务运行正常"
else
    echo "[run-services] ❌ system-gateway 服务启动失败，请检查日志: ${log_dir}/system-gateway.log"
fi

echo "[run-services] 服务启动完成，按 Ctrl+C 停止所有服务"

trap 'echo "停止服务..."; kill ${AUTH_PID} ${GATEWAY_PID} 2>/dev/null || true' INT TERM
wait ${AUTH_PID} ${GATEWAY_PID} 2>/dev/null || true

