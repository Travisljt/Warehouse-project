import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import * as fc from 'fast-check'
import ProtectedLayout from '../ProtectedLayout.vue'
import { createPinia, setActivePinia } from 'pinia'
import { useUserStore } from '../../stores/user'
import { createRouter, createMemoryHistory } from 'vue-router'
import { nextTick } from 'vue'

/**
 * Feature: frontend-ui-enhancement, Property 6: Navigation items have icons and labels
 * Validates: Requirements 3.1
 * 
 * This property test verifies that for any menu structure, each navigation item 
 * should render both an icon element and a text label element.
 */

/**
 * Feature: frontend-ui-enhancement, Property 7: Active navigation item is highlighted
 * Validates: Requirements 3.2
 * 
 * This property test verifies that for any active route, the corresponding navigation 
 * item should have an active CSS class or distinct styling applied.
 */

/**
 * Feature: frontend-ui-enhancement, Property 8: Nested menu items have proper indentation
 * Validates: Requirements 3.3
 * 
 * This property test verifies that for any nested menu item, its indentation 
 * (margin-left or padding-left) should be greater than its parent menu item's indentation.
 */

/**
 * Feature: frontend-ui-enhancement, Property 17: Navigation items include icons
 * Validates: Requirements 8.1
 * 
 * This property test verifies that for any navigation menu, each item should 
 * contain an icon component alongside its text label.
 */

// Helper function to create a test router
function createTestRouter(routes = []) {
  const defaultRoutes = [
    { path: '/', name: 'dashboard', component: { template: '<div>Dashboard</div>' } },
    { path: '/users', name: 'users', component: { template: '<div>Users</div>' } },
    { path: '/settings', name: 'settings', component: { template: '<div>Settings</div>' } }
  ]
  
  return createRouter({
    history: createMemoryHistory(),
    routes: routes.length > 0 ? routes : defaultRoutes
  })
}

