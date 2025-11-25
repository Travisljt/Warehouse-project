<template>
  <Icon :size="size">
    <rect x="3" y="3" width="7" height="7" />
    <rect x="14" y="3" width="7" height="7" />
    <rect x="14" y="14" width="7" height="7" />
    <rect x="3" y="14" width="7" height="7" />
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
