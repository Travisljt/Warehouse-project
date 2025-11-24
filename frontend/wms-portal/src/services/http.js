import axios from 'axios'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:9001',
  timeout: 10000
})

http.interceptors.request.use((config) => {
  const token = localStorage.getItem('satoken')
  if (token) {
    config.headers.satoken = token
  }
  return config
})

http.interceptors.response.use(
  (response) => {
    if (response.data && response.data.success === false) {
      return Promise.reject({ response, message: response.data.message })
    }
    return response.data
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('satoken')
    }
    return Promise.reject(error)
  }
)

export default http

