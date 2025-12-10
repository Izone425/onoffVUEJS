<template>
  <Dialog
    :visible="visible"
    @update:visible="$emit('update:visible', $event)"
    :header="dialogTitle"
    :style="{ width: '900px' }"
    :modal="true"
    :closable="true"
    :draggable="false"
    class="permission-matrix-dialog"
  >
    <div class="matrix-container">
      <!-- View Mode: All Roles Comparison -->
      <div v-if="!editMode && !selectedRole" class="matrix-comparison">
        <table class="permission-table">
          <thead>
            <tr>
              <th class="module-header">Module</th>
              <th v-for="role in roles" :key="role.id" class="role-header">
                <div class="role-header-content">
                  <span class="role-name">{{ role.name }}</span>
                  <span class="role-users">{{ role.userCount }} users</span>
                </div>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="module in permissionModules" :key="module.key" class="module-row">
              <td class="module-cell">
                <div class="module-info">
                  <i :class="['pi', module.icon]"></i>
                  <span>{{ module.label }}</span>
                </div>
              </td>
              <td v-for="role in roles" :key="role.id" class="permission-cell">
                <div class="permission-badges">
                  <Tag
                    v-if="role.permissions[module.key]?.read && role.permissions[module.key]?.write"
                    value="Full"
                    severity="success"
                    class="perm-tag"
                  />
                  <Tag
                    v-else-if="role.permissions[module.key]?.read"
                    value="Read"
                    severity="info"
                    class="perm-tag"
                  />
                  <Tag
                    v-else
                    value="None"
                    severity="secondary"
                    class="perm-tag none"
                  />
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Edit Mode: Single Role Permission Editor -->
      <div v-else-if="editMode && selectedRole" class="matrix-editor">
        <div class="editor-header">
          <div class="role-info">
            <div class="role-badge" :class="getRoleColorClass(selectedRole.id)">
              {{ selectedRole.name.charAt(0) }}
            </div>
            <div class="role-details">
              <h3>{{ selectedRole.name }}</h3>
              <p>{{ selectedRole.description }}</p>
            </div>
          </div>
          <div class="quick-actions">
            <Button
              label="Grant All"
              icon="pi pi-check-circle"
              size="small"
              severity="success"
              outlined
              @click="grantAllPermissions"
            />
            <Button
              label="Revoke All"
              icon="pi pi-times-circle"
              size="small"
              severity="danger"
              outlined
              @click="revokeAllPermissions"
            />
          </div>
        </div>

        <div class="permissions-grid">
          <div v-for="module in permissionModules" :key="module.key" class="permission-card">
            <div class="card-header">
              <div class="module-icon">
                <i :class="['pi', module.icon]"></i>
              </div>
              <div class="module-name">{{ module.label }}</div>
            </div>
            <div class="card-body">
              <div class="permission-toggles">
                <div class="toggle-row">
                  <label class="toggle-label">
                    <i class="pi pi-eye"></i>
                    <span>Read Access</span>
                  </label>
                  <InputSwitch
                    v-model="editedPermissions[module.key].read"
                    @change="onPermissionChange(module.key, 'read')"
                  />
                </div>
                <div class="toggle-row">
                  <label class="toggle-label">
                    <i class="pi pi-pencil"></i>
                    <span>Write Access</span>
                  </label>
                  <InputSwitch
                    v-model="editedPermissions[module.key].write"
                    :disabled="!editedPermissions[module.key].read"
                    @change="onPermissionChange(module.key, 'write')"
                  />
                </div>
              </div>
              <div class="permission-summary">
                <Tag
                  v-if="editedPermissions[module.key].read && editedPermissions[module.key].write"
                  value="Full Access"
                  severity="success"
                />
                <Tag
                  v-else-if="editedPermissions[module.key].read"
                  value="Read Only"
                  severity="info"
                />
                <Tag
                  v-else
                  value="No Access"
                  severity="secondary"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Changes Summary -->
        <div v-if="hasChanges" class="changes-summary">
          <div class="summary-header">
            <i class="pi pi-info-circle"></i>
            <span>Pending Changes</span>
          </div>
          <div class="changes-list">
            <div v-for="change in changesList" :key="change.module" class="change-item">
              <span class="change-module">{{ change.moduleLabel }}</span>
              <span class="change-arrow">→</span>
              <Tag :value="change.newValue" :severity="change.severity" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <Button
          v-if="!editMode"
          label="Close"
          icon="pi pi-times"
          severity="secondary"
          outlined
          @click="$emit('update:visible', false)"
        />
        <template v-else>
          <Button
            label="Cancel"
            icon="pi pi-times"
            severity="secondary"
            outlined
            @click="cancelEdit"
          />
          <Button
            label="Save Changes"
            icon="pi pi-check"
            :disabled="!hasChanges"
            @click="saveChanges"
          />
        </template>
      </div>
    </template>
  </Dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Dialog from 'primevue/dialog'
