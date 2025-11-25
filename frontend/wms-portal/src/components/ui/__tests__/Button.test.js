import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import * as fc from 'fast-check'
import Button from '../Button.vue'

/**
 * Feature: frontend-ui-enhancement, Property 11: Loading state disables and shows indicator
 * Validates: Requirements 6.3
 * 
 * This property test verifies that for any button component with loading state true,
 * the button should be disabled and display a loading spinner element.
 */

describe('Button Component - Property-Based Tests', () => {
  describe('Property 11: Loading state disables and shows indicator', () => {
    it('should disable button and show spinner when loading is true', () => {
      fc.assert(
        fc.property(
          // Generate arbitrary button configurations
          fc.record({
            variant: fc.constantFrom('primary', 'secondary', 'outline', 'ghost', 'danger'),
            size: fc.constantFrom('sm', 'md', 'lg'),
            disabled: fc.boolean(),
            block: fc.boolean(),
            text: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 50)
          }),
          (config) => {
            // Mount button with loading=true
            const wrapper = mount(Button, {
              props: {
                variant: config.variant,
                size: config.size,
                disabled: config.disabled,
                block: config.block,
                loading: true
              },
              slots: {
                default: config.text
              }
            })

            const button = wrapper.find('button')
            
            // Property: Button must be disabled when loading
            expect(button.attributes('disabled')).toBeDefined()
            
            // Property: Button must show loading spinner
            const spinner = wrapper.find('.btn-spinner')
            expect(spinner.exists()).toBe(true)
            
            // Property: Button must have loading class
            expect(button.classes()).toContain('loading')
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 } // Run 100 iterations as specified in design doc
      )
    })

    it('should not be disabled and should not show spinner when loading is false', () => {
      fc.assert(
        fc.property(
          fc.record({
            variant: fc.constantFrom('primary', 'secondary', 'outline', 'ghost', 'danger'),
            size: fc.constantFrom('sm', 'md', 'lg'),
            block: fc.boolean(),
            text: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 50)
          }),
          (config) => {
            // Mount button with loading=false and disabled=false
            const wrapper = mount(Button, {
              props: {
                variant: config.variant,
                size: config.size,
                disabled: false,
                block: config.block,
                loading: false
              },
              slots: {
                default: config.text
              }
            })

            const button = wrapper.find('button')
            
            // Property: Button must not be disabled when not loading and not explicitly disabled
            expect(button.attributes('disabled')).toBeUndefined()
            
            // Property: Button must not show loading spinner when not loading
            const spinner = wrapper.find('.btn-spinner')
            expect(spinner.exists()).toBe(false)
            
            // Property: Button must not have loading class when not loading
            expect(button.classes()).not.toContain('loading')
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should be disabled when explicitly disabled, regardless of loading state', () => {
      fc.assert(
        fc.property(
          fc.record({
            variant: fc.constantFrom('primary', 'secondary', 'outline', 'ghost', 'danger'),
            size: fc.constantFrom('sm', 'md', 'lg'),
            loading: fc.boolean(),
            text: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 50)
          }),
          (config) => {
            // Mount button with disabled=true
            const wrapper = mount(Button, {
              props: {
                variant: config.variant,
                size: config.size,
                disabled: true,
                loading: config.loading
              },
              slots: {
                default: config.text
              }
            })

            const button = wrapper.find('button')
            
            // Property: Button must always be disabled when disabled prop is true
            expect(button.attributes('disabled')).toBeDefined()
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })
})
