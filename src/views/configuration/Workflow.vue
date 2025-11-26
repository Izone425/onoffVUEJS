<template>
    <div class="page-container">
      <div class="page-title-section">
        <div>
          <h1 class="text-h1">Workflow</h1>
          <p class="page-description">Create and manage onboarding and offboarding workflows</p>
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
          <Button label="Create Workflow" icon="pi pi-plus" @click="createWorkflow" />
        </div>
      </div>

      <div class="content-card">
        <!-- List View -->
        <div v-if="viewMode === 'list'" class="table-container">
          <DataTable :value="filteredWorkflows" responsiveLayout="scroll" stripedRows>
            <Column field="name" header="Workflow Name" style="min-width: 300px">
              <template #body="{ data }">
                <div class="workflow-name">
                  <span class="pi pi-sitemap"></span>
                  <span>{{ data.name }}</span>
                </div>
              </template>
            </Column>
            <Column field="taskCount" header="Tasks" style="min-width: 100px">
              <template #body="{ data }">
                {{ data.taskCount }} tasks
              </template>
            </Column>
            <Column field="status" header="Status" style="min-width: 120px">
              <template #body="{ data }">
                <span :class="['status-badge', data.status]">
                  {{ data.status }}
                </span>
              </template>
            </Column>
            <Column field="updatedAt" header="Updated" style="min-width: 150px"></Column>
            <Column header="Actions" style="min-width: 150px">
              <template #body="{ data }">
                <div class="action-buttons">
                  <Button icon="pi pi-eye" size="small" text rounded title="View" @click="viewWorkflow(data)" />
                  <Button icon="pi pi-pencil" size="small" text rounded title="Edit" @click="editWorkflow(data.id)" />
                  <Button icon="pi pi-trash" size="small" text rounded severity="danger" title="Delete" @click="confirmDeleteWorkflow(data)" />
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
                  <Button icon="pi pi-eye" size="small" text rounded title="View" @click="viewWorkflow(workflow)" />
                  <Button icon="pi pi-pencil" size="small" text rounded title="Edit" @click="editWorkflow(workflow.id)" />
                  <Button icon="pi pi-trash" size="small" text rounded severity="danger" title="Delete" @click="confirmDeleteWorkflow(workflow)" />
                </div>
              </div>
              <div class="card-body">
                <h3 class="card-title">{{ workflow.name }}</h3>
                <div class="card-details">
                  <div class="detail-row">
                    <span class="detail-label">Tasks:</span>
                    <span class="detail-value">{{ workflow.taskCount }} tasks</span>
                  </div>
                  <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span :class="['status-badge', workflow.status]">
                      {{ workflow.status }}
                    </span>
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
      </div>
    </div>

    <!-- Delete Confirmation Dialog -->
    <Dialog
      v-model:visible="deleteDialogVisible"
      modal
      header="Delete Workflow"
      :style="{ width: '450px' }"
      :closable="true"
    >
      <div class="delete-dialog-content">
        <div class="delete-icon-wrapper">
          <span class="pi pi-exclamation-triangle"></span>
        </div>
        <p class="delete-message">
          Are you sure you want to delete <strong>"{{ workflowToDelete?.name }}"</strong>?
        </p>
        <p class="delete-warning">
          This action cannot be undone. All associated tasks and configurations will be permanently removed.
        </p>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <Button label="Cancel" severity="secondary" outlined @click="closeDeleteDialog" />
          <Button label="Delete" severity="danger" icon="pi pi-trash" @click="deleteWorkflow" />
        </div>
      </template>
    </Dialog>
  </template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dialog from 'primevue/dialog'
import { workflows } from '../../data/mockData'

const router = useRouter()
const toast = useToast()

const selectedCategory = ref('onboarding')
const viewMode = ref('list') // 'list' or 'card'
const deleteDialogVisible = ref(false)
const workflowToDelete = ref(null)

const filteredWorkflows = computed(() => {
  return workflows.filter(w => w.category === selectedCategory.value)
})

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

// Open delete confirmation dialog
const confirmDeleteWorkflow = (workflow) => {
  workflowToDelete.value = workflow
  deleteDialogVisible.value = true
}

// Close delete dialog
const closeDeleteDialog = () => {
  deleteDialogVisible.value = false
  workflowToDelete.value = null
}

// Delete workflow
const deleteWorkflow = () => {
  // In a real application, this would make an API call to delete the workflow
  toast.add({
    severity: 'success',
    summary: 'Workflow Deleted',
    detail: `"${workflowToDelete.value?.name}" has been deleted successfully`,
    life: 3000
  })

  closeDeleteDialog()
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
}

.table-container {
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

/* Delete Dialog Styles */
.delete-dialog-content {
  text-align: center;
  padding: var(--spacing-3) 0;
}

.delete-icon-wrapper {
  width: 64px;
  height: 64px;
  background-color: #fee2e2;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto var(--spacing-4);
}

.delete-icon-wrapper .pi {
  font-size: 28px;
  color: #dc2626;
}

.delete-message {
  font-size: 15px;
  color: var(--color-gray-900);
  margin: 0 0 var(--spacing-2) 0;
  line-height: 1.5;
}

.delete-warning {
  font-size: 13px;
  color: var(--color-gray-600);
  margin: 0;
  line-height: 1.5;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-2);
}

.w-full {
  width: 100%;
}
</style>
