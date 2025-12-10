<template>
  <Dialog
    :visible="visible"
    @update:visible="$emit('update:visible', $event)"
    :header="dialogTitle"
    :style="{ width: '600px' }"
    :modal="true"
    :closable="true"
    :draggable="false"
    class="role-editor-dialog"
  >
    <div class="editor-container">
      <!-- Role Basic Info -->
      <div class="form-section">
        <div class="section-header">
          <i class="pi pi-info-circle"></i>
          <span>Role Information</span>
        </div>
        <div class="form-fields">
          <div class="field-group">
            <label for="roleName" class="form-label">Role Name <span class="required">*</span></label>
            <InputText
              id="roleName"
              v-model="formData.name"
              placeholder="e.g., Department Head"
              class="w-full"
              :class="{ 'p-invalid': errors.name }"
            />
            <small v-if="errors.name" class="p-error">{{ errors.name }}</small>
          </div>

          <div class="field-group">
            <label for="roleDescription" class="form-label">Description <span class="required">*</span></label>
            <Textarea
              id="roleDescription"
              v-model="formData.description"
              placeholder="Describe the role's responsibilities and access level..."
              :rows="3"
              class="w-full"
              :class="{ 'p-invalid': errors.description }"
            />
            <small v-if="errors.description" class="p-error">{{ errors.description }}</small>
          </div>
        </div>
      </div>

      <!-- Permission Presets -->
      <div class="form-section">
        <div class="section-header">
          <i class="pi pi-sliders-h"></i>
          <span>Permission Preset</span>
        </div>
        <div class="preset-options">
          <div
            v-for="preset in presetOptions"
            :key="preset.id"
            class="preset-card"
            :class="{ 'selected': selectedPreset === preset.id }"
            @click="applyPreset(preset.id)"
          >
            <div class="preset-icon" :class="preset.colorClass">
              <i :class="['pi', preset.icon]"></i>
            </div>
            <div class="preset-info">
              <span class="preset-name">{{ preset.name }}</span>
              <span class="preset-description">{{ preset.description }}</span>
            </div>
            <div v-if="selectedPreset === preset.id" class="preset-check">
              <i class="pi pi-check-circle"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Permission Overview -->
      <div class="form-section">
        <div class="section-header">
          <i class="pi pi-shield"></i>
          <span>Permission Overview</span>
          <Button
            label="Customize"
            icon="pi pi-pencil"
            size="small"
            text
            @click="showPermissionEditor = true"
          />
        </div>
        <div class="permission-overview">
          <div class="overview-grid">
            <div
              v-for="module in permissionModules"
              :key="module.key"
              class="overview-item"
            >
              <div class="overview-module">
                <i :class="['pi', module.icon]"></i>
                <span>{{ module.label }}</span>
              </div>
              <Tag
                v-if="formData.permissions[module.key]?.read && formData.permissions[module.key]?.write"
                value="Full"
                severity="success"
                class="overview-tag"
              />
              <Tag
                v-else-if="formData.permissions[module.key]?.read"
                value="Read"
                severity="info"
                class="overview-tag"
              />
              <Tag
                v-else
                value="None"
                severity="secondary"
                class="overview-tag"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Inline Permission Editor (Expandable) -->
      <Transition name="slide">
        <div v-if="showPermissionEditor" class="permission-editor-inline">
          <div class="editor-title">
            <span>Fine-tune Permissions</span>
            <Button
              icon="pi pi-times"
              text
              rounded
              size="small"
              @click="showPermissionEditor = false"
            />
          </div>
          <div class="permissions-list">
            <div v-for="module in permissionModules" :key="module.key" class="permission-row">
              <div class="perm-module">
                <i :class="['pi', module.icon]"></i>
                <span>{{ module.label }}</span>
              </div>
              <div class="perm-toggles">
                <div class="toggle-item">
                  <span class="toggle-label">Read</span>
                  <InputSwitch
                    v-model="formData.permissions[module.key].read"
                    @change="onReadChange(module.key)"
                  />
                </div>
                <div class="toggle-item">
                  <span class="toggle-label">Write</span>
                  <InputSwitch
                    v-model="formData.permissions[module.key].write"
                    :disabled="!formData.permissions[module.key].read"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <Button
          label="Cancel"
          icon="pi pi-times"
          severity="secondary"
          outlined
          @click="handleCancel"
        />
        <Button
          :label="isEditing ? 'Update Role' : 'Create Role'"
          :icon="isEditing ? 'pi pi-check' : 'pi pi-plus'"
          @click="handleSubmit"
          :loading="saving"
        />
      </div>
    </template>
  </Dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Dialog from 'primevue/dialog'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import InputSwitch from 'primevue/inputswitch'
