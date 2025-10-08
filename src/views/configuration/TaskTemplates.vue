<template>
    <div class="page-container">
      <div class="page-title-section">
        <div>
          <h1 class="text-h1">Task Templates</h1>
          <p class="page-description">Configure reusable task templates for onboarding and offboarding workflows. Create templates with specific requirements, documents, and settings.</p>
        </div>
      </div>

      <div class="page-header-new">
        <div class="search-section">
          <span class="pi pi-search search-icon"></span>
          <InputText
            v-model="searchQuery"
            placeholder="Search templates..."
            class="search-input"
          />
        </div>
        <div class="filter-section">
          <Dropdown
            v-model="selectedType"
            :options="taskTypes"
            optionLabel="label"
            optionValue="value"
            placeholder="All Types"
            showClear
            class="filter-dropdown"
          />
          <Dropdown
            v-model="selectedIndicator"
            :options="indicators"
            optionLabel="label"
            optionValue="value"
            placeholder="All Categories"
            showClear
            class="filter-dropdown"
          />
          <div class="view-toggle">
            <Button
              icon="pi pi-list"
              :severity="viewMode === 'list' ? 'primary' : 'secondary'"
              :outlined="viewMode !== 'list'"
              size="small"
              @click="viewMode = 'list'"
              title="List View"
            />
            <Button
              icon="pi pi-th-large"
              :severity="viewMode === 'card' ? 'primary' : 'secondary'"
              :outlined="viewMode !== 'card'"
              size="small"
              @click="viewMode = 'card'"
              title="Card View"
            />
          </div>
          <Button label="Create Template" icon="pi pi-plus" @click="openDrawer(null)" />
        </div>
      </div>

      <!-- Task Template Drawer -->
      <TaskTemplateDrawer
        v-model:visible="drawerVisible"
        :editingTemplate="editingTemplate"
        @save="handleSaveTemplate"
      />

      <div class="content-card">
        <!-- List View -->
        <div v-if="viewMode === 'list'" class="table-container">
          <DataTable :value="filteredTemplates" responsiveLayout="scroll" stripedRows scrollable scrollHeight="flex">
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

        <!-- Card View -->
        <div v-else class="card-grid-container">
          <div class="card-grid">
            <div v-for="template in filteredTemplates" :key="template.id" class="template-card">
              <div class="card-header">
                <div class="card-icon">
                  <span class="pi pi-file"></span>
                </div>
                <div class="card-actions">
                  <Button icon="pi pi-pencil" size="small" text rounded />
                  <Button icon="pi pi-copy" size="small" text rounded />
                  <Button icon="pi pi-trash" size="small" text rounded severity="danger" />
                </div>
              </div>
              <div class="card-body">
                <h3 class="card-title">{{ template.name }}</h3>
                <div class="card-details">
                  <div class="detail-row">
                    <span class="detail-label">Type:</span>
                    <span class="detail-value">{{ getTypeName(template.type) }}</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Indicator:</span>
                    <StatusChip :status="template.indicator === 'onboarding' ? 'in_progress' : 'pending'" :label="template.indicator" />
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Owner Role:</span>
                    <span class="detail-value">{{ template.ownerRole }}</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">SLA:</span>
                    <span class="detail-value">{{ template.sla }} days</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Mandatory:</span>
                    <span :class="template.mandatory ? 'text-success' : 'text-muted'">
                      {{ template.mandatory ? 'Yes' : 'No' }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="table-footer">
          <span class="result-count">Showing {{ filteredTemplates.length }} of {{ taskTemplates.length }} templates</span>
        </div>
      </div>
    </div>
  </template>

<script setup>
import { ref, computed } from 'vue'
import { useToast } from 'primevue/usetoast'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dropdown from 'primevue/dropdown'
import InputText from 'primevue/inputtext'
import StatusChip from '../../components/ui/StatusChip.vue'
import TaskTemplateDrawer from '../../components/drawers/TaskTemplateDrawer.vue'
import { taskTemplates, taskTypes } from '../../data/mockData'

const toast = useToast()
const searchQuery = ref('')
const selectedType = ref(null)
const selectedIndicator = ref(null)
const viewMode = ref('list') // 'list' or 'card'
const drawerVisible = ref(false)
const editingTemplate = ref(null)

const indicators = [
  { label: 'Onboarding', value: 'onboarding' },
  { label: 'Offboarding', value: 'offboarding' }
]

const filteredTemplates = computed(() => {
  let filtered = taskTemplates

  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(t =>
      t.name.toLowerCase().includes(query) ||
      t.ownerRole.toLowerCase().includes(query)
    )
  }

  // Filter by type
  if (selectedType.value) {
    filtered = filtered.filter(t => t.type === selectedType.value)
  }

  // Filter by indicator
  if (selectedIndicator.value) {
    filtered = filtered.filter(t => t.indicator === selectedIndicator.value)
  }

  return filtered
})

