<template>
  <div class="form-section">
    <div class="config-header">
      <div class="header-content">
        <div class="header-icon">
          <span class="pi pi-file-edit"></span>
        </div>
        <div>
          <label class="form-label">Information Fields</label>
          <p class="header-description">Define what information users need to provide for this task</p>
        </div>
      </div>
    </div>

    <div class="config-body">
      <label class="form-label">Required Information</label>
      <p class="form-help">Select which information fields users need to complete for this task</p>

      <!-- Information Field Categories -->
      <div class="field-categories">
        <div v-for="(category, categoryKey) in informationFieldCategories" :key="categoryKey" class="category-section">
          <h4 class="category-title">{{ category.title }}</h4>
          <div class="field-grid">
            <div v-for="field in category.fields" :key="field.id" class="field-checkbox">
              <Checkbox
                :inputId="field.id"
                v-model="localSelectedFields"
                :value="field.id"
                :disabled="viewMode"
              />
              <label :for="field.id" class="checkbox-label">{{ field.label }}</label>
            </div>
          </div>
        </div>

        <!-- Custom Fields Section -->
        <div v-if="customFields.length > 0" class="category-section">
          <h4 class="category-title">Custom Fields</h4>
          <div class="field-grid">
            <div v-for="field in customFields" :key="field.id" class="field-checkbox">
              <Checkbox
                :inputId="field.id"
                v-model="localSelectedFields"
                :value="field.id"
                :disabled="viewMode"
              />
              <label :for="field.id" class="checkbox-label">
                {{ field.label }}
                <Button
                  v-if="!viewMode"
                  icon="pi pi-times"
                  text
                  rounded
                  severity="danger"
                  size="small"
                  class="remove-btn"
                  @click="handleRemoveField(field.id)"
                />
              </label>
            </div>
          </div>
        </div>
      </div>

      <!-- Add Custom Field - Hidden in view mode -->
      <div v-if="!viewMode" class="add-field-section">
        <Button
          v-if="!isAddingField"
          label="Add Custom Field"
          icon="pi pi-plus"
          size="small"
          outlined
          @click="isAddingField = true"
        />
        <div v-else class="add-field-input">
          <InputText
            v-model="newFieldName"
            placeholder="Enter field name (e.g., Full Name, Phone Number)"
            class="w-full"
            @keydown.enter="handleAddField"
            @keydown.esc="cancelAddField"
          />
          <Button
            icon="pi pi-check"
            size="small"
            @click="handleAddField"
            :disabled="!newFieldName.trim()"
          />
          <Button
            icon="pi pi-times"
            size="small"
            outlined
            @click="cancelAddField"
          />
        </div>
      </div>

      <!-- Field Requirements -->
      <div v-if="localSelectedFields.length > 0" class="field-requirements">
        <div class="requirements-header">
          <label class="form-label">Information Requirements</label>
          <p class="form-help">{{ localSelectedFields.length }} field{{ localSelectedFields.length !== 1 ? 's' : '' }} selected</p>
        </div>
        <div class="requirements-list">
          <div v-for="fieldId in localSelectedFields" :key="fieldId" class="requirement-item">
            <div class="requirement-info">
              <div :class="['status-dot', localRequirements[fieldId] !== false ? 'required' : 'optional']"></div>
              <span class="field-name">{{ getFieldLabel(fieldId) }}</span>
              <Button
                v-if="fieldId.startsWith('custom-field-') && !viewMode"
                icon="pi pi-times"
                text
                rounded
                severity="danger"
                size="small"
                @click="handleRemoveField(fieldId)"
              />
            </div>
            <div class="requirement-toggle">
              <span :class="['toggle-label', localRequirements[fieldId] !== false ? 'inactive' : 'active']">Optional</span>
              <InputSwitch
                v-model="localRequirements[fieldId]"
                :trueValue="true"
                :falseValue="false"
                :disabled="viewMode"
              />
              <span :class="['toggle-label', localRequirements[fieldId] !== false ? 'active' : 'inactive']">Compulsory</span>
            </div>
          </div>
        </div>
        <div class="info-box">
          <p><strong>Toggle switch:</strong> ON = Compulsory (users must provide), OFF = Optional (users can choose)</p>
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
  selectedFields: {
    type: Array,
    default: () => []
  },
  requirements: {
    type: Object,
    default: () => ({})
  },
  viewMode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:selectedFields', 'update:requirements'])

