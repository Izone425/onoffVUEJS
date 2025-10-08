<template>
  <div class="form-section">
    <div class="config-header blue">
      <div class="header-content">
        <div class="header-icon blue">
          <span class="pi pi-upload"></span>
        </div>
        <div class="header-text">
          <label class="form-label">Document to be Uploaded</label>
          <p class="header-description">Enable if this task requires users to upload documents</p>
        </div>
      </div>
      <InputSwitch v-model="localRequiresUpload" />
    </div>

    <div v-if="localRequiresUpload" class="config-body">
      <label class="form-label">Required Documents</label>
      <p class="form-help">Select which documents users need to upload for this task</p>

      <!-- Document Selection Grid -->
      <div class="field-grid">
        <div v-for="doc in allDocuments" :key="doc.id" class="field-checkbox">
          <Checkbox
            :inputId="doc.id"
            v-model="localSelectedDocuments"
            :value="doc.id"
          />
          <label :for="doc.id" class="checkbox-label">
            {{ doc.label }}
            <Button
              v-if="doc.id.startsWith('custom-')"
              icon="pi pi-times"
              text
              rounded
              severity="danger"
              size="small"
              class="remove-btn"
              @click="handleRemoveDocument(doc.id)"
            />
          </label>
        </div>
      </div>

      <!-- Add Custom Document -->
      <div class="add-field-section">
        <Button
          v-if="!isAddingDocument"
          label="Add Custom Document"
          icon="pi pi-plus"
          size="small"
          outlined
          @click="isAddingDocument = true"
        />
        <div v-else class="add-field-input">
          <InputText
            v-model="newDocumentName"
            placeholder="Enter document name"
            class="w-full"
            @keydown.enter="handleAddDocument"
            @keydown.esc="cancelAddDocument"
          />
          <Button
            icon="pi pi-check"
            size="small"
            @click="handleAddDocument"
            :disabled="!newDocumentName.trim()"
          />
          <Button
            icon="pi pi-times"
            size="small"
            outlined
            @click="cancelAddDocument"
          />
        </div>
      </div>

      <!-- Document Requirements -->
      <div v-if="localSelectedDocuments.length > 0" class="field-requirements">
        <div class="requirements-header">
          <label class="form-label">Document Requirements</label>
          <p class="form-help">{{ localSelectedDocuments.length }} document{{ localSelectedDocuments.length !== 1 ? 's' : '' }} selected</p>
        </div>
        <div class="requirements-list">
          <div v-for="docId in localSelectedDocuments" :key="docId" class="requirement-item">
            <div class="requirement-info">
              <div :class="['status-dot', localRequirements[docId] !== false ? 'required' : 'optional']"></div>
              <span class="field-name">{{ getDocumentLabel(docId) }}</span>
            </div>
            <div class="requirement-toggle">
              <span :class="['toggle-label', localRequirements[docId] !== false ? 'inactive' : 'active']">Optional</span>
              <InputSwitch
                v-model="localRequirements[docId]"
                :trueValue="true"
                :falseValue="false"
              />
              <span :class="['toggle-label', localRequirements[docId] !== false ? 'active' : 'inactive']">Compulsory</span>
            </div>
          </div>
        </div>
        <div class="info-box">
          <p><strong>Toggle switch:</strong> ON = Compulsory (users must upload), OFF = Optional (users can choose)</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Checkbox from 'primevue/checkbox'
import InputSwitch from 'primevue/inputswitch'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'

