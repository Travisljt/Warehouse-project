<template>
  <div class="input-wrapper" :class="{ error: hasError, disabled }">
    <label v-if="label" :for="inputId" class="input-label">
      {{ label }}
      <span v-if="required" class="required">*</span>
    </label>
    <div class="input-container">
      <div v-if="$slots.prefix" class="input-prefix">
        <slot name="prefix"></slot>
      </div>
      <input
        :id="inputId"
        :type="type"
        :value="modelValue"
        :placeholder="placeholder"
        :disabled="disabled"
        :required="required"
        class="input"
        @input="$emit('update:modelValue', $event.target.value)"
        @focus="$emit('focus', $event)"
        @blur="$emit('blur', $event)"
      />
      <div v-if="$slots.suffix" class="input-suffix">
        <slot name="suffix"></slot>
      </div>
    </div>
    <transition name="message-fade">
      <div v-if="errorMessage || hint" class="input-message">
        <span v-if="errorMessage" class="error-message">{{ errorMessage }}</span>
        <span v-else-if="hint" class="hint-message">{{ hint }}</span>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: [String, Number],
    default: ''
  },
  type: {
    type: String,
    default: 'text'
  },
  label: String,
  placeholder: String,
  errorMessage: String,
  hint: String,
  disabled: Boolean,
  required: Boolean,
  id: String
})

defineEmits(['update:modelValue', 'focus', 'blur'])

const hasError = computed(() => !!props.errorMessage)
const inputId = computed(() => props.id || `input-${Math.random().toString(36).substr(2, 9)}`)
</script>

<style scoped>
.input-wrapper {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
}

.input-label {
  font-size: var(--font-size-sm);
  font-weight: 500;
  color: var(--color-text-primary);
}

.required {
  color: var(--color-error);
  margin-left: 2px;
}

.input-container {
  display: flex;
  align-items: center;
  position: relative;
  background: var(--color-bg-primary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  transition: all var(--transition-fast) cubic-bezier(0.4, 0, 0.2, 1);
}

.input-container:focus-within {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.input-wrapper.error .input-container {
  border-color: var(--color-error);
}

.input-wrapper.error .input-container:focus-within {
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.input-wrapper.disabled .input-container {
  background: var(--color-bg-tertiary);
  cursor: not-allowed;
}

.input {
  flex: 1;
  padding: var(--spacing-sm) var(--spacing-md);
  border: none;
  background: transparent;
  font-size: var(--font-size-base);
  color: var(--color-text-primary);
  outline: none;
}

.input::placeholder {
  color: var(--color-text-tertiary);
}

.input:disabled {
  cursor: not-allowed;
}

.input-prefix,
.input-suffix {
  display: flex;
  align-items: center;
  padding: 0 var(--spacing-sm);
  color: var(--color-text-secondary);
}

.input-message {
  font-size: var(--font-size-xs);
  min-height: 18px;
}

.error-message {
  color: var(--color-error);
}

.hint-message {
  color: var(--color-text-secondary);
}

/* Responsive Design - Mobile */
@media (max-width: 640px) {
  .input {
    padding: var(--spacing-md);
    font-size: var(--font-size-base);
    min-height: 44px;
  }

  .input-container {
    min-height: 44px;
  }

  .input-prefix,
  .input-suffix {
    padding: 0 var(--spacing-md);
  }
}

/* Ensure minimum touch target size */
.input-container {
  min-height: 44px;
}

/* Message fade transition */
.message-fade-enter-active,
.message-fade-leave-active {
  transition: all var(--transition-fast);
}

.message-fade-enter-from {
  opacity: 0;
  transform: translateY(-4px);
}

.message-fade-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}
</style>
