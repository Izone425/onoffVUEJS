<template>
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="text-h1">Task Templates</h1>
          <p class="page-description">Manage reusable task templates</p>
        </div>
        <Button label="Create Template" icon="pi pi-plus" @click="createTemplate" />
      </div>

      <div class="filters-bar">
        <Dropdown
          v-model="selectedType"
          :options="taskTypes"
          optionLabel="label"
          optionValue="value"
          placeholder="All Types"
          showClear
        />
        <Dropdown
          v-model="selectedIndicator"
          :options="indicators"
          optionLabel="label"
          optionValue="value"
          placeholder="All Indicators"
          showClear
        />
      </div>

      <div class="content-card">
        <DataTable :value="filteredTemplates" responsiveLayout="scroll" stripedRows>
          <Column field="name" header="Name" style="min-width: 200px">
            <template #body="{ data }">
              <div class="template-name">
                <span class="pi pi-file"></span>
                <span>{{ data.name }}</span>
              </div>
            </template>
          </Column>
          <Column field="type" header="Type" style="min-width: 180px">
            <template #body="{ data }">
              {{ getTypeName(data.type) }}
            </template>
          </Column>
          <Column field="indicator" header="Indicator" style="min-width: 120px">
            <template #body="{ data }">
              <StatusChip :status="data.indicator === 'onboarding' ? 'in_progress' : 'pending'" :label="data.indicator" />
            </template>
          </Column>
          <Column field="ownerRole" header="Owner Role" style="min-width: 140px"></Column>
          <Column field="sla" header="SLA (days)" style="min-width: 100px"></Column>
          <Column field="mandatory" header="Mandatory" style="min-width: 100px">
            <template #body="{ data }">
              <span :class="data.mandatory ? 'text-success' : 'text-muted'">
                {{ data.mandatory ? 'Yes' : 'No' }}
              </span>
            </template>
          </Column>
          <Column header="Actions" style="min-width: 150px">
            <template #body>
              <div class="action-buttons">
                <Button icon="pi pi-pencil" size="small" text rounded />
                <Button icon="pi pi-copy" size="small" text rounded />
                <Button icon="pi pi-trash" size="small" text rounded severity="danger" />
              </div>
            </template>
          </Column>
        </DataTable>
      </div>
    </div>
  </template>

<script setup>
import { ref, computed } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dropdown from 'primevue/dropdown'
import StatusChip from '../../components/ui/StatusChip.vue'
import { taskTemplates, taskTypes } from '../../data/mockData'

const selectedType = ref(null)
const selectedIndicator = ref(null)

const indicators = [
  { label: 'Onboarding', value: 'onboarding' },
  { label: 'Offboarding', value: 'offboarding' }
]

const filteredTemplates = computed(() => {
  let filtered = taskTemplates
  if (selectedType.value) {
    filtered = filtered.filter(t => t.type === selectedType.value)
  }
  if (selectedIndicator.value) {
    filtered = filtered.filter(t => t.indicator === selectedIndicator.value)
  }
  return filtered
})

const getTypeName = (type) => {
  const taskType = taskTypes.find(t => t.value === type)
  return taskType ? taskType.label : type
}

const createTemplate = () => {
  console.log('Create new template')
}
</script>

<style scoped>
.page-container {
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: var(--spacing-4);
}

.page-description {
  color: var(--color-gray-600);
  margin-top: var(--spacing-1);
}

.filters-bar {
  display: flex;
  gap: var(--spacing-2);
  margin-bottom: var(--spacing-3);
}

.content-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.template-name {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-weight: 500;
}

.action-buttons {
  display: flex;
  gap: var(--spacing-1);
}

.text-success {
  color: var(--color-success);
  font-weight: 500;
}

.text-muted {
  color: var(--color-gray-500);
}
</style>
