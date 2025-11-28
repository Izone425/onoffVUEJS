<template>
    <div class="page-container">
      <div class="page-header">
        <div>
          <h1 class="text-h1">Pre-Hire Entry</h1>
          <p class="page-description">Manage next pre-hires and create user accounts</p>
        </div>
        <Button label="Import from ATS" icon="pi pi-download" outlined />
      </div>

      <div class="content-card">
        <DataTable :value="preHires" responsiveLayout="scroll" stripedRows class="compact-table">
          <Column field="name" header="Employee" style="width: 200px">
            <template #body="{ data }">
              <div class="employee-name">
                <div class="employee-avatar">{{ getInitials(data.name) }}</div>
                <div class="employee-info">
                  <div class="employee-name-text">{{ data.name }}</div>
                </div>
              </div>
            </template>
          </Column>
          <Column field="position" header="Designation" style="width: 150px"></Column>
          <Column field="department" header="Department" style="width: 130px"></Column>
          <Column field="startDate" header="Start Date" style="width: 110px"></Column>
          <Column header="Workflow" style="width: 220px">
            <template #body="{ data }">
              <Dropdown
                v-model="data.workflowId"
                :options="onboardingWorkflows"
                optionLabel="name"
                optionValue="id"
                placeholder="Select workflow"
                class="workflow-select"
              />
            </template>
          </Column>
          <Column header="Appraisal" style="width: 200px">
            <template #body="{ data }">
              <Dropdown
                v-model="data.appraisalTemplateId"
                :options="appraisalTemplates"
                optionLabel="name"
                optionValue="id"
                placeholder="Select template"
                class="workflow-select"
              />
            </template>
          </Column>
          <Column header="Actions" style="width: 140px; text-align: center">
            <template #body="{ data }">
              <div class="action-buttons">
                <Button
                  v-if="data.emailStatus === 'not_issued'"
                  label="Create"
                  size="small"
                  @click="createUser(data)"
                />
                <Button
                  v-else
                  label="View"
                  size="small"
                  outlined
                  @click="viewCandidate(data)"
                />
              </div>
            </template>
          </Column>
        </DataTable>
      </div>
    </div>

    <!-- Create User Drawer -->
    <Sidebar v-model:visible="showCreateUserDrawer" position="right" class="create-user-drawer">
      <template #header>
        <div class="drawer-header">
          <h2 class="drawer-title">Create User Account</h2>
        </div>
      </template>

      <div class="drawer-content">
        <div class="form-container">
          <div class="form-field">
            <label class="form-label">Full Name <span class="required">*</span></label>
            <InputText v-model="newUser.fullName" class="w-full" />
          </div>
          <div class="form-field">
            <label class="form-label">Personal Email <span class="required">*</span></label>
            <InputText v-model="newUser.personalEmail" type="email" class="w-full" />
          </div>
          <div class="form-field">
            <label class="form-label">Temporary ID <span class="required">*</span></label>
            <InputText v-model="newUser.temporaryId" class="w-full" />
          </div>
          <div class="form-field">
            <label class="form-label">Hire Date <span class="required">*</span></label>
            <Calendar v-model="newUser.hireDate" dateFormat="yy-mm-dd" showIcon class="w-full" />
          </div>
          <div class="form-field">
            <label class="form-label">Manager <span class="required">*</span></label>
            <Dropdown v-model="newUser.manager" :options="managers" optionLabel="name" placeholder="Select manager" class="w-full" />
          </div>
          <div class="form-field">
            <label class="form-label">Location <span class="required">*</span></label>
            <InputText v-model="newUser.location" class="w-full" placeholder="e.g., HQ" />
          </div>
          <div class="form-field">
            <label class="form-label">Work Type <span class="required">*</span></label>
            <Dropdown v-model="newUser.workType" :options="workTypes" placeholder="Select work type" class="w-full" />
          </div>
        </div>
      </div>

      <div class="drawer-footer">
        <Button label="Cancel" severity="secondary" @click="showCreateUserDrawer = false" outlined />
        <Button label="Create & Start Onboarding" @click="submitCreateUser" />
      </div>
    </Sidebar>
  </template>

<script setup>
import { ref } from 'vue'
import { useToast } from 'primevue/usetoast'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dropdown from 'primevue/dropdown'
import Sidebar from 'primevue/sidebar'
import InputText from 'primevue/inputtext'
import Calendar from 'primevue/calendar'
import { preHires, workflows, appraisalTemplates, users } from '../../../data/mockData'

const toast = useToast()
const showCreateUserDrawer = ref(false)
const selectedCandidate = ref(null)

const onboardingWorkflows = workflows.filter(w => w.category === 'onboarding')
const managers = users.filter(u => u.role.includes('Manager'))
const workTypes = ['Onsite', 'Hybrid', 'Remote']

const newUser = ref({
  fullName: '',
  personalEmail: '',
  temporaryId: '',
  hireDate: null,
  manager: null,
  location: '',
  workType: null
})

const getInitials = (name) => {
  return name.split(' ').map(n => n[0]).join('').toUpperCase()
}

const createUser = (candidate) => {
  selectedCandidate.value = candidate
  newUser.value.fullName = candidate.name
  newUser.value.personalEmail = candidate.personalEmail
  newUser.value.hireDate = new Date(candidate.startDate)
  showCreateUserDrawer.value = true
}

const viewCandidate = (candidate) => {
  console.log('View candidate:', candidate)
}

const submitCreateUser = () => {
  // Simulate API call
  toast.add({
    severity: 'success',
    summary: 'User Created',
    detail: `User account created for ${newUser.value.fullName}`,
    life: 3000
  })
  showCreateUserDrawer.value = false
}
</script>

<style scoped>
.page-container {
  max-width: 1600px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: var(--spacing-3);
}

.page-description {
  color: var(--color-gray-600);
  margin-top: var(--spacing-1);
  font-size: 13px;
}

.content-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: auto;
}

.employee-name {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.employee-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.employee-name-text {
  font-weight: 500;
  font-size: 13px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
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
  flex-shrink: 0;
}

.workflow-select {
  width: 100%;
  font-size: 12px;
}

.action-buttons {
  display: flex;
  gap: var(--spacing-1);
  justify-content: center;
}

.compact-table {
  font-size: 13px;
}

.compact-table :deep(th) {
  padding: 10px 8px !important;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}

.compact-table :deep(td) {
  padding: 10px 8px !important;
  font-size: 13px;
}

.compact-table :deep(.p-datatable-tbody > tr > td) {
  border-bottom: 1px solid var(--color-divider);
}

.form-container {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
  padding: var(--spacing-3) 0;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-1);
}

.form-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.required {
  color: var(--color-danger);
}

.w-full {
  width: 100%;
}

/* Drawer Styles */
.create-user-drawer {
  width: 500px !important;
}

.drawer-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.drawer-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.drawer-content {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-3) 0;
}

.drawer-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-2);
  padding-top: var(--spacing-3);
  border-top: 1px solid var(--color-divider);
  margin-top: auto;
}
</style>
