<template>
  <Drawer v-model:visible="visible" position="right" :style="{ width: '600px' }" @hide="handleClose">
    <template #header>
      <div class="drawer-header">
        <div class="header-title-section">
          <span :class="['header-icon', 'pi', isViewMode ? 'pi-eye' : 'pi-clipboard']"></span>
          <div class="header-text">
            <h2 class="drawer-title">{{ drawerTitle }}</h2>
            <p class="drawer-subtitle">{{ drawerSubtitle }}</p>
          </div>
        </div>
      </div>
    </template>

    <div class="drawer-content">
      <!-- Copy Template From - Only show when creating new template (not in view mode) -->
      <div v-if="!editingTemplate && !isViewMode" class="form-section copy-section">
        <div class="field-group">
          <label for="copyFrom" class="form-label">Copy Template From</label>
          <Dropdown
            id="copyFrom"
            v-model="copyFromTemplateId"
            :options="templateOptions"
            optionLabel="label"
            optionValue="value"
            placeholder="Select template to copy (optional)"
            class="w-full dropdown-large"
            @change="handleCopyFromTemplate"
          >
            <template #value="slotProps">
              <div v-if="slotProps.value && slotProps.value !== 'none'">
                <div class="template-option">
                  <span :class="['indicator-badge', getIndicatorClass(slotProps.value)]">
                    {{ getIndicatorLabel(slotProps.value) }}
                  </span>
                  <span>{{ templateOptions.find(t => t.value === slotProps.value)?.label }}</span>
                </div>
              </div>
              <span v-else-if="slotProps.value === 'none'">Start from scratch</span>
              <span v-else>{{ slotProps.placeholder }}</span>
            </template>
            <template #option="slotProps">
              <div v-if="slotProps.option.value === 'none'" class="template-option-simple">
                <span>{{ slotProps.option.label }}</span>
              </div>
              <div v-else class="template-option">
                <span :class="['indicator-badge', slotProps.option.indicator === 'onboarding' ? 'onboarding' : 'offboarding']">
                  {{ slotProps.option.indicator }}
                </span>
                <span>{{ slotProps.option.label }}</span>
              </div>
            </template>
          </Dropdown>
          <small class="form-help">Select an existing template to copy its settings and description as a starting point</small>
        </div>
      </div>

      <!-- Task Basic Information -->
      <div class="form-section">
        <div class="field-group">
          <label for="taskName" class="form-label">Task Name <span class="required" v-if="!isViewMode">*</span></label>
          <InputText
            id="taskName"
            v-model="formData.taskName"
            placeholder="Enter a descriptive task name"
            class="w-full"
            :disabled="isViewMode"
          />
        </div>

        <div class="grid-2">
          <div class="field-group">
            <label for="taskType" class="form-label">Task Type <span class="required" v-if="!isViewMode">*</span></label>
            <Dropdown
              id="taskType"
              v-model="formData.taskType"
              :options="taskTypeOptions"
              optionLabel="label"
              optionValue="value"
              placeholder="Select type"
              class="w-full"
              :disabled="isViewMode"
            />
          </div>

          <div class="field-group">
            <label for="category" class="form-label">Category <span class="required" v-if="!isViewMode">*</span></label>
            <Dropdown
              id="category"
              v-model="formData.category"
              :options="categoryOptions"
              optionLabel="label"
              optionValue="value"
              placeholder="Select category"
              class="w-full"
              :disabled="isViewMode"
            />
          </div>
        </div>
      </div>

      <!-- Task Details -->
      <div class="form-section">
        <div class="field-group">
          <label for="description" class="form-label">Description</label>
          <Textarea
            id="description"
            v-model="formData.description"
            placeholder="Provide a detailed description of what this task involves, including any specific instructions or requirements..."
            :rows="4"
            class="w-full"
            :disabled="isViewMode"
          />
          <small class="form-help" v-if="!isViewMode">Detailed descriptions help users understand task requirements</small>
        </div>

        <div class="field-group">
          <label for="url" class="form-label">URL/Link</label>
          <InputText
            id="url"
            v-model="formData.url"
            type="url"
            placeholder="https://example.com/resources"
            class="w-full"
            :disabled="isViewMode"
          />
          <small class="form-help" v-if="!isViewMode">Optional: Add a relevant URL or link for this task (documentation, forms, training materials, etc.)</small>
        </div>
      </div>

      <!-- Information Fields Settings - Only for Information Form -->
      <InformationFieldsConfig
        v-if="formData.taskType === 'information'"
        v-model:selectedFields="selectedInformationFields"
        v-model:requirements="informationRequirements"
        :viewMode="isViewMode"
      />

      <!-- Document Upload Settings - Only for Document Form -->
      <DocumentUploadConfig
        v-if="formData.taskType === 'document'"
        v-model:requiresUpload="requiresDocumentUpload"
        v-model:selectedDocuments="selectedDocuments"
        v-model:requirements="documentRequirements"
        :viewMode="isViewMode"
      />

      <!-- System/Access Configuration - Only for System/Access -->
      <SystemAccessConfig
        v-if="formData.taskType === 'system'"
        v-model:systemAccesses="systemAccesses"
        :viewMode="isViewMode"
      />

      <!-- Asset Configuration - Only for Asset -->
      <AssetConfig
        v-if="formData.taskType === 'asset'"
        v-model:assetItems="assetItems"
        :viewMode="isViewMode"
      />

      <!-- Questionnaire Configuration - Only for Questionnaire -->
      <QuestionnaireConfig
        v-if="formData.taskType === 'questionnaire'"
        v-model:questions="questionnaireQuestions"
        :taskName="formData.taskName"
        :viewMode="isViewMode"
      />

      <!-- Checklist Configuration - Only for Checklist -->
      <ChecklistConfig
        v-if="formData.taskType === 'checklist'"
        v-model:checklistItems="checklistItems"
        :viewMode="isViewMode"
      />

      <!-- Active Status -->
      <div class="form-section">
        <div class="field-group">
          <div class="active-status-toggle">
            <div class="toggle-content">
              <label class="form-label">Active Status</label>
              <p class="toggle-description">{{ isViewMode ? 'Template is ' + (formData.isActive ? 'active' : 'inactive') : 'Enable this template for use in onboarding/offboarding workflows' }}</p>
            </div>
            <InputSwitch v-model="formData.isActive" :disabled="isViewMode" />
          </div>
        </div>
      </div>

    </div>

    <template #footer>
      <div class="drawer-footer">
        <div v-if="!isViewMode">
          <Button label="Reset Form" severity="secondary" @click="resetForm" text />
        </div>
        <div v-else></div>
        <div class="footer-actions">
          <Button :label="isViewMode ? 'Close' : 'Cancel'" severity="secondary" @click="handleClose" outlined />
          <Button v-if="!isViewMode" :label="editingTemplate ? 'Update Template' : 'Create Template'" @click="handleSave" :loading="saving" />
        </div>
      </div>
    </template>
  </Drawer>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Drawer from 'primevue/drawer'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import Dropdown from 'primevue/dropdown'