const localSelectedFields = computed({
  get: () => props.selectedFields,
  set: (val) => emit('update:selectedFields', val)
})

const localRequirements = computed({
  get: () => props.requirements,
  set: (val) => emit('update:requirements', val)
})

const isAddingField = ref(false)
const newFieldName = ref('')
const customFields = ref([])

const informationFieldCategories = {
  personal: {
    title: 'Personal Information',
    fields: [
      { id: 'full-name', label: 'Full Name' },
      { id: 'email-address', label: 'Email Address' },
      { id: 'phone-number', label: 'Phone Number' },
      { id: 'date-of-birth', label: 'Date of Birth' },
      { id: 'nationality', label: 'Nationality' },
      { id: 'marital-status', label: 'Marital Status' }
    ]
  },
  contact: {
    title: 'Contact Information',
    fields: [
      { id: 'home-address', label: 'Home Address' },
      { id: 'emergency-contact', label: 'Emergency Contact' },
      { id: 'emergency-contact-phone', label: 'Emergency Contact Phone' }
    ]
  },
  financial: {
    title: 'Financial Information',
    fields: [
      { id: 'bank-account-number', label: 'Bank Account Number' },
      { id: 'bank-name', label: 'Bank Name' },
      { id: 'tax-id-number', label: 'Tax ID Number' }
    ]
  },
  payroll: {
    title: 'Payroll Information',
    fields: [
      { id: 'tax-identification-number', label: 'Tax Identification Number' },
      { id: 'epf-number', label: 'EPF Number' },
      { id: 'socso-number', label: 'Socso Number' }
    ]
  }
}

const getAllPredefinedFields = () => {
  return Object.values(informationFieldCategories).flatMap(cat => cat.fields)
}

const getFieldLabel = (fieldId) => {
  const allFields = [...getAllPredefinedFields(), ...customFields.value]
  return allFields.find(f => f.id === fieldId)?.label || fieldId
}

const handleAddField = () => {
  if (newFieldName.value.trim()) {
    const newField = {
      id: `custom-field-${Date.now()}`,
      label: newFieldName.value.trim()
    }
    customFields.value.push(newField)
    localSelectedFields.value.push(newField.id)
    localRequirements.value[newField.id] = true // Default to compulsory
    newFieldName.value = ''
    isAddingField.value = false
  }
}

const cancelAddField = () => {
  newFieldName.value = ''
  isAddingField.value = false
}

const handleRemoveField = (fieldId) => {
  customFields.value = customFields.value.filter(f => f.id !== fieldId)
  localSelectedFields.value = localSelectedFields.value.filter(id => id !== fieldId)
  const newRequirements = { ...localRequirements.value }
  delete newRequirements[fieldId]
  emit('update:requirements', newRequirements)
}

watch(localSelectedFields, (newFields) => {
  // Initialize requirements for newly selected fields
  newFields.forEach(fieldId => {
    if (!(fieldId in localRequirements.value)) {
      localRequirements.value[fieldId] = true // Default to compulsory
    }
  })
})
</script>

<style scoped>
.config-header {
  padding: var(--spacing-3);
  background-color: #f0fdf4;
  border: 1px solid #bbf7d0;
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-4);
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

.field-categories {
  margin: var(--spacing-3) 0;
}

.category-section {
  margin-bottom: var(--spacing-4);
}

.category-title {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-gray-700);
  margin-bottom: var(--spacing-2);
  padding-bottom: var(--spacing-1);
  border-bottom: 1px solid var(--color-divider);
}

.field-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-2);
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
