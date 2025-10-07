<template>
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="text-h1">Workflow Builder</h1>
          <p class="page-description">Compose and manage workflows from task templates</p>
        </div>
        <Button label="Create Workflow" icon="pi pi-plus" @click="createWorkflow" />
      </div>

      <div class="content-card">
        <DataTable :value="workflows" responsiveLayout="scroll" stripedRows>
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
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import StatusChip from '../../components/ui/StatusChip.vue'
import { workflows } from '../../data/mockData'

const createWorkflow = () => {
  console.log('Create new workflow')
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