const props = defineProps({
  requiresUpload: {
    type: Boolean,
    default: false
  },
  selectedDocuments: {
    type: Array,
    default: () => []
  },
  requirements: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:requiresUpload', 'update:selectedDocuments', 'update:requirements'])

const localRequiresUpload = computed({
  get: () => props.requiresUpload,
  set: (val) => emit('update:requiresUpload', val)
})

const localSelectedDocuments = computed({
  get: () => props.selectedDocuments,
  set: (val) => emit('update:selectedDocuments', val)
})

const localRequirements = computed({
  get: () => props.requirements,
  set: (val) => emit('update:requirements', val)
})

const isAddingDocument = ref(false)
const newDocumentName = ref('')
const customDocuments = ref([])

const predefinedDocuments = [
  { id: 'ic', label: 'IC (Identity Card)' },
  { id: 'passport', label: 'Passport' },
  { id: 'work-permit', label: 'Work Permit' },
  { id: 'medical-checkup', label: 'Medical Checkup Report' },
  { id: 'driving-license', label: 'Driving License' },
  { id: 'ea-form', label: 'EA Form' },
  { id: 'tp3', label: 'TP3' }
]

const allDocuments = computed(() => {
  return [...predefinedDocuments, ...customDocuments.value]
})

const getDocumentLabel = (docId) => {
  return allDocuments.value.find(d => d.id === docId)?.label || docId
}

const handleAddDocument = () => {
  if (newDocumentName.value.trim()) {
    const newDoc = {
      id: `custom-${Date.now()}`,
      label: newDocumentName.value.trim()
    }
    customDocuments.value.push(newDoc)
    localSelectedDocuments.value.push(newDoc.id)
    localRequirements.value[newDoc.id] = true // Default to compulsory
    newDocumentName.value = ''
    isAddingDocument.value = false
  }
}

const cancelAddDocument = () => {
  newDocumentName.value = ''
  isAddingDocument.value = false
}

const handleRemoveDocument = (docId) => {
  customDocuments.value = customDocuments.value.filter(d => d.id !== docId)
  localSelectedDocuments.value = localSelectedDocuments.value.filter(id => id !== docId)
  const newRequirements = { ...localRequirements.value }
  delete newRequirements[docId]
  emit('update:requirements', newRequirements)
}

watch(localSelectedDocuments, (newDocs) => {
  // Initialize requirements for newly selected documents
  newDocs.forEach(docId => {
    if (!(docId in localRequirements.value)) {
      localRequirements.value[docId] = true // Default to compulsory
    }
  })
})
</script>

<style scoped>
.config-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-3);
  background-color: #f0fdf4;
  border: 1px solid #bbf7d0;
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-4);
}

.config-header.blue {
  background-color: #eff6ff;
  border-color: #bfdbfe;
}

.header-content {
  display: flex;
  gap: var(--spacing-2);
  align-items: flex-start;
}

.header-icon {
  width: 32px;
  height: 32px;
  background-color: #86efac;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #16a34a;
  flex-shrink: 0;
}

.header-icon.blue {
  background-color: #93c5fd;
  color: #1d4ed8;
}

.header-text {
  flex: 1;
}

.header-description {
  font-size: 13px;
  color: var(--color-gray-600);
  margin-top: 2px;
}

.config-body {
  padding: var(--spacing-3);
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.field-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-2);
  margin: var(--spacing-3) 0;
}

.field-checkbox {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
}

.checkbox-label {
  font-size: 13px;
  color: var(--color-gray-900);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
}

.remove-btn {
  width: 20px !important;
  height: 20px !important;
  padding: 0 !important;
}

.add-field-section {
  padding-top: var(--spacing-3);
  border-top: 1px solid var(--color-divider);
  margin-top: var(--spacing-3);
}

.add-field-input {
  display: flex;
  gap: var(--spacing-2);
  align-items: center;
}

.field-requirements {
  margin-top: var(--spacing-4);
}

.requirements-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-3);
}

.requirements-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.requirement-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-3);
  background-color: white;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.requirement-info {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-dot.required {
  background-color: #ef4444;
}

.status-dot.optional {
  background-color: #22c55e;
}

.field-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.requirement-toggle {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.toggle-label {
  font-size: 13px;
  color: var(--color-gray-500);
}

.toggle-label.active {
  color: #ef4444;
  font-weight: 500;
}

.info-box {
  margin-top: var(--spacing-3);
  padding: var(--spacing-2);
  background-color: #dbeafe;
  border: 1px solid #93c5fd;
  border-radius: var(--radius-md);
  font-size: 12px;
  color: var(--color-gray-700);
}

.w-full {
  width: 100%;
}
</style>
