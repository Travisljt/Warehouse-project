<template>
  <div class="dashboard">
    <h1>欢迎回来，{{ userStore.profile?.nickname || '访客' }}</h1>
    <p>当前角色：{{ userStore.roles.join(', ') || '未分配' }}</p>
    <section class="cards">
      <article class="card" v-for="item in cards" :key="item.title">
        <h3>{{ item.title }}</h3>
        <p>{{ item.desc }}</p>
      </article>
    </section>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '../stores/user'

const userStore = useUserStore()
const cards = computed(() => [
  { title: '实时库存', desc: '由 WMS 主服务提供' },
  { title: '任务调度', desc: '结合 WCS 调用 RabbitMQ 消息' },
  { title: '可视化监控', desc: '前端支持 3D/2D 场景扩展' }
])
</script>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
}
.card {
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
}
</style>