import Button from 'primevue/button'
import Tag from 'primevue/tag'
import InputSwitch from 'primevue/inputswitch'
import { useUserStore } from '../../stores/userStore'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  editMode: {
    type: Boolean,
    default: false
  },
  selectedRole: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:visible', 'save', 'cancel'])

const userStore = useUserStore()
const roles = computed(() => userStore.roles)
const permissionModules = computed(() => userStore.permissionModules)

const editedPermissions = ref({})
const originalPermissions = ref({})

const dialogTitle = computed(() => {
  if (props.editMode && props.selectedRole) {
    return `Edit Permissions - ${props.selectedRole.name}`
  }
  return 'Permission Matrix'
})

// Initialize edited permissions when role changes
watch(() => props.selectedRole, (newRole) => {
  if (newRole && props.editMode) {
    // Deep clone permissions
    editedPermissions.value = JSON.parse(JSON.stringify(newRole.permissions))
    originalPermissions.value = JSON.parse(JSON.stringify(newRole.permissions))
  }
}, { immediate: true })

watch(() => props.visible, (isVisible) => {
  if (isVisible && props.selectedRole && props.editMode) {
    editedPermissions.value = JSON.parse(JSON.stringify(props.selectedRole.permissions))
    originalPermissions.value = JSON.parse(JSON.stringify(props.selectedRole.permissions))
  }
})

const getRoleColorClass = (roleId) => {
  const colorMap = {
    'hr-admin': 'role-blue',
    'hr-coordinator': 'role-green',
    'manager': 'role-purple',
    'it-pic': 'role-orange',
    'staff': 'role-gray'
  }
  return colorMap[roleId] || 'role-gray'
}

const hasChanges = computed(() => {
  if (!props.editMode || !props.selectedRole) return false
  return JSON.stringify(editedPermissions.value) !== JSON.stringify(originalPermissions.value)
})

const changesList = computed(() => {
  if (!hasChanges.value) return []

  const changes = []
  for (const module of permissionModules.value) {
    const orig = originalPermissions.value[module.key]
    const edited = editedPermissions.value[module.key]

    if (JSON.stringify(orig) !== JSON.stringify(edited)) {
      let newValue = 'No Access'
      let severity = 'secondary'

      if (edited.read && edited.write) {
        newValue = 'Full Access'
        severity = 'success'
      } else if (edited.read) {
        newValue = 'Read Only'
        severity = 'info'
      }

      changes.push({
        module: module.key,
        moduleLabel: module.label,
        newValue,
        severity
      })
    }
  }
  return changes
})

const onPermissionChange = (moduleKey, permType) => {
  // If read is disabled, also disable write
  if (permType === 'read' && !editedPermissions.value[moduleKey].read) {
    editedPermissions.value[moduleKey].write = false
  }
}

const grantAllPermissions = () => {
  for (const module of permissionModules.value) {
    editedPermissions.value[module.key] = { read: true, write: true }
  }
}

const revokeAllPermissions = () => {
  for (const module of permissionModules.value) {
    editedPermissions.value[module.key] = { read: false, write: false }
  }
}

const cancelEdit = () => {
  editedPermissions.value = JSON.parse(JSON.stringify(originalPermissions.value))
  emit('cancel')
}

