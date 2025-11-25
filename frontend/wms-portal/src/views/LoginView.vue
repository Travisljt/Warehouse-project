<template>
  <div class="login-page">
    <div class="login-background">
      <div class="background-pattern"></div>
    </div>
    
    <div class="login-container">
      <div class="login-card">
        <!-- Brand Logo Area -->
        <div class="brand-section">
          <div class="logo-wrapper">
            <IconWarehouse size="xl" />
          </div>
          <h1 class="brand-title">WMS 仓库管理系统</h1>
          <p class="brand-subtitle">智能仓储 · 高效管理</p>
        </div>

        <!-- Login Form -->
        <form class="login-form" @submit.prevent="handleSubmit">
          <Input
            v-model="form.username"
            type="text"
            label="用户名"
            placeholder="请输入用户名"
            required
            :error-message="fieldErrors.username"
            @focus="clearFieldError('username')"
          >
            <template #prefix>
              <IconUser size="sm" />
            </template>
          </Input>

          <Input
            v-model="form.password"
            type="password"
            label="密码"
            placeholder="请输入密码"
            required
            :error-message="fieldErrors.password"
            @focus="clearFieldError('password')"
          >
            <template #prefix>
              <IconLock size="sm" />
            </template>
          </Input>

          <Button
            type="submit"
            variant="primary"
            size="lg"
            block
            :loading="userStore.loading"
            :disabled="userStore.loading"
          >
            登录
          </Button>

          <p class="hint">默认账号：admin / Admin@123</p>

          <!-- Error Message with Animation -->
          <Transition name="error-fade">
            <div v-if="error" class="error-message">
              <span class="error-icon">⚠</span>
              <span>{{ error }}</span>
            </div>
          </Transition>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '../stores/user'
import Button from '../components/ui/Button.vue'
import Input from '../components/ui/Input.vue'
import IconUser from '../components/icons/IconUser.vue'
import IconLock from '../components/icons/IconLock.vue'
import IconWarehouse from '../components/icons/IconWarehouse.vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const error = ref('')
const fieldErrors = reactive({
  username: '',
  password: ''
})
const form = reactive({
  username: 'admin',
  password: 'Admin@123'
})

const clearFieldError = (field) => {
  fieldErrors[field] = ''
  error.value = ''
}

const handleSubmit = async () => {
  try {
    error.value = ''
    fieldErrors.username = ''
    fieldErrors.password = ''
    await userStore.login(form)
    router.push(route.query.redirect || { name: 'dashboard' })
  } catch (err) {
    error.value = err.response?.data?.message || '登录失败，请稍后再试'
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

/* Background with gradient and pattern */
.login-background {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 50%, #60a5fa 100%);
  z-index: 0;
}

.background-pattern {
  position: absolute;
  inset: 0;
  background-image: 
    repeating-linear-gradient(
      45deg,
      transparent,
      transparent 35px,
      rgba(255, 255, 255, 0.03) 35px,
      rgba(255, 255, 255, 0.03) 70px
    );
  animation: pattern-move 20s linear infinite;
}

@keyframes pattern-move {
  0% {
    transform: translateX(0) translateY(0);
  }
  100% {
    transform: translateX(70px) translateY(70px);
  }
}

/* Login Container */
.login-container {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 440px;
  padding: var(--spacing-lg);
  animation: fade-in-up 0.6s ease-out;
}

@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Login Card */
.login-card {
  background: var(--color-bg-primary);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-xl);
  padding: var(--spacing-2xl);
  backdrop-filter: blur(10px);
}

/* Brand Section */
.brand-section {
  text-align: center;
  margin-bottom: var(--spacing-xl);
}

.logo-wrapper {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-light));
  border-radius: var(--radius-xl);
  color: white;
  margin-bottom: var(--spacing-md);
  box-shadow: var(--shadow-lg);
}

.brand-title {
  font-size: var(--font-size-2xl);
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 var(--spacing-xs) 0;
}

.brand-subtitle {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin: 0;
}

/* Login Form */
.login-form {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
}

.hint {
  margin: 0;
  color: var(--color-text-tertiary);
  font-size: var(--font-size-xs);
  text-align: center;
}

/* Error Message with Animation */
.error-message {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-md);
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid var(--color-error);
  border-radius: var(--radius-md);
  color: var(--color-error);
  font-size: var(--font-size-sm);
}

.error-icon {
  font-size: var(--font-size-lg);
}

/* Error fade transition */
.error-fade-enter-active,
.error-fade-leave-active {
  transition: all var(--transition-base);
}

.error-fade-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}

.error-fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* Responsive Design - Mobile */
@media (max-width: 640px) {
  .login-container {
    max-width: 100%;
    padding: var(--spacing-md);
  }

  .login-card {
    padding: var(--spacing-xl);
  }

  .logo-wrapper {
    width: 64px;
    height: 64px;
  }

  .brand-title {
    font-size: var(--font-size-xl);
  }

  .brand-subtitle {
    font-size: var(--font-size-xs);
  }
}

/* Responsive Design - Tablet */
@media (min-width: 641px) and (max-width: 1024px) {
  .login-container {
    max-width: 400px;
  }
}
</style>

