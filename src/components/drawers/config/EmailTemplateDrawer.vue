<template>
  <Drawer
    v-model:visible="visible"
    position="right"
    :style="{ width: '720px' }"
    :modal="true"
    :dismissable="true"
    @hide="onClose"
  >
    <template #header>
      <div class="drawer-header">
        <div class="drawer-title-section">
          <span class="pi pi-envelope drawer-icon"></span>
          <div>
            <h2 class="drawer-title">{{ isEditing ? 'Edit Email Template' : 'View Email Template' }}</h2>
            <p class="drawer-subtitle">{{ template?.name }}</p>
          </div>
        </div>
        <div class="drawer-actions">
          <Button
            v-if="!isEditing"
            label="Edit"
            icon="pi pi-pencil"
            size="small"
            @click="isEditing = true"
          />
        </div>
      </div>
    </template>

    <div class="drawer-content" v-if="template">
      <!-- Template Info Card -->
      <div class="info-card">
        <div class="info-row">
          <div class="info-item">
            <span class="info-label">Status</span>
            <Tag
              :value="formData.status"
              :severity="formData.status === 'active' ? 'success' : 'warn'"
              :style="{ textTransform: 'capitalize' }"
            />
          </div>
          <div class="info-item">
            <span class="info-label">Last Updated</span>
            <span class="info-value">{{ formatDate(template.lastUpdated) }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Category</span>
            <Tag :value="template.category" severity="info" />
          </div>
        </div>
      </div>

      <!-- Template Form -->
      <div class="form-sections">
        <!-- Basic Information -->
        <div class="form-section">
          <div class="section-header">
            <span class="pi pi-info-circle"></span>
            <h3>Basic Information</h3>
          </div>
          <div class="section-content">
            <div class="form-field">
              <label class="form-label">Template Name <span class="required">*</span></label>
              <InputText
                v-model="formData.name"
                :disabled="!isEditing"
                placeholder="Enter template name"
                class="w-full"
              />
            </div>

            <div class="form-row">
              <div class="form-field">
                <label class="form-label">Status</label>
                <Dropdown
                  v-model="formData.status"
                  :options="statusOptions"
                  optionLabel="label"
                  optionValue="value"
                  :disabled="!isEditing"
                  class="w-full"
                />
              </div>
              <div class="form-field">
                <label class="form-label">Trigger Event</label>
                <Dropdown
                  v-model="formData.triggerEvent"
                  :options="triggerEventOptions"
                  optionLabel="label"
                  optionValue="value"
                  :disabled="!isEditing"
                  class="w-full"
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Email Subject -->
        <div class="form-section">
          <div class="section-header">
            <span class="pi pi-tag"></span>
            <h3>Email Subject</h3>
          </div>
          <div class="section-content">
            <div class="form-field">
              <label class="form-label">Subject Line <span class="required">*</span></label>
              <InputText
                v-model="formData.subject"
                :disabled="!isEditing"
                placeholder="Enter email subject"
                class="w-full"
              />
              <small class="form-help">Use variables like {{employee_name}}, {{company_name}}</small>
            </div>
          </div>
        </div>

        <!-- Email Body -->
        <div class="form-section">
          <div class="section-header">
            <span class="pi pi-file-edit"></span>
            <h3>Email Body</h3>
          </div>
          <div class="section-content">
            <div class="form-field">
              <label class="form-label">Content <span class="required">*</span></label>
              <Textarea
                v-model="formData.body"
                :disabled="!isEditing"
                placeholder="Enter email content..."
                rows="12"
                class="w-full template-textarea"
              />
            </div>
          </div>
        </div>

        <!-- Available Variables -->
        <div class="form-section variables-section">
          <div class="section-header">
            <span class="pi pi-code"></span>
            <h3>Available Variables</h3>
            <span class="section-badge">Click to copy</span>
          </div>
          <div class="section-content">
            <div class="variables-grid">
              <div
                v-for="variable in availableVariables"
                :key="variable.key"
                class="variable-chip"
                :class="{ 'disabled': !isEditing }"
                @click="isEditing && copyVariable(variable.key)"
                :title="variable.description"
              >
                <code>{{ variable.key }}</code>
                <span class="variable-desc">{{ variable.label }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Preview Section -->
        <div class="form-section preview-section">
          <div class="section-header">
            <span class="pi pi-eye"></span>
            <h3>Preview</h3>
            <Button
              label="Refresh Preview"
              icon="pi pi-refresh"
              size="small"
              text
              @click="refreshPreview"
            />
          </div>
          <div class="section-content">
            <div class="email-preview">
              <div class="preview-header">
                <div class="preview-meta">
                  <span class="preview-label">From:</span>
                  <span>noreply@company.com</span>
                </div>
                <div class="preview-meta">
                  <span class="preview-label">To:</span>
                  <span>{{ previewData.employee_email }}</span>
                </div>
                <div class="preview-meta">
                  <span class="preview-label">Subject:</span>
                  <span class="preview-subject">{{ renderPreview(formData.subject) }}</span>
                </div>
              </div>
              <div class="preview-body" v-html="renderPreviewHtml(formData.body)"></div>
            </div>
          </div>
        </div>

        <!-- Settings -->
        <div class="form-section">
          <div class="section-header">
            <span class="pi pi-cog"></span>
            <h3>Settings</h3>
          </div>
          <div class="section-content">
            <div class="settings-grid">
              <div class="setting-item">
                <div class="setting-info">
                  <span class="setting-label">Send Copy to HR</span>
                  <span class="setting-desc">CC HR team on this email</span>
                </div>
                <InputSwitch v-model="formData.ccHR" :disabled="!isEditing" />
              </div>
              <div class="setting-item">
                <div class="setting-info">
                  <span class="setting-label">Send Copy to Manager</span>
                  <span class="setting-desc">CC direct manager on this email</span>
                </div>
                <InputSwitch v-model="formData.ccManager" :disabled="!isEditing" />
              </div>
              <div class="setting-item">
                <div class="setting-info">
                  <span class="setting-label">Include Attachments</span>
                  <span class="setting-desc">Allow file attachments</span>
                </div>
                <InputSwitch v-model="formData.includeAttachments" :disabled="!isEditing" />
              </div>
              <div class="setting-item">
                <div class="setting-info">
                  <span class="setting-label">Track Opens</span>
                  <span class="setting-desc">Track when email is opened</span>
                </div>
                <InputSwitch v-model="formData.trackOpens" :disabled="!isEditing" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="drawer-footer">
        <Button label="Cancel" severity="secondary" outlined @click="onClose" />
        <Button
          v-if="isEditing"
          label="Save Template"
          icon="pi pi-check"
          :loading="saving"
          @click="saveTemplate"
        />
      </div>
    </template>
  </Drawer>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { useToast } from 'primevue/usetoast'
import Drawer from 'primevue/drawer'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import Dropdown from 'primevue/dropdown'
import InputSwitch from 'primevue/inputswitch'
import Tag from 'primevue/tag'

const props = defineProps({
  modelValue: Boolean,
  template: Object
})

const emit = defineEmits(['update:modelValue', 'save'])

const toast = useToast()
const visible = ref(false)
const isEditing = ref(false)
const saving = ref(false)

const formData = ref({
  name: '',
  status: 'active',
  triggerEvent: '',
  subject: '',
  body: '',
  ccHR: false,
  ccManager: false,
  includeAttachments: false,
  trackOpens: true
})

const previewData = {
  employee_name: 'John Smith',
  employee_email: 'john.smith@company.com',
  company_name: 'TimeTec Corporation',
  department: 'Engineering',
  position: 'Software Engineer',
  start_date: '2025-01-15',
  manager_name: 'Sarah Johnson',
  hr_contact: 'hr@company.com',
  portal_link: 'https://portal.company.com',
  task_name: 'Complete Documentation',
  due_date: '2025-01-20'
}

const statusOptions = [
  { label: 'Active', value: 'active' },
  { label: 'Draft', value: 'draft' },
  { label: 'Inactive', value: 'inactive' }
]

const triggerEventOptions = [
  { label: 'New Hire Created', value: 'new_hire' },
  { label: 'Task Assigned', value: 'task_assigned' },
  { label: 'Task Reminder', value: 'task_reminder' },
  { label: 'Task Overdue', value: 'task_overdue' },
  { label: 'Onboarding Complete', value: 'onboarding_complete' },
  { label: 'Offboarding Initiated', value: 'offboarding_initiated' },
  { label: 'Exit Interview Scheduled', value: 'exit_interview' },
  { label: 'Escalation Notice', value: 'escalation' }
]

const availableVariables = [
  { key: '{{employee_name}}', label: 'Employee Name', description: 'Full name of the employee' },
  { key: '{{employee_email}}', label: 'Employee Email', description: 'Email address of the employee' },
  { key: '{{company_name}}', label: 'Company Name', description: 'Name of the company' },
  { key: '{{department}}', label: 'Department', description: 'Employee department' },
  { key: '{{position}}', label: 'Position', description: 'Job position/title' },
  { key: '{{start_date}}', label: 'Start Date', description: 'Employment start date' },
  { key: '{{manager_name}}', label: 'Manager Name', description: 'Direct manager name' },
  { key: '{{hr_contact}}', label: 'HR Contact', description: 'HR email address' },
  { key: '{{portal_link}}', label: 'Portal Link', description: 'Link to employee portal' },
  { key: '{{task_name}}', label: 'Task Name', description: 'Name of the task' },
  { key: '{{due_date}}', label: 'Due Date', description: 'Task due date' }
]

watch(() => props.modelValue, (val) => {
  visible.value = val
  if (val && props.template) {
    loadTemplate()
  }
})

watch(visible, (val) => {
  emit('update:modelValue', val)
})

const loadTemplate = () => {
  if (props.template) {
    formData.value = {
      name: props.template.name,
      status: props.template.status,
      triggerEvent: props.template.triggerEvent || 'new_hire',
      subject: props.template.subject || '',
      body: props.template.body || '',
      ccHR: props.template.ccHR || false,
      ccManager: props.template.ccManager || false,
      includeAttachments: props.template.includeAttachments || false,
      trackOpens: props.template.trackOpens !== false
    }
    isEditing.value = false
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-MY', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const copyVariable = (variable) => {
  navigator.clipboard.writeText(variable)
  toast.add({
    severity: 'info',
    summary: 'Copied',
    detail: `${variable} copied to clipboard`,
    life: 2000
  })
}

const renderPreview = (text) => {
  if (!text) return ''
  let result = text
  Object.keys(previewData).forEach(key => {
    const regex = new RegExp(`{{${key}}}`, 'g')
    result = result.replace(regex, previewData[key])
  })
  return result
}

const renderPreviewHtml = (text) => {
  const rendered = renderPreview(text)
  return rendered.replace(/\n/g, '<br>')
}

const refreshPreview = () => {
  toast.add({
    severity: 'info',
    summary: 'Preview Updated',
    detail: 'Preview has been refreshed',
    life: 2000
  })
}

const saveTemplate = async () => {
  if (!formData.value.name || !formData.value.subject || !formData.value.body) {
    toast.add({
      severity: 'error',
      summary: 'Validation Error',
      detail: 'Please fill in all required fields',
      life: 3000
    })
    return
  }

  saving.value = true

  setTimeout(() => {
    emit('save', {
      ...props.template,
      ...formData.value,
      lastUpdated: new Date().toISOString().split('T')[0]
    })
    saving.value = false
    isEditing.value = false
    toast.add({
      severity: 'success',
      summary: 'Template Saved',
      detail: 'Email template has been updated successfully',
      life: 3000
    })
    onClose()
  }, 800)
}

const onClose = () => {
  visible.value = false
  isEditing.value = false
}
</script>

<style scoped>
.drawer-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.drawer-title-section {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
}

.drawer-icon {
  font-size: 24px;
  color: var(--color-primary-600);
}

.drawer-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.drawer-subtitle {
  font-size: 13px;
  color: var(--color-gray-500);
  margin: 2px 0 0 0;
}

.drawer-content {
  padding: var(--spacing-4);
}

.info-card {
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  padding: var(--spacing-3);
  margin-bottom: var(--spacing-4);
}

.info-row {
  display: flex;
  gap: var(--spacing-6);
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-label {
  font-size: 11px;
  font-weight: 600;
  color: var(--color-gray-500);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-value {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.form-sections {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-4);
}

.form-section {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.section-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  padding: var(--spacing-3);
  background-color: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
}

.section-header .pi {
  font-size: 16px;
  color: var(--color-primary-600);
}

.section-header h3 {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
  flex: 1;
}

.section-badge {
  font-size: 11px;
  color: var(--color-gray-500);
  background-color: var(--color-gray-100);
  padding: 2px 8px;
  border-radius: var(--radius-full);
}

.section-content {
  padding: var(--spacing-3);
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: var(--spacing-3);
}

.form-field:last-child {
  margin-bottom: 0;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-3);
}

.form-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-700);
}

.required {
  color: var(--color-danger);
}

.form-help {
  font-size: 12px;
  color: var(--color-gray-500);
}

.template-textarea {
  font-family: 'Monaco', 'Menlo', monospace;
  font-size: 13px;
  line-height: 1.6;
}

.variables-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.variable-chip {
  display: flex;
  flex-direction: column;
  padding: 8px 12px;
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s;
}

.variable-chip:not(.disabled):hover {
  background-color: var(--color-primary-50);
  border-color: var(--color-primary-200);
}

.variable-chip.disabled {
  cursor: default;
  opacity: 0.7;
}

.variable-chip code {
  font-size: 12px;
  font-weight: 600;
  color: var(--color-primary-700);
}

.variable-desc {
  font-size: 10px;
  color: var(--color-gray-500);
  margin-top: 2px;
}

.email-preview {
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
}

.preview-header {
  background-color: var(--color-gray-50);
  padding: var(--spacing-3);
  border-bottom: 1px solid var(--color-divider);
}

.preview-meta {
  display: flex;
  gap: var(--spacing-2);
  margin-bottom: 6px;
  font-size: 13px;
}

.preview-meta:last-child {
  margin-bottom: 0;
}

.preview-label {
  font-weight: 600;
  color: var(--color-gray-600);
  min-width: 60px;
}

.preview-subject {
  font-weight: 500;
  color: var(--color-gray-900);
}

.preview-body {
  padding: var(--spacing-4);
  font-size: 14px;
  line-height: 1.7;
  color: var(--color-gray-700);
  min-height: 150px;
  background-color: white;
}

.settings-grid {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.setting-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--spacing-2) var(--spacing-3);
  background-color: var(--color-gray-50);
  border-radius: var(--radius-md);
}

.setting-info {
  display: flex;
  flex-direction: column;
}

.setting-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.setting-desc {
  font-size: 11px;
  color: var(--color-gray-500);
}

.drawer-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-2);
  padding: var(--spacing-3) var(--spacing-4);
  border-top: 1px solid var(--color-divider);
  background-color: var(--color-gray-50);
}

.w-full {
  width: 100%;
}
</style>
