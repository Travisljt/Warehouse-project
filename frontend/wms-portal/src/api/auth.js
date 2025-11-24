import http from '../services/http'

export const login = (payload) => http.post('/api/auth/login', payload)
export const logout = () => http.post('/api/auth/logout')
export const getProfile = () => http.get('/api/auth/profile')
export const getMenus = () => http.get('/api/auth/menus')

