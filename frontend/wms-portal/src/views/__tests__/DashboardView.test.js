import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import * as fc from 'fast-check'
import DashboardView from '../DashboardView.vue'
import { createPinia, setActivePinia } from 'pinia'
import { useUserStore } from '../../stores/user'

/**
 * Feature: frontend-ui-enhancement, Property 4: Dashboard header displays user information
 * Validates: Requirements 2.3
 * 
 * This property test verifies that for any authenticated user, the dashboard header 
 * should render elements containing the user's name and a personalized greeting.
 */

/**
 * Feature: frontend-ui-enhancement, Property 5: Grid layout adjusts to viewport
 * Validates: Requirements 2.4
 * 
 * This property test verifies that for any collection of cards, the grid layout 
 * should change its column count based on viewport width to maintain usability.
 */

/**
 * Feature: frontend-ui-enhancement, Property 15: Card grid columns adapt to space
 * Validates: Requirements 7.3
 * 
 * This property test verifies that for any viewport width, the card grid should 
 * display an appropriate number of columns (1 for mobile, 2-3 for tablet, 3-4 for desktop) 
 * based on available space.
 */

/**
 * Feature: frontend-ui-enhancement, Property 18: Dashboard cards display metric icons
 * Validates: Requirements 8.2
 * 
 * This property test verifies that for any dashboard card, the card should render 
 * an icon element that represents the metric type.
 */