import Tag from 'primevue/tag'
import { useUserStore } from '../../stores/userStore'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  role: {
    type: Object,
    default: null
  },
  isCopy: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:visible', 'save', 'cancel'])

const userStore = useUserStore()
const permissionModules = computed(() => userStore.permissionModules)

const saving = ref(false)
const showPermissionEditor = ref(false)
const selectedPreset = ref(null)
const errors = ref({})

const isEditing = computed(() => props.role && !props.isCopy)

const dialogTitle = computed(() => {
  if (props.isCopy) return 'Copy Role'
  if (props.role) return 'Edit Role'
  return 'Create New Role'
})

// Initialize default permissions structure
const getDefaultPermissions = () => {
  const perms = {}
  const modules = userStore.permissionModules || []
  for (const module of modules) {
    perms[module.key] = { read: false, write: false }
  }
  return perms
}

const formData = ref({
  name: '',
  description: '',
  permissions: getDefaultPermissions()
})

// Preset options
const presetOptions = [
  {
    id: 'full-admin',
    name: 'Full Admin',
    description: 'Full access to all modules',
    icon: 'pi-crown',
    colorClass: 'preset-gold',
    permissions: () => {
      const perms = {}
      const modules = userStore.permissionModules || []
      for (const module of modules) {
        perms[module.key] = { read: true, write: true }
      }
      return perms
    }
  },
  {
    id: 'config-viewer',
    name: 'Config Viewer',
    description: 'Read-only access to configuration',
    icon: 'pi-eye',
    colorClass: 'preset-blue',
    permissions: () => {
      const perms = {}
      const modules = userStore.permissionModules || []
      for (const module of modules) {
        perms[module.key] = { read: true, write: false }
      }
      return perms
    }
  },
  {
    id: 'operation-only',
    name: 'Operation Only',
    description: 'Access to dashboards and tasks only',
    icon: 'pi-briefcase',
    colorClass: 'preset-green',
    permissions: () => {
      const perms = {}
      const modules = userStore.permissionModules || []
      for (const module of modules) {
        const isOperation = ['preHireEntry', 'dashboards', 'assignTasks'].includes(module.key)
        perms[module.key] = { read: isOperation, write: isOperation }
      }
      return perms
    }
  },
  {
    id: 'minimal',
    name: 'Minimal Access',
    description: 'Dashboard view only',
    icon: 'pi-user',
    colorClass: 'preset-gray',
    permissions: () => {
      const perms = {}
      const modules = userStore.permissionModules || []
      for (const module of modules) {
        perms[module.key] = {
          read: module.key === 'dashboards',
          write: false
        }
      }
      return perms
    }
  },
  {
    id: 'custom',
    name: 'Custom',
    description: 'Define permissions manually',
    icon: 'pi-sliders-v',
    colorClass: 'preset-purple',
    permissions: null
  }
]

// Define resetForm before watchers that use it
const resetForm = () => {
  formData.value = {
    name: '',
    description: '',
    permissions: getDefaultPermissions()
  }
  selectedPreset.value = null
}

// Watch for role prop changes
watch(() => props.role, (newRole) => {
  if (newRole) {
    formData.value = {
      id: props.isCopy ? null : newRole.id,
      name: props.isCopy ? `${newRole.name} (Copy)` : newRole.name,
      description: newRole.description,
      permissions: JSON.parse(JSON.stringify(newRole.permissions))
    }
    selectedPreset.value = 'custom'
  } else {
    resetForm()
  }
}, { immediate: true })

watch(() => props.visible, (isVisible) => {
  if (isVisible) {
    errors.value = {}
    showPermissionEditor.value = false
    if (!props.role) {
      resetForm()
    }
  }
})

const applyPreset = (presetId) => {
  selectedPreset.value = presetId
  const preset = presetOptions.find(p => p.id === presetId)
  if (preset && preset.permissions) {
    formData.value.permissions = preset.permissions()
  }
  if (presetId === 'custom') {
    showPermissionEditor.value = true
  }
}

const onReadChange = (moduleKey) => {
  if (!formData.value.permissions[moduleKey].read) {
    formData.value.permissions[moduleKey].write = false
  }
  selectedPreset.value = 'custom'
}

