<template>
  <div class="form-section">
    <div class="config-header purple">
      <div class="header-content">
        <div class="header-icon purple">
          <span class="pi pi-cog"></span>
        </div>
        <div class="header-text">
          <label class="form-label">System & Application Access</label>
          <p class="header-description">Configure which systems and applications need to be set up for this task</p>
        </div>
      </div>
    </div>

    <div class="config-body">
      <div class="section-header">
        <label class="form-label">Systems to Configure</label>
        <Button
          v-if="!viewMode"
          label="Add System/Application"
          icon="pi pi-plus"
          size="small"
          outlined
          @click="handleAddSystem"
        />
      </div>

      <p class="form-help">Add systems and applications that need to be configured or accessed for this task</p>

      <!-- Systems List -->
      <div v-if="localSystemAccesses.length > 0" class="systems-list">
        <div v-for="(system, index) in localSystemAccesses" :key="system.id" class="system-card">
          <div class="system-header">
            <span class="system-number">#{{ index + 1 }}</span>
            <Button
              v-if="!viewMode"
              icon="pi pi-trash"
              text
              rounded
              severity="danger"
              size="small"
              @click="handleRemoveSystem(system.id)"
            />
          </div>

          <div class="system-body">
            <div class="field-group">
              <label class="field-label">System/Application Name {{ viewMode ? '' : '*' }}</label>
              <InputText
                v-model="system.name"
                placeholder="e.g., Company Email, HRMS, Zoho CRM"
                class="w-full"
                :disabled="viewMode"
              />
            </div>

            <div class="field-group">
              <label class="field-label">Description {{ viewMode ? '' : '*' }}</label>
              <Textarea
                v-model="system.description"
                placeholder="Brief description of what access/setup is required..."
                :rows="2"
                class="w-full"
                :disabled="viewMode"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <div class="empty-icon">
          <span class="pi pi-cog"></span>
        </div>
        <p class="empty-title">No systems configured yet</p>
        <p class="empty-text">Click "Add System/Application" to get started</p>
      </div>

    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'

const props = defineProps({
  systemAccesses: {
    type: Array,
    default: () => []
  },
  viewMode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:systemAccesses'])

const localSystemAccesses = computed({
  get: () => props.systemAccesses,
  set: (val) => emit('update:systemAccesses', val)
})

const handleAddSystem = () => {
  const newSystem = {
    id: `system-${Date.now()}`,
    name: '',
    description: ''
  }
  localSystemAccesses.value.push(newSystem)
}

const handleRemoveSystem = (systemId) => {
  localSystemAccesses.value = localSystemAccesses.value.filter(s => s.id !== systemId)
}
</script>

<style scoped>
.config-header {
  padding: var(--spacing-3);
  background-color: #faf5ff;
  border: 1px solid #e9d5ff;
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-4);
}

.config-header.purple {
  background-color: #faf5ff;
  border-color: #e9d5ff;
}

.header-content {
  display: flex;
  gap: var(--spacing-2);
  align-items: flex-start;
}

.header-icon {
  width: 32px;
  height: 32px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.header-icon.purple {
  background-color: #d8b4fe;
  color: #7c3aed;
}

.header-text {
  flex: 1;
}

.header-description {
  font-size: 13px;
  color: var(--color-gray-600);
  margin-top: 2px;
}

.config-body {
  padding: var(--spacing-3);
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-2);
}

.systems-list {
  margin-top: var(--spacing-3);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.system-card {
  background-color: white;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: var(--spacing-3);
}

.system-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-3);
}

.system-number {
  font-size: 12px;
  font-weight: 600;
  color: var(--color-gray-600);
  padding: 4px 8px;
  background-color: var(--color-gray-100);
  border-radius: var(--radius-sm);
}

.system-body {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-1);
}

.field-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.empty-state {
  text-align: center;
  padding: var(--spacing-6) var(--spacing-3);
  color: var(--color-gray-500);
}

.empty-icon {
  width: 48px;
  height: 48px;
  background-color: var(--color-gray-100);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto var(--spacing-2);
}

.empty-icon .pi {
  font-size: 24px;
}

.empty-title {
  font-weight: 500;
  color: var(--color-gray-900);
  margin-bottom: var(--spacing-1);
}

.empty-text {
  font-size: 13px;
}

.w-full {
  width: 100%;
}
</style>
