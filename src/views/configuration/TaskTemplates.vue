<template>
  <div class="page-container">
    <div class="page-title-section">
      <div>
        <h1 class="text-h1">Task Templates</h1>
        <p class="page-description">Configure reusable task templates for onboarding and offboarding workflows. Create templates with specific requirements, documents, and settings.</p>
      </div>
    </div>

    <!-- Tabs for Active/Archived -->
    <div class="tabs-section">
      <div class="tabs-container">
        <button
          :class="['tab-button', { active: activeTab === 'active' }]"
          @click="activeTab = 'active'"
        >
          <i class="pi pi-check-circle"></i>
          <span>Active</span>
          <span class="tab-count">{{ activeTemplatesCount }}</span>
        </button>
        <button
          :class="['tab-button', { active: activeTab === 'archived' }]"
          @click="activeTab = 'archived'"
        >
          <i class="pi pi-inbox"></i>
          <span>Archived</span>
          <span class="tab-count archived">{{ archivedTemplatesCount }}</span>
        </button>
      </div>
    </div>

    <div class="page-header-new">
      <div class="search-section">
        <span class="pi pi-search search-icon"></span>
        <InputText
          v-model="searchQuery"
          :placeholder="activeTab === 'active' ? 'Search active templates...' : 'Search archived templates...'"
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
        <Button v-if="activeTab === 'active'" label="Create Template" icon="pi pi-plus" @click="openDrawer(null)" />
      </div>
    </div>

    <!-- Task Template Drawer -->
    <TaskTemplateDrawer
      v-model:visible="drawerVisible"
      :editingTemplate="editingTemplate"
      @save="handleSaveTemplate"
    />

    <div class="content-card">
      <!-- Active Templates Tab -->
      <template v-if="activeTab === 'active'">
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
            <Column header="Actions" style="min-width: 140px" headerClass="actions-header">
              <template #body="{ data }">
                <div class="action-buttons">
                  <Button
                    icon="pi pi-eye"
                    size="small"
                    text
                    rounded
                    @click="handleView(data)"
                    v-tooltip.top="'View'"
                    class="action-btn view"
                  />
                  <Button
                    icon="pi pi-pencil"
                    size="small"
                    text
                    rounded
                    @click="openDrawer(data)"
                    v-tooltip.top="'Edit'"
                    class="action-btn edit"
                  />
                  <Button
                    icon="pi pi-inbox"
                    size="small"
                    text
                    rounded
                    severity="warning"
                    @click="handleArchive(data)"
                    v-tooltip.top="'Archive'"
                    class="action-btn archive"
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
                  <Button icon="pi pi-eye" size="small" text rounded @click="handleView(template)" v-tooltip.top="'View'" />
                  <Button icon="pi pi-pencil" size="small" text rounded @click="openDrawer(template)" v-tooltip.top="'Edit'" />
                  <Button icon="pi pi-inbox" size="small" text rounded severity="warning" @click="handleArchive(template)" v-tooltip.top="'Archive'" />
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
                </div>
                <div class="card-footer">
                  <span class="card-date">Updated {{ formatDate(template.updatedAt) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </template>

      <!-- Archived Templates Tab -->
      <template v-else>
        <!-- Archived Empty State -->
        <div v-if="sortedArchivedTemplates.length === 0" class="empty-state">
          <div class="empty-icon">
            <i class="pi pi-inbox"></i>
          </div>
          <h3 class="empty-title">No Archived Templates</h3>
          <p class="empty-description">Templates you archive will appear here. You can restore them anytime.</p>
        </div>

        <!-- Archived List View -->
        <div v-else-if="viewMode === 'list'" class="table-container">
          <DataTable
            :value="sortedArchivedTemplates"
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
                <div class="template-name-cell archived">
                  <div :class="['template-type-icon', data.type, 'archived']">
                    <span :class="['pi', getTypeIcon(data.type)]"></span>
                  </div>
                  <div class="template-info">
                    <div class="template-title archived">{{ data.name }}</div>
                    <div class="template-description">{{ data.description || 'No description provided' }}</div>
                  </div>
                </div>
              </template>
            </Column>
            <Column field="type" header="Type" sortable style="min-width: 160px">
              <template #body="{ data }">
                <span :class="['type-badge', data.type, 'archived']">
                  {{ getTypeName(data.type) }}
                </span>
              </template>
            </Column>
            <Column field="indicator" header="Category" sortable style="min-width: 140px">
              <template #body="{ data }">
                <span :class="['category-badge', data.indicator, 'archived']">
                  {{ data.indicator }}
                </span>
              </template>
            </Column>
            <Column field="archivedAt" header="Archived Date" sortable style="min-width: 140px">
              <template #body="{ data }">
                <span class="date-text">{{ formatDate(data.archivedAt) }}</span>
              </template>
            </Column>
            <Column header="Actions" style="min-width: 160px" headerClass="actions-header">
              <template #body="{ data }">
                <div class="action-buttons">
                  <Button
                    icon="pi pi-eye"
                    size="small"
                    text
                    rounded
                    @click="handleView(data)"
                    v-tooltip.top="'View'"
                    class="action-btn view"
                  />
                  <Button
                    icon="pi pi-replay"
                    size="small"
                    text
                    rounded
                    severity="success"
                    @click="handleRestore(data)"
                    v-tooltip.top="'Restore'"
                    class="action-btn restore"
                  />
                  <Button
                    icon="pi pi-trash"
                    size="small"
                    text
                    rounded
                    severity="danger"
                    @click="handlePermanentDelete(data)"
                    v-tooltip.top="'Delete Permanently'"
                    class="action-btn delete"
                  />
                </div>
              </template>
            </Column>
          </DataTable>
        </div>

        <!-- Archived Card View -->
        <div v-else class="card-grid-container">
          <div class="card-grid">
            <div v-for="template in sortedArchivedTemplates" :key="template.id" class="template-card archived">
              <div class="card-header">
                <div :class="['card-icon', template.type, 'archived']">
                  <span :class="['pi', getTypeIcon(template.type)]"></span>
                </div>
                <div class="card-actions">
                  <Button icon="pi pi-eye" size="small" text rounded @click="handleView(template)" v-tooltip.top="'View'" />
                  <Button icon="pi pi-replay" size="small" text rounded severity="success" @click="handleRestore(template)" v-tooltip.top="'Restore'" />
                  <Button icon="pi pi-trash" size="small" text rounded severity="danger" @click="handlePermanentDelete(template)" v-tooltip.top="'Delete Permanently'" />
                </div>
              </div>
              <div class="card-body">
                <div class="archived-badge">
                  <i class="pi pi-inbox"></i>
                  <span>Archived</span>
                </div>
                <h3 class="card-title archived">{{ template.name }}</h3>
                <p class="card-description">{{ template.description || 'No description provided' }}</p>
                <div class="card-badges">
                  <span :class="['type-badge', template.type, 'archived']">{{ getTypeName(template.type) }}</span>
                  <span :class="['category-badge', template.indicator, 'archived']">{{ template.indicator }}</span>
                </div>
                <div class="card-details">
                  <div class="detail-row">
                    <span class="detail-label">Owner Role:</span>
                    <span class="detail-value">{{ template.ownerRole }}</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Archived:</span>
                    <span class="detail-value">{{ formatDate(template.archivedAt) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </template>

      <div class="table-footer">
        <span class="result-count">
          <template v-if="activeTab === 'active'">
            Showing {{ sortedTemplates.length }} of {{ activeTemplatesCount }} active templates
          </template>
          <template v-else>
            Showing {{ sortedArchivedTemplates.length }} of {{ archivedTemplatesCount }} archived templates
          </template>
        </span>
      </div>
    </div>

    <!-- Archive Confirmation Dialog -->
    <Dialog
      v-model:visible="archiveDialogVisible"
      header="Archive Template"
      :style="{ width: '420px' }"
      :modal="true"
    >
      <div class="confirm-dialog-content">
        <div class="confirm-icon warning">
          <i class="pi pi-inbox"></i>
        </div>
        <div class="confirm-message">
          <p>Are you sure you want to archive <strong>"{{ templateToArchive?.name }}"</strong>?</p>
          <p class="confirm-hint">Archived templates can be restored later from the Archived tab.</p>
        </div>
      </div>
      <template #footer>
        <Button label="Cancel" severity="secondary" outlined @click="archiveDialogVisible = false" />
        <Button label="Archive" icon="pi pi-inbox" severity="warning" @click="confirmArchive" />
      </template>
    </Dialog>

    <!-- Restore Confirmation Dialog -->
    <Dialog
      v-model:visible="restoreDialogVisible"
      header="Restore Template"
      :style="{ width: '420px' }"
      :modal="true"
    >
      <div class="confirm-dialog-content">
        <div class="confirm-icon success">
          <i class="pi pi-replay"></i>
        </div>
        <div class="confirm-message">
          <p>Are you sure you want to restore <strong>"{{ templateToRestore?.name }}"</strong>?</p>
          <p class="confirm-hint">The template will be moved back to active templates.</p>
        </div>
      </div>
      <template #footer>
        <Button label="Cancel" severity="secondary" outlined @click="restoreDialogVisible = false" />
        <Button label="Restore" icon="pi pi-replay" severity="success" @click="confirmRestore" />
      </template>
    </Dialog>

    <!-- Permanent Delete Confirmation Dialog -->
    <Dialog
      v-model:visible="deleteDialogVisible"
      header="Delete Permanently"
      :style="{ width: '420px' }"
      :modal="true"
    >
      <div class="confirm-dialog-content">
        <div class="confirm-icon danger">
          <i class="pi pi-exclamation-triangle"></i>
        </div>
        <div class="confirm-message">
          <p>Are you sure you want to permanently delete <strong>"{{ templateToDelete?.name }}"</strong>?</p>
          <p class="confirm-hint warning">This action cannot be undone. The template will be permanently removed.</p>
        </div>
      </div>
      <template #footer>
        <Button label="Cancel" severity="secondary" outlined @click="deleteDialogVisible = false" />
        <Button label="Delete Permanently" icon="pi pi-trash" severity="danger" @click="confirmPermanentDelete" />
      </template>
    </Dialog>

    <Toast />
  </div>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import { useToast } from 'primevue/usetoast'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dropdown from 'primevue/dropdown'
import InputText from 'primevue/inputtext'
import Dialog from 'primevue/dialog'
import Toast from 'primevue/toast'
import TaskTemplateDrawer from '../../components/drawers/TaskTemplateDrawer.vue'
import { taskTemplates as initialTemplates } from '../../data/mockData'

const toast = useToast()

// Tab state
const activeTab = ref('active')

// Reactive templates data with archive support
const templatesData = reactive({
  active: initialTemplates.map(t => ({ ...t, isArchived: false })),
  archived: []
})

const searchQuery = ref('')
const selectedType = ref(null)
const selectedIndicator = ref(null)
const viewMode = ref('list')
const drawerVisible = ref(false)
const editingTemplate = ref(null)
const sortField = ref('name')
const sortOrder = ref(1)

// Dialog states
const archiveDialogVisible = ref(false)
const restoreDialogVisible = ref(false)
const deleteDialogVisible = ref(false)
const templateToArchive = ref(null)
const templateToRestore = ref(null)
const templateToDelete = ref(null)

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

// Computed counts
const activeTemplatesCount = computed(() => templatesData.active.length)
const archivedTemplatesCount = computed(() => templatesData.archived.length)

// Filter active templates
const filteredTemplates = computed(() => {
  let filtered = [...templatesData.active]

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(t =>
      t.name.toLowerCase().includes(query) ||
      (t.description && t.description.toLowerCase().includes(query)) ||
      (typeLabels[t.type] && typeLabels[t.type].toLowerCase().includes(query)) ||
      t.ownerRole.toLowerCase().includes(query)
    )
  }

  if (selectedType.value) {
    filtered = filtered.filter(t => t.type === selectedType.value)
  }

  if (selectedIndicator.value) {
    filtered = filtered.filter(t => t.indicator === selectedIndicator.value)
  }

  return filtered
})

// Filter archived templates
const filteredArchivedTemplates = computed(() => {
  let filtered = [...templatesData.archived]

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(t =>
      t.name.toLowerCase().includes(query) ||
      (t.description && t.description.toLowerCase().includes(query)) ||
      (typeLabels[t.type] && typeLabels[t.type].toLowerCase().includes(query)) ||
      t.ownerRole.toLowerCase().includes(query)
    )
  }

  if (selectedType.value) {
    filtered = filtered.filter(t => t.type === selectedType.value)
  }

  if (selectedIndicator.value) {
    filtered = filtered.filter(t => t.indicator === selectedIndicator.value)
  }

  return filtered
})

const sortedTemplates = computed(() => {
  const templates = [...filteredTemplates.value]
  return sortTemplates(templates)
})

const sortedArchivedTemplates = computed(() => {
  const templates = [...filteredArchivedTemplates.value]
  return sortTemplates(templates)
})

const sortTemplates = (templates) => {
  if (sortField.value) {
    templates.sort((a, b) => {
      let valueA = a[sortField.value]
      let valueB = b[sortField.value]

      if (sortField.value === 'type') {
        valueA = typeLabels[valueA] || valueA
        valueB = typeLabels[valueB] || valueB
      }

      if (sortField.value === 'updatedAt' || sortField.value === 'archivedAt') {
        valueA = new Date(valueA || 0).getTime()
        valueB = new Date(valueB || 0).getTime()
        return sortOrder.value * (valueA - valueB)
      }

      if (typeof valueA === 'string' && typeof valueB === 'string') {
        return sortOrder.value * valueA.localeCompare(valueB, undefined, { sensitivity: 'base' })
      }

      return 0
    })
  }

  return templates
}

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
  editingTemplate.value = { ...template, viewMode: true }
  drawerVisible.value = true
}

// Archive functionality
const handleArchive = (template) => {
  templateToArchive.value = template
  archiveDialogVisible.value = true
}

const confirmArchive = () => {
  if (templateToArchive.value) {
    const index = templatesData.active.findIndex(t => t.id === templateToArchive.value.id)
    if (index !== -1) {
      const [archivedTemplate] = templatesData.active.splice(index, 1)
      archivedTemplate.isArchived = true
      archivedTemplate.archivedAt = new Date().toISOString()
      templatesData.archived.push(archivedTemplate)

      toast.add({
        severity: 'success',
        summary: 'Template Archived',
        detail: `"${templateToArchive.value.name}" has been archived`,
        life: 3000
      })
    }
  }
  archiveDialogVisible.value = false
  templateToArchive.value = null
}

// Restore functionality
const handleRestore = (template) => {
  templateToRestore.value = template
  restoreDialogVisible.value = true
}

const confirmRestore = () => {
  if (templateToRestore.value) {
    const index = templatesData.archived.findIndex(t => t.id === templateToRestore.value.id)
    if (index !== -1) {
      const [restoredTemplate] = templatesData.archived.splice(index, 1)
      restoredTemplate.isArchived = false
      restoredTemplate.archivedAt = null
      templatesData.active.push(restoredTemplate)

      toast.add({
        severity: 'success',
        summary: 'Template Restored',
        detail: `"${templateToRestore.value.name}" has been restored`,
        life: 3000
      })
    }
  }
  restoreDialogVisible.value = false
  templateToRestore.value = null
}

// Permanent delete functionality
const handlePermanentDelete = (template) => {
  templateToDelete.value = template
  deleteDialogVisible.value = true
}

const confirmPermanentDelete = () => {
  if (templateToDelete.value) {
    const index = templatesData.archived.findIndex(t => t.id === templateToDelete.value.id)
    if (index !== -1) {
      templatesData.archived.splice(index, 1)

      toast.add({
        severity: 'success',
        summary: 'Template Deleted',
        detail: `"${templateToDelete.value.name}" has been permanently deleted`,
        life: 3000
      })
    }
  }
  deleteDialogVisible.value = false
  templateToDelete.value = null
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
  max-width: 100%;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  height: calc(100vh - 100px);
}

.page-title-section {
  margin-bottom: var(--spacing-3);
}

.page-description {
  color: var(--color-gray-600);
  margin-top: var(--spacing-1);
  font-size: 13px;
  line-height: 1.5;
}

/* Tabs Section */
.tabs-section {
  margin-bottom: var(--spacing-3);
}

.tabs-container {
  display: flex;
  gap: var(--spacing-2);
  background-color: var(--color-gray-100);
  padding: 4px;
  border-radius: var(--radius-lg);
  width: fit-content;
}

.tab-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border: none;
  background: transparent;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-600);
  transition: all 0.2s ease;
}

