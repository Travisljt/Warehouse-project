<template>
  <svg 
    class="icon" 
    :class="size"
    xmlns="http://www.w3.org/2000/svg" 
    fill="none" 
    viewBox="0 0 24 24" 
    stroke="currentColor"
    stroke-width="2"
  >
    <slot></slot>
  </svg>
</template>

<script setup>
defineProps({
  size: {
    type: String,
    default: 'md',
    validator: (v) => ['sm', 'md', 'lg', 'xl'].includes(v)
  }
})
</script>

<style scoped>
.icon {
  display: inline-block;
  vertical-align: middle;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.icon.sm {
  width: 16px;
  height: 16px;
}

.icon.md {
  width: 20px;
  height: 20px;
}

.icon.lg {
  width: 24px;
  height: 24px;
}

.icon.xl {
  width: 32px;
  height: 32px;
}
</style>
