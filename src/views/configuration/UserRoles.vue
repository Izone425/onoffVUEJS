<template>
  <div class="page-container">
    <div class="page-header">
      <div class="header-content">
        <h1 class="text-h1">User Roles</h1>
        <p class="page-description">Configure role-based access control and manage permissions</p>
      </div>
      <div class="header-actions">
        <Button
          label="View Permission Matrix"
          icon="pi pi-table"
          outlined
          @click="showPermissionMatrix"
        />
        <Button
          label="Create Role"
          icon="pi pi-plus"
          @click="showCreateRole"
        />
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-section">
      <div class="stat-card">
        <div class="stat-icon roles-icon">
          <i class="pi pi-shield"></i>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ roles.length }}</span>
          <span class="stat-label">Total Roles</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon users-icon">
          <i class="pi pi-users"></i>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ totalUsers }}</span>
          <span class="stat-label">Total Users</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon modules-icon">
          <i class="pi pi-th-large"></i>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ permissionModules.length }}</span>
          <span class="stat-label">Permission Modules</span>
        </div>
      </div>
    </div>

    <!-- Roles Table -->
    <div class="content-card">
      <DataTable
        :value="roles"
        responsiveLayout="scroll"
        stripedRows
        :rowHover="true"
        class="roles-table"
      >
        <Column header="Role" style="min-width: 220px">
          <template #body="{ data }">
            <div class="role-cell">
              <div class="role-avatar" :class="getRoleColorClass(data.id)">
                {{ data.name.charAt(0) }}
              </div>
              <div class="role-info">
                <span class="role-name">{{ data.name }}</span>
                <span class="role-description">{{ data.description }}</span>
              </div>
            </div>
          </template>
        </Column>

        <Column header="Users" style="min-width: 100px">
          <template #body="{ data }">
            <div class="users-cell">
              <i class="pi pi-users"></i>
              <span>{{ data.userCount }}</span>
            </div>
          </template>
        </Column>

        <Column header="Permission Level" style="min-width: 200px">
          <template #body="{ data }">
            <div class="permission-level">
              <Tag
                :value="getPermissionLevel(data.permissions)"
                :severity="getPermissionSeverity(data.permissions)"
              />
              <span class="permission-summary">
                {{ getPermissionSummary(data.permissions) }}
              </span>
            </div>
          </template>
        </Column>

        <Column header="Last Updated" style="min-width: 130px">
          <template #body="{ data }">
            <span class="date-text">{{ formatDate(data.lastUpdated) }}</span>
          </template>
        </Column>

        <Column header="Actions" style="min-width: 180px">
          <template #body="{ data }">
            <div class="action-buttons">
              <Button
                icon="pi pi-eye"
                size="small"
                text
                rounded
                v-tooltip.top="'View Permissions'"
                @click="viewRolePermissions(data)"
              />
              <Button
                icon="pi pi-pencil"
                size="small"
                text
                rounded
                v-tooltip.top="'Edit Role'"
                @click="editRole(data)"
              />
              <Button
                icon="pi pi-copy"
                size="small"
                text
                rounded
                v-tooltip.top="'Duplicate Role'"
                @click="copyRole(data)"
              />
              <Button
                icon="pi pi-trash"
                size="small"
                text
                rounded
                severity="danger"
                v-tooltip.top="'Delete Role'"
                @click="confirmDeleteRole(data)"
                :disabled="isSystemRole(data.id)"
              />
            </div>
          </template>
        </Column>
      </DataTable>
    </div>

    <!-- Permission Matrix Dialog -->
    <PermissionMatrixDialog
      v-model:visible="permissionMatrixVisible"
      :editMode="permissionEditMode"
      :selectedRole="selectedRoleForPermission"
      @save="handlePermissionSave"
      @cancel="handlePermissionCancel"
    />

    <!-- Role Editor Dialog -->
    <RoleEditorDialog
      v-model:visible="roleEditorVisible"
      :role="selectedRoleForEdit"
      :isCopy="isCopyMode"
      @save="handleRoleSave"
      @cancel="handleRoleCancel"
    />

    <!-- Delete Confirmation Dialog -->
    <Dialog
      v-model:visible="deleteDialogVisible"
      header="Delete Role"
      :style="{ width: '400px' }"
      :modal="true"
    >
      <div class="delete-confirmation">
        <i class="pi pi-exclamation-triangle"></i>
        <div class="delete-message">
          <p>Are you sure you want to delete the role <strong>{{ roleToDelete?.name }}</strong>?</p>
          <p class="warning-text">This action cannot be undone. All users with this role will need to be reassigned.</p>
        </div>
      </div>
      <template #footer>
        <Button
          label="Cancel"
          icon="pi pi-times"
          severity="secondary"
          outlined
          @click="deleteDialogVisible = false"
        />
        <Button
          label="Delete"
          icon="pi pi-trash"
          severity="danger"
          @click="deleteRole"
        />
      </template>
    </Dialog>

    <!-- Toast -->
    <Toast />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Tag from 'primevue/tag'
