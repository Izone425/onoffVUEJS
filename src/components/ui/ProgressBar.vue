<template>
  <div class="progress-container">
    <div class="progress-header" v-if="showLabel">
      <span class="progress-label">{{ label }}</span>
      <span class="progress-percentage">{{ percentage }}%</span>
    </div>
    <div class="progress-bar">
      <div class="progress-fill" :style="{ width: `${percentage}%`, backgroundColor: color }"></div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  percentage: {
    type: Number,
    required: true,
    validator: (value) => value >= 0 && value <= 100
  },
  label: {
    type: String,
    default: 'Progress'
  },
  showLabel: {
    type: Boolean,
    default: true
  },
  color: {
    type: String,
    default: '#155EEF'
  }
})
</script>

<style scoped>
.progress-container {
  width: 100%;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-1);
}

.progress-label {
  font-size: 13px;
  color: var(--color-gray-700);
  font-weight: 500;
}

.progress-percentage {
  font-size: 13px;
  color: var(--color-gray-900);
  font-weight: 600;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background-color: var(--color-gray-100);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background-color: var(--color-primary-600);
  border-radius: 4px;
  transition: width 0.3s ease;
}
</style>
