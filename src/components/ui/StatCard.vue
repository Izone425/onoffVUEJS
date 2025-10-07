<template>
  <div class="stat-card" :style="{ backgroundColor: color }">
    <div class="stat-content">
      <div class="stat-label">{{ label }}</div>
      <div class="stat-value">{{ value }}</div>
      <div class="stat-change" v-if="change">
        <span :class="changeClass">{{ change }}</span>
      </div>
    </div>
    <div class="stat-icon">
      <span :class="`pi ${icon}`"></span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  label: {
    type: String,
    required: true
  },
  value: {
    type: [String, Number],
    required: true
  },
  icon: {
    type: String,
    required: true
  },
  color: {
    type: String,
    default: '#155EEF'
  },
  change: {
    type: String,
    default: null
  }
})

const changeClass = computed(() => {
  if (!props.change) return ''
  return props.change.startsWith('+') ? 'positive' : 'negative'
})
</script>

<style scoped>
.stat-card {
  padding: var(--spacing-4);
  border-radius: var(--radius-lg);
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  min-height: 140px;
  box-shadow: var(--shadow-md);
  transition: transform 0.2s, box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

.stat-content {
  flex: 1;
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
  margin-bottom: var(--spacing-1);
  font-weight: 500;
}

.stat-value {
  font-size: 36px;
  font-weight: 600;
  line-height: 1.2;
  margin-bottom: var(--spacing-1);
}

.stat-change {
  font-size: 13px;
  opacity: 0.9;
}

.stat-change .positive {
  color: rgba(255, 255, 255, 0.95);
}

.stat-change .negative {
  color: rgba(255, 255, 255, 0.95);
}

.stat-icon {
  width: 56px;
  height: 56px;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-icon .pi {
  font-size: 28px;
  opacity: 0.9;
}
</style>