import Dialog from 'primevue/dialog'
import Toast from 'primevue/toast'
import { useToast } from 'primevue/usetoast'
import { useUserStore } from '../../stores/userStore'
import PermissionMatrixDialog from '../../components/dialogs/PermissionMatrixDialog.vue'
import RoleEditorDialog from '../../components/dialogs/RoleEditorDialog.vue'

const toast = useToast()
const userStore = useUserStore()

const roles = computed(() => userStore.roles)
const permissionModules = computed(() => userStore.permissionModules)

// Computed stats
const totalUsers = computed(() => {
  return roles.value.reduce((sum, role) => sum + role.userCount, 0)
})

// Permission Matrix Dialog
const permissionMatrixVisible = ref(false)
const permissionEditMode = ref(false)
const selectedRoleForPermission = ref(null)

// Role Editor Dialog
const roleEditorVisible = ref(false)
const selectedRoleForEdit = ref(null)
const isCopyMode = ref(false)

// Delete Dialog
const deleteDialogVisible = ref(false)
const roleToDelete = ref(null)

// System roles that cannot be deleted
const systemRoles = ['hr-admin', 'staff']

const isSystemRole = (roleId) => systemRoles.includes(roleId)

const getRoleColorClass = (roleId) => {
  const colorMap = {
    'hr-admin': 'role-blue',
    'hr-coordinator': 'role-green',
    'manager': 'role-purple',
    'it-pic': 'role-orange',
    'staff': 'role-gray'
  }
  return colorMap[roleId] || 'role-cyan'
}

const getPermissionLevel = (permissions) => {
  const modules = Object.values(permissions)
  const fullAccess = modules.every(p => p.read && p.write)
  const readOnly = modules.every(p => !p.write)
  const noAccess = modules.every(p => !p.read && !p.write)

  if (fullAccess) return 'Full Access'
  if (noAccess) return 'No Access'
  if (readOnly && modules.some(p => p.read)) return 'Read Only'
  return 'Partial'
}

const getPermissionSeverity = (permissions) => {
  const level = getPermissionLevel(permissions)
  const severityMap = {
    'Full Access': 'success',
    'Read Only': 'info',
    'Partial': 'warning',
    'No Access': 'secondary'
  }
  return severityMap[level] || 'secondary'
}

const getPermissionSummary = (permissions) => {
  const modules = Object.entries(permissions)
  const readCount = modules.filter(([, p]) => p.read).length
  const writeCount = modules.filter(([, p]) => p.write).length
  return `${readCount} read, ${writeCount} write`
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-MY', {
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  })
}

// Actions
const showPermissionMatrix = () => {
  permissionEditMode.value = false
  selectedRoleForPermission.value = null
  permissionMatrixVisible.value = true
}

const viewRolePermissions = (role) => {
  permissionEditMode.value = true
  selectedRoleForPermission.value = role
  permissionMatrixVisible.value = true
}

const showCreateRole = () => {
  selectedRoleForEdit.value = null
  isCopyMode.value = false
  roleEditorVisible.value = true
}

const editRole = (role) => {
  selectedRoleForEdit.value = role
  isCopyMode.value = false
  roleEditorVisible.value = true
}

const copyRole = (role) => {
  selectedRoleForEdit.value = role
  isCopyMode.value = true
  roleEditorVisible.value = true
}