.tab-button:hover {
  color: var(--color-gray-900);
  background-color: var(--color-gray-200);
}

.tab-button.active {
  background-color: white;
  color: var(--color-primary);
  box-shadow: var(--shadow-sm);
}

.tab-button i {
  font-size: 14px;
}

.tab-count {
  background-color: var(--color-primary-100);
  color: var(--color-primary);
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.tab-count.archived {
  background-color: var(--color-gray-200);
  color: var(--color-gray-600);
}

.tab-button.active .tab-count {
  background-color: var(--color-primary);
  color: white;
}

.tab-button.active .tab-count.archived {
  background-color: var(--color-gray-500);
  color: white;
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
  flex: 1;
  min-height: 0;
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

/* Empty State */
.empty-state {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-8);
  text-align: center;
}

.empty-icon {
  width: 80px;
  height: 80px;
  background-color: var(--color-gray-100);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: var(--spacing-4);
}

.empty-icon i {
  font-size: 36px;
  color: var(--color-gray-400);
}

.empty-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0 0 var(--spacing-2);
}

.empty-description {
  font-size: 14px;
  color: var(--color-gray-500);
  margin: 0;
  max-width: 360px;
}

.template-name-cell {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-3);
}

.template-name-cell.archived {
  opacity: 0.7;
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

.template-type-icon.archived {
  filter: grayscale(50%);
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

.template-title.archived {
  color: var(--color-gray-600);
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

.type-badge.archived {
  filter: grayscale(40%);
  opacity: 0.8;
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

.category-badge.archived {
  filter: grayscale(40%);
  opacity: 0.8;
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

.action-btn.archive:hover {
  color: #d97706 !important;
  background-color: #fffbeb !important;
}

.action-btn.restore:hover {
  color: #059669 !important;
  background-color: #ecfdf5 !important;
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

.template-card.archived {
  background-color: var(--color-gray-50);
  border-color: var(--color-gray-200);
}

.template-card.archived:hover {
  border-color: var(--color-gray-400);
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

.card-icon.archived {
  filter: grayscale(50%);
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

.archived-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 10px;
  background-color: var(--color-gray-200);
  color: var(--color-gray-600);
  border-radius: var(--radius-sm);
  font-size: 11px;
  font-weight: 600;
  width: fit-content;
  margin-bottom: var(--spacing-1);
}

.archived-badge i {
  font-size: 11px;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0 0 6px 0;
  line-height: 1.3;
}

.card-title.archived {
  color: var(--color-gray-600);
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

/* Confirmation Dialog Styles */
.confirm-dialog-content {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-4);
  padding: var(--spacing-2) 0;
}

.confirm-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.confirm-icon.warning {
  background-color: #fef3c7;
}

.confirm-icon.warning i {
  font-size: 24px;
  color: #d97706;
}

.confirm-icon.success {
  background-color: #dcfce7;
}

.confirm-icon.success i {
  font-size: 24px;
  color: #16a34a;
}

.confirm-icon.danger {
  background-color: #fee2e2;
}

.confirm-icon.danger i {
  font-size: 24px;
  color: #dc2626;
}

.confirm-message p {
  margin: 0 0 var(--spacing-2);
  color: var(--color-gray-700);
  font-size: 14px;
}

.confirm-hint {
  font-size: 13px !important;
  color: var(--color-gray-500) !important;
}

.confirm-hint.warning {
  color: #b91c1c !important;
}
</style>
