<template>
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="text-h1">Audit Trail</h1>
          <p class="page-description">Track all configuration and operational changes</p>
        </div>
      </div>

      <div class="filters-bar">
        <Calendar v-model="dateRange" selectionMode="range" placeholder="Date Range" showIcon />
        <InputText v-model="searchActor" placeholder="Search by actor..." />
        <Dropdown
          v-model="selectedEntity"
          :options="entityTypes"
          placeholder="All Entities"
          showClear
        />
        <Dropdown
          v-model="selectedAction"
          :options="actionTypes"
          placeholder="All Actions"
          showClear
        />
      </div>

      <div class="content-card">
        <DataTable :value="auditTrail" responsiveLayout="scroll" stripedRows>
          <Column field="timestamp" header="Timestamp" style="min-width: 180px"></Column>
          <Column field="actor" header="Actor" style="min-width: 140px"></Column>
          <Column field="entity" header="Entity Type" style="min-width: 140px"></Column>
          <Column field="entityName" header="Entity Name" style="min-width: 200px"></Column>
          <Column field="action" header="Action" style="min-width: 100px">
            <template #body="{ data }">
              <StatusChip :status="getActionStatus(data.action)" :label="data.action" />
            </template>
          </Column>
          <Column header="Changes" style="min-width: 200px">
            <template #body="{ data }">
              <span v-if="data.before && data.after">
                {{ data.before }} → {{ data.after }}
              </span>
              <span v-else-if="data.after">{{ data.after }}</span>
              <span v-else class="text-muted">—</span>
            </template>
          </Column>
          <Column field="sourceIp" header="Source IP" style="min-width: 140px"></Column>
        </DataTable>
      </div>
    </div>
  </template>

<script setup>
import { ref } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Calendar from 'primevue/calendar'
import InputText from 'primevue/inputtext'
import Dropdown from 'primevue/dropdown'
import StatusChip from '../../components/ui/StatusChip.vue'
import { auditTrail } from '../../data/mockData'

const dateRange = ref(null)
const searchActor = ref('')
const selectedEntity = ref(null)
const selectedAction = ref(null)

const entityTypes = ['Workflow', 'Task', 'Task Template', 'Role', 'Settings']
const actionTypes = ['Create', 'Update', 'Delete', 'Assign', 'Complete', 'Sign-Off']

const getActionStatus = (action) => {
  const statusMap = {
    'Create': 'completed',
    'Update': 'in_progress',
    'Delete': 'overdue',
    'Assign': 'pending'
  }
  return statusMap[action] || 'pending'
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

.filters-bar {
  display: flex;
  gap: var(--spacing-2);
  margin-bottom: var(--spacing-3);
  flex-wrap: wrap;
}

.content-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.text-muted {
  color: var(--color-gray-400);
}
</style>
