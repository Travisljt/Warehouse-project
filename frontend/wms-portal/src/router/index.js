import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

const LoginView = () => import('../views/LoginView.vue')
const DashboardView = () => import('../views/DashboardView.vue')
const UsersView = () => import('../views/UsersView.vue')

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: LoginView,
      meta: { public: true }
    },
    {
      path: '/',
      redirect: '/dashboard'
    },
    {
      path: '/',
      component: () => import('../layouts/ProtectedLayout.vue'),
      children: [
        {
          path: 'dashboard',
          name: 'dashboard',
          component: DashboardView,
          meta: { permission: 'dashboard:view' }
        },
        {
          path: 'users',
          name: 'users',
          component: UsersView,
          meta: { permission: 'user:list' }
        }
      ]
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/'
    }
  ]
})

router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  console.log('Route guard:', { to: to.path, isPublic: to.meta.public, hasToken: !!userStore.token })
  
  if (to.meta.public) {
    if (userStore.isAuthenticated && to.name === 'login') {
      next({ name: 'dashboard' })
    } else {
      next()
    }
    return
  }
  if (!userStore.token) {
    console.log('No token, redirecting to login')
    return next({ name: 'login', query: { redirect: to.fullPath } })
  }
  if (!userStore.profile) {
    try {
      console.log('Bootstrapping user profile...')
      await userStore.bootstrap()
      console.log('Bootstrap successful')
    } catch (error) {
      console.error('Bootstrap failed:', error)
      userStore.logout()
      return next({ name: 'login', query: { redirect: to.fullPath } })
    }
  }
  const requiredPermission = to.meta.permission
  if (requiredPermission && !userStore.permissions.includes(requiredPermission)) {
    return next({ name: 'dashboard' })
  }
  next()
})

export default router

