<template>
  <div class="card" :class="[variant, { hoverable }]">
    <div v-if="$slots.header" class="card-header">
      <slot name="header"></slot>
    </div>
    <div class="card-body">
      <slot></slot>
    </div>
    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>

<script setup>
defineProps({
  variant: {
    type: String,
    default: 'default',
    validator: (v) => ['default', 'bordered', 'elevated'].includes(v)
  },
  hoverable: Boolean
})
</script>

<style scoped>
.card {
  background: var(--color-bg-primary);
  border-radius: var(--radius-md);
  overflow: hidden;
  transition: all var(--transition-base) cubic-bezier(0.4, 0, 0.2, 1);
}

.card.default {
  border: 1px solid var(--color-border);
}

.card.bordered {
  border: 2px solid var(--color-border);
}

.card.elevated {
  box-shadow: var(--shadow-md);
  border: none;
}

.card.hoverable {
  cursor: pointer;
}

.card.hoverable:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.card.hoverable:active {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.card-header {
  padding: var(--spacing-md) var(--spacing-lg);
  border-bottom: 1px solid var(--color-border-light);
  font-weight: 600;
  color: var(--color-text-primary);
}

.card-body {
  padding: var(--spacing-lg);
}

.card-footer {
  padding: var(--spacing-md) var(--spacing-lg);
  border-top: 1px solid var(--color-border-light);
  background: var(--color-bg-secondary);
}
</style>
