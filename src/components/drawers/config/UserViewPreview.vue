<template>
  <div class="user-view-preview">
    <!-- Toggle Header -->
    <div class="preview-toggle-header" @click="isExpanded = !isExpanded">
      <div class="toggle-left">
        <div class="toggle-icon">
          <span class="pi pi-eye"></span>
        </div>
        <div class="toggle-text">
          <label class="form-label">User View Preview</label>
          <p class="toggle-description">Preview how this task will appear to employees</p>
        </div>
      </div>
      <div class="toggle-right">
        <span class="view-mode-badge" :class="viewMode">{{ viewMode === 'ultra' ? 'Ultra Detail' : 'Standard' }}</span>
        <span :class="['pi', isExpanded ? 'pi-chevron-up' : 'pi-chevron-down']"></span>
      </div>
    </div>

    <!-- Preview Content -->
    <div v-if="isExpanded" class="preview-content">
      <!-- View Mode Toggle -->
      <div class="view-mode-toggle">
        <Button
          :label="'Standard View'"
          :outlined="viewMode === 'ultra'"
          size="small"
          @click="viewMode = 'standard'"
        />
        <Button
          :label="'Ultra Detail'"
          :outlined="viewMode === 'standard'"
          size="small"
          @click="viewMode = 'ultra'"
        />
      </div>

      <!-- Preview Card -->
      <div class="preview-card" :class="{ 'ultra-mode': viewMode === 'ultra' }">
        <!-- Task Header -->
        <div class="task-header">
          <div class="task-icon" :class="getTaskTypeClass(taskType)">
            <span :class="['pi', getTaskTypeIcon(taskType)]"></span>
          </div>
          <div class="task-info">
            <h3 class="task-title">{{ taskName || 'Task Name' }}</h3>
            <div class="task-badges">
              <span class="task-type-badge" :class="getTaskTypeClass(taskType)">
                {{ getTaskTypeLabel(taskType) }}
              </span>
              <span class="category-badge" :class="category">
                {{ category || 'Category' }}
              </span>
            </div>
          </div>
          <div class="task-status">
            <span class="status-badge pending">Pending</span>
          </div>
        </div>

        <!-- Task Description -->
        <div v-if="description || viewMode === 'ultra'" class="task-description">
          <p>{{ description || 'Task description will appear here...' }}</p>
        </div>

        <!-- Ultra Detail: Task Metadata -->
        <div v-if="viewMode === 'ultra'" class="task-metadata">
          <div class="metadata-item">
            <span class="pi pi-calendar"></span>
            <span>Due: <strong>3 days after assignment</strong></span>
          </div>
          <div class="metadata-item">
            <span class="pi pi-user"></span>
            <span>Assigned by: <strong>HR Department</strong></span>
          </div>
          <div v-if="url" class="metadata-item">
            <span class="pi pi-link"></span>
            <a :href="url" target="_blank" class="task-link">{{ url }}</a>
          </div>
        </div>

        <!-- Document Upload Section -->
        <div v-if="taskType === 'document' && requiresDocumentUpload && selectedDocuments.length > 0" class="preview-section">
          <div class="section-header">
            <span class="pi pi-upload"></span>
            <h4>Documents to Upload</h4>
          </div>
          <div class="document-list">
            <div v-for="docId in selectedDocuments" :key="docId" class="document-item">
              <div class="document-icon">
                <span class="pi pi-file"></span>
              </div>
              <div class="document-info">
                <span class="document-name">{{ getDocumentLabel(docId) }}</span>
                <span v-if="viewMode === 'ultra'" class="document-hint">Click to upload or drag & drop</span>
              </div>
              <span :class="['requirement-badge', documentRequirements[docId] !== false ? 'required' : 'optional']">
                {{ documentRequirements[docId] !== false ? 'Required' : 'Optional' }}
              </span>
              <div class="upload-action">
                <Button icon="pi pi-upload" size="small" outlined disabled />
              </div>
            </div>
          </div>
          <div v-if="viewMode === 'ultra'" class="upload-hint">
            <span class="pi pi-info-circle"></span>
            <span>Supported formats: PDF, JPG, PNG (Max 10MB per file)</span>
          </div>
        </div>

        <!-- Information Fields Section -->
        <div v-if="taskType === 'information' && selectedInformationFields.length > 0" class="preview-section">
          <div class="section-header">
            <span class="pi pi-pencil"></span>
            <h4>Information to Provide</h4>
          </div>
          <div class="information-form">
            <div v-for="fieldId in selectedInformationFields" :key="fieldId" class="form-field">
              <label class="field-label">
                {{ getFieldLabel(fieldId) }}
                <span v-if="informationRequirements[fieldId] !== false" class="required-marker">*</span>
              </label>
              <InputText
                :placeholder="getFieldPlaceholder(fieldId)"
                class="w-full"
                disabled
              />
              <small v-if="viewMode === 'ultra' && informationRequirements[fieldId] !== false" class="field-hint required">
                This field is required
              </small>
            </div>
          </div>
        </div>

        <!-- Questionnaire Section -->
        <div v-if="taskType === 'questionnaire' && questions.length > 0" class="preview-section">
          <div class="section-header">
            <span class="pi pi-question-circle"></span>
            <h4>Questions to Answer</h4>
          </div>
          <div class="questionnaire-preview">
            <div v-for="(question, index) in questions" :key="question.id" class="question-item">
              <div class="question-number">Q{{ index + 1 }}</div>
              <div class="question-content">
                <p class="question-text">
                  {{ question.question || `Question ${index + 1}` }}
                  <span v-if="question.required" class="required-marker">*</span>
                </p>

                <!-- Text Response -->
                <div v-if="question.responseType === 'text-single'" class="response-input">
                  <InputText placeholder="Your answer..." class="w-full" disabled />
                </div>
                <div v-else-if="question.responseType === 'text-multiline'" class="response-input">
                  <Textarea placeholder="Your answer..." :rows="3" class="w-full" disabled />
                </div>

                <!-- Picklist Response -->
                <div v-else-if="question.responseType === 'picklist-single' || question.responseType === 'picklist-multiple'" class="response-options">
                  <div v-for="option in question.picklistOptions" :key="option.id" class="option-item">
                    <RadioButton v-if="question.responseType === 'picklist-single'" disabled />
                    <Checkbox v-else :binary="true" disabled />
                    <span class="option-text">{{ option.text || 'Option' }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div v-if="viewMode === 'ultra'" class="questionnaire-footer">
            <span class="pi pi-info-circle"></span>
            <span>{{ questions.filter(q => q.required).length }} required question(s) out of {{ questions.length }} total</span>
          </div>
        </div>

        <!-- System Access Section -->
        <div v-if="taskType === 'system' && systemAccesses.length > 0" class="preview-section">
          <div class="section-header">
            <span class="pi pi-cog"></span>
            <h4>System Access Requests</h4>
          </div>
          <div class="system-list">
            <div v-for="system in systemAccesses" :key="system.id" class="system-item">
              <div class="system-icon">
                <span class="pi pi-desktop"></span>
              </div>
              <div class="system-info">
                <span class="system-name">{{ system.name }}</span>
                <span v-if="viewMode === 'ultra'" class="system-description">{{ system.description }}</span>
              </div>
              <div class="system-status">
                <span class="status-badge pending">Pending Setup</span>
              </div>
            </div>
          </div>
          <div v-if="viewMode === 'ultra'" class="system-note">
            <span class="pi pi-info-circle"></span>
            <span>Access will be granted by the assigned IT administrator</span>
          </div>
        </div>

        <!-- Asset Section -->
        <div v-if="taskType === 'asset' && assetItems.length > 0" class="preview-section">
          <div class="section-header">
            <span class="pi pi-box"></span>
            <h4>Assets to Receive/Return</h4>
          </div>
          <div class="asset-list">
            <div v-for="asset in assetItems" :key="asset.id" class="asset-item">
              <div class="asset-icon">
                <span class="pi pi-briefcase"></span>
              </div>
              <div class="asset-info">
                <span class="asset-name">{{ asset.name }}</span>
                <span v-if="viewMode === 'ultra'" class="asset-description">{{ asset.description }}</span>
                <div v-if="viewMode === 'ultra' && asset.handoverLetter" class="handover-badge">
                  <span class="pi pi-file-edit"></span>
                  <span>Handover letter required</span>
                </div>
              </div>
              <div class="asset-status">
                <span class="status-badge pending">Pending</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Checklist Section -->
        <div v-if="taskType === 'checklist' && checklistItems.length > 0" class="preview-section">
          <div class="section-header">
            <span class="pi pi-check-square"></span>
            <h4>Checklist Items</h4>
          </div>
          <div class="checklist-preview">
            <div v-for="(item, index) in checklistItems" :key="item.id" class="checklist-item">
              <Checkbox :binary="true" disabled />
              <div class="checklist-content">
                <span class="checklist-title">{{ item.title }}</span>
                <span v-if="viewMode === 'ultra'" class="checklist-description">{{ item.description }}</span>
                <div v-if="viewMode === 'ultra' && item.pic !== 'None'" class="checklist-pic">
                  <span class="pi pi-user"></span>
                  <span>Assigned to: {{ item.pic }}</span>
                </div>
              </div>
            </div>
          </div>
          <div v-if="viewMode === 'ultra'" class="checklist-progress">
            <div class="progress-bar">
              <div class="progress-fill" style="width: 0%"></div>
            </div>
            <span class="progress-text">0 of {{ checklistItems.length }} completed</span>
          </div>
        </div>

        <!-- General Task Section -->
        <div v-if="taskType === 'general' || (!taskType && viewMode === 'ultra')" class="preview-section">
          <div class="section-header">
            <span class="pi pi-file"></span>
            <h4>Task Actions</h4>
          </div>
          <div class="general-task-actions">
            <div class="action-hint">
              <span class="pi pi-info-circle"></span>
              <span>Review the task details and mark as complete when finished</span>
            </div>
            <div class="action-buttons">
              <Button label="Mark as Complete" severity="success" disabled />
              <Button label="Request Help" severity="secondary" outlined disabled />
            </div>
          </div>
        </div>

        <!-- Meeting Section -->
        <div v-if="taskType === 'meeting'" class="preview-section">
          <div class="section-header">
            <span class="pi pi-calendar"></span>
            <h4>Meeting/Event Details</h4>
          </div>
          <div class="meeting-preview">
            <div class="meeting-info">
              <div class="meeting-item">
                <span class="pi pi-clock"></span>
                <span>Time: <strong>To be scheduled</strong></span>
              </div>
              <div class="meeting-item">
                <span class="pi pi-map-marker"></span>
                <span>Location: <strong>TBD</strong></span>
              </div>
              <div v-if="viewMode === 'ultra'" class="meeting-item">
                <span class="pi pi-users"></span>
                <span>Attendees: <strong>You + Organizer</strong></span>
              </div>
            </div>
            <div v-if="viewMode === 'ultra'" class="meeting-actions">
              <Button label="Add to Calendar" icon="pi pi-calendar-plus" outlined disabled />
            </div>
          </div>
        </div>

        <!-- Task Footer -->
        <div class="task-footer">
          <div class="footer-actions">
            <Button
              v-if="taskType !== 'general'"
              label="Submit"
              severity="success"
              disabled
            />
            <Button
              v-else
              label="Mark Complete"
              severity="success"
              disabled
            />
            <Button label="Save Draft" severity="secondary" outlined disabled />
          </div>
          <div v-if="viewMode === 'ultra'" class="footer-hint">
            <span class="pi pi-info-circle"></span>
            <span>All required fields must be completed before submission</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import Checkbox from 'primevue/checkbox'
import RadioButton from 'primevue/radiobutton'

const props = defineProps({
  taskName: { type: String, default: '' },
  taskType: { type: String, default: '' },
  category: { type: String, default: '' },
  description: { type: String, default: '' },
  url: { type: String, default: '' },
  // Document
  requiresDocumentUpload: { type: Boolean, default: false },
  selectedDocuments: { type: Array, default: () => [] },
  documentRequirements: { type: Object, default: () => ({}) },
  // Information
  selectedInformationFields: { type: Array, default: () => [] },
  informationRequirements: { type: Object, default: () => ({}) },
  // Questionnaire
  questions: { type: Array, default: () => [] },
  // System
  systemAccesses: { type: Array, default: () => [] },
  // Asset
  assetItems: { type: Array, default: () => [] },
  // Checklist
  checklistItems: { type: Array, default: () => [] }
})

const isExpanded = ref(false)
const viewMode = ref('standard') // 'standard' or 'ultra'

const predefinedDocuments = [
  { id: 'ic', label: 'IC (Identity Card)' },
  { id: 'passport', label: 'Passport' },
  { id: 'work-permit', label: 'Work Permit' },
  { id: 'medical-checkup', label: 'Medical Checkup Report' },
  { id: 'driving-license', label: 'Driving License' },
  { id: 'ea-form', label: 'EA Form' },
  { id: 'tp3', label: 'TP3' }
]

const informationFieldCategories = {
  personal: {
    fields: [
      { id: 'full-name', label: 'Full Name', placeholder: 'Enter your full legal name' },
      { id: 'email', label: 'Email Address', placeholder: 'example@company.com' },
      { id: 'phone', label: 'Phone Number', placeholder: '+60 12-345 6789' },
      { id: 'date-of-birth', label: 'Date of Birth', placeholder: 'DD/MM/YYYY' },
      { id: 'nationality', label: 'Nationality', placeholder: 'Select your nationality' },
      { id: 'marital-status', label: 'Marital Status', placeholder: 'Select status' }
    ]
  },
  contact: {
    fields: [
      { id: 'address', label: 'Home Address', placeholder: 'Enter your full address' },
      { id: 'emergency-contact', label: 'Emergency Contact', placeholder: 'Contact name' },
      { id: 'emergency-phone', label: 'Emergency Phone', placeholder: '+60 12-345 6789' }
    ]
  },
  financial: {
    fields: [
      { id: 'bank-account', label: 'Bank Account Number', placeholder: 'Enter account number' },
      { id: 'bank-name', label: 'Bank Name', placeholder: 'Select your bank' },
      { id: 'tax-id', label: 'Tax ID Number', placeholder: 'Enter tax ID' }
    ]
  },
  payroll: {
    fields: [
      { id: 'tax-identification', label: 'Tax Identification Number', placeholder: 'Enter TIN' },
      { id: 'epf-number', label: 'EPF Number', placeholder: 'Enter EPF number' },
      { id: 'socso-number', label: 'Socso Number', placeholder: 'Enter Socso number' }
    ]
  }
}

const getDocumentLabel = (docId) => {
  const doc = predefinedDocuments.find(d => d.id === docId)
  if (doc) return doc.label
  // Handle custom documents
  if (docId.startsWith('custom-')) {
    return docId.replace('custom-', '').replace(/-/g, ' ')
  }
  return docId
}

const getAllFields = () => {
  return Object.values(informationFieldCategories).flatMap(cat => cat.fields)
}

const getFieldLabel = (fieldId) => {
  const field = getAllFields().find(f => f.id === fieldId)
  if (field) return field.label
  // Handle custom fields
  if (fieldId.startsWith('custom-field-')) {
    return fieldId.replace('custom-field-', '').replace(/-/g, ' ')
  }
  return fieldId
}

const getFieldPlaceholder = (fieldId) => {
  const field = getAllFields().find(f => f.id === fieldId)
  return field?.placeholder || 'Enter value...'
}

const getTaskTypeIcon = (type) => {
  const icons = {
    general: 'pi-file',
    document: 'pi-upload',
    information: 'pi-pencil',
    questionnaire: 'pi-question-circle',
    meeting: 'pi-calendar',
    system: 'pi-cog',
    asset: 'pi-box',
    checklist: 'pi-check-square'
  }
  return icons[type] || 'pi-file'
}

const getTaskTypeLabel = (type) => {
  const labels = {
    general: 'General Task',
    document: 'Document Form',
    information: 'Information Form',
    questionnaire: 'Questionnaire',
    meeting: 'Meeting/Event',
    system: 'System/Access',
    asset: 'Asset',
    checklist: 'Checklist'
  }
  return labels[type] || 'Task'
}

const getTaskTypeClass = (type) => {
  const classes = {
    general: 'type-general',
    document: 'type-document',
    information: 'type-information',
    questionnaire: 'type-questionnaire',
    meeting: 'type-meeting',
    system: 'type-system',
    asset: 'type-asset',
    checklist: 'type-checklist'
  }
  return classes[type] || 'type-general'
}
</script>

<style scoped>
.user-view-preview {
  margin-top: var(--spacing-4);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
}

.preview-toggle-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-3);
  background-color: #f0f9ff;
  border-bottom: 1px solid #bfdbfe;
  cursor: pointer;
  transition: background-color 0.2s;
}