const saveChanges = () => {
  emit('save', {
    roleId: props.selectedRole.id,
    permissions: JSON.parse(JSON.stringify(editedPermissions.value))
  })
}
</script>

<style scoped>
.permission-matrix-dialog :deep(.p-dialog-content) {
  padding: 0;
}

.matrix-container {
  padding: 1.5rem;
}

/* Comparison Table Styles */
.matrix-comparison {
  overflow-x: auto;
}

.permission-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.permission-table th,
.permission-table td {
  padding: 0.75rem 1rem;
  text-align: center;
  border-bottom: 1px solid var(--color-divider);
}

.module-header {
  text-align: left !important;
  font-weight: 600;
  color: var(--color-gray-700);
  background-color: var(--color-gray-50);
  min-width: 180px;
}

.role-header {
  background-color: var(--color-gray-50);
  min-width: 120px;
}

.role-header-content {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.role-header-content .role-name {
  font-weight: 600;
  color: var(--color-gray-900);
  font-size: 12px;
}

.role-header-content .role-users {
  font-size: 11px;
  color: var(--color-gray-500);
  font-weight: 400;
}

.module-row:hover {
  background-color: var(--color-gray-50);
}

.module-cell {
  text-align: left !important;
}

.module-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.module-info i {
  color: var(--color-gray-500);
  font-size: 14px;
}

.permission-cell {
  padding: 0.5rem;
}

.permission-badges {
  display: flex;
  justify-content: center;
}

.perm-tag {
  font-size: 11px;
  padding: 2px 8px;
}

.perm-tag.none {
  opacity: 0.5;
}

/* Editor Styles */
.matrix-editor {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--color-divider);
}

.role-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.role-badge {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 600;
  color: white;
}

.role-blue { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
.role-green { background: linear-gradient(135deg, #22c55e, #16a34a); }
.role-purple { background: linear-gradient(135deg, #a855f7, #7c3aed); }
.role-orange { background: linear-gradient(135deg, #f97316, #ea580c); }
.role-gray { background: linear-gradient(135deg, #6b7280, #4b5563); }

.role-details h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--color-gray-900);
}

.role-details p {
  margin: 4px 0 0;
  font-size: 13px;
  color: var(--color-gray-600);
}

.quick-actions {
  display: flex;
  gap: 0.5rem;
}

.permissions-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.permission-card {
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  background-color: white;
  border-bottom: 1px solid var(--color-divider);
}

.module-icon {
  width: 32px;
  height: 32px;
  background-color: var(--color-gray-100);
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
}

.module-icon i {
  font-size: 14px;
  color: var(--color-gray-600);
}

.module-name {
  font-weight: 500;
  color: var(--color-gray-900);
  font-size: 13px;
}

.card-body {
  padding: 1rem;
}

.permission-toggles {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.toggle-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.toggle-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 13px;
  color: var(--color-gray-700);
}

.toggle-label i {
  font-size: 12px;
  color: var(--color-gray-500);
}

.permission-summary {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid var(--color-divider);
  display: flex;
  justify-content: center;
}

/* Changes Summary */
.changes-summary {
  background-color: #fffbeb;
  border: 1px solid #fcd34d;
  border-radius: var(--radius-md);
  padding: 1rem;
}

.summary-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  color: #92400e;
  font-size: 13px;
  margin-bottom: 0.75rem;
}

.summary-header i {
  font-size: 14px;
}

.changes-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.change-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background-color: white;
  padding: 0.25rem 0.75rem;
  border-radius: var(--radius-sm);
  font-size: 12px;
}

.change-module {
  font-weight: 500;
  color: var(--color-gray-700);
}

.change-arrow {
  color: var(--color-gray-400);
}

/* Dialog Footer */
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

/* Responsive */
@media (max-width: 768px) {
  .permissions-grid {
    grid-template-columns: 1fr;
  }

  .editor-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }

  .quick-actions {
    width: 100%;
  }

  .quick-actions button {
    flex: 1;
  }
}
</style>
