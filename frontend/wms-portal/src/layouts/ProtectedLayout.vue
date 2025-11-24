<template>
  <div class="layout">
    <aside class="sidebar">
      <div class="brand">WMS 控制台</div>
      <nav>
        <div v-for="menu in menus" :key="menu.id">
          <router-link
            :to="menu.path"
            class="nav-item"
          >
            {{ menu.title }}
          </router-link>
          <router-link
            v-for="child in menu.children"
            :key="child.id"
            :to="child.path"
            class="nav-item child"
          >
            {{ child.title }}
          </router-link>
        </div>
      </nav>
    </aside>
    <main class="content">
      <header class="toolbar">
        <div class="breadcrumbs">当前位置：{{ activeTitle }}</div>
        <button class="link" @click="onLogout">退出登录</button>
      </header>
      <section class="view">
        <router-view />
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const menus = computed(() => userStore.menuTree || [])

const activeTitle = computed(() => {
  const target = menus.value.find((item) => item.path === route.path)
  return target?.title || '仪表盘'
})

const onLogout = async () => {
  await userStore.logout()
  router.push({ name: 'login' })
}
</script>

<style scoped>
.layout {
  display: flex;
  min-height: 100vh;
  background: #f5f6fa;
}
.sidebar {
  width: 220px;
  background: #1f2a44;
  color: #fff;
  display: flex;
  flex-direction: column;
  padding: 24px 16px;
}
.brand {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 24px;
}
.nav-item {
  display: block;
  color: #cfd6e6;
  text-decoration: none;
  padding: 10px 12px;
  border-radius: 8px;
  margin-bottom: 8px;
}
.nav-item.router-link-active {
  background: #3b82f6;
  color: #fff;
}
.nav-item.child {
  margin-left: 12px;
  font-size: 14px;
}
.content {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: #fff;
  border-bottom: 1px solid #e5e7eb;
}
.view {
  flex: 1;
  padding: 24px;
}
.link {
  background: none;
  border: none;
  color: #ef4444;
  cursor: pointer;
  font-weight: 600;
}
</style>

