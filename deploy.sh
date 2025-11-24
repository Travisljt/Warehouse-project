#!/bin/bash
set -euo pipefail

echo "🚀 WMS Warehouse Management System - 部署脚本"
echo "=============================================="

# 检查必要的工具
check_requirements() {
    echo "📋 检查系统要求..."

    if ! command -v java &> /dev/null; then
        echo "❌ Java 未安装，请安装 JDK 17+"
        exit 1
    fi

    if ! command -v node &> /dev/null; then
        echo "❌ Node.js 未安装，请安装 Node.js 20+"
        exit 1
    fi

    if ! command -v pnpm &> /dev/null; then
        echo "❌ pnpm 未安装，请运行: npm install -g pnpm"
        exit 1
    fi

    echo "✅ 系统要求检查通过"
}

# 安装后端依赖
install_backend() {
    echo "🔧 安装后端依赖..."
    cd backend
    mvn clean install -DskipTests -q
    cd ..
    echo "✅ 后端依赖安装完成"
}

# 安装前端依赖
install_frontend() {
    echo "🎨 安装前端依赖..."
    cd frontend/wms-portal
    pnpm install --frozen-lockfile
    cd ../..
    echo "✅ 前端依赖安装完成"
}

# 构建前端
build_frontend() {
    echo "🏗️ 构建前端应用..."
    cd frontend/wms-portal
    pnpm build
    cd ../..
    echo "✅ 前端构建完成"
}

# 显示使用说明
show_usage() {
    echo ""
    echo "🎉 部署完成！使用方法："
    echo "======================"
    echo ""
    echo "启动所有服务："
    echo "  ./scripts/start-all-services.sh"
    echo ""
    echo "或者分别启动："
    echo "  # 启动后端服务"
    echo "  cd backend && ./scripts/run-services.sh"
    echo ""
    echo "  # 启动前端服务"
    echo "  cd frontend/wms-portal && pnpm dev"
    echo ""
    echo "访问地址："
    echo "  前端界面: http://localhost:5173"
    echo "  API网关:   http://localhost:9000"
    echo "  认证服务: http://localhost:9001"
    echo ""
    echo "默认账号："
    echo "  用户名: admin"
    echo "  密码: Admin@123"
}

# 主函数
main() {
    local skip_build=${1:-false}

    check_requirements

    if [[ "$skip_build" != "true" ]]; then
        install_backend
        install_frontend
        build_frontend
    fi

    show_usage
}

# 参数处理
case "${1:-}" in
    --help|-h)
        echo "WMS 部署脚本"
        echo ""
        echo "用法:"
        echo "  $0              # 完整部署（安装依赖 + 构建）"
        echo "  $0 --no-build   # 跳过构建，只显示使用说明"
        echo "  $0 --help       # 显示此帮助信息"
        ;;
    --no-build)
        main "true"
        ;;
    *)
        main
        ;;
esac
