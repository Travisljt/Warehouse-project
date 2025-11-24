<template>
  <div class="login-page">
    <form class="panel" @submit.prevent="handleSubmit">
      <h2>WMS 登录</h2>
      <label>
        用户名
        <input v-model="form.username" type="text" placeholder="请输入用户名" required />
      </label>
      <label>
        密码
        <input v-model="form.password" type="password" placeholder="请输入密码" required />
      </label>
      <button class="btn" type="submit" :disabled="userStore.loading">
        {{ userStore.loading ? '登录中...' : '登录' }}
      </button>
      <p class="hint">默认账号：admin / Admin@123</p>
      <p class="error" v-if="error">{{ error }}</p>
    </form>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '../stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const error = ref('')
const form = reactive({
  username: 'admin',
  password: 'Admin@123'
})

const handleSubmit = async () => {
  try {
    error.value = ''
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
  background: linear-gradient(135deg, #111827, #1f2937);
}
.panel {
  width: 360px;
  padding: 32px;
  background: #fff;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
}
label {
  display: flex;
  flex-direction: column;
  color: #4b5563;
  font-size: 14px;
  gap: 6px;
}
input {
  padding: 10px 12px;
  border-radius: 8px;
  border: 1px solid #d1d5db;
}
.btn {
  background: #2563eb;
  color: #fff;
  border: none;
  padding: 12px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
}
.hint {
  margin: 0;
  color: #9ca3af;
  font-size: 12px;
  text-align: center;
}
.error {
  color: #ef4444;
  text-align: center;
}
</style>

