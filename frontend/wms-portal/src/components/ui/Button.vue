<template>
  <button 
    class="btn" 
    :class="[variant, size, { loading, block }]"
    :disabled="disabled || loading"
  >
    <span v-if="loading" class="btn-spinner"></span>
    <slot></slot>
  </button>
</template>

<script setup>
defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (v) => ['primary', 'secondary', 'outline', 'ghost', 'danger'].includes(v)
  },
  size: {
    type: String,
    default: 'md',
    validator: (v) => ['sm', 'md', 'lg'].includes(v)
  },
  loading: Boolean,
  disabled: Boolean,
  block: Boolean
})
</script>

<style scoped>
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
  font-family: var(--font-sans);
  font-weight: 500;
  border-radius: var(--radius-md);
  border: none;
  cursor: pointer;
  transition: all var(--transition-fast) cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Sizes */
.btn.sm {
  padding: var(--spacing-xs) var(--spacing-md);
  font-size: var(--font-size-sm);
}

.btn.md {
  padding: var(--spacing-sm) var(--spacing-lg);
  font-size: var(--font-size-base);
}

.btn.lg {
  padding: var(--spacing-md) var(--spacing-xl);
  font-size: var(--font-size-lg);
}

/* Variants */
.btn.primary {
  background: var(--color-primary);
  color: white;
  box-shadow: 0 1px 2px rgba(59, 130, 246, 0.2);
}

.btn.primary:hover:not(:disabled) {
  background: var(--color-primary-dark);
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.3);
  transform: translateY(-1px);
}

.btn.primary:active:not(:disabled) {
  background: var(--color-primary-dark);
  box-shadow: 0 1px 2px rgba(59, 130, 246, 0.2);
  transform: translateY(0);
}

.btn.secondary {
  background: var(--color-secondary);
  color: white;
  box-shadow: 0 1px 2px rgba(139, 92, 246, 0.2);
}

.btn.secondary:hover:not(:disabled) {
  opacity: 0.9;
  box-shadow: 0 4px 8px rgba(139, 92, 246, 0.3);
  transform: translateY(-1px);
}

.btn.secondary:active:not(:disabled) {
  opacity: 0.95;
  box-shadow: 0 1px 2px rgba(139, 92, 246, 0.2);
  transform: translateY(0);
}

.btn.outline {
  background: transparent;
  border: 2px solid var(--color-primary);
  color: var(--color-primary);
}

.btn.outline:hover:not(:disabled) {
  background: var(--color-primary);
  color: white;
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.2);
  transform: translateY(-1px);
}

.btn.outline:active:not(:disabled) {
  background: var(--color-primary-dark);
  box-shadow: 0 1px 2px rgba(59, 130, 246, 0.2);
  transform: translateY(0);
}

.btn.ghost {
  background: transparent;
  color: var(--color-text-primary);
}

.btn.ghost:hover:not(:disabled) {
  background: var(--color-bg-tertiary);
  transform: translateY(-1px);
}

.btn.ghost:active:not(:disabled) {
  background: var(--color-border-light);
  transform: translateY(0);
}

.btn.danger {
  background: var(--color-error);
  color: white;
  box-shadow: 0 1px 2px rgba(239, 68, 68, 0.2);
}

.btn.danger:hover:not(:disabled) {
  opacity: 0.9;
  box-shadow: 0 4px 8px rgba(239, 68, 68, 0.3);
  transform: translateY(-1px);
}

.btn.danger:active:not(:disabled) {
  opacity: 0.95;
  box-shadow: 0 1px 2px rgba(239, 68, 68, 0.2);
  transform: translateY(0);
}

/* Block */
.btn.block {
  width: 100%;
}

/* Loading state */
.btn.loading {
  pointer-events: none;
}

.btn-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid currentColor;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Ensure minimum touch target size (44x44px) */
.btn {
  min-width: 44px;
  min-height: 44px;
}

.btn.sm {
  min-width: 44px;
  min-height: 44px;
}

/* Responsive Design - Mobile */
@media (max-width: 640px) {
  .btn.md {
    padding: var(--spacing-md) var(--spacing-lg);
    min-height: 48px;
  }

  .btn.lg {
    padding: var(--spacing-md) var(--spacing-xl);
    min-height: 52px;
  }
}
</style>
