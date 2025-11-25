<template>
  <div class="layout">
    <!-- Mobile Overlay -->
    <div 
      v-if="isMobileSidebarOpen" 
      class="sidebar-overlay"
      @click="closeMobileSidebar"
    ></div>

    <aside class="sidebar" :class="{ 'sidebar-mobile-open': isMobileSidebarOpen }">
      <div class="brand">
        <IconWarehouse size="lg" class="brand-icon" />
        <span class="brand-text">WMS 控制台</span>
      </div>
      <nav class="nav">
        <div v-for="menu in menus" :key="menu.id" class="nav-group">
          <router-link
            :to="menu.path"
            class="nav-item"
            :class="{ 'has-children': menu.children && menu.children.length > 0 }"
            @click="closeMobileSidebar"
          >
            <component :is="getMenuIcon(menu)" size="md" class="nav-icon" />
            <span class="nav-label">{{ menu.title }}</span>
          </router-link>
          <div v-if="menu.children && menu.children.length > 0" class="nav-children">
            <router-link
              v-for="child in menu.children"
              :key="child.id"
              :to="child.path"
              class="nav-item nav-item-child"
              @click="closeMobileSidebar"
            >
              <IconChevronRight size="sm" class="nav-icon nav-icon-chevron" />
              <span class="nav-label">{{ child.title }}</span>
            </router-link>
          </div>
        </div>
      </nav>
    </aside>
    <main class="content">
      <header class="toolbar">
        <div class="toolbar-left">
          <!-- Hamburger Menu Button (Mobile) -->
          <button 
            class="hamburger-btn"
            @click="toggleMobileSidebar"
            aria-label="Toggle navigation menu"
          >
            <span class="hamburger-line"></span>
            <span class="hamburger-line"></span>
            <span class="hamburger-line"></span>
          </button>

          <nav class="breadcrumbs" aria-label="Breadcrumb">
            <ol class="breadcrumb-list">
              <li class="breadcrumb-item">
                <router-link to="/dashboard" class="breadcrumb-link">
                  <IconDashboard size="sm" class="breadcrumb-icon" />
                  <span>首页</span>
                </router-link>
              </li>
              <li class="breadcrumb-separator">/</li>
              <li class="breadcrumb-item breadcrumb-current">
                <span>{{ activeTitle }}</span>
              </li>
            </ol>
          </nav>
        </div>
        <div class="toolbar-right">
          <div class="toolbar-actions">
            <button class="toolbar-btn toolbar-btn-secondary" @click="onLogout">
              <IconLock size="sm" class="toolbar-btn-icon" />
              <span>退出登录</span>
            </button>
          </div>
        </div>
      </header>
      <section class="view">
        <router-view />
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import IconWarehouse from '../components/icons/IconWarehouse.vue'
import IconDashboard from '../components/icons/IconDashboard.vue'
import IconUser from '../components/icons/IconUser.vue'
import IconSettings from '../components/icons/IconSettings.vue'
import IconChevronRight from '../components/icons/IconChevronRight.vue'
import IconLock from '../components/icons/IconLock.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// Mobile sidebar state
const isMobileSidebarOpen = ref(false)

const menus = computed(() => userStore.menuTree || [])

const activeTitle = computed(() => {
  const target = menus.value.find((item) => item.path === route.path)
  return target?.title || '仪表盘'
})

// Map menu titles to icons
const getMenuIcon = (menu) => {
  const iconMap = {
    '仪表盘': IconDashboard,
    '用户管理': IconUser,
    '系统设置': IconSettings,
    '仓库管理': IconWarehouse
  }
  return iconMap[menu.title] || IconDashboard
}

const toggleMobileSidebar = () => {
  isMobileSidebarOpen.value = !isMobileSidebarOpen.value
}

const closeMobileSidebar = () => {
  isMobileSidebarOpen.value = false
}

const onLogout = async () => {
  await userStore.logout()
  router.push({ name: 'login' })
}
</script>

<style scoped>
.layout {
  display: flex;
  min-height: 100vh;
  background: var(--color-bg-secondary);
}

/* Sidebar Styles */
.sidebar {
  width: 260px;
  background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
  color: var(--color-text-inverse);
  display: flex;
  flex-direction: column;
  padding: var(--spacing-lg) 0;
  box-shadow: var(--shadow-lg);
}

/* Brand Area */
.brand {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  padding: 0 var(--spacing-lg);
  margin-bottom: var(--spacing-xl);
}