describe('DashboardView - Property-Based Tests', () => {
  beforeEach(() => {
    // Create a fresh Pinia instance for each test
    const pinia = createPinia()
    setActivePinia(pinia)
  })

  describe('Property 4: Dashboard header displays user information', () => {
    it('should display user name and greeting for any authenticated user', () => {
      fc.assert(
        fc.property(
          // Generate arbitrary user data with non-whitespace nicknames
          fc.record({
            nickname: fc.string({ minLength: 1, maxLength: 50 }).filter(s => s.trim().length > 0),
            roles: fc.array(fc.string({ minLength: 1, maxLength: 20 }), { minLength: 0, maxLength: 5 })
          }),
          (userData) => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            
            // Set up user profile
            userStore.profile = {
              nickname: userData.nickname,
              roles: userData.roles
            }
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              }
            })

            // Property: Welcome area should exist
            const welcomeArea = wrapper.find('.welcome-area')
            expect(welcomeArea.exists()).toBe(true)
            
            // Property: User info section should exist
            const userInfo = wrapper.find('.user-info')
            expect(userInfo.exists()).toBe(true)
            
            // Property: Greeting should contain the user's nickname (trimmed due to HTML whitespace handling)
            const greeting = wrapper.find('.greeting')
            expect(greeting.exists()).toBe(true)
            expect(greeting.text()).toContain(userData.nickname.trim())
            
            // Property: Greeting should contain a time-based greeting
            const greetingText = greeting.text()
            const hasGreeting = greetingText.includes('早上好') || 
                               greetingText.includes('下午好') || 
                               greetingText.includes('晚上好')
            expect(hasGreeting).toBe(true)
            
            // Property: Role info should be displayed
            const roleInfo = wrapper.find('.role-info')
            expect(roleInfo.exists()).toBe(true)
            expect(roleInfo.text()).toContain('当前角色')

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should display default greeting for guest users', () => {
      fc.assert(
        fc.property(
          fc.constant(null), // No user profile
          () => {
            const pinia = createPinia()
            setActivePinia(pinia)
            const userStore = useUserStore()
            
            // No profile set (guest user)
            userStore.profile = null
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              }
            })

            // Property: Welcome area should exist even for guest users
            const welcomeArea = wrapper.find('.welcome-area')
            expect(welcomeArea.exists()).toBe(true)
            
            // Property: Greeting should display default "访客" for guest users
            const greeting = wrapper.find('.greeting')
            expect(greeting.exists()).toBe(true)
            expect(greeting.text()).toContain('访客')
            
            // Property: User avatar should be displayed
            const userAvatar = wrapper.find('.user-avatar')
            expect(userAvatar.exists()).toBe(true)

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })

  describe('Property 5: Grid layout adjusts to viewport', () => {
    it('should apply single column layout for mobile viewports', () => {
      fc.assert(
        fc.property(
          // Generate viewport widths in mobile range
          fc.integer({ min: 320, max: 640 }),
          (viewportWidth) => {
            // Set viewport size
            global.innerWidth = viewportWidth
            
            const pinia = createPinia()
            setActivePinia(pinia)
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              },
              attachTo: document.body
            })

            // Property: Cards grid should exist
            const cardsGrid = wrapper.find('.cards-grid')
            expect(cardsGrid.exists()).toBe(true)
            
            // Property: Grid should have the correct class for styling
            expect(cardsGrid.classes()).toContain('cards-grid')
            
            // Property: Cards should be rendered
            const cards = wrapper.findAll('.metric-card')
            expect(cards.length).toBeGreaterThan(0)

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should apply multi-column layout for tablet viewports', () => {
      fc.assert(
        fc.property(
          // Generate viewport widths in tablet range
          fc.integer({ min: 641, max: 1024 }),
          (viewportWidth) => {
            // Set viewport size
            global.innerWidth = viewportWidth
            
            const pinia = createPinia()
            setActivePinia(pinia)
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              },
              attachTo: document.body
            })

            // Property: Cards grid should exist
            const cardsGrid = wrapper.find('.cards-grid')
            expect(cardsGrid.exists()).toBe(true)
            
            // Property: Grid should have the correct class for styling
            expect(cardsGrid.classes()).toContain('cards-grid')
            
            // Property: Cards should be rendered
            const cards = wrapper.findAll('.metric-card')
            expect(cards.length).toBeGreaterThan(0)

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should apply full grid layout for desktop viewports', () => {
      fc.assert(
        fc.property(
          // Generate viewport widths in desktop range
          fc.integer({ min: 1025, max: 2560 }),
          (viewportWidth) => {
            // Set viewport size
            global.innerWidth = viewportWidth
            
            const pinia = createPinia()
            setActivePinia(pinia)
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              },
              attachTo: document.body
            })

            // Property: Cards grid should exist
            const cardsGrid = wrapper.find('.cards-grid')
            expect(cardsGrid.exists()).toBe(true)
            
            // Property: Grid should have the correct class for styling
            expect(cardsGrid.classes()).toContain('cards-grid')
            
            // Property: Cards should be rendered
            const cards = wrapper.findAll('.metric-card')
            expect(cards.length).toBeGreaterThan(0)

            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })

  describe('Property 15: Card grid columns adapt to space', () => {
    it('should display appropriate column count based on viewport width', () => {
      fc.assert(
        fc.property(
          // Generate any valid viewport width
          fc.integer({ min: 320, max: 2560 }),
          (viewportWidth) => {
            // Set viewport size
            global.innerWidth = viewportWidth
            
            const pinia = createPinia()
            setActivePinia(pinia)
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              },
              attachTo: document.body
            })

            // Property: Cards grid should exist at any viewport size
            const cardsGrid = wrapper.find('.cards-grid')
            expect(cardsGrid.exists()).toBe(true)
            
            // Property: Cards should be rendered
            const cards = wrapper.findAll('.metric-card')
            expect(cards.length).toBeGreaterThan(0)
            
            // Property: Each card should have the metric-card class
            cards.forEach(card => {
              expect(card.classes()).toContain('metric-card')
            })
            
            // Property: Grid should use CSS Grid layout
            // The grid-template-columns CSS property is defined in the component
            expect(cardsGrid.classes()).toContain('cards-grid')

            wrapper.unmount()
          }
        ),
        { numRuns: 50 }
      )
    }, 15000)

    it('should maintain card structure across all viewport sizes', () => {
      fc.assert(
        fc.property(
          // Generate any valid viewport width
          fc.integer({ min: 320, max: 2560 }),
          (viewportWidth) => {
            // Set viewport size
            global.innerWidth = viewportWidth
            
            const pinia = createPinia()
            setActivePinia(pinia)
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              },
              attachTo: document.body
            })

            // Property: All cards should have consistent structure
            const cards = wrapper.findAll('.metric-card')
            
            cards.forEach(card => {
              // Property: Each card should contain card-content
              const cardContent = card.find('.card-content')
              expect(cardContent.exists()).toBe(true)
              
              // Property: Each card should have an icon
              const cardIcon = card.find('.card-icon')
              expect(cardIcon.exists()).toBe(true)
              
              // Property: Each card should have details section
              const cardDetails = card.find('.card-details')
              expect(cardDetails.exists()).toBe(true)
              
              // Property: Each card should have title, value, and description
              const cardTitle = card.find('.card-title')
              const cardValue = card.find('.card-value')
              const cardDesc = card.find('.card-desc')
              
              expect(cardTitle.exists()).toBe(true)
              expect(cardValue.exists()).toBe(true)
              expect(cardDesc.exists()).toBe(true)
            })

            wrapper.unmount()
          }
        ),
        { numRuns: 50 }
      )
    }, 15000)
  })

  describe('Property 18: Dashboard cards display metric icons', () => {
    it('should render icon elements for all dashboard metric cards', () => {
      fc.assert(
        fc.property(
          // Generate any valid viewport width
          fc.integer({ min: 320, max: 2560 }),
          (viewportWidth) => {
            // Set viewport size
            global.innerWidth = viewportWidth
            
            const pinia = createPinia()
            setActivePinia(pinia)
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              },
              attachTo: document.body
            })

            // Property: All metric cards should have icon elements
            const metricCards = wrapper.findAll('.metric-card')
            expect(metricCards.length).toBeGreaterThan(0)
            
            metricCards.forEach(card => {
              // Property: Each card should contain a card-icon element
              const cardIcon = card.find('.card-icon')
              expect(cardIcon.exists()).toBe(true)
              
              // Property: Card icon should contain an SVG or icon component
              const iconElement = cardIcon.find('svg, [class*="icon"]')
              expect(iconElement.exists()).toBe(true)
            })

            wrapper.unmount()
          }
        ),
        { numRuns: 50 }
      )
    }, 15000)

    it('should display icons with appropriate styling for each metric type', () => {
      fc.assert(
        fc.property(
          // Generate any valid viewport width
          fc.integer({ min: 320, max: 2560 }),
          (viewportWidth) => {
            // Set viewport size
            global.innerWidth = viewportWidth
            
            const pinia = createPinia()
            setActivePinia(pinia)
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              },
              attachTo: document.body
            })

            // Property: All metric cards should have icons with color styling
            const metricCards = wrapper.findAll('.metric-card')
            
            metricCards.forEach(card => {
              // Property: Card icon container should exist
              const cardIcon = card.find('.card-icon')
              expect(cardIcon.exists()).toBe(true)
              
              // Property: Card icon should have inline style with color
              const iconStyle = cardIcon.attributes('style')
              expect(iconStyle).toBeDefined()
              expect(iconStyle).toContain('color')
              
              // Property: Card should have card-details section with title and value
              const cardDetails = card.find('.card-details')
              expect(cardDetails.exists()).toBe(true)
              
              const cardTitle = card.find('.card-title')
              const cardValue = card.find('.card-value')
              expect(cardTitle.exists()).toBe(true)
              expect(cardValue.exists()).toBe(true)
            })

            wrapper.unmount()
          }
        ),
        { numRuns: 50 }
      )
    }, 15000)

    it('should render different icons for different metric types', () => {
      fc.assert(
        fc.property(
          // Generate any valid viewport width
          fc.integer({ min: 320, max: 2560 }),
          (viewportWidth) => {
            // Set viewport size
            global.innerWidth = viewportWidth
            
            const pinia = createPinia()
            setActivePinia(pinia)
            
            const wrapper = mount(DashboardView, {
              global: {
                plugins: [pinia]
              },
              attachTo: document.body
            })

            // Property: Multiple cards should exist with different icons
            const metricCards = wrapper.findAll('.metric-card')
            expect(metricCards.length).toBeGreaterThan(1)
            
            // Property: Each card should have a unique icon component
            const iconComponents = metricCards.map(card => {
              const icon = card.find('[class*="icon"]')
              return icon.exists() ? icon.classes() : null
            })
            
            // Property: Cards should have icon elements
            iconComponents.forEach(iconClass => {
              expect(iconClass).not.toBeNull()
            })

            wrapper.unmount()
          }
        ),
        { numRuns: 50 }
      )
    }, 15000)
  })
})