.preview-toggle-header:hover {
  background-color: #e0f2fe;
}

.toggle-left {
  display: flex;
  gap: var(--spacing-2);
  align-items: center;
}

.toggle-icon {
  width: 36px;
  height: 36px;
  background-color: #3b82f6;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 16px;
}

.toggle-text .form-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.toggle-description {
  font-size: 12px;
  color: var(--color-gray-600);
  margin: 2px 0 0 0;
}

.toggle-right {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.view-mode-badge {
  padding: 4px 10px;
  border-radius: var(--radius-sm);
  font-size: 11px;
  font-weight: 600;
  text-transform: capitalize;
}

.view-mode-badge.standard {
  background-color: #e5e7eb;
  color: #374151;
}

.view-mode-badge.ultra {
  background-color: #7c3aed;
  color: white;
}

.preview-content {
  padding: var(--spacing-4);
  background-color: #f8fafc;
}

.view-mode-toggle {
  display: flex;
  gap: var(--spacing-2);
  margin-bottom: var(--spacing-4);
}

.preview-card {
  background-color: white;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.preview-card.ultra-mode {
  border-color: #7c3aed;
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.15);
}

/* Task Header */
.task-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
  padding: var(--spacing-4);
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-bottom: 1px solid var(--color-divider);
}

.task-icon {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.task-icon.type-general { background-color: #e5e7eb; color: #374151; }
.task-icon.type-document { background-color: #dbeafe; color: #1d4ed8; }
.task-icon.type-information { background-color: #d1fae5; color: #059669; }
.task-icon.type-questionnaire { background-color: #fef3c7; color: #d97706; }
.task-icon.type-meeting { background-color: #fce7f3; color: #db2777; }
.task-icon.type-system { background-color: #e0e7ff; color: #4f46e5; }
.task-icon.type-asset { background-color: #fed7aa; color: #ea580c; }
.task-icon.type-checklist { background-color: #ccfbf1; color: #0d9488; }

.task-info {
  flex: 1;
}

.task-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0 0 8px 0;
}

.task-badges {
  display: flex;
  gap: var(--spacing-2);
}

.task-type-badge, .category-badge {
  padding: 4px 10px;
  border-radius: var(--radius-sm);
  font-size: 11px;
  font-weight: 600;
  text-transform: capitalize;
}

.task-type-badge.type-general { background-color: #e5e7eb; color: #374151; }
.task-type-badge.type-document { background-color: #dbeafe; color: #1d4ed8; }
.task-type-badge.type-information { background-color: #d1fae5; color: #059669; }
.task-type-badge.type-questionnaire { background-color: #fef3c7; color: #d97706; }
.task-type-badge.type-meeting { background-color: #fce7f3; color: #db2777; }
.task-type-badge.type-system { background-color: #e0e7ff; color: #4f46e5; }
.task-type-badge.type-asset { background-color: #fed7aa; color: #ea580c; }
.task-type-badge.type-checklist { background-color: #ccfbf1; color: #0d9488; }

.category-badge.onboarding { background-color: #dbeafe; color: #1e40af; }
.category-badge.offboarding { background-color: #fee2e2; color: #991b1b; }

.task-status {
  flex-shrink: 0;
}

.status-badge {
  padding: 6px 12px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
}

.status-badge.pending {
  background-color: #fef3c7;
  color: #92400e;
}

/* Task Description */
.task-description {
  padding: var(--spacing-3) var(--spacing-4);
  border-bottom: 1px solid var(--color-divider);
}

.task-description p {
  margin: 0;
  font-size: 14px;
  color: var(--color-gray-600);
  line-height: 1.5;
}

/* Task Metadata (Ultra Mode) */
.task-metadata {
  padding: var(--spacing-3) var(--spacing-4);
  background-color: #f8fafc;
  border-bottom: 1px solid var(--color-divider);
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-3);
}

.metadata-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
  font-size: 13px;
  color: var(--color-gray-600);
}

.metadata-item .pi {
  color: var(--color-gray-400);
}

.task-link {
  color: var(--primary-color);
  text-decoration: none;
}

.task-link:hover {
  text-decoration: underline;
}

/* Preview Sections */
.preview-section {
  padding: var(--spacing-4);
  border-bottom: 1px solid var(--color-divider);
}

.preview-section:last-child {
  border-bottom: none;
}

.section-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  margin-bottom: var(--spacing-3);
}

.section-header .pi {
  color: var(--primary-color);
  font-size: 16px;
}

.section-header h4 {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

/* Document List */
.document-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.document-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
  padding: var(--spacing-3);
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.document-icon {
  width: 36px;
  height: 36px;
  background-color: #dbeafe;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #1d4ed8;
}

.document-info {
  flex: 1;
}

.document-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  display: block;
}

.document-hint {
  font-size: 11px;
  color: var(--color-gray-500);
  display: block;
  margin-top: 2px;
}

.requirement-badge {
  padding: 4px 8px;
  border-radius: var(--radius-sm);
  font-size: 10px;
  font-weight: 600;
}

.requirement-badge.required {
  background-color: #fee2e2;
  color: #991b1b;
}

.requirement-badge.optional {
  background-color: #d1fae5;
  color: #065f46;
}

.upload-hint {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
  margin-top: var(--spacing-3);
  font-size: 12px;
  color: var(--color-gray-500);
}

/* Information Form */
.information-form {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.field-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-700);
}

.required-marker {
  color: #ef4444;
  margin-left: 2px;
}

.field-hint {
  font-size: 11px;
}

.field-hint.required {
  color: #ef4444;
}

/* Questionnaire */
.questionnaire-preview {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-4);
}

.question-item {
  display: flex;
  gap: var(--spacing-3);
}

.question-number {
  width: 28px;
  height: 28px;
  background-color: var(--primary-color);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 600;
  flex-shrink: 0;
}

.question-content {
  flex: 1;
}

.question-text {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
  margin: 0 0 var(--spacing-2) 0;
}

.response-input {
  margin-top: var(--spacing-2);
}

.response-options {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
  margin-top: var(--spacing-2);
}

.option-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  padding: var(--spacing-2);
  background-color: var(--color-gray-50);
  border-radius: var(--radius-sm);
}

.option-text {
  font-size: 13px;
  color: var(--color-gray-700);
}

.questionnaire-footer {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
  margin-top: var(--spacing-3);
  font-size: 12px;
  color: var(--color-gray-500);
}

/* System/Asset/Checklist Lists */
.system-list, .asset-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.system-item, .asset-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
  padding: var(--spacing-3);
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.system-icon, .asset-icon {
  width: 36px;
  height: 36px;
  background-color: #e0e7ff;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #4f46e5;
}

.asset-icon {
  background-color: #fed7aa;
  color: #ea580c;
}

.system-info, .asset-info {
  flex: 1;
}

.system-name, .asset-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  display: block;
}

.system-description, .asset-description {
  font-size: 11px;
  color: var(--color-gray-500);
  display: block;
  margin-top: 2px;
}

.handover-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 4px;
  font-size: 11px;
  color: #7c3aed;
}

.system-note {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
  margin-top: var(--spacing-3);
  font-size: 12px;
  color: var(--color-gray-500);
}

/* Checklist */
.checklist-preview {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.checklist-item {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-2);
  padding: var(--spacing-2);
}

.checklist-content {
  flex: 1;
}

.checklist-title {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  display: block;
}

.checklist-description {
  font-size: 11px;
  color: var(--color-gray-500);
  display: block;
  margin-top: 2px;
}

.checklist-pic {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 4px;
  font-size: 11px;
  color: var(--color-gray-500);
}

.checklist-progress {
  margin-top: var(--spacing-3);
}

.progress-bar {
  height: 8px;
  background-color: var(--color-gray-200);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background-color: var(--primary-color);
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 11px;
  color: var(--color-gray-500);
  margin-top: 4px;
  display: block;
}

/* Meeting */
.meeting-preview {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.meeting-info {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.meeting-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-size: 13px;
  color: var(--color-gray-600);
}

.meeting-item .pi {
  color: var(--color-gray-400);
}

/* General Task */
.general-task-actions {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.action-hint {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
  font-size: 13px;
  color: var(--color-gray-600);
  background-color: var(--color-gray-50);
  padding: var(--spacing-3);
  border-radius: var(--radius-md);
}

.action-buttons {
  display: flex;
  gap: var(--spacing-2);
}

/* Task Footer */
.task-footer {
  padding: var(--spacing-4);
  background-color: var(--color-gray-50);
  border-top: 1px solid var(--color-divider);
}

.footer-actions {
  display: flex;
  gap: var(--spacing-2);
  justify-content: flex-end;
}

.footer-hint {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
  margin-top: var(--spacing-3);
  font-size: 12px;
  color: var(--color-gray-500);
  justify-content: center;
}

.w-full {
  width: 100%;
}
</style>