.brand-icon {
  color: var(--color-primary-light);
  flex-shrink: 0;
}

.brand-text {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text-inverse);
  letter-spacing: -0.5px;
}

/* Navigation */
.nav {
  flex: 1;
  overflow-y: auto;
  padding: 0 var(--spacing-md);
}

.nav-group {
  margin-bottom: var(--spacing-sm);
}

/* Navigation Items */
.nav-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  color: #cbd5e1;
  text-decoration: none;
  padding: var(--spacing-md) var(--spacing-md);
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-xs);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  transition: all var(--transition-base);
  position: relative;
}

.nav-item:hover {
  background: rgba(59, 130, 246, 0.1);
  color: var(--color-text-inverse);
  transform: translateX(2px);
}

.nav-item.router-link-active {
  background: var(--color-primary);
  color: var(--color-text-inverse);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.nav-item.router-link-active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 60%;
  background: var(--color-text-inverse);
  border-radius: 0 2px 2px 0;
}

/* Navigation Icons */
.nav-icon {
  flex-shrink: 0;
  transition: transform var(--transition-base);
}

.nav-item:hover .nav-icon {
  transform: scale(1.1);
}

.nav-label {
  flex: 1;
}

/* Nested Menu Items */
.nav-children {
  margin-left: var(--spacing-lg);
  padding-left: var(--spacing-md);
  border-left: 2px solid rgba(148, 163, 184, 0.2);
}

.nav-item-child {
  padding: var(--spacing-sm) var(--spacing-md);
  font-size: var(--font-size-xs);
  color: #94a3b8;
  margin-left: var(--spacing-sm);
}

.nav-item-child:hover {
  color: var(--color-text-inverse);
  background: rgba(59, 130, 246, 0.08);
}

.nav-item-child.router-link-active {
  color: var(--color-primary-light);
  background: rgba(59, 130, 246, 0.15);
}

.nav-icon-chevron {
  opacity: 0.6;
}

/* Content Area */
.content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* Toolbar Styles */
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-md) var(--spacing-xl);
  background: var(--color-bg-primary);
  border-bottom: 2px solid var(--color-border);
  box-shadow: var(--shadow-md);
  min-height: 64px;
  position: sticky;
  top: 0;
  z-index: 10;
  backdrop-filter: blur(8px);
}

.toolbar-left {
  flex: 1;
  display: flex;
  align-items: center;
}

.toolbar-right {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
}

/* Breadcrumbs */
.breadcrumbs {
  display: flex;
  align-items: center;
}

.breadcrumb-list {
  display: flex;
  align-items: center;
  list-style: none;
  margin: 0;
  padding: 0;
  gap: var(--spacing-sm);
}

.breadcrumb-item {
  display: flex;
  align-items: center;
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
}

.breadcrumb-link {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  color: var(--color-text-secondary);
  text-decoration: none;
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: var(--radius-sm);
  transition: all var(--transition-fast);
  font-weight: var(--font-weight-medium);
}

.breadcrumb-link:hover {
  color: var(--color-primary);
  background: var(--color-bg-tertiary);
}

.breadcrumb-icon {
  flex-shrink: 0;
}

.breadcrumb-separator {
  color: var(--color-text-tertiary);
  font-size: var(--font-size-sm);
  user-select: none;
}

.breadcrumb-current {
  color: var(--color-text-primary);
  font-weight: var(--font-weight-semibold);
}

/* Toolbar Actions */
.toolbar-actions {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.toolbar-btn {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-sm) var(--spacing-md);
  border: 1px solid transparent;
  border-radius: var(--radius-md);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: all var(--transition-base);
  white-space: nowrap;
  background: none;
}

.toolbar-btn-icon {
  flex-shrink: 0;
  transition: transform var(--transition-fast);
}

.toolbar-btn:hover .toolbar-btn-icon {
  transform: scale(1.1);
}

.toolbar-btn-secondary {
  color: var(--color-error);
  border-color: var(--color-border);
  background: var(--color-bg-primary);
}

.toolbar-btn-secondary:hover {
  color: var(--color-error);
  background: rgba(239, 68, 68, 0.08);
  border-color: rgba(239, 68, 68, 0.3);
  box-shadow: var(--shadow-sm);
}

.toolbar-btn-secondary:active {
  transform: translateY(1px);
  box-shadow: none;
}

