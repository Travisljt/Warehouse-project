import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import * as fc from 'fast-check'
import Card from '../Card.vue'
import Icon from '../Icon.vue'

/**
 * Feature: frontend-ui-enhancement, Property 3: Dashboard cards contain required visual elements
 * Validates: Requirements 2.1
 * 
 * This property test verifies that for any metric data, the rendered card component
 * should contain an icon element, a color class, and the metric content.
 */

describe('Card Component - Property-Based Tests', () => {
  describe('Property 3: Dashboard cards contain required visual elements', () => {
    it('should render card with icon, color class, and metric content', () => {
      fc.assert(
        fc.property(
          // Generate arbitrary metric data
          fc.record({
            variant: fc.constantFrom('default', 'bordered', 'elevated'),
            hoverable: fc.boolean(),
            colorClass: fc.constantFrom('primary', 'success', 'warning', 'error', 'info'),
            metricLabel: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 50),
            metricValue: fc.integer({ min: 0, max: 999999 }),
            iconPath: fc.constantFrom(
              'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6',
              'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z',
              'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
            )
          }),
          (config) => {
            // Mount card with metric data
            const wrapper = mount(Card, {
              props: {
                variant: config.variant,
                hoverable: config.hoverable
              },
              slots: {
                default: `
                  <div class="metric-card ${config.colorClass}">
                    <div class="metric-icon">
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${config.iconPath}" />
                      </svg>
                    </div>
                    <div class="metric-content">
                      <div class="metric-label">${config.metricLabel}</div>
                      <div class="metric-value">${config.metricValue}</div>
                    </div>
                  </div>
                `
              }
            })

            const cardBody = wrapper.find('.card-body')
            expect(cardBody.exists()).toBe(true)
            
            // Property: Card must contain an icon element
            const iconElement = cardBody.find('svg')
            expect(iconElement.exists()).toBe(true)
            
            // Property: Card must have a color class applied
            const metricCard = cardBody.find('.metric-card')
            expect(metricCard.exists()).toBe(true)
            expect(metricCard.classes()).toContain(config.colorClass)
            
            // Property: Card must contain the metric content (label and value)
            const metricLabel = cardBody.find('.metric-label')
            const metricValue = cardBody.find('.metric-value')
            expect(metricLabel.exists()).toBe(true)
            expect(metricValue.exists()).toBe(true)
            // HTML rendering normalizes whitespace (collapses newlines and multiple spaces)
            const normalizeWhitespace = (str) => str.replace(/\s+/g, ' ').trim()
            expect(normalizeWhitespace(metricLabel.text())).toBe(normalizeWhitespace(config.metricLabel))
            expect(metricValue.text()).toBe(config.metricValue.toString())
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 } // Run 100 iterations as specified in design doc
      )
    })

    it('should render card with header slot containing icon and title', () => {
      fc.assert(
        fc.property(
          fc.record({
            variant: fc.constantFrom('default', 'bordered', 'elevated'),
            title: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 50),
            iconPath: fc.constantFrom(
              'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6',
              'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z'
            )
          }),
          (config) => {
            const wrapper = mount(Card, {
              props: {
                variant: config.variant
              },
              slots: {
                header: `
                  <div class="card-header-content">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${config.iconPath}" />
                    </svg>
                    <span>${config.title}</span>
                  </div>
                `,
                default: 'Content'
              }
            })

            // Property: Card header must contain icon
            const header = wrapper.find('.card-header')
            expect(header.exists()).toBe(true)
            const headerIcon = header.find('svg')
            expect(headerIcon.exists()).toBe(true)
            
            // Property: Card header must contain title text
            // HTML rendering normalizes whitespace (collapses newlines and multiple spaces)
            const normalizeWhitespace = (str) => str.replace(/\s+/g, ' ').trim()
            const normalizedTitle = normalizeWhitespace(config.title)
            if (normalizedTitle.length > 0) {
              expect(normalizeWhitespace(header.text())).toContain(normalizedTitle)
            }
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should apply hoverable effect when hoverable prop is true', () => {
      fc.assert(
        fc.property(
          fc.record({
            variant: fc.constantFrom('default', 'bordered', 'elevated'),
            content: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 50)
          }),
          (config) => {
            const wrapper = mount(Card, {
              props: {
                variant: config.variant,
                hoverable: true
              },
              slots: {
                default: config.content
              }
            })

            const card = wrapper.find('.card')
            
            // Property: Card with hoverable=true must have hoverable class
            expect(card.classes()).toContain('hoverable')
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })
})
