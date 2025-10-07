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
        <DataTable :value="preHires" responsiveLayout="scroll" stripedRows>
          <Column field="name" header="Candidate Name" style="min-width: 180px">
            <template #body="{ data }">
              <div class="candidate-name">
                <div class="candidate-avatar">{{ getInitials(data.name) }}</div>
                <span>{{ data.name }}</span>
              </div>
            </template>
          </Column>
          <Column field="position" header="Position" style="min-width: 180px"></Column>
          <Column field="department" header="Department" style="min-width: 130px"></Column>
          <Column field="startDate" header="Start Date" style="min-width: 130px"></Column>
          <Column field="emailStatus" header="Email Status" style="min-width: 160px">
            <template #body="{ data }">
              <StatusChip :status="data.emailStatus" />
            </template>
          </Column>
          <Column header="Workflow" style="min-width: 200px">
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
          <Column header="Appraisal Template" style="min-width: 200px">
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
          <Column header="Actions" style="min-width: 180px">
            <template #body="{ data }">
              <div class="action-buttons">
                <Button
                  v-if="data.emailStatus === 'not_issued'"
                  label="Create User"
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

    <!-- Create User Modal -->
    <Dialog v-model:visible="showCreateUserModal" header="Create User Account" :modal="true" style="width: 600px">
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
      <template #footer>
        <Button label="Cancel" severity="secondary" @click="showCreateUserModal = false" outlined />
        <Button label="Create & Start Onboarding" @click="submitCreateUser" />
      </template>
    </Dialog>
  </template>

<script setup>
import { ref } from 'vue'
import { useToast } from 'primevue/usetoast'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Dropdown from 'primevue/dropdown'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import Calendar from 'primevue/calendar'
import StatusChip from '../../../components/ui/StatusChip.vue'
import { preHires, workflows, appraisalTemplates, users } from '../../../data/mockData'

const toast = useToast()
const showCreateUserModal = ref(false)
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
  showCreateUserModal.value = true
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
  showCreateUserModal.value = false
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

.candidate-name {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-weight: 500;
}

.candidate-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, #155EEF, #0B4EDD);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
}

.workflow-select {
  width: 100%;
  font-size: 13px;
}

.action-buttons {
  display: flex;
  gap: var(--spacing-1);
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
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.required {
  color: var(--color-danger);
}

.w-full {
  width: 100%;
}
</style>
