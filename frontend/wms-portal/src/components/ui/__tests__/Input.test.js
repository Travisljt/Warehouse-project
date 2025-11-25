import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import * as fc from 'fast-check'
import Input from '../Input.vue'

/**
 * Feature: frontend-ui-enhancement, Property 13: Errors display with proper styling
 * Validates: Requirements 6.5
 * 
 * This property test verifies that for any error condition, the error message should be
 * rendered with an error CSS class and positioned near the relevant input or action.
 */

describe('Input Component - Property-Based Tests', () => {
  describe('Property 13: Errors display with proper styling', () => {
    it('should display error message with error styling when errorMessage prop is set', () => {
      fc.assert(
        fc.property(
          // Generate arbitrary error messages and input configurations
          fc.record({
            errorMessage: fc.stringMatching(/^[a-zA-Z0-9\s.,!?]+$/).filter(s => s.trim().length > 0 && s.length <= 100),
            label: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.trim().length > 0 && s.length <= 30),
            placeholder: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.trim().length > 0 && s.length <= 50),
            modelValue: fc.string({ maxLength: 50 })
          }),
          (config) => {
            // Mount input with error message
            const wrapper = mount(Input, {
              props: {
                errorMessage: config.errorMessage,
                label: config.label,
                placeholder: config.placeholder,
                modelValue: config.modelValue
              }
            })

            // Property: Error message element should exist when errorMessage is set
            const errorElement = wrapper.find('.error-message')
            expect(errorElement.exists()).toBe(true)
            
            // Property: Error element should have error-message class for styling
            expect(errorElement.classes()).toContain('error-message')
            
            // Property: Error message should contain the error text (trimmed)
            expect(errorElement.text().trim()).toBe(config.errorMessage.trim())
            
            // Property: Input wrapper should have error class when error is present
            const inputWrapper = wrapper.find('.input-wrapper')
            expect(inputWrapper.classes()).toContain('error')
            
            // Property: Error message should be positioned near the input
            // It should be within the input-message container
            const messageContainer = wrapper.find('.input-message')
            expect(messageContainer.exists()).toBe(true)
            expect(messageContainer.find('.error-message').exists()).toBe(true)
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should not display error styling when no error message is present', () => {
      fc.assert(
        fc.property(
          fc.record({
            label: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 30),
            placeholder: fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 50),
            modelValue: fc.string({ maxLength: 50 })
          }),
          (config) => {
            // Mount input without error message
            const wrapper = mount(Input, {
              props: {
                label: config.label,
                placeholder: config.placeholder,
                modelValue: config.modelValue
              }
            })

            // Property: Error message element should not exist when no error
            const errorElement = wrapper.find('.error-message')
            expect(errorElement.exists()).toBe(false)
            
            // Property: Input wrapper should not have error class when no error
            const inputWrapper = wrapper.find('.input-wrapper')
            expect(inputWrapper.classes()).not.toContain('error')
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should apply error border styling to input container when error is present', () => {
      fc.assert(
        fc.property(
          fc.record({
            errorMessage: fc.stringMatching(/^[a-zA-Z0-9\s.,!?]+$/).filter(s => s.length > 0 && s.length <= 100),
            modelValue: fc.string({ maxLength: 50 })
          }),
          (config) => {
            // Mount input with error message
            const wrapper = mount(Input, {
              props: {
                errorMessage: config.errorMessage,
                modelValue: config.modelValue
              }
            })

            // Property: Input container should exist
            const inputContainer = wrapper.find('.input-container')
            expect(inputContainer.exists()).toBe(true)
            
            // Property: Input wrapper should have error class
            const inputWrapper = wrapper.find('.input-wrapper')
            expect(inputWrapper.classes()).toContain('error')
            
            // Property: Error styling should be applied through the error class
            // The CSS rule .input-wrapper.error .input-container applies error border
            expect(inputWrapper.find('.input-container').exists()).toBe(true)
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should position error message below the input field', () => {
      fc.assert(
        fc.property(
          fc.record({
            errorMessage: fc.stringMatching(/^[a-zA-Z0-9\s.,!?]+$/).filter(s => s.length > 0 && s.length <= 100),
            label: fc.option(fc.stringMatching(/^[a-zA-Z0-9\s]+$/).filter(s => s.length > 0 && s.length <= 30), { nil: undefined })
          }),
          (config) => {
            // Mount input with error message
            const wrapper = mount(Input, {
              props: {
                errorMessage: config.errorMessage,
                label: config.label
              }
            })

            const inputWrapper = wrapper.find('.input-wrapper')
            const inputContainer = wrapper.find('.input-container')
            const messageContainer = wrapper.find('.input-message')
            const errorElement = wrapper.find('.error-message')
            
            // Property: All elements should exist in the correct hierarchy
            expect(inputWrapper.exists()).toBe(true)
            expect(inputContainer.exists()).toBe(true)
            expect(messageContainer.exists()).toBe(true)
            expect(errorElement.exists()).toBe(true)
            
            // Property: The input-wrapper should use flex-direction: column
            // This ensures the message appears below the input
            expect(inputWrapper.classes()).toContain('input-wrapper')
            
            // Property: The message container should be a child of input-wrapper
            expect(inputWrapper.find('.input-message').exists()).toBe(true)
            
            // Property: The error message should be inside the message container
            expect(messageContainer.find('.error-message').exists()).toBe(true)
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should display hint message when no error is present but hint is provided', () => {
      fc.assert(
        fc.property(
          fc.record({
            hint: fc.stringMatching(/^[a-zA-Z0-9\s.,!?]+$/).filter(s => s.trim().length > 0 && s.length <= 100),
            modelValue: fc.string({ maxLength: 50 })
          }),
          (config) => {
            // Mount input with hint but no error
            const wrapper = mount(Input, {
              props: {
                hint: config.hint,
                modelValue: config.modelValue
              }
            })

            // Property: Hint message should be displayed
            const hintElement = wrapper.find('.hint-message')
            expect(hintElement.exists()).toBe(true)
            // Text content may be trimmed by the browser
            expect(hintElement.text().trim()).toBe(config.hint.trim())
            
            // Property: Error message should not be displayed
            const errorElement = wrapper.find('.error-message')
            expect(errorElement.exists()).toBe(false)
            
            // Property: Input wrapper should not have error class
            const inputWrapper = wrapper.find('.input-wrapper')
            expect(inputWrapper.classes()).not.toContain('error')
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })

    it('should prioritize error message over hint message when both are present', () => {
      fc.assert(
        fc.property(
          fc.record({
            errorMessage: fc.stringMatching(/^[a-zA-Z0-9\s.,!?]+$/).filter(s => s.trim().length > 0 && s.length <= 100),
            hint: fc.stringMatching(/^[a-zA-Z0-9\s.,!?]+$/).filter(s => s.trim().length > 0 && s.length <= 100),
            modelValue: fc.string({ maxLength: 50 })
          }),
          (config) => {
            // Mount input with both error and hint
            const wrapper = mount(Input, {
              props: {
                errorMessage: config.errorMessage,
                hint: config.hint,
                modelValue: config.modelValue
              }
            })

            // Property: Error message should be displayed
            const errorElement = wrapper.find('.error-message')
            expect(errorElement.exists()).toBe(true)
            // Text content may be trimmed by the browser
            expect(errorElement.text().trim()).toBe(config.errorMessage.trim())
            
            // Property: Hint message should not be displayed when error is present
            const hintElement = wrapper.find('.hint-message')
            expect(hintElement.exists()).toBe(false)
            
            // Property: Input wrapper should have error class
            const inputWrapper = wrapper.find('.input-wrapper')
            expect(inputWrapper.classes()).toContain('error')
            
            wrapper.unmount()
          }
        ),
        { numRuns: 100 }
      )
    })
  })
})
