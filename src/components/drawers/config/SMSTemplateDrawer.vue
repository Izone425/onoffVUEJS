<template>
  <Drawer
    v-model:visible="visible"
    position="right"
    :style="{ width: '600px' }"
    :modal="true"
    :dismissable="true"
    @hide="onClose"
  >
    <template #header>
      <div class="drawer-header">
        <div class="drawer-title-section">
          <span class="pi pi-comments drawer-icon"></span>
          <div>
            <h2 class="drawer-title">{{ isEditing ? 'Edit SMS Template' : 'View SMS Template' }}</h2>
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
            <span class="info-label">Characters</span>
            <span class="info-value" :class="charCountClass">{{ charCount }}/{{ maxChars }}</span>
          </div>
        </div>
      </div>

      <!-- SMS Form -->
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

        <!-- SMS Message -->
        <div class="form-section">
          <div class="section-header">
            <span class="pi pi-comment"></span>
            <h3>SMS Message</h3>
            <div class="char-counter" :class="charCountClass">
              {{ charCount }}/{{ maxChars }}
              <span v-if="smsSegments > 1" class="segments-badge">({{ smsSegments }} SMS)</span>
            </div>
          </div>
          <div class="section-content">
            <div class="form-field">
              <label class="form-label">Message Content <span class="required">*</span></label>
              <Textarea
                v-model="formData.message"
                :disabled="!isEditing"
                placeholder="Enter SMS message..."
                rows="6"
                class="w-full sms-textarea"
                :class="{ 'over-limit': charCount > maxChars }"
              />
              <div class="message-hints">
                <span class="hint-item">
                  <span class="pi pi-info-circle"></span>
                  Standard SMS: 160 chars | With variables: ~200 chars max recommended
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Available Variables -->
        <div class="form-section variables-section">
          <div class="section-header">
            <span class="pi pi-code"></span>
            <h3>Quick Variables</h3>
            <span class="section-badge">Click to insert</span>
          </div>
          <div class="section-content">
            <div class="variables-grid">
              <div
                v-for="variable in smsVariables"
                :key="variable.key"
                class="variable-chip"
                :class="{ 'disabled': !isEditing }"
                @click="isEditing && insertVariable(variable.key)"
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
            <span class="pi pi-mobile"></span>
            <h3>Phone Preview</h3>
          </div>
          <div class="section-content">
            <div class="phone-preview">
              <div class="phone-frame">
                <div class="phone-notch"></div>
                <div class="phone-screen">
                  <div class="sms-bubble">
                    <div class="sms-sender">TimeTec HR</div>
                    <div class="sms-text">{{ renderPreview(formData.message) || 'Your message will appear here...' }}</div>
                    <div class="sms-time">Just now</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Settings -->
        <div class="form-section">
          <div class="section-header">
            <span class="pi pi-cog"></span>
            <h3>Delivery Settings</h3>
          </div>
          <div class="section-content">
            <div class="settings-grid">
              <div class="setting-item">
                <div class="setting-info">
                  <span class="setting-label">Urgent Delivery</span>
                  <span class="setting-desc">Mark as high priority for immediate delivery</span>
                </div>
                <InputSwitch v-model="formData.urgent" :disabled="!isEditing" />
              </div>
              <div class="setting-item">
                <div class="setting-info">
                  <span class="setting-label">Delivery Report</span>
                  <span class="setting-desc">Request delivery confirmation</span>
                </div>
                <InputSwitch v-model="formData.deliveryReport" :disabled="!isEditing" />
              </div>
              <div class="setting-item">
                <div class="setting-info">
                  <span class="setting-label">Business Hours Only</span>
                  <span class="setting-desc">Send only during 9AM - 6PM</span>
                </div>
                <InputSwitch v-model="formData.businessHoursOnly" :disabled="!isEditing" />
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
const maxChars = 160

const formData = ref({
  name: '',
  status: 'active',
  triggerEvent: '',
  message: '',
  urgent: false,
  deliveryReport: true,
  businessHoursOnly: true
})

const previewData = {
  name: 'John',
  task: 'Complete Docs',
  due: 'Jan 20',
  company: 'TimeTec',
  link: 'bit.ly/abc123'
}

const statusOptions = [
  { label: 'Active', value: 'active' },
  { label: 'Draft', value: 'draft' },
  { label: 'Inactive', value: 'inactive' }
]

