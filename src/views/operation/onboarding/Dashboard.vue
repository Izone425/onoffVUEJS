<template>
    <div class="dashboard-container">
      <div class="page-header">
        <h1 class="text-h1">Onboarding Dashboard</h1>
      </div>

      <!-- KPI Cards -->
      <div class="kpi-grid">
        <StatCard
          label="Overall Progress"
          :value="'62%'"
          icon="pi-chart-line"
          color="#16A34A"
        />
        <StatCard
          label="Pending Documents"
          :value="7"
          icon="pi-file"
          color="#F59E0B"
        />
        <StatCard
          label="Overdue Tasks"
          :value="3"
          icon="pi-exclamation-triangle"
          color="#DC2626"
        />
        <StatCard
          label="New Hires This Month"
          :value="5"
          icon="pi-users"
          color="#155EEF"
        />
      </div>

      <!-- Progress by New Hire -->
      <div class="content-card">
        <div class="card-header">
          <h2 class="card-title">Progress by New Hire</h2>
        </div>
        <DataTable :value="newHires" responsiveLayout="scroll" stripedRows>
          <Column field="name" header="Name" style="min-width: 180px">
            <template #body="{ data }">
              <div class="employee-cell">
                <div class="employee-avatar">{{ getInitials(data.name) }}</div>
                <span>{{ data.name }}</span>
              </div>
            </template>
          </Column>
          <Column field="manager" header="Manager" style="min-width: 150px"></Column>
          <Column field="startDate" header="Start Date" style="min-width: 120px"></Column>
          <Column header="Tasks" style="min-width: 150px">
            <template #body="{ data }">
              {{ data.completedTasks }}/{{ data.totalTasks }}
            </template>
          </Column>
          <Column header="Progress" style="min-width: 200px">
            <template #body="{ data }">
              <ProgressBar :percentage="data.progress" :showLabel="false" />
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
          <div class="card-filters">
            <Button label="Assigned to Me" size="small" :class="{ 'active-filter': taskFilter === 'me' }" @click="taskFilter = 'me'" text />
            <Button label="Team" size="small" :class="{ 'active-filter': taskFilter === 'team' }" @click="taskFilter = 'team'" text />
            <Button label="All" size="small" :class="{ 'active-filter': taskFilter === 'all' }" @click="taskFilter = 'all'" text />
          </div>
        </div>
        <DataTable :value="tasks" responsiveLayout="scroll" stripedRows>
          <Column field="task" header="Task" style="min-width: 250px"></Column>
          <Column field="assignee" header="Assignee" style="min-width: 150px"></Column>
          <Column field="dueDate" header="Due Date" style="min-width: 120px"></Column>
          <Column field="type" header="Type" style="min-width: 180px"></Column>
          <Column field="indicator" header="Indicator" style="min-width: 120px">
            <template #body="{ data }">
              <StatusChip :status="'in_progress'" :label="data.indicator" />
            </template>
          </Column>
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
const taskFilter = ref('me')

const newHires = [
  {
    id: 1,
    name: 'Aina Zulkifli',
    manager: 'Farah Kassim',
    startDate: '2025-09-15',
    completedTasks: 8,
    totalTasks: 12,
    progress: 67,
    status: 'in_progress'
  },
  {
    id: 2,
    name: 'Harith Rahman',
    manager: 'Nizam Salleh',
    startDate: '2025-09-22',
    completedTasks: 3,
    totalTasks: 12,
    progress: 25,
    status: 'not_started'
  },
  {
    id: 3,
    name: 'Nur Iman',
    manager: 'Ahmed Fauzi',
    startDate: '2025-10-01',
    completedTasks: 1,
    totalTasks: 12,
    progress: 8,
    status: 'not_started'
  }
]

const tasks = [
  {
    id: 1,
    task: 'Grant Email & HRMS Access',
    assignee: 'IT Team',
    dueDate: '2025-09-16',
    type: 'System / Access Task',
    indicator: 'Onboarding',
    status: 'overdue'
  },
  {
    id: 2,
    task: 'Issue Laptop & ID Card',
    assignee: 'IT Team',
    dueDate: '2025-09-15',
    type: 'Asset Task',
    indicator: 'Onboarding',
    status: 'in_progress'
  },
  {
    id: 3,
    task: 'Day 1 Orientation',
    assignee: 'HR Team',
    dueDate: '2025-09-15',
    type: 'Meeting/Event Task',
    indicator: 'Onboarding',
    status: 'completed'
  },
  {
    id: 4,
    task: 'Read Employee Handbook',
    assignee: 'Aina Zulkifli',
    dueDate: '2025-09-18',
    type: 'Information/Document',
    indicator: 'Onboarding',
    status: 'pending'
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

.card-filters {
  display: flex;
  gap: var(--spacing-1);
}

.active-filter {
  background-color: var(--color-primary-600) !important;
  color: white !important;
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
</style>