const validateForm = () => {
  errors.value = {}

  if (!formData.value.name.trim()) {
    errors.value.name = 'Role name is required'
  } else if (formData.value.name.length < 3) {
    errors.value.name = 'Role name must be at least 3 characters'
  }

  if (!formData.value.description.trim()) {
    errors.value.description = 'Description is required'
  }

  return Object.keys(errors.value).length === 0
}

const handleCancel = () => {
  emit('update:visible', false)
  emit('cancel')
}

const handleSubmit = async () => {
  if (!validateForm()) return

  saving.value = true
  try {
    const roleData = {
      id: formData.value.id || `role-${Date.now()}`,
      name: formData.value.name.trim(),
      description: formData.value.description.trim(),
      permissions: JSON.parse(JSON.stringify(formData.value.permissions)),
      userCount: props.role?.userCount || 0,
      lastUpdated: new Date().toISOString().split('T')[0]
    }

    emit('save', roleData)
    emit('update:visible', false)
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.editor-container {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-section {
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background-color: white;
  border-bottom: 1px solid var(--color-divider);
  font-weight: 500;
  font-size: 13px;
  color: var(--color-gray-900);
}

.section-header i {
  color: var(--color-gray-500);
}

.section-header button {
  margin-left: auto;
}

.form-fields {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.form-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-700);
}

.required {
  color: var(--color-danger);
}

.w-full {
  width: 100%;
}

.p-error {
  color: var(--color-danger);
  font-size: 12px;
}

/* Preset Options */
.preset-options {
  padding: 1rem;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
}

.preset-card {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  background-color: white;
  border: 2px solid var(--color-divider);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s ease;
}

.preset-card:hover {
  border-color: var(--color-primary);
  background-color: var(--color-primary-light);
}

.preset-card.selected {
  border-color: var(--color-primary);
  background-color: var(--color-primary-light);
}

.preset-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.preset-icon i {
  font-size: 16px;
  color: white;
}

.preset-gold { background: linear-gradient(135deg, #f59e0b, #d97706); }
.preset-blue { background: linear-gradient(135deg, #3b82f6, #2563eb); }
.preset-green { background: linear-gradient(135deg, #22c55e, #16a34a); }
.preset-gray { background: linear-gradient(135deg, #6b7280, #4b5563); }
.preset-purple { background: linear-gradient(135deg, #a855f7, #7c3aed); }

.preset-info {
  flex: 1;
  min-width: 0;
}

.preset-name {
  display: block;
  font-weight: 500;
  font-size: 13px;
  color: var(--color-gray-900);
}

.preset-description {
  display: block;
  font-size: 11px;
  color: var(--color-gray-500);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.preset-check {
  color: var(--color-primary);
}

.preset-check i {
  font-size: 18px;
}

/* Permission Overview */
.permission-overview {
  padding: 1rem;
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem;
}

.overview-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0.75rem;
  background-color: white;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-sm);
}

.overview-module {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
  color: var(--color-gray-700);
}

.overview-module i {
  font-size: 12px;
  color: var(--color-gray-500);
}

.overview-tag {
  font-size: 10px;
  padding: 2px 6px;
}

/* Inline Permission Editor */
.permission-editor-inline {
  background-color: white;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  margin-top: -0.5rem;
}

.editor-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  border-bottom: 1px solid var(--color-divider);
  font-weight: 500;
  font-size: 13px;
  color: var(--color-gray-900);
}

.permissions-list {
  padding: 0.5rem;
  max-height: 300px;
  overflow-y: auto;
}

.permission-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid var(--color-divider);
}

.permission-row:last-child {
  border-bottom: none;
}

.perm-module {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 13px;
  color: var(--color-gray-700);
}

.perm-module i {
  font-size: 14px;
  color: var(--color-gray-500);
}

.perm-toggles {
  display: flex;
  gap: 1.5rem;
}

.toggle-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.toggle-label {
  font-size: 12px;
  color: var(--color-gray-600);
}

/* Dialog Footer */
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

/* Transitions */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  opacity: 0;
  max-height: 0;
  overflow: hidden;
}

.slide-enter-to,
.slide-leave-from {
  opacity: 1;
  max-height: 400px;
}

/* Responsive */
@media (max-width: 600px) {
  .preset-options {
    grid-template-columns: 1fr;
  }

  .overview-grid {
    grid-template-columns: 1fr;
  }

  .perm-toggles {
    gap: 1rem;
  }
}
</style>