const confirmDeleteRole = (role) => {
  roleToDelete.value = role
  deleteDialogVisible.value = true
}

const deleteRole = () => {
  if (roleToDelete.value) {
    userStore.deleteRole(roleToDelete.value.id)
    toast.add({
      severity: 'success',
      summary: 'Role Deleted',
      detail: `${roleToDelete.value.name} has been deleted`,
      life: 3000
    })
    deleteDialogVisible.value = false
    roleToDelete.value = null
  }
}

// Event handlers
const handlePermissionSave = ({ roleId, permissions }) => {
  userStore.updateRolePermissions(roleId, permissions)
  permissionMatrixVisible.value = false
  toast.add({
    severity: 'success',
    summary: 'Permissions Updated',
    detail: 'Role permissions have been saved successfully',
    life: 3000
  })
}

const handlePermissionCancel = () => {
  permissionMatrixVisible.value = false
}

const handleRoleSave = (roleData) => {
  if (isCopyMode.value || !selectedRoleForEdit.value) {
    // Creating new role
    userStore.addRole(roleData)
    toast.add({
      severity: 'success',
      summary: 'Role Created',
      detail: `${roleData.name} has been created successfully`,
      life: 3000
    })
  } else {
    // Updating existing role
    userStore.updateRole(roleData)
    toast.add({
      severity: 'success',
      summary: 'Role Updated',
      detail: `${roleData.name} has been updated successfully`,
      life: 3000
    })
  }
  roleEditorVisible.value = false
}

const handleRoleCancel = () => {
  roleEditorVisible.value = false
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

.header-content {
  flex: 1;
}

.page-description {
  color: var(--color-gray-600);
  margin-top: var(--spacing-1);
}

.header-actions {
  display: flex;
  gap: var(--spacing-2);
}

/* Stats Section */
.stats-section {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-4);
  margin-bottom: var(--spacing-4);
}

.stat-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  padding: var(--spacing-4);
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon i {
  font-size: 20px;
  color: white;
}

.roles-icon {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
}

.users-icon {
  background: linear-gradient(135deg, #22c55e, #16a34a);
}

.modules-icon {
  background: linear-gradient(135deg, #a855f7, #7c3aed);
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: var(--color-gray-900);
}

.stat-label {
  font-size: 13px;
  color: var(--color-gray-600);
}

/* Content Card */
.content-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

/* Role Cell */
.role-cell {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
}

.role-avatar {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  color: white;
  flex-shrink: 0;
}

.role-blue { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
.role-green { background: linear-gradient(135deg, #22c55e, #16a34a); }
.role-purple { background: linear-gradient(135deg, #a855f7, #7c3aed); }
.role-orange { background: linear-gradient(135deg, #f97316, #ea580c); }
.role-gray { background: linear-gradient(135deg, #6b7280, #4b5563); }
.role-cyan { background: linear-gradient(135deg, #06b6d4, #0891b2); }

.role-info {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.role-name {
  font-weight: 600;
  color: var(--color-gray-900);
  font-size: 14px;
}

.role-description {
  font-size: 12px;
  color: var(--color-gray-500);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}

/* Users Cell */
.users-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--color-gray-700);
  font-size: 14px;
}

.users-cell i {
  font-size: 14px;
  color: var(--color-gray-500);
}

/* Permission Level */
.permission-level {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.permission-summary {
  font-size: 11px;
  color: var(--color-gray-500);
}

/* Date Text */
.date-text {
  font-size: 13px;
  color: var(--color-gray-600);
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 2px;
}

/* Delete Confirmation */
.delete-confirmation {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 0.5rem 0;
}

.delete-confirmation i {
  font-size: 32px;
  color: var(--color-danger);
  flex-shrink: 0;
}

.delete-message p {
  margin: 0 0 0.5rem;
  color: var(--color-gray-700);
}

.delete-message .warning-text {
  font-size: 13px;
  color: var(--color-gray-500);
  margin-bottom: 0;
}

/* Responsive */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: var(--spacing-3);
  }

  .header-actions {
    width: 100%;
  }

  .header-actions button {
    flex: 1;
  }

  .stats-section {
    grid-template-columns: 1fr;
  }
}
</style>
