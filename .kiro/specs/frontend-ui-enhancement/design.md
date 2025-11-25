# Design Document

## Overview

本设计文档描述了 WMS+WCS 前端界面优化的技术方案。优化将基于现有的 Vue 3 + Vite 技术栈，通过改进 CSS 样式、引入图标库、优化组件结构和增强交互效果来提升用户体验。设计遵循现代 Web 设计原则，注重视觉一致性、可访问性和响应式布局。

## Architecture

### 技术栈
- **框架**: Vue 3 (Composition API)
- **构建工具**: Vite
- **路由**: Vue Router 4
- **状态管理**: Pinia
- **HTTP 客户端**: Axios
- **图标库**: 将引入 Heroicons 或类似的 SVG 图标库
- **样式方案**: CSS Variables + Scoped CSS

### 设计系统结构

```
frontend/wms-portal/src/
├── assets/
│   ├── styles/
│   │   ├── variables.css      # CSS 变量定义（颜色、间距等）
│   │   ├── reset.css          # 样式重置
│   │   ├── utilities.css      # 工具类
│   │   └── animations.css     # 动画定义
│   └── icons/                 # 自定义图标组件
├── components/
│   ├── ui/                    # 通用 UI 组件
│   │   ├── Card.vue
│   │   ├── Button.vue
│   │   ├── Input.vue
│   │   └── Icon.vue
│   └── ...
├── layouts/
│   └── ProtectedLayout.vue    # 优化后的布局
└── views/
    ├── LoginView.vue          # 优化后的登录页
    └── DashboardView.vue      # 优化后的仪表板
```

## Components and Interfaces

### 1. 设计令牌系统 (Design Tokens)

使用 CSS Variables 定义设计令牌，确保整个应用的视觉一致性：

```css
:root {
  /* 颜色系统 */
  --color-primary: #3b82f6;
  --color-primary-dark: #2563eb;
  --color-primary-light: #60a5fa;
  
  --color-secondary: #8b5cf6;
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  
  --color-bg-primary: #ffffff;
  --color-bg-secondary: #f9fafb;
  --color-bg-tertiary: #f3f4f6;
  
  --color-text-primary: #111827;
  --color-text-secondary: #6b7280;
  --color-text-tertiary: #9ca3af;
  
  --color-border: #e5e7eb;
  --color-border-light: #f3f4f6;
  
  /* 间距系统 */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --spacing-2xl: 48px;
  
  /* 圆角 */
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  
  /* 阴影 */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
  --shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.15);
  
  /* 字体 */
  --font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-size-xs: 12px;
  --font-size-sm: 14px;
  --font-size-base: 16px;
  --font-size-lg: 18px;
  --font-size-xl: 20px;
  --font-size-2xl: 24px;
  --font-size-3xl: 30px;
  
  /* 过渡 */
  --transition-fast: 150ms ease;
  --transition-base: 200ms ease;
  --transition-slow: 300ms ease;
}
```

### 2. 通用 UI 组件

#### Card 组件
```vue
<template>
  <div class="card" :class="[variant, { hoverable }]">
    <div v-if="$slots.header" class="card-header">
      <slot name="header"></slot>
    </div>
    <div class="card-body">
      <slot></slot>
    </div>
    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>

<script setup>
defineProps({
  variant: {
    type: String,
    default: 'default',
    validator: (v) => ['default', 'bordered', 'elevated'].includes(v)
  },
  hoverable: Boolean
})
</script>
```

#### Button 组件
```vue
<template>
  <button 
    class="btn" 
    :class="[variant, size, { loading, block }]"
    :disabled="disabled || loading"
  >
    <span v-if="loading" class="btn-spinner"></span>
    <slot></slot>
  </button>
</template>

<script setup>
defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (v) => ['primary', 'secondary', 'outline', 'ghost', 'danger'].includes(v)
  },
  size: {
    type: String,
    default: 'md',
    validator: (v) => ['sm', 'md', 'lg'].includes(v)
  },
  loading: Boolean,
  disabled: Boolean,
  block: Boolean
})
</script>
```

#### Icon 组件
```vue
<template>
  <svg 
    class="icon" 
    :class="size"
    xmlns="http://www.w3.org/2000/svg" 
    fill="none" 
    viewBox="0 0 24 24" 
    stroke="currentColor"
  >
    <slot></slot>
  </svg>
</template>

<script setup>
defineProps({
  size: {
    type: String,
    default: 'md',
    validator: (v) => ['sm', 'md', 'lg', 'xl'].includes(v)
  }
})
</script>
```

### 3. 页面组件设计

#### LoginView 优化设计
- 全屏渐变背景，带有仓库相关的装饰元素
- 居中的登录卡片，带有品牌 logo
- 输入框带有图标前缀和清晰的焦点状态
- 登录按钮带有加载动画
- 错误提示带有淡入动画
- 响应式布局适配移动设备

#### DashboardView 优化设计
- 欢迎区域带有用户头像和个性化问候
- 统计卡片采用网格布局，带有图标、数字和趋势指示
- 卡片悬停效果和点击反馈
- 快捷操作区域
- 最近活动时间线

#### ProtectedLayout 优化设计
- 侧边栏带有品牌区域、导航菜单和用户信息
- 导航项带有图标和激活状态指示
- 顶部工具栏带有面包屑、搜索和用户菜单
- 主内容区域带有适当的内边距和背景
- 响应式：移动端侧边栏可折叠

## Data Models

本次优化主要涉及 UI 层面，不涉及新的数据模型。现有的数据模型保持不变：

- **User**: 用户信息（来自 Pinia store）
- **Menu**: 菜单树结构（来自后端 API）
- **Dashboard Metrics**: 仪表板指标数据

