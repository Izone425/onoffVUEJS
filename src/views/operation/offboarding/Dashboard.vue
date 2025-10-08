<template>
  <div class="dashboard-container">
    <div class="page-header">
      <h1 class="text-h1">Offboarding Dashboard</h1>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-grid">
      <StatCard
        label="Overall Progress"
        :value="'54%'"
        icon="pi-chart-line"
        color="#F59E0B"
      />
      <StatCard
        label="Pending Documents"
        :value="4"
        icon="pi-file"
        color="#155EEF"
      />
      <StatCard
        label="Overdue Tasks"
        :value="2"
        icon="pi-exclamation-triangle"
        color="#DC2626"
      />
      <StatCard
        label="Exits This Month"
        :value="3"
        icon="pi-sign-out"
        color="#64748B"
      />
    </div>

    <!-- Progress by Leaver -->
    <div class="content-card">
      <div class="card-header">
        <h2 class="card-title">Progress by Leaver</h2>
      </div>
      <DataTable :value="leavers" responsiveLayout="scroll" stripedRows>
        <Column field="name" header="Name" style="min-width: 180px">
          <template #body="{ data }">
            <div class="employee-cell">
              <div class="employee-avatar">{{ getInitials(data.name) }}</div>
              <span>{{ data.name }}</span>
            </div>
          </template>
        </Column>
        <Column field="manager" header="Manager" style="min-width: 150px"></Column>
        <Column field="lastWorkingDay" header="Last Working Day" style="min-width: 150px"></Column>
        <Column header="Tasks" style="min-width: 150px">
          <template #body="{ data }">
            {{ data.completedTasks }}/{{ data.totalTasks }}
          </template>
        </Column>
        <Column header="Progress" style="min-width: 200px">
          <template #body="{ data }">
            <ProgressBar :percentage="data.progress" :showLabel="false" :color="'#F59E0B'" />
          </template>
        </Column>
        <Column field="progress" header="%" style="min-width: 80px">
          <template #body="{ data }">
            {{ data.progress }}%
          </template>
        </Column>
        <Column header="Status" style="min-width: 140px">
          <template #body="{ data }">
            <StatusChip :status="data.status" />
          </template>
        </Column>
      </DataTable>
    </div>

    <!-- My Tasks -->
    <div class="content-card">
      <div class="card-header">
        <h2 class="card-title">My Tasks</h2>
      </div>
      <DataTable :value="tasks" responsiveLayout="scroll" stripedRows>
        <Column field="task" header="Task" style="min-width: 250px"></Column>
        <Column field="employee" header="Employee" style="min-width: 150px"></Column>
        <Column field="assignee" header="Assignee" style="min-width: 150px"></Column>
        <Column field="dueDate" header="Due Date" style="min-width: 120px"></Column>
        <Column field="type" header="Type" style="min-width: 180px"></Column>
        <Column field="status" header="Status" style="min-width: 140px">
          <template #body="{ data }">
            <StatusChip :status="data.status" />
          </template>
        </Column>
        <Column header="Actions" style="min-width: 150px">
          <template #body="{ data }">
            <div class="action-buttons">
              <Button label="View" size="small" outlined @click="viewTask(data)" />
              <Button v-if="data.status !== 'completed'" label="Complete" size="small" @click="completeTask(data)" />
            </div>
          </template>
        </Column>
      </DataTable>
    </div>

    <!-- Assets to Collect -->
    <div class="content-card">
      <div class="card-header">
        <h2 class="card-title">Assets to Collect</h2>
      </div>
      <DataTable :value="assetsToCollect" responsiveLayout="scroll" stripedRows>
        <Column field="employee" header="Employee" style="min-width: 180px"></Column>
        <Column field="asset" header="Asset" style="min-width: 150px"></Column>
        <Column field="tag" header="Tag" style="min-width: 150px"></Column>
        <Column field="status" header="Status" style="min-width: 140px">
          <template #body="{ data }">
            <StatusChip :status="data.status === 'issued' ? 'pending' : 'completed'" :label="data.status" />
          </template>
        </Column>
        <Column header="Action" style="min-width: 150px">
          <template #body="{ data }">
            <Button
              v-if="data.status === 'issued'"
              label="Record Return"
              size="small"
              @click="recordReturn(data)"
            />
            <span v-else class="text-muted">—</span>
          </template>
        </Column>
      </DataTable>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useToast } from 'primevue/usetoast'
import StatCard from '../../../components/ui/StatCard.vue'
import ProgressBar from '../../../components/ui/ProgressBar.vue'
import StatusChip from '../../../components/ui/StatusChip.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'

const toast = useToast()

const leavers = [
  {
    id: 1,
    name: 'Zulkifli Hassan',
    manager: 'Farah Kassim',
    lastWorkingDay: '2025-09-12',
    completedTasks: 5,
    totalTasks: 9,
    progress: 56,
    status: 'in_progress'
  },
  {
    id: 2,
    name: 'Siti Rahmah',
    manager: 'Nizam Salleh',
    lastWorkingDay: '2025-09-20',
    completedTasks: 2,
    totalTasks: 8,
    progress: 25,
    status: 'not_started'
  }
]

const tasks = [
  {
    id: 1,
    task: 'Exit Interview',
    employee: 'Zulkifli Hassan',
    assignee: 'HR Team',
    dueDate: '2025-09-10',
    type: 'Meeting/Event Task',
    status: 'completed'
  },
  {
    id: 2,
    task: 'Revoke Access & Collect Assets',
    employee: 'Zulkifli Hassan',
    assignee: 'IT Team',
    dueDate: '2025-09-12',
    type: 'Checklist Task',
    status: 'in_progress'
  },
  {
    id: 3,
    task: 'Final Pay & Benefits Briefing',
    employee: 'Siti Rahmah',
    assignee: 'HR Team',
    dueDate: '2025-09-18',
    type: 'General Task',
    status: 'pending'
  }
]

const assetsToCollect = [
  {
    employee: 'Zulkifli Hassan',
    asset: 'Laptop',
    tag: 'MBP-14-2024-072',
    status: 'issued'
  },
  {
    employee: 'Zulkifli Hassan',
    asset: 'Access Card',
    tag: 'AC-6671',
    status: 'returned'
  },
  {
    employee: 'Siti Rahmah',
    asset: 'Phone',
    tag: 'IP13-221',
    status: 'issued'
  }
]

const getInitials = (name) => {
  return name.split(' ').map(n => n[0]).join('').toUpperCase()
}

const viewTask = (task) => {
  console.log('View task:', task)
}

const completeTask = (task) => {
  toast.add({
    severity: 'success',
    summary: 'Task Completed',
    detail: `${task.task} has been marked as completed`,
    life: 3000
  })
}

const recordReturn = (asset) => {
  toast.add({
    severity: 'success',
    summary: 'Asset Returned',
    detail: `${asset.asset} (${asset.tag}) has been recorded as returned`,
    life: 3000
  })
}
</script>

<style scoped>
.dashboard-container {
  max-width: 1600px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: var(--spacing-3);
}

.kpi-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: var(--spacing-3);
  margin-bottom: var(--spacing-3);
}

.content-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
  margin-bottom: var(--spacing-3);
}

.card-header {
  padding: var(--spacing-3);
  border-bottom: 1px solid var(--color-divider);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.employee-cell {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-weight: 500;
}

.employee-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: linear-gradient(135deg, #155EEF, #0B4EDD);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 600;
}

.action-buttons {
  display: flex;
  gap: var(--spacing-1);
}

.text-muted {
  color: var(--color-gray-400);
}
</style>
