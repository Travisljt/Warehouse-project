<template>
  <div class="dashboard">
    <!-- Welcome Area -->
    <div class="welcome-area">
      <div class="user-avatar">
        <IconUser size="xl" />
      </div>
      <div class="user-info">
        <h1 class="greeting">{{ greeting }}，{{ userStore.profile?.nickname || '访客' }}</h1>
        <p class="role-info">当前角色：{{ userStore.roles.join(', ') || '未分配' }}</p>
      </div>
    </div>

    <!-- Dashboard Cards Grid -->
    <section class="cards-grid">
      <Card 
        v-for="(item, index) in cards" 
        :key="item.title"
        variant="elevated"
        hoverable
        :class="['metric-card', `fade-in-${index}`]"
      >
        <div class="card-content">
          <div class="card-icon" :style="{ color: item.color }">
            <component :is="item.icon" size="xl" />
          </div>
          <div class="card-details">
            <h3 class="card-title">{{ item.title }}</h3>
            <p class="card-value">{{ item.value }}</p>
            <p class="card-desc">{{ item.desc }}</p>
          </div>
        </div>
      </Card>
    </section>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useUserStore } from '../stores/user'
import Card from '../components/ui/Card.vue'
import IconUser from '../components/icons/IconUser.vue'
import IconWarehouse from '../components/icons/IconWarehouse.vue'
import IconTooling from '../components/icons/IconTooling.vue'
import IconEcosystem from '../components/icons/IconEcosystem.vue'

const userStore = useUserStore()

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 12) return '早上好'
  if (hour < 18) return '下午好'
  return '晚上好'
})

const cards = computed(() => [
  { 
    title: '实时库存', 
    value: '1,234',
    desc: '由 WMS 主服务提供',
    icon: IconWarehouse,
    color: 'var(--color-primary)'
  },
  { 
    title: '任务调度', 
    value: '56',
    desc: '结合 WCS 调用 RabbitMQ 消息',
    icon: IconTooling,
    color: 'var(--color-secondary)'
  },
  { 
    title: '可视化监控', 
    value: '实时',
    desc: '前端支持 3D/2D 场景扩展',
    icon: IconEcosystem,
    color: 'var(--color-success)'
  }
])
</script>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xl);
  padding: var(--spacing-lg);
}

/* Welcome Area */
.welcome-area {
  display: flex;
  align-items: center;
  gap: var(--spacing-lg);
  padding: var(--spacing-xl);
  background: var(--color-bg-primary);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
}

.user-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-light));
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.user-info {
  flex: 1;
}

.greeting {
  font-size: var(--font-size-2xl);
  font-weight: 600;
  color: var(--color-text-primary);
  margin: 0 0 var(--spacing-xs) 0;
}

.role-info {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin: 0;
}

/* Cards Grid */
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-lg);
}

.metric-card {
  animation-duration: 0.5s;
  animation-fill-mode: both;
  animation-timing-function: ease-out;
}

.fade-in-0 {
  animation-name: fadeInUp;
  animation-delay: 0.1s;
}

.fade-in-1 {
  animation-name: fadeInUp;
  animation-delay: 0.2s;
}

.fade-in-2 {
  animation-name: fadeInUp;
  animation-delay: 0.3s;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.card-content {
  display: flex;
  gap: var(--spacing-lg);
  align-items: flex-start;
}

.card-icon {
  flex-shrink: 0;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg-secondary);
  border-radius: var(--radius-md);
}

.card-details {
  flex: 1;
}

.card-title {
  font-size: var(--font-size-base);
  font-weight: 600;
  color: var(--color-text-primary);
  margin: 0 0 var(--spacing-xs) 0;
}

.card-value {
  font-size: var(--font-size-2xl);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 var(--spacing-sm) 0;
}

.card-desc {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin: 0;
  line-height: 1.5;
}

/* Responsive Design */
@media (max-width: 640px) {
  .dashboard {
    padding: var(--spacing-md);
    gap: var(--spacing-lg);
  }

  .welcome-area {
    padding: var(--spacing-lg);
  }

  .greeting {
    font-size: var(--font-size-xl);
  }

  .cards-grid {
    grid-template-columns: 1fr;
    gap: var(--spacing-md);
  }
}

@media (min-width: 641px) and (max-width: 1024px) {
  .cards-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1025px) {
  .cards-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>

