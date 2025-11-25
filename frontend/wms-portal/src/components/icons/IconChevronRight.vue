<template>
  <Icon :size="size">
    <polyline points="9 18 15 12 9 6" />
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