/* View Area */
.view {
  flex: 1;
  padding: var(--spacing-lg);
}

/* Scrollbar Styling for Sidebar */
.nav::-webkit-scrollbar {
  width: 6px;
}

.nav::-webkit-scrollbar-track {
  background: transparent;
}

.nav::-webkit-scrollbar-thumb {
  background: rgba(148, 163, 184, 0.3);
  border-radius: 3px;
}

.nav::-webkit-scrollbar-thumb:hover {
  background: rgba(148, 163, 184, 0.5);
}

/* Hamburger Menu Button */
.hamburger-btn {
  display: none;
  flex-direction: column;
  justify-content: space-between;
  width: 44px;
  height: 44px;
  padding: 10px;
  background: none;
  border: none;
  cursor: pointer;
  margin-right: var(--spacing-md);
  border-radius: var(--radius-md);
  transition: background var(--transition-base);
}

.hamburger-btn:hover {
  background: var(--color-bg-tertiary);
}

.hamburger-btn:active {
  background: var(--color-bg-secondary);
}

.hamburger-line {
  display: block;
  width: 100%;
  height: 3px;
  background: var(--color-text-primary);
  border-radius: 2px;
  transition: all var(--transition-base);
}

/* Sidebar Overlay for Mobile */
.sidebar-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 998;
  animation: fade-in var(--transition-base);
}

@keyframes fade-in {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

/* Responsive Design - Mobile (max-width: 640px) */
@media (max-width: 640px) {
  .layout {
    flex-direction: column;
  }

  /* Hide sidebar by default on mobile */
  .sidebar {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    width: 280px;
    transform: translateX(-100%);
    transition: transform var(--transition-base);
    z-index: 999;
  }

  /* Show sidebar when open */
  .sidebar-mobile-open {
    transform: translateX(0);
  }

  /* Show overlay when sidebar is open */
  .sidebar-mobile-open ~ .content .sidebar-overlay,
  .sidebar-overlay {
    display: block;
  }

  /* Show hamburger button on mobile */
  .hamburger-btn {
    display: flex;
  }

  /* Adjust content area */
  .content {
    width: 100%;
  }

  /* Adjust toolbar for mobile */
  .toolbar {
    padding: var(--spacing-sm) var(--spacing-md);
    min-height: 56px;
  }

  .toolbar-left {
    flex: 1;
    min-width: 0;
  }

  /* Hide breadcrumb text on very small screens */
  .breadcrumb-link span {
    display: none;
  }

  .breadcrumb-current span {
    display: inline;
  }

  /* Adjust toolbar button text */
  .toolbar-btn span {
    display: none;
  }

  .toolbar-btn {
    padding: var(--spacing-sm);
    min-width: 44px;
    min-height: 44px;
    justify-content: center;
  }

  /* Adjust view padding */
  .view {
    padding: var(--spacing-md);
  }
}

/* Responsive Design - Tablet (641px - 1024px) */
@media (min-width: 641px) and (max-width: 1024px) {
  .sidebar {
    width: 220px;
  }

  .brand-text {
    font-size: var(--font-size-lg);
  }

  .toolbar {
    padding: var(--spacing-md) var(--spacing-lg);
  }

  .view {
    padding: var(--spacing-lg);
  }

  /* Show hamburger on tablet if needed */
  .hamburger-btn {
    display: flex;
  }

  .sidebar {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    transform: translateX(-100%);
    transition: transform var(--transition-base);
    z-index: 999;
  }

  .sidebar-mobile-open {
    transform: translateX(0);
  }

  .sidebar-overlay {
    display: none;
  }

  .sidebar-mobile-open ~ .content .sidebar-overlay,
  .sidebar-overlay {
    display: block;
  }

  .content {
    width: 100%;
  }
}

/* Responsive Design - Desktop (min-width: 1025px) */
@media (min-width: 1025px) {
  /* Sidebar always visible on desktop */
  .sidebar {
    position: relative;
    transform: translateX(0);
  }

  /* Hide hamburger button on desktop */
  .hamburger-btn {
    display: none;
  }

  /* No overlay needed on desktop */
  .sidebar-overlay {
    display: none !important;
  }
}

/* Ensure all interactive elements meet minimum touch target size */
.nav-item,
.toolbar-btn,
.breadcrumb-link,
.hamburger-btn {
  min-width: 44px;
  min-height: 44px;
}
</style>

