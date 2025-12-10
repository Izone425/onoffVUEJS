<template>
    <div class="page-container">
      <div class="page-title-section">
        <div>
          <h1 class="text-h1">Workflow</h1>
          <p class="page-description">Create and manage onboarding and offboarding workflows</p>
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
            <span class="tab-count">{{ activeWorkflowsCount }}</span>
          </button>
          <button
            :class="['tab-button', { active: activeTab === 'archived' }]"
            @click="activeTab = 'archived'"
          >
            <i class="pi pi-inbox"></i>
            <span>Archived</span>
            <span class="tab-count archived">{{ archivedWorkflowsCount }}</span>
          </button>
        </div>
      </div>

      <div class="page-header-new">
        <div class="category-tabs">
          <button
            :class="['category-tab', { active: selectedCategory === 'onboarding' }]"
            @click="selectedCategory = 'onboarding'"
          >
            Onboarding
          </button>
          <button
            :class="['category-tab', { active: selectedCategory === 'offboarding' }]"
            @click="selectedCategory = 'offboarding'"
          >
            Offboarding
          </button>
        </div>
        <div class="header-actions">
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
          <Button v-if="activeTab === 'active'" label="Create Workflow" icon="pi pi-plus" @click="createWorkflow" />
        </div>
      </div>

      <div class="content-card">
        <!-- Active Workflows Tab -->
        <template v-if="activeTab === 'active'">
          <!-- List View -->
          <div v-if="viewMode === 'list'" class="table-container">
            <DataTable :value="filteredWorkflows" responsiveLayout="scroll" stripedRows>
              <Column field="name" header="Workflow Name" style="min-width: 300px">
                <template #body="{ data }">
                  <div class="workflow-name">
                    <span class="pi pi-sitemap"></span>
                    <span>{{ getDisplayName(data.name) }}</span>
                  </div>
                </template>
              </Column>
              <Column field="taskCount" header="Tasks" style="min-width: 100px">
                <template #body="{ data }">
                  {{ data.taskCount }} tasks
                </template>
              </Column>
              <Column field="updatedAt" header="Updated" style="min-width: 150px"></Column>
              <Column header="Actions" style="min-width: 150px">
                <template #body="{ data }">
                  <div class="action-buttons">
                    <Button icon="pi pi-eye" size="small" text rounded v-tooltip.top="'View'" @click="viewWorkflow(data)" />
                    <Button icon="pi pi-pencil" size="small" text rounded v-tooltip.top="'Edit'" @click="editWorkflow(data.id)" />
                    <Button icon="pi pi-inbox" size="small" text rounded severity="warning" v-tooltip.top="'Archive'" @click="handleArchive(data)" />
                  </div>
                </template>
              </Column>
            </DataTable>
          </div>

          <!-- Card View -->
          <div v-else class="card-grid-container">
            <div class="card-grid">
              <div v-for="workflow in filteredWorkflows" :key="workflow.id" class="workflow-card">
                <div class="card-header">
                  <div class="card-icon">
                    <span class="pi pi-sitemap"></span>
                  </div>
                  <div class="card-actions">
                    <Button icon="pi pi-eye" size="small" text rounded v-tooltip.top="'View'" @click="viewWorkflow(workflow)" />
                    <Button icon="pi pi-pencil" size="small" text rounded v-tooltip.top="'Edit'" @click="editWorkflow(workflow.id)" />
                    <Button icon="pi pi-inbox" size="small" text rounded severity="warning" v-tooltip.top="'Archive'" @click="handleArchive(workflow)" />
                  </div>
                </div>
                <div class="card-body">
                  <h3 class="card-title">{{ getDisplayName(workflow.name) }}</h3>
                  <div class="card-details">
                    <div class="detail-row">
                      <span class="detail-label">Tasks:</span>
                      <span class="detail-value">{{ workflow.taskCount }} tasks</span>
                    </div>
                    <div class="detail-row">
                      <span class="detail-label">Updated:</span>
                      <span class="detail-value">{{ workflow.updatedAt }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- Archived Workflows Tab -->
        <template v-else>
          <!-- Archived Empty State -->
          <div v-if="filteredArchivedWorkflows.length === 0" class="empty-state">
            <div class="empty-icon">
              <i class="pi pi-inbox"></i>
            </div>
            <h3 class="empty-title">No Archived Workflows</h3>
            <p class="empty-description">Workflows you archive will appear here. You can restore them anytime.</p>
          </div>

          <!-- Archived List View -->
          <div v-else-if="viewMode === 'list'" class="table-container">
            <DataTable :value="filteredArchivedWorkflows" responsiveLayout="scroll" stripedRows>
              <Column field="name" header="Workflow Name" style="min-width: 300px">
                <template #body="{ data }">
                  <div class="workflow-name archived">
                    <span class="pi pi-sitemap"></span>
                    <span>{{ getDisplayName(data.name) }}</span>
                  </div>
                </template>
              </Column>
              <Column field="taskCount" header="Tasks" style="min-width: 100px">
                <template #body="{ data }">
                  {{ data.taskCount }} tasks
                </template>
              </Column>
              <Column field="archivedAt" header="Archived Date" style="min-width: 150px">
                <template #body="{ data }">
                  {{ formatDate(data.archivedAt) }}
                </template>
              </Column>
              <Column header="Actions" style="min-width: 160px">
                <template #body="{ data }">
                  <div class="action-buttons">
                    <Button icon="pi pi-eye" size="small" text rounded v-tooltip.top="'View'" @click="viewWorkflow(data)" />
                    <Button icon="pi pi-replay" size="small" text rounded severity="success" v-tooltip.top="'Restore'" @click="handleRestore(data)" />
                    <Button icon="pi pi-trash" size="small" text rounded severity="danger" v-tooltip.top="'Delete Permanently'" @click="handlePermanentDelete(data)" />
                  </div>
                </template>
              </Column>
            </DataTable>
          </div>

          <!-- Archived Card View -->
          <div v-else class="card-grid-container">
            <div class="card-grid">
              <div v-for="workflow in filteredArchivedWorkflows" :key="workflow.id" class="workflow-card archived">
                <div class="card-header">
                  <div class="card-icon archived">
                    <span class="pi pi-sitemap"></span>
                  </div>
                  <div class="card-actions">
                    <Button icon="pi pi-eye" size="small" text rounded v-tooltip.top="'View'" @click="viewWorkflow(workflow)" />
                    <Button icon="pi pi-replay" size="small" text rounded severity="success" v-tooltip.top="'Restore'" @click="handleRestore(workflow)" />
                    <Button icon="pi pi-trash" size="small" text rounded severity="danger" v-tooltip.top="'Delete Permanently'" @click="handlePermanentDelete(workflow)" />
                  </div>
                </div>
                <div class="card-body">
                  <div class="archived-badge">
                    <i class="pi pi-inbox"></i>
                    <span>Archived</span>
                  </div>
                  <h3 class="card-title archived">{{ getDisplayName(workflow.name) }}</h3>
                  <div class="card-details">
                    <div class="detail-row">
                      <span class="detail-label">Tasks:</span>
                      <span class="detail-value">{{ workflow.taskCount }} tasks</span>
                    </div>
                    <div class="detail-row">
                      <span class="detail-label">Archived:</span>
                      <span class="detail-value">{{ formatDate(workflow.archivedAt) }}</span>
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
              Showing {{ filteredWorkflows.length }} of {{ activeWorkflowsCount }} active workflows
            </template>
            <template v-else>
              Showing {{ filteredArchivedWorkflows.length }} of {{ archivedWorkflowsCount }} archived workflows
            </template>
          </span>
        </div>
      </div>
    </div>

    <!-- Archive Confirmation Dialog -->
    <Dialog
      v-model:visible="archiveDialogVisible"
      header="Archive Workflow"
      :style="{ width: '420px' }"
      :modal="true"
    >
      <div class="confirm-dialog-content">
        <div class="confirm-icon warning">
          <i class="pi pi-inbox"></i>
        </div>
        <div class="confirm-message">
          <p>Are you sure you want to archive <strong>"{{ workflowToArchive?.name }}"</strong>?</p>
          <p class="confirm-hint">Archived workflows can be restored later from the Archived tab.</p>
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
      header="Restore Workflow"
      :style="{ width: '420px' }"
      :modal="true"
    >
      <div class="confirm-dialog-content">
        <div class="confirm-icon success">
          <i class="pi pi-replay"></i>
        </div>
        <div class="confirm-message">
          <p>Are you sure you want to restore <strong>"{{ workflowToRestore?.name }}"</strong>?</p>
          <p class="confirm-hint">The workflow will be moved back to active workflows.</p>
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
          <p>Are you sure you want to permanently delete <strong>"{{ workflowToDelete?.name }}"</strong>?</p>
          <p class="confirm-hint warning">This action cannot be undone. The workflow will be permanently removed.</p>
        </div>
      </div>
      <template #footer>
        <Button label="Cancel" severity="secondary" outlined @click="deleteDialogVisible = false" />
        <Button label="Delete Permanently" icon="pi pi-trash" severity="danger" @click="confirmPermanentDelete" />
      </template>
    </Dialog>

    <Toast />
  </template>

<script setup>
import { ref, computed, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dialog from 'primevue/dialog'
import Toast from 'primevue/toast'
import { workflows as initialWorkflows } from '../../data/mockData'

const router = useRouter()
const toast = useToast()

// Tab state
const activeTab = ref('active')
const selectedCategory = ref('onboarding')
const viewMode = ref('list')

// Reactive workflows data with archive support
const workflowsData = reactive({
  active: initialWorkflows.map(w => ({ ...w, isArchived: false })),
  archived: []
})

// Dialog states
const archiveDialogVisible = ref(false)
const restoreDialogVisible = ref(false)
const deleteDialogVisible = ref(false)
const workflowToArchive = ref(null)
const workflowToRestore = ref(null)
const workflowToDelete = ref(null)

// Computed counts
const activeWorkflowsCount = computed(() => workflowsData.active.length)
const archivedWorkflowsCount = computed(() => workflowsData.archived.length)

// Filter active workflows by category
const filteredWorkflows = computed(() => {
  return workflowsData.active.filter(w => w.category === selectedCategory.value)
})

// Filter archived workflows by category
const filteredArchivedWorkflows = computed(() => {
  return workflowsData.archived.filter(w => w.category === selectedCategory.value)
})

// Format date
const formatDate = (dateString) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-MY', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
}

// Remove category prefix from workflow name
const getDisplayName = (name) => {
  if (!name) return ''
  // Remove "Onboarding — " or "Offboarding — " prefix
  return name.replace(/^(Onboarding|Offboarding)\s*[—-]\s*/i, '')
}

const createWorkflow = () => {
  router.push({
    name: 'WorkflowCreate',
    query: { type: selectedCategory.value }
  })
}

// View workflow (read-only mode)
const viewWorkflow = (workflow) => {
  router.push({
    name: 'WorkflowEdit',
    params: { id: workflow.id },
    query: { type: selectedCategory.value, mode: 'view' }
  })
}

// Edit workflow
const editWorkflow = (workflowId) => {
  router.push({
    name: 'WorkflowEdit',
    params: { id: workflowId },
    query: { type: selectedCategory.value }
  })
}

// Archive functionality
const handleArchive = (workflow) => {
  workflowToArchive.value = workflow
  archiveDialogVisible.value = true
}

const confirmArchive = () => {
  if (workflowToArchive.value) {
    const index = workflowsData.active.findIndex(w => w.id === workflowToArchive.value.id)
    if (index !== -1) {
      const [archivedWorkflow] = workflowsData.active.splice(index, 1)
      archivedWorkflow.isArchived = true
      archivedWorkflow.archivedAt = new Date().toISOString()
      workflowsData.archived.push(archivedWorkflow)

      toast.add({
        severity: 'success',
        summary: 'Workflow Archived',
        detail: `"${workflowToArchive.value.name}" has been archived`,
        life: 3000
      })
    }
  }
  archiveDialogVisible.value = false
  workflowToArchive.value = null
}

// Restore functionality
const handleRestore = (workflow) => {
  workflowToRestore.value = workflow
  restoreDialogVisible.value = true
}

const confirmRestore = () => {
  if (workflowToRestore.value) {
    const index = workflowsData.archived.findIndex(w => w.id === workflowToRestore.value.id)
    if (index !== -1) {
      const [restoredWorkflow] = workflowsData.archived.splice(index, 1)
      restoredWorkflow.isArchived = false
      restoredWorkflow.archivedAt = null
      workflowsData.active.push(restoredWorkflow)

      toast.add({
        severity: 'success',
        summary: 'Workflow Restored',
        detail: `"${workflowToRestore.value.name}" has been restored`,
        life: 3000
      })
    }
  }
  restoreDialogVisible.value = false
  workflowToRestore.value = null
}

// Permanent delete functionality
const handlePermanentDelete = (workflow) => {
  workflowToDelete.value = workflow
  deleteDialogVisible.value = true
}

const confirmPermanentDelete = () => {
  if (workflowToDelete.value) {
    const index = workflowsData.archived.findIndex(w => w.id === workflowToDelete.value.id)
    if (index !== -1) {
      workflowsData.archived.splice(index, 1)

      toast.add({
        severity: 'success',
        summary: 'Workflow Deleted',
        detail: `"${workflowToDelete.value.name}" has been permanently deleted`,
        life: 3000
      })
    }
  }
  deleteDialogVisible.value = false
  workflowToDelete.value = null
}
</script>

<style scoped>
.page-container {
  max-width: 1400px;
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

.category-tabs {
  display: flex;
  gap: 0;
  background-color: #f1f5f9;
  border-radius: var(--radius-md);
  padding: 4px;
}

.category-tab {
  padding: 8px 24px;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-600);
  background: transparent;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all 0.2s;
}

.category-tab:hover {
  color: var(--color-gray-900);
}

.category-tab.active {
  background-color: white;
  color: var(--color-primary-600);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

.header-actions {
  display: flex;
  gap: var(--spacing-2);
  align-items: center;
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

.workflow-name {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-weight: 500;
}

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
  border: 1px solid #bfdbfe;
}

.category-badge.offboarding {
  background-color: #fee2e2;
  color: #991b1b;
  border: 1px solid #fecaca;
}

.status-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
  text-transform: capitalize;
}

.status-badge.active {
  background-color: #d1fae5;
  color: #065f46;
  border: 1px solid #6ee7b7;
}

.status-badge.draft {
  background-color: #fef3c7;
  color: #92400e;
  border: 1px solid #fde68a;
}

.action-buttons {
  display: flex;
  gap: var(--spacing-1);
}

/* Card View Styles */
.card-grid-container {
  flex: 1;
  padding: var(--spacing-3);
  overflow: auto;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: var(--spacing-3);
}

.workflow-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  padding: var(--spacing-3);
  transition: all 0.2s;
  cursor: pointer;
}

.workflow-card:hover {
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

.workflow-card:hover .card-actions {
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

/* Table Footer */
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

/* Archived Styles */
.workflow-name.archived {
  opacity: 0.7;
}

.workflow-card.archived {
  background-color: var(--color-gray-50);
  border-color: var(--color-gray-200);
}

.workflow-card.archived:hover {
  border-color: var(--color-gray-400);
}

.card-icon.archived {
  filter: grayscale(50%);
}

.card-title.archived {
  color: var(--color-gray-600);
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
