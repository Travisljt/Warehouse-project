<template>
  <Icon :size="size">
    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
    <path d="M7 11V7a5 5 0 0110 0v4" />
  </Icon>
</template>

<script setup>
import Icon from '../ui/Icon.vue'

defineProps({
  size: {
    type: String,
    default: 'md'
  }
})
</script>
