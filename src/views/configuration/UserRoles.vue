<template>
    <div class="page-container">
      <div class="page-header">
        <h1 class="text-h1">User Roles</h1>
        <p class="page-description">Configure role-based access control</p>
      </div>

      <div class="content-card">
        <DataTable :value="roles" responsiveLayout="scroll" stripedRows>
          <Column field="name" header="Role" style="min-width: 150px">
            <template #body="{ data }">
              <div class="role-cell">
                <span class="role-name">{{ data.name }}</span>
              </div>
            </template>
          </Column>
          <Column field="description" header="Description" style="min-width: 250px"></Column>
          <Column header="Permissions" style="min-width: 200px">
            <template #body>
              <Button label="View Matrix" size="small" outlined @click="showPermissions" />
            </template>
          </Column>
          <Column field="updatedAt" header="Last Updated" style="min-width: 150px"></Column>
          <Column header="Actions" style="min-width: 120px">
            <template #body>
              <div class="action-buttons">
                <Button icon="pi pi-pencil" size="small" text rounded />
                <Button icon="pi pi-copy" size="small" text rounded />
              </div>
            </template>
          </Column>
        </DataTable>
      </div>
    </div>
  </template>

<script setup>
import { ref } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import { roles } from '../../data/mockData'

const showPermissions = () => {
  // Would open permissions matrix modal
  console.log('Show permissions matrix')
}
</script>

<style scoped>
.page-container {
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
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

.role-cell {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.role-name {
  font-weight: 500;
  color: var(--color-gray-900);
}

.action-buttons {
  display: flex;
  gap: var(--spacing-1);
}
</style>