import InputSwitch from 'primevue/inputswitch'
import InformationFieldsConfig from './config/InformationFieldsConfig.vue'
import DocumentUploadConfig from './config/DocumentUploadConfig.vue'
import SystemAccessConfig from './config/SystemAccessConfig.vue'
import AssetConfig from './config/AssetConfig.vue'
import QuestionnaireConfig from './config/QuestionnaireConfig.vue'
import ChecklistConfig from './config/ChecklistConfig.vue'
import { taskTemplates } from '../../data/mockData'

const props = defineProps({
  visible: Boolean,
  editingTemplate: Object
})

const emit = defineEmits(['update:visible', 'save'])

const visible = computed({
  get: () => props.visible,
  set: (val) => emit('update:visible', val)
})

// Computed for view mode
const isViewMode = computed(() => props.editingTemplate?.viewMode === true)

// Computed for drawer title based on mode
const drawerTitle = computed(() => {
  if (isViewMode.value) return 'View Task Template'
  if (props.editingTemplate) return 'Edit Task Template'
  return 'Create New Task Template'
})

// Computed for drawer subtitle based on mode
const drawerSubtitle = computed(() => {
  if (isViewMode.value) return 'View the task template details and requirements in read-only mode.'
  if (props.editingTemplate) return 'Edit the selected task template with its specific settings and requirements.'
  return 'Design a new task template with specific requirements, documents, and configuration settings.'
})

const saving = ref(false)
const copyFromTemplateId = ref(null)

const formData = ref({
  taskName: '',
  taskType: '',
  category: '',
  description: '',
  url: '',
  isActive: true
})

const selectedInformationFields = ref([])
const informationRequirements = ref({})
const requiresDocumentUpload = ref(false)
const selectedDocuments = ref([])
const documentRequirements = ref({})
const systemAccesses = ref([])
const assetItems = ref([])
const questionnaireQuestions = ref([])
const checklistItems = ref([])

const taskTypeOptions = [
  { label: 'General Task', value: 'general' },
  { label: 'Document Form', value: 'document' },
  { label: 'Information Form', value: 'information' },
  { label: 'Questionnaire', value: 'questionnaire' },
  { label: 'Meeting/Event', value: 'meeting' },
  { label: 'System/Access', value: 'system' },
  { label: 'Asset', value: 'asset' },
  { label: 'Checklist', value: 'checklist' }
]

const categoryOptions = [
  { label: 'Onboarding', value: 'onboarding' },
  { label: 'Offboarding', value: 'offboarding' }
]

const templateOptions = computed(() => {
  return [
    { label: 'Start from scratch', value: 'none' },
    ...taskTemplates.map(t => ({
      label: t.name,
      value: t.id,
      indicator: t.indicator
    }))
  ]
})

const getIndicatorClass = (templateId) => {
  const template = taskTemplates.find(t => t.id === templateId)
  return template?.indicator === 'onboarding' ? 'onboarding' : 'offboarding'
}

