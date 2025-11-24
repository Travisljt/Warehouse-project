import { defineStore } from 'pinia'
import { getMenus, getProfile, login as loginApi, logout as logoutApi } from '../api/auth'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('satoken') || '',
    profile: null,
    menus: [],
    loading: false
  }),
  getters: {
    isAuthenticated: (state) => Boolean(state.token),
    roles: (state) => (state.profile?.roles || []),
    permissions: (state) => (state.profile?.permissions || []),
    menuTree: (state) => state.menus
  },
  actions: {
    async login(payload) {
      this.loading = true
      try {
        const { data } = await loginApi(payload)
        this.token = data.token
        localStorage.setItem('satoken', data.token)
        await this.bootstrap()
      } finally {
        this.loading = false
      }
    },
    async bootstrap() {
      if (!this.token) {
        throw new Error('token missing')
      }
      const [{ data: profile }, { data: menus }] = await Promise.all([getProfile(), getMenus()])
      this.profile = profile
      this.menus = menus
    },
    async logout() {
      await logoutApi()
      this.token = ''
      this.profile = null
      this.menus = []
      localStorage.removeItem('satoken')
    }
  }
})

