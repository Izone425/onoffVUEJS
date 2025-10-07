<template>
  <span class="status-chip" :class="variantClass">
    {{ label }}
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: {
    type: String,
    required: true,
    validator: (value) => ['pending', 'in_progress', 'completed', 'overdue', 'blocked', 'not_started', 'activated', 'not_issued', 'pending_activation'].includes(value)
  },
  label: {
    type: String,
    default: null
  }
})

const variantClass = computed(() => {
  const variants = {
    pending: 'warning',
    in_progress: 'info',
    completed: 'success',
    overdue: 'danger',
    blocked: 'danger',
    not_started: 'secondary',
    activated: 'success',
    not_issued: 'secondary',
    pending_activation: 'warning'
  }
  return variants[props.status] || 'secondary'
})

const defaultLabel = computed(() => {
  const labels = {
    pending: 'Pending',
    in_progress: 'In Progress',
    completed: 'Completed',
    overdue: 'Overdue',
    blocked: 'Blocked',
    not_started: 'Not Started',
    activated: 'Activated',
    not_issued: 'Not Issued',
    pending_activation: 'Pending Activation'
  }
  return props.label || labels[props.status] || props.status
})
</script>

<style scoped>
.status-chip {
  display: inline-flex;
  align-items: center;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  line-height: 1.4;
  white-space: nowrap;
}

.status-chip.success {
  background-color: rgba(22, 163, 74, 0.1);
  color: #16A34A;
}

.status-chip.warning {
  background-color: rgba(245, 158, 11, 0.1);
  color: #F59E0B;
}

.status-chip.danger {
  background-color: rgba(220, 38, 38, 0.1);
  color: #DC2626;
}

.status-chip.info {
  background-color: rgba(14, 165, 233, 0.1);
  color: #0EA5E9;
}

.status-chip.secondary {
  background-color: var(--color-gray-100);
  color: var(--color-gray-700);
}
</style>
