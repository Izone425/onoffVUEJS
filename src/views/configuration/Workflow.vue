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
        <Button label="Create Workflow" icon="pi pi-plus" @click="createWorkflow" />
      </div>

      <div class="content-card">
        <DataTable :value="filteredWorkflows" responsiveLayout="scroll" stripedRows>
          <Column field="name" header="Name" style="min-width: 300px">
            <template #body="{ data }">
              <div class="workflow-name">
                <span class="pi pi-sitemap"></span>
                <span>{{ data.name }}</span>
              </div>
            </template>
          </Column>
          <Column field="category" header="Category" style="min-width: 140px">
            <template #body="{ data }">
              <StatusChip
                :status="data.category === 'onboarding' ? 'in_progress' : 'pending'"
                :label="data.category"
              />
            </template>
          </Column>
          <Column field="version" header="Version" style="min-width: 100px"></Column>
          <Column field="taskCount" header="Tasks" style="min-width: 100px"></Column>
          <Column field="updatedAt" header="Last Updated" style="min-width: 150px"></Column>
          <Column field="status" header="Status" style="min-width: 120px">
            <template #body="{ data }">
              <StatusChip :status="data.status === 'active' ? 'completed' : 'pending'" :label="data.status" />
            </template>
          </Column>
          <Column header="Actions" style="min-width: 150px">
            <template #body>
              <div class="action-buttons">
                <Button icon="pi pi-pencil" size="small" text rounded />
                <Button icon="pi pi-copy" size="small" text rounded />
                <Button icon="pi pi-eye" size="small" text rounded />
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
import StatusChip from '../../components/ui/StatusChip.vue'
import { workflows } from '../../data/mockData'

const selectedCategory = ref('onboarding')

const filteredWorkflows = computed(() => {
  return workflows.filter(w => w.category === selectedCategory.value)
})

const createWorkflow = () => {
  console.log('Create new workflow')
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

.content-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.workflow-name {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-weight: 500;
}

.action-buttons {
  display: flex;
  gap: var(--spacing-1);
}
</style>
