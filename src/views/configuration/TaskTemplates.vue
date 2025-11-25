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
            :options="taskTypeOptions"
            optionLabel="label"
            optionValue="value"
            placeholder="All Types"
            showClear
            class="filter-dropdown"
          >
            <template #value="{ value, placeholder }">
              <div v-if="value" class="type-dropdown-value">
                <span :class="['pi', getTypeIcon(value)]"></span>
                <span>{{ getTypeName(value) }}</span>
              </div>
              <span v-else>{{ placeholder }}</span>
            </template>
            <template #option="{ option }">
              <div class="type-dropdown-option">
                <span :class="['pi', getTypeIcon(option.value)]"></span>
                <span>{{ option.label }}</span>
              </div>
            </template>
          </Dropdown>
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
          <DataTable
            :value="sortedTemplates"
            responsiveLayout="scroll"
            stripedRows
            scrollable
            scrollHeight="flex"
            :sortField="sortField"
            :sortOrder="sortOrder"
            @sort="onSort"
          >
            <Column field="name" header="Template Name" sortable style="min-width: 350px">
              <template #body="{ data }">
                <div class="template-name-cell">
                  <div :class="['template-type-icon', data.type]">
                    <span :class="['pi', getTypeIcon(data.type)]"></span>
                  </div>
                  <div class="template-info">
                    <div class="template-title">{{ data.name }}</div>
                    <div class="template-description">{{ data.description || 'No description provided' }}</div>
                  </div>
                </div>
              </template>
            </Column>
            <Column field="type" header="Type" sortable style="min-width: 160px">
              <template #body="{ data }">
                <span :class="['type-badge', data.type]">
                  {{ getTypeName(data.type) }}
                </span>
              </template>
            </Column>
            <Column field="indicator" header="Category" sortable style="min-width: 140px">
              <template #body="{ data }">
                <span :class="['category-badge', data.indicator]">
                  {{ data.indicator }}
                </span>
              </template>
            </Column>
            <Column field="updatedAt" header="Last Updated" sortable style="min-width: 140px">
              <template #body="{ data }">
                <span class="date-text">{{ formatDate(data.updatedAt) }}</span>
              </template>
            </Column>
            <Column field="isActive" header="Status" style="min-width: 110px">
              <template #body="{ data }">
                <span :class="['status-badge', data.isActive !== false ? 'active' : 'inactive']">
                  {{ data.isActive !== false ? 'Active' : 'Inactive' }}
                </span>
              </template>
            </Column>
            <Column header="Actions" style="min-width: 140px" headerClass="actions-header">
              <template #body="{ data }">
                <div class="action-buttons">
                  <Button
                    icon="pi pi-eye"
                    size="small"
                    text
                    rounded
                    @click="handleView(data)"
                    title="View"
                    class="action-btn view"
                  />
                  <Button
                    icon="pi pi-pencil"
                    size="small"
                    text
                    rounded
                    @click="openDrawer(data)"
                    title="Edit"
                    class="action-btn edit"
                  />
                  <Button
                    icon="pi pi-trash"
                    size="small"
                    text
                    rounded
                    severity="danger"
                    @click="handleDelete(data)"
                    title="Delete"
                    class="action-btn delete"
                  />
                </div>
              </template>
            </Column>
          </DataTable>
        </div>

        <!-- Card View -->
        <div v-else class="card-grid-container">
          <div class="card-grid">
            <div v-for="template in sortedTemplates" :key="template.id" class="template-card">
              <div class="card-header">
                <div :class="['card-icon', template.type]">
                  <span :class="['pi', getTypeIcon(template.type)]"></span>
                </div>
                <div class="card-actions">
                  <Button icon="pi pi-eye" size="small" text rounded @click="handleView(template)" title="View" />
                  <Button icon="pi pi-pencil" size="small" text rounded @click="openDrawer(template)" title="Edit" />
                  <Button icon="pi pi-trash" size="small" text rounded severity="danger" @click="handleDelete(template)" title="Delete" />
                </div>
              </div>
              <div class="card-body">
                <h3 class="card-title">{{ template.name }}</h3>
                <p class="card-description">{{ template.description || 'No description provided' }}</p>
                <div class="card-badges">
                  <span :class="['type-badge', template.type]">{{ getTypeName(template.type) }}</span>
                  <span :class="['category-badge', template.indicator]">{{ template.indicator }}</span>
                </div>
                <div class="card-details">
                  <div class="detail-row">
                    <span class="detail-label">Owner Role:</span>
                    <span class="detail-value">{{ template.ownerRole }}</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">SLA:</span>
                    <span class="detail-value">{{ template.sla }} days</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span :class="['status-badge', template.isActive !== false ? 'active' : 'inactive']">
                      {{ template.isActive !== false ? 'Active' : 'Inactive' }}
                    </span>
                  </div>
                </div>
                <div class="card-footer">
                  <span class="card-date">Updated {{ formatDate(template.updatedAt) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="table-footer">
          <span class="result-count">Showing {{ sortedTemplates.length }} of {{ taskTemplates.length }} templates</span>
        </div>
      </div>
    </div>
  </template>

<script setup>
import { ref, computed } from 'vue'
import { useToast } from 'primevue/usetoast'
import { useConfirm } from 'primevue/useconfirm'
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
const sortField = ref('name')
const sortOrder = ref(1)

// Type icons mapping
const typeIcons = {
  general: 'pi-file',
  document: 'pi-file-edit',
  information: 'pi-info-circle',
  questionnaire: 'pi-comments',
  meeting: 'pi-calendar',
  system: 'pi-cog',
  asset: 'pi-box',
  checklist: 'pi-check-square'
}

// Type labels mapping
const typeLabels = {
  general: 'General Task',
  document: 'Document Form',
  information: 'Information Form',
  questionnaire: 'Questionnaire',
  meeting: 'Meeting/Event',
  system: 'System/Access',
  asset: 'Asset',
  checklist: 'Checklist'
}

const taskTypeOptions = [
  { label: 'General Task', value: 'general' },
  { label: 'Document Form', value: 'document' },
  { label: 'Information Form', value: 'information' },
  { label: 'Questionnaire', value: 'questionnaire' },
  { label: 'Meeting/Event', value: 'meeting' },
  { label: 'System/Access', value: 'system' },
  { label: 'Asset', value: 'asset' },
  { label: 'Checklist', value: 'checklist' }
]

const indicators = [
  { label: 'Onboarding', value: 'onboarding' },
  { label: 'Offboarding', value: 'offboarding' }
]

const filteredTemplates = computed(() => {
  let filtered = [...taskTemplates]

  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(t =>
      t.name.toLowerCase().includes(query) ||
      (t.description && t.description.toLowerCase().includes(query)) ||
      (typeLabels[t.type] && typeLabels[t.type].toLowerCase().includes(query)) ||
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

const sortedTemplates = computed(() => {
  const templates = [...filteredTemplates.value]

  if (sortField.value) {
    templates.sort((a, b) => {
      let valueA = a[sortField.value]
      let valueB = b[sortField.value]

      // Handle type sorting by label
      if (sortField.value === 'type') {
        valueA = typeLabels[valueA] || valueA
        valueB = typeLabels[valueB] || valueB
      }

      // Handle date sorting
      if (sortField.value === 'updatedAt') {
        valueA = new Date(valueA).getTime()
        valueB = new Date(valueB).getTime()
        return sortOrder.value * (valueA - valueB)
      }

      // String comparison
      if (typeof valueA === 'string' && typeof valueB === 'string') {
        return sortOrder.value * valueA.localeCompare(valueB, undefined, { sensitivity: 'base' })
      }

      return 0
    })
  }

  return templates
})

const onSort = (event) => {
  sortField.value = event.sortField
  sortOrder.value = event.sortOrder
}

const getTypeIcon = (type) => {
  return typeIcons[type] || 'pi-file'
}

const getTypeName = (type) => {
  return typeLabels[type] || type
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-MY', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
}

const openDrawer = (template = null) => {
  editingTemplate.value = template === null ? null : template
  drawerVisible.value = true
}

const handleView = (template) => {
  // Open drawer in view mode
  editingTemplate.value = { ...template, viewMode: true }
  drawerVisible.value = true
}

const handleDelete = (template) => {
  toast.add({
    severity: 'warn',
    summary: 'Delete Template',
    detail: `Are you sure you want to delete "${template.name}"?`,
    life: 5000
  })
}

const handleSaveTemplate = (templateData) => {
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

.template-name-cell {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-3);
}

.template-type-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  background-color: var(--color-gray-100);
}

.template-type-icon .pi {
  font-size: 16px;
  color: var(--color-gray-500);
}

/* Type-specific icon colors */
.template-type-icon.general { background-color: #f3f4f6; }
.template-type-icon.general .pi { color: #6b7280; }

.template-type-icon.document { background-color: #dbeafe; }
.template-type-icon.document .pi { color: #2563eb; }

.template-type-icon.information { background-color: #e0e7ff; }
.template-type-icon.information .pi { color: #4f46e5; }

.template-type-icon.questionnaire { background-color: #fce7f3; }
.template-type-icon.questionnaire .pi { color: #db2777; }

.template-type-icon.meeting { background-color: #fef3c7; }
.template-type-icon.meeting .pi { color: #d97706; }

.template-type-icon.system { background-color: #ccfbf1; }
.template-type-icon.system .pi { color: #0d9488; }

.template-type-icon.asset { background-color: #fed7aa; }
.template-type-icon.asset .pi { color: #ea580c; }

.template-type-icon.checklist { background-color: #d1fae5; }
.template-type-icon.checklist .pi { color: #059669; }

.template-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
  min-width: 0;
}

.template-title {
  font-weight: 600;
  color: var(--color-gray-900);
  font-size: 14px;
  line-height: 1.3;
}

.template-description {
  font-size: 12px;
  color: var(--color-gray-500);
  line-height: 1.4;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 280px;
}

/* Type Badge Styles */
.type-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 500;
  border: 1px solid;
}

.type-badge.general {
  background-color: #f9fafb;
  color: #4b5563;
  border-color: #e5e7eb;
}

.type-badge.document {
  background-color: #eff6ff;
  color: #1d4ed8;
  border-color: #bfdbfe;
}

.type-badge.information {
  background-color: #eef2ff;
  color: #4338ca;
  border-color: #c7d2fe;
}

.type-badge.questionnaire {
  background-color: #fdf2f8;
  color: #be185d;
  border-color: #fbcfe8;
}

.type-badge.meeting {
  background-color: #fffbeb;
  color: #b45309;
  border-color: #fde68a;
}

.type-badge.system {
  background-color: #f0fdfa;
  color: #0f766e;
  border-color: #99f6e4;
}

.type-badge.asset {
  background-color: #fff7ed;
  color: #c2410c;
  border-color: #fed7aa;
}

.type-badge.checklist {
  background-color: #ecfdf5;
  color: #047857;
  border-color: #a7f3d0;
}

/* Category Badge Styles */
.category-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
  text-transform: capitalize;
}

.category-badge.onboarding {
  background-color: #dbeafe;
  color: #1e40af;
  border: 1px solid #93c5fd;
}

.category-badge.offboarding {
  background-color: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
}

/* Status Badge Styles */
.status-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
}

.status-badge.active {
  background-color: #dcfce7;
  color: #166534;
  border: 1px solid #86efac;
}

.status-badge.inactive {
  background-color: #f3f4f6;
  color: #6b7280;
  border: 1px solid #d1d5db;
}

.date-text {
  color: var(--color-gray-600);
  font-size: 13px;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 4px;
  justify-content: flex-end;
}

.action-btn {
  transition: all 0.2s;
}

.action-btn.view:hover {
  color: var(--color-primary-600) !important;
  background-color: var(--color-primary-50) !important;
}

.action-btn.edit:hover {
  color: #2563eb !important;
  background-color: #eff6ff !important;
}

.action-btn.delete:hover {
  color: #dc2626 !important;
  background-color: #fef2f2 !important;
}

/* Dropdown option styles */
.type-dropdown-value,
.type-dropdown-option {
  display: flex;
  align-items: center;
  gap: 8px;
}

.type-dropdown-value .pi,
.type-dropdown-option .pi {
  font-size: 14px;
  color: var(--color-gray-500);
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
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-gray-100);
}

.card-icon .pi {
  font-size: 22px;
  color: var(--color-gray-500);
}

/* Card icon type-specific colors */
.card-icon.general { background: linear-gradient(135deg, #f3f4f6, #e5e7eb); }
.card-icon.general .pi { color: #6b7280; }

.card-icon.document { background: linear-gradient(135deg, #dbeafe, #bfdbfe); }
.card-icon.document .pi { color: #2563eb; }

.card-icon.information { background: linear-gradient(135deg, #e0e7ff, #c7d2fe); }
.card-icon.information .pi { color: #4f46e5; }

.card-icon.questionnaire { background: linear-gradient(135deg, #fce7f3, #fbcfe8); }
.card-icon.questionnaire .pi { color: #db2777; }

.card-icon.meeting { background: linear-gradient(135deg, #fef3c7, #fde68a); }
.card-icon.meeting .pi { color: #d97706; }

.card-icon.system { background: linear-gradient(135deg, #ccfbf1, #99f6e4); }
.card-icon.system .pi { color: #0d9488; }

.card-icon.asset { background: linear-gradient(135deg, #fed7aa, #fdba74); }
.card-icon.asset .pi { color: #ea580c; }

.card-icon.checklist { background: linear-gradient(135deg, #d1fae5, #a7f3d0); }
.card-icon.checklist .pi { color: #059669; }

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
  font-size: 15px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0 0 6px 0;
  line-height: 1.3;
}

.card-description {
  font-size: 12px;
  color: var(--color-gray-500);
  line-height: 1.4;
  margin: 0 0 var(--spacing-2) 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-badges {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: var(--spacing-3);
}

.card-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-top: var(--spacing-2);
  border-top: 1px solid var(--color-divider);
}

.card-footer {
  margin-top: var(--spacing-3);
  padding-top: var(--spacing-2);
  border-top: 1px solid var(--color-divider);
}

.card-date {
  font-size: 11px;
  color: var(--color-gray-500);
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