const triggerEventOptions = [
  { label: 'Task Due Reminder', value: 'task_reminder' },
  { label: 'Urgent Action Required', value: 'urgent_action' },
  { label: 'Task Overdue', value: 'task_overdue' },
  { label: 'Approval Needed', value: 'approval_needed' },
  { label: 'Welcome Message', value: 'welcome' },
  { label: 'Exit Reminder', value: 'exit_reminder' }
]

const smsVariables = [
  { key: '{{name}}', label: 'Name', description: 'First name of recipient' },
  { key: '{{task}}', label: 'Task', description: 'Task name (shortened)' },
  { key: '{{due}}', label: 'Due', description: 'Due date (short format)' },
  { key: '{{company}}', label: 'Company', description: 'Company name' },
  { key: '{{link}}', label: 'Link', description: 'Shortened URL' }
]

const charCount = computed(() => {
  return formData.value.message?.length || 0
})

const charCountClass = computed(() => {
  if (charCount.value > maxChars) return 'over-limit'
  if (charCount.value > maxChars * 0.9) return 'near-limit'
  return ''
})

const smsSegments = computed(() => {
  return Math.ceil(charCount.value / 160) || 1
})

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
      triggerEvent: props.template.triggerEvent || 'task_reminder',
      message: props.template.message || '',
      urgent: props.template.urgent || false,
      deliveryReport: props.template.deliveryReport !== false,
      businessHoursOnly: props.template.businessHoursOnly !== false
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

const insertVariable = (variable) => {
  formData.value.message += variable
  toast.add({
    severity: 'info',
    summary: 'Variable Inserted',
    detail: `${variable} added to message`,
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

const saveTemplate = async () => {
  if (!formData.value.name || !formData.value.message) {
    toast.add({
      severity: 'error',
      summary: 'Validation Error',
      detail: 'Please fill in all required fields',
      life: 3000
    })
    return
  }

  if (charCount.value > maxChars * 2) {
    toast.add({
      severity: 'warn',
      summary: 'Message Too Long',
      detail: 'Consider shortening your message for better delivery',
      life: 3000
    })
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
      detail: 'SMS template has been updated successfully',
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
  color: #16a34a;
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

.info-value.over-limit {
  color: #dc2626;
}

.info-value.near-limit {
  color: #f59e0b;
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
  color: #16a34a;
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

.char-counter {
  font-size: 12px;
  font-weight: 600;
  color: var(--color-gray-600);
  padding: 2px 8px;
  background-color: var(--color-gray-100);
  border-radius: var(--radius-full);
}

.char-counter.near-limit {
  background-color: #fef3c7;
  color: #92400e;
}

.char-counter.over-limit {
  background-color: #fee2e2;
  color: #991b1b;
}

.segments-badge {
  margin-left: 4px;
  opacity: 0.8;
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

.sms-textarea {
  font-family: inherit;
  font-size: 14px;
  line-height: 1.5;
}

.sms-textarea.over-limit {
  border-color: #dc2626;
}

.message-hints {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.hint-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  color: var(--color-gray-500);
}

.hint-item .pi {
  font-size: 12px;
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
  background-color: #dcfce7;
  border-color: #86efac;
}

.variable-chip.disabled {
  cursor: default;
  opacity: 0.7;
}

.variable-chip code {
  font-size: 12px;
  font-weight: 600;
  color: #16a34a;
}

.variable-desc {
  font-size: 10px;
  color: var(--color-gray-500);
  margin-top: 2px;
}

.phone-preview {
  display: flex;
  justify-content: center;
  padding: var(--spacing-3);
}

.phone-frame {
  width: 280px;
  background: linear-gradient(135deg, #1f2937, #111827);
  border-radius: 32px;
  padding: 12px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.phone-notch {
  width: 100px;
  height: 24px;
  background-color: #000;
  border-radius: 12px;
  margin: 0 auto 12px;
}

.phone-screen {
  background-color: #f3f4f6;
  border-radius: 20px;
  min-height: 200px;
  padding: var(--spacing-3);
}

.sms-bubble {
  background-color: #dcfce7;
  border-radius: 16px 16px 4px 16px;
  padding: var(--spacing-3);
  max-width: 90%;
  margin-left: auto;
}

.sms-sender {
  font-size: 10px;
  font-weight: 600;
  color: #16a34a;
  margin-bottom: 4px;
}

.sms-text {
  font-size: 13px;
  line-height: 1.4;
  color: #1f2937;
  word-break: break-word;
}

.sms-time {
  font-size: 10px;
  color: #6b7280;
  text-align: right;
  margin-top: 6px;
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