const getTypeName = (type) => {
  const taskType = taskTypes.find(t => t.value === type)
  return taskType ? taskType.label : type
}

const openDrawer = (template = null) => {
  // Explicitly set to null for create, or to the template object for edit
  editingTemplate.value = template === null ? null : template
  drawerVisible.value = true
}

const handleSaveTemplate = (templateData) => {
  // Handle save logic here
  toast.add({
    severity: 'success',
    summary: 'Template Saved',
    detail: editingTemplate.value ? 'Template updated successfully' : 'Template created successfully',
    life: 3000
  })
  console.log('Template data:', templateData)
}
</script>

<style scoped>
.page-container {
  max-width: 1400px;
  margin: 0 auto;
}

.page-title-section {
  margin-bottom: var(--spacing-4);
}

.page-description {
  color: var(--color-gray-600);
  margin-top: var(--spacing-1);
  font-size: 13px;
  line-height: 1.5;
}

.page-header-new {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--spacing-3);
  margin-bottom: var(--spacing-3);
  padding: var(--spacing-3);
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
}

.search-section {
  position: relative;
  flex: 1;
  max-width: 400px;
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-gray-500);
  font-size: 14px;
}

.search-input {
  width: 100%;
  padding-left: 36px;
}

.filter-section {
  display: flex;
  gap: var(--spacing-2);
  align-items: center;
}

.filter-dropdown {
  min-width: 160px;
}

.view-toggle {
  display: flex;
  gap: 0;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
}

.view-toggle .p-button {
  border-radius: 0;
  border: none;
}

.view-toggle .p-button:first-child {
  border-right: 1px solid var(--color-divider);
}

.content-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  height: calc(100vh - 280px);
}

.table-container {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.table-container :deep(.p-datatable) {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.table-container :deep(.p-datatable-wrapper) {
  flex: 1;
  overflow: auto;
}

.table-footer {
  padding: var(--spacing-3);
  border-top: 1px solid var(--color-divider);
  background-color: var(--color-bg);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.result-count {
  font-size: 13px;
  color: var(--color-gray-600);
  font-weight: 500;
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

/* Card View Styles */
.card-grid-container {
  flex: 1;
  overflow: auto;
  padding: var(--spacing-3);
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: var(--spacing-3);
}

.template-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  padding: var(--spacing-3);
  transition: all 0.2s;
  cursor: pointer;
}

.template-card:hover {
  border-color: var(--color-primary-300);
  box-shadow: var(--shadow-md);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: var(--spacing-3);
}

.card-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, var(--color-primary-100), var(--color-primary-200));
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
}

.card-icon .pi {
  font-size: 24px;
  color: var(--color-primary-600);
}

.card-actions {
  display: flex;
  gap: var(--spacing-1);
  opacity: 0;
  transition: opacity 0.2s;
}

.template-card:hover .card-actions {
  opacity: 1;
}

.card-body {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0 0 var(--spacing-2) 0;
  line-height: 1.3;
}

.card-details {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.detail-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 13px;
}

.detail-label {
  color: var(--color-gray-600);
  font-weight: 500;
}

.detail-value {
  color: var(--color-gray-900);
}
</style>
