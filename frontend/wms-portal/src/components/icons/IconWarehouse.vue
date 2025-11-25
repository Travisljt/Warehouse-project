<template>
  <Icon :size="size">
    <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z" />
    <polyline points="9 22 9 12 15 12 15 22" />
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