## Error Handling

### 样式加载错误
- 确保 CSS 变量有回退值
- 使用渐进增强策略，基础样式优先

### 图标加载错误
- 提供文本回退
- 使用内联 SVG 避免网络请求失败

### 响应式布局问题
- 使用 CSS Grid 和 Flexbox 的浏览器兼容写法
- 提供移动端和桌面端的最小宽度限制

## Testing Strategy

### 单元测试
本次优化主要关注视觉和交互改进，单元测试将聚焦于：
- 通用 UI 组件的 props 验证
- 组件的条件渲染逻辑
- 事件处理函数

测试框架：Vitest（Vue 官方推荐）

### 视觉回归测试
- 手动测试不同浏览器的渲染效果
- 验证响应式断点的布局变化
- 检查深色模式兼容性（如果实现）

### 可访问性测试
- 验证颜色对比度符合 WCAG 2.1 AA 标准
- 确保键盘导航可用
- 检查屏幕阅读器兼容性

### 性能测试
- 测量首次内容绘制 (FCP) 时间
- 验证动画性能（60fps）
- 检查 CSS 文件大小

### 浏览器兼容性测试
- Chrome/Edge (最新版本)
- Firefox (最新版本)
- Safari (最新版本)
- 移动端浏览器 (iOS Safari, Chrome Mobile)

## Implementation Notes

### CSS 组织策略
1. 使用 CSS 变量实现主题系统
2. 采用 BEM 命名约定或语义化类名
3. 利用 Vue 的 scoped CSS 避免样式冲突
4. 提取公共样式到独立文件

### 性能优化
1. 使用 CSS transform 和 opacity 实现动画（GPU 加速）
2. 避免过度使用 box-shadow 和复杂渐变
3. 图标使用 SVG 格式，支持按需加载
4. 延迟加载非关键 CSS

### 渐进增强
1. 确保基础功能在禁用 JavaScript 时可用
2. 使用语义化 HTML 标签
3. 提供合理的回退样式

### 响应式断点
```css
/* 移动设备 */
@media (max-width: 640px) { }

/* 平板设备 */
@media (min-width: 641px) and (max-width: 1024px) { }

/* 桌面设备 */
@media (min-width: 1025px) { }
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Input focus states are visually distinct
*For any* form input element, when it receives focus, the element should have distinct CSS styling (border color, shadow, or outline) different from its unfocused state.
**Validates: Requirements 1.2**

### Property 2: Responsive layout adapts at breakpoints
*For any* viewport width, the layout should apply appropriate CSS rules based on defined media query breakpoints (mobile < 640px, tablet 641-1024px, desktop > 1024px).
**Validates: Requirements 1.5**

### Property 3: Dashboard cards contain required visual elements
*For any* metric data, the rendered card component should contain an icon element, a color class, and the metric content.
**Validates: Requirements 2.1**

### Property 4: Dashboard header displays user information
*For any* authenticated user, the dashboard header should render elements containing the user's name and a personalized greeting.
**Validates: Requirements 2.3**

### Property 5: Grid layout adjusts to viewport
*For any* collection of cards, the grid layout should change its column count based on viewport width to maintain usability.
**Validates: Requirements 2.4**

### Property 6: Navigation items have icons and labels
*For any* menu structure, each navigation item should render both an icon element and a text label element.
**Validates: Requirements 3.1**

### Property 7: Active navigation item is highlighted
*For any* active route, the corresponding navigation item should have an active CSS class or distinct styling applied.
**Validates: Requirements 3.2**

### Property 8: Nested menu items have proper indentation
*For any* nested menu item, its indentation (margin-left or padding-left) should be greater than its parent menu item's indentation.
**Validates: Requirements 3.3**

### Property 9: Text contrast meets accessibility standards
*For any* text element and its background, the color contrast ratio should meet or exceed WCAG 2.1 AA standards (4.5:1 for normal text, 3:1 for large text).
**Validates: Requirements 5.2**

### Property 10: Status colors indicate different states
*For any* status value (success, warning, error, info), the rendered element should apply a distinct color class corresponding to that status.
**Validates: Requirements 5.5**

### Property 11: Loading state disables and shows indicator
*For any* button component with loading state true, the button should be disabled and display a loading spinner element.
**Validates: Requirements 6.3**

### Property 12: Form submission shows processing state
*For any* form submission, the submit button should become disabled and display a processing indicator until submission completes.
**Validates: Requirements 6.4**

### Property 13: Errors display with proper styling
*For any* error condition, the error message should be rendered with an error CSS class and positioned near the relevant input or action.
**Validates: Requirements 6.5**

### Property 14: Layout adjusts across viewport changes
*For any* viewport width change that crosses a breakpoint, the layout should apply different CSS rules to maintain usability.
**Validates: Requirements 7.1**

### Property 15: Card grid columns adapt to space
*For any* viewport width, the card grid should display an appropriate number of columns (1 for mobile, 2-3 for tablet, 3-4 for desktop) based on available space.
**Validates: Requirements 7.3**

### Property 16: Touch targets meet minimum size
*For any* interactive element on tablet/mobile viewports, the element should have minimum dimensions of 44x44 pixels for touch accessibility.
**Validates: Requirements 7.5**

### Property 17: Navigation items include icons
*For any* navigation menu, each item should contain an icon component alongside its text label.
**Validates: Requirements 8.1**

### Property 18: Dashboard cards display metric icons
*For any* dashboard card, the card should render an icon element that represents the metric type.
**Validates: Requirements 8.2**

### Property 19: Status indicators combine symbols and text
*For any* status indicator, the rendered output should contain both a visual icon element and text description.
**Validates: Requirements 8.4**
