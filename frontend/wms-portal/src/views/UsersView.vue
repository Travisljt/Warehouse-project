<template>
  <div class="users-page">
    <header>
      <h1>用户管理</h1>
      <p>演示权限路由，未来可接入独立微服务。</p>
    </header>
    <table>
      <thead>
        <tr>
          <th>用户名</th>
          <th>角色</th>
          <th>状态</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in seeded" :key="user.username">
          <td>{{ user.username }}</td>
          <td>{{ user.role }}</td>
          <td>{{ user.status }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
const seeded = [
  { username: 'admin', role: 'ADMIN', status: '启用' },
  { username: 'planner', role: 'PLANNER', status: '启用' }
]
</script>

<style scoped>
.users-page {
  background: #fff;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.06);
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 16px;
}
th,
td {
  text-align: left;
  padding: 12px 8px;
  border-bottom: 1px solid #e5e7eb;
}
th {
  color: #6b7280;
  font-weight: 600;
}
</style>