const getIndicatorLabel = (templateId) => {
  const template = taskTemplates.find(t => t.id === templateId)
  return template?.indicator || ''
}

const handleCopyFromTemplate = () => {
  if (copyFromTemplateId.value && copyFromTemplateId.value !== 'none') {
    const template = taskTemplates.find(t => t.id === copyFromTemplateId.value)
    if (template) {
      formData.value.description = template.description || ''
      formData.value.taskType = template.type
      formData.value.category = template.indicator
    }
  }
}

const handleClose = () => {
  visible.value = false
  resetForm()
}

const handleSave = () => {
  saving.value = true
  setTimeout(() => {
    emit('save', {
      ...formData.value,
      selectedInformationFields: selectedInformationFields.value,
      informationRequirements: informationRequirements.value,
      requiresDocumentUpload: requiresDocumentUpload.value,
      selectedDocuments: selectedDocuments.value,
      documentRequirements: documentRequirements.value,
      systemAccesses: systemAccesses.value,
      assetItems: assetItems.value,
      questionnaireQuestions: questionnaireQuestions.value,
      checklistItems: checklistItems.value
    })
    saving.value = false
    handleClose()
  }, 1000)
}

const resetForm = () => {
  formData.value = {
    taskName: '',
    taskType: '',
    category: '',
    description: '',
    url: '',
    isActive: true
  }
  copyFromTemplateId.value = null
  selectedInformationFields.value = []
  informationRequirements.value = {}
  requiresDocumentUpload.value = false
  selectedDocuments.value = []
  documentRequirements.value = {}
  systemAccesses.value = []
  assetItems.value = []
  questionnaireQuestions.value = []
  checklistItems.value = []
}

watch(() => props.editingTemplate, (template) => {
  if (template) {
    formData.value = {
      taskName: template.name,
      taskType: template.type,
      category: template.indicator,
      description: template.description || '',
      url: template.url || '',
      isActive: template.isActive !== undefined ? template.isActive : true
    }
  } else {
    // Reset form when creating new template
    resetForm()
  }
}, { immediate: true })

// Watch visibility to reset form when drawer opens for new template
watch(() => props.visible, (isVisible) => {
  if (isVisible && !props.editingTemplate) {
    resetForm()
  }
})
</script>

<style scoped>
.drawer-header {
  padding: 0;
}

.header-title-section {
  display: flex;
  gap: var(--spacing-2);
  align-items: flex-start;
}

.header-icon {
  width: 40px;
  height: 40px;
  background-color: var(--color-gray-100);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-gray-700);
  font-size: 18px;
  flex-shrink: 0;
}

.header-icon.pi-eye {
  background-color: #dbeafe;
  color: #1d4ed8;
}

.header-text {
  flex: 1;
}

.drawer-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
  line-height: 1.3;
}

.drawer-subtitle {
  font-size: 13px;
  color: var(--color-gray-600);
  margin: 4px 0 0 0;
  line-height: 1.4;
}

.drawer-content {
  padding: var(--spacing-4);
  max-height: calc(100vh - 180px);
  overflow-y: auto;
}

.form-section {
  margin-bottom: var(--spacing-5);
  padding-bottom: var(--spacing-5);
  border-bottom: 1px solid var(--color-divider);
}

.form-section:last-child {
  border-bottom: none;
}

.field-group {
  margin-bottom: var(--spacing-4);
}

.field-group:last-child {
  margin-bottom: 0;
}

.form-label {
  display: block;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
  margin-bottom: var(--spacing-1);
}

.required {
  color: var(--color-danger);
}

.form-help {
  display: block;
  font-size: 12px;
  color: var(--color-gray-500);
  margin-top: var(--spacing-1);
}

.grid-2 {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-4);
}

.copy-section {
  background-color: #f9fafb;
  padding: var(--spacing-4);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-divider);
}

.dropdown-large :deep(.p-dropdown) {
  min-height: 44px;
}

.template-option {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.template-option-simple {
  font-weight: 500;
}

.indicator-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: var(--radius-sm);
  font-size: 11px;
  font-weight: 600;
  text-transform: capitalize;
  border: 1px solid;
}

.indicator-badge.onboarding {
  background-color: #dbeafe;
  color: #1e40af;
  border-color: #bfdbfe;
}

.indicator-badge.offboarding {
  background-color: #fee2e2;
  color: #991b1b;
  border-color: #fecaca;
}

.drawer-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--spacing-2);
  padding: var(--spacing-3);
  border-top: 1px solid var(--color-divider);
}

.footer-actions {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.active-status-toggle {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-3);
  background-color: #f0f9ff;
  border: 1px solid #bfdbfe;
  border-radius: var(--radius-md);
}

.toggle-content {
  flex: 1;
}

.toggle-description {
  font-size: 12px;
  color: var(--color-gray-600);
  margin: 4px 0 0 0;
}

.w-full {
  width: 100%;
}
</style>