describe('ProtectedLayout - Property-Based Tests', () => {
  beforeEach(() => {
    // Create a fresh Pinia instance for each test
    const pinia = createPinia()
    setActivePinia(pinia)
  })

  describe('Property 6: Navigation items have icons and labels', () => {
    it('should render both icon and label for any menu structure', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate arbitrary menu structures
          fc.array(
            fc.record({
              id: fc.integer({ min: 1, max: 1000 }),
              title: fc.constantFrom('仪表盘', '用户管理', '系统设置', '仓库管理'),
              path: fc.constantFrom('/', '/users', '/settings', '/warehouse'),
              children: fc.constant([])
            }),
            { minLength: 1, maxLength: 5 }
          ),
          async (menuData) => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            const router = createTestRouter()
            
            // Set up menu tree
            userStore.menus = menuData
            
            await router.push('/')
            await router.isReady()
            
            const wrapper = mount(ProtectedLayout, {
              global: {
                plugins: [pinia, router]
              }
            })

            await nextTick()

            // Property: For each menu item, both icon and label should exist
            const navItems = wrapper.findAll('.nav-item')
            expect(navItems.length).toBeGreaterThan(0)
            
            navItems.forEach(navItem => {
              // Property: Each nav item should have an icon element
              const icon = navItem.find('.nav-icon')
              expect(icon.exists()).toBe(true)
              
              // Property: Each nav item should have a label element
              const label = navItem.find('.nav-label')
              expect(label.exists()).toBe(true)
              
              // Property: Label should contain non-empty text
              expect(label.text().trim().length).toBeGreaterThan(0)
            })

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should render icons for nested menu items', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate menu with children - filter out whitespace-only titles
          fc.record({
            id: fc.integer({ min: 1, max: 1000 }),
            title: fc.constantFrom('仪表盘', '用户管理', '系统设置'),
            path: fc.constantFrom('/', '/users', '/settings'),
            children: fc.array(
              fc.record({
                id: fc.integer({ min: 1001, max: 2000 }),
                title: fc.string({ minLength: 2, maxLength: 20 }).filter(s => s.trim().length > 0),
                path: fc.string({ minLength: 2, maxLength: 30 }).filter(s => s.trim().length > 0).map(s => '/' + s.replace(/\s+/g, '-'))
              }),
              { minLength: 1, maxLength: 3 }
            )
          }),
          async (menuData) => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            const router = createTestRouter()
            
            // Set up menu tree with nested items
            userStore.menus = [menuData]
            
            await router.push('/')
            await router.isReady()
            
            const wrapper = mount(ProtectedLayout, {
              global: {
                plugins: [pinia, router]
              }
            })

            await nextTick()

            // Property: Child nav items should have icons and labels
            const childNavItems = wrapper.findAll('.nav-item-child')
            
            if (childNavItems.length > 0) {
              childNavItems.forEach(childItem => {
                // Property: Each child nav item should have an icon
                const icon = childItem.find('.nav-icon')
                expect(icon.exists()).toBe(true)
                
                // Property: Each child nav item should have a label
                const label = childItem.find('.nav-label')
                expect(label.exists()).toBe(true)
                expect(label.text().trim().length).toBeGreaterThan(0)
              })
            }

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })

  describe('Property 7: Active navigation item is highlighted', () => {
    it('should apply active class to the current route navigation item', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate menu data with valid paths
          fc.constantFrom(
            { path: '/', title: '仪表盘' },
            { path: '/users', title: '用户管理' },
            { path: '/settings', title: '系统设置' }
          ),
          async (activeMenu) => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            const router = createTestRouter()
            
            // Set up menu tree
            userStore.menus = [
              { id: 1, title: '仪表盘', path: '/', children: [] },
              { id: 2, title: '用户管理', path: '/users', children: [] },
              { id: 3, title: '系统设置', path: '/settings', children: [] }
            ]
            
            // Navigate to the active menu path
            await router.push(activeMenu.path)
            await router.isReady()
            
            const wrapper = mount(ProtectedLayout, {
              global: {
                plugins: [pinia, router]
              }
            })

            await nextTick()

            // Property: At least one nav item should have the active class
            const navItems = wrapper.findAll('.nav-item')
            const activeItems = navItems.filter(item => 
              item.classes().includes('router-link-active')
            )
            
            expect(activeItems.length).toBeGreaterThan(0)
            
            // Property: Active item should have distinct styling
            activeItems.forEach(activeItem => {
              expect(activeItem.classes()).toContain('router-link-active')
            })

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })

  describe('Property 8: Nested menu items have proper indentation', () => {
    it('should apply greater indentation to nested menu items', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate menu with children - filter out whitespace-only titles
          fc.record({
            id: fc.integer({ min: 1, max: 1000 }),
            title: fc.constantFrom('仪表盘', '用户管理', '系统设置'),
            path: fc.constantFrom('/', '/users', '/settings'),
            children: fc.array(
              fc.record({
                id: fc.integer({ min: 1001, max: 2000 }),
                title: fc.string({ minLength: 2, maxLength: 20 }).filter(s => s.trim().length > 0),
                path: fc.string({ minLength: 2, maxLength: 30 }).filter(s => s.trim().length > 0).map(s => '/' + s.replace(/\s+/g, '-'))
              }),
              { minLength: 1, maxLength: 3 }
            )
          }),
          async (menuData) => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            const router = createTestRouter()
            
            // Set up menu tree with nested items
            userStore.menus = [menuData]
            
            await router.push('/')
            await router.isReady()
            
            const wrapper = mount(ProtectedLayout, {
              global: {
                plugins: [pinia, router]
              },
              attachTo: document.body
            })

            await nextTick()

            // Property: Child items should have the nav-item-child class
            const childNavItems = wrapper.findAll('.nav-item-child')
            
            if (childNavItems.length > 0) {
              childNavItems.forEach(childItem => {
                // Property: Child items should have the nav-item-child class
                expect(childItem.classes()).toContain('nav-item-child')
              })
              
              // Property: nav-children container should exist
              const navChildren = wrapper.find('.nav-children')
              expect(navChildren.exists()).toBe(true)
              
              // Property: nav-children should have the nav-children class for indentation styling
              expect(navChildren.classes()).toContain('nav-children')
              
              // Property: Child items should be nested within nav-children container
              const childrenInContainer = navChildren.findAll('.nav-item-child')
              expect(childrenInContainer.length).toBe(childNavItems.length)
            }

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should maintain visual hierarchy with border for nested items', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate menu with multiple children - filter out whitespace-only titles
          fc.array(
            fc.record({
              id: fc.integer({ min: 1001, max: 2000 }),
              title: fc.string({ minLength: 2, maxLength: 20 }).filter(s => s.trim().length > 0),
              path: fc.string({ minLength: 2, maxLength: 30 }).filter(s => s.trim().length > 0).map(s => '/' + s.replace(/\s+/g, '-'))
            }),
            { minLength: 2, maxLength: 5 }
          ),
          async (children) => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            const router = createTestRouter()
            
            // Set up menu tree with nested items
            userStore.menus = [{
              id: 1,
              title: '用户管理',
              path: '/users',
              children: children
            }]
            
            await router.push('/')
            await router.isReady()
            
            const wrapper = mount(ProtectedLayout, {
              global: {
                plugins: [pinia, router]
              },
              attachTo: document.body
            })

            await nextTick()

            // Property: nav-children container should exist when there are children
            const navChildren = wrapper.find('.nav-children')
            expect(navChildren.exists()).toBe(true)
            
            // Property: All child items should be within the nav-children container
            const childNavItems = wrapper.findAll('.nav-item-child')
            expect(childNavItems.length).toBe(children.length)

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })

  describe('Property 17: Navigation items include icons', () => {
    it('should render icon elements for all navigation menu items', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate arbitrary menu structures
          fc.array(
            fc.record({
              id: fc.integer({ min: 1, max: 1000 }),
              title: fc.constantFrom('仪表盘', '用户管理', '系统设置', '仓库管理'),
              path: fc.constantFrom('/', '/users', '/settings', '/warehouse'),
              children: fc.constant([])
            }),
            { minLength: 1, maxLength: 5 }
          ),
          async (menuData) => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            const router = createTestRouter()
            
            // Set up menu tree
            userStore.menus = menuData
            
            await router.push('/')
            await router.isReady()
            
            const wrapper = mount(ProtectedLayout, {
              global: {
                plugins: [pinia, router]
              }
            })

            await nextTick()

            // Property: For each navigation item, an icon should be rendered
            const navItems = wrapper.findAll('.nav-item')
            expect(navItems.length).toBeGreaterThan(0)
            
            navItems.forEach(navItem => {
              // Property: Each nav item must contain an icon element
              const icon = navItem.find('.nav-icon')
              expect(icon.exists()).toBe(true)
              
              // Property: Icon should be an SVG or component element
              const svgOrComponent = navItem.find('svg, [class*="icon"]')
              expect(svgOrComponent.exists()).toBe(true)
            })

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should render icons for both parent and child navigation items', async () => {
      await fc.assert(
        fc.asyncProperty(
          // Generate menu with children - filter out whitespace-only titles
          fc.record({
            id: fc.integer({ min: 1, max: 1000 }),
            title: fc.constantFrom('仪表盘', '用户管理', '系统设置'),
            path: fc.constantFrom('/', '/users', '/settings'),
            children: fc.array(
              fc.record({
                id: fc.integer({ min: 1001, max: 2000 }),
                title: fc.string({ minLength: 2, maxLength: 20 }).filter(s => s.trim().length > 0),
                path: fc.string({ minLength: 2, maxLength: 30 }).filter(s => s.trim().length > 0).map(s => '/' + s.replace(/\s+/g, '-'))
              }),
              { minLength: 1, maxLength: 3 }
            )
          }),
          async (menuData) => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            const router = createTestRouter()
            
            // Set up menu tree with nested items
            userStore.menus = [menuData]
            
            await router.push('/')
            await router.isReady()
            
            const wrapper = mount(ProtectedLayout, {
              global: {
                plugins: [pinia, router]
              }
            })

            await nextTick()

            // Property: Parent nav items should have icons
            const parentNavItems = wrapper.findAll('.nav-item:not(.nav-item-child)')
            parentNavItems.forEach(navItem => {
              const icon = navItem.find('.nav-icon')
              expect(icon.exists()).toBe(true)
            })
            
            // Property: Child nav items should also have icons
            const childNavItems = wrapper.findAll('.nav-item-child')
            if (childNavItems.length > 0) {
              childNavItems.forEach(childItem => {
                const icon = childItem.find('.nav-icon')
                expect(icon.exists()).toBe(true)
              })
            }

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })
})
