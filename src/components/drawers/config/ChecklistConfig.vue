<template>
  <div class="form-section">
    <div class="config-header">
      <div class="header-content">
        <div class="header-icon">
          <span class="pi pi-check-square"></span>
        </div>
        <div class="header-text">
          <label class="form-label">Checklist Items</label>
          <p class="header-description">Add checklist items that need to be completed and assign a Person in Charge (PIC) for each item</p>
        </div>
      </div>
      <Button
        v-if="!viewMode"
        label="Add Checklist Item"
        icon="pi pi-plus"
        size="small"
        outlined
        @click="isAddingChecklistItem = true"
      />
    </div>

    <div class="config-body">
      <!-- Add New Checklist Item Form - Hidden in view mode -->
      <div v-if="isAddingChecklistItem && !viewMode" class="add-item-form">
        <div class="form-header">
          <label class="form-label">Add New Checklist Item</label>
          <Button
            icon="pi pi-times"
            text
            rounded
            size="small"
            @click="cancelAddItem"
          />
        </div>

        <div class="form-fields">
          <div class="field-group">
            <label for="checklistTitle" class="form-label">Checklist Item Title <span class="required">*</span></label>
            <InputText
              id="checklistTitle"
              v-model="newChecklistItem.title"
              placeholder="e.g., Complete security clearance, Submit required documents"
              class="w-full"
            />
          </div>

          <div class="field-group">
            <label for="checklistDescription" class="form-label">Description <span class="required">*</span></label>
            <Textarea
              id="checklistDescription"
              v-model="newChecklistItem.description"
              placeholder="Detailed description of what needs to be completed for this checklist item..."
              :rows="3"
              class="w-full"
            />
          </div>

          <div class="field-group">
            <label for="checklistPIC" class="form-label">Person In Charge (PIC) <span class="required">*</span></label>
            <Dropdown
              id="checklistPIC"
              v-model="newChecklistItem.pic"
              :options="picOptions"
              optionLabel="label"
              optionValue="value"
              placeholder="Select PIC responsible for this checklist item"
              class="w-full"
            />
          </div>
        </div>

        <div class="form-actions">
          <Button
            label="Cancel"
            severity="secondary"
            outlined
            size="small"
            @click="cancelAddItem"
          />
          <Button
            label="Add Item"
            icon="pi pi-save"
            size="small"
            @click="handleAddChecklistItem"
            :disabled="!newChecklistItem.title.trim() || !newChecklistItem.description.trim() || !newChecklistItem.pic"
          />
        </div>
      </div>

      <!-- Checklist Items List -->
      <div v-if="checklistItems.length > 0" class="checklist-items-section">
        <div class="items-header">
          <label class="form-label">Configured Checklist Items</label>
          <p class="items-count">{{ checklistItems.length }} item{{ checklistItems.length !== 1 ? 's' : '' }} configured</p>
        </div>

        <div class="items-list">
          <div v-for="(item, index) in checklistItems" :key="item.id" class="checklist-item-card">
            <div class="item-content">
              <div class="item-fields">
                <div class="field-row">
                  <span class="item-badge">#{{ index + 1 }}</span>
                  <div class="field-group flex-1">
                    <InputText
                      v-model="item.title"
                      @input="handleChecklistItemChange(item.id, 'title', item.title)"
                      placeholder="Checklist item title"
                      class="w-full item-title-input"
                      :disabled="viewMode"
                    />
                  </div>
                </div>

                <div class="field-group">
                  <Textarea
                    v-model="item.description"
                    @input="handleChecklistItemChange(item.id, 'description', item.description)"
                    placeholder="Description of what needs to be completed..."
                    :rows="2"
                    class="w-full"
                    :disabled="viewMode"
                  />
                </div>

                <div class="field-group">
                  <Dropdown
                    v-model="item.pic"
                    @change="handleChecklistItemChange(item.id, 'pic', item.pic)"
                    :options="picOptions"
                    optionLabel="label"
                    optionValue="value"
                    placeholder="Select PIC"
                    class="w-full"
                    :disabled="viewMode"
                  />
                </div>

                <div class="assigned-info">
                  <span class="pi pi-user"></span>
                  <span>Assigned to: <strong>{{ item.pic }}</strong></span>
                </div>
              </div>

              <Button
                v-if="!viewMode"
                icon="pi pi-trash"
                text
                rounded
                severity="danger"
                size="small"
                @click="handleRemoveChecklistItem(item.id)"
                class="remove-btn"
              />
            </div>
          </div>
        </div>

        <div class="info-note">
          <p><strong>Example:</strong> For "Employee Exit Process" checklist, you might add: "Complete security clearance" → "Return company property" → "Submit final documentation", each with specific requirements and assigned PICs.</p>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="checklistItems.length === 0 && !isAddingChecklistItem" class="empty-state">
        <div class="empty-icon">
          <span class="pi pi-check-square"></span>
        </div>
        <p class="empty-title">No checklist items configured{{ viewMode ? '' : ' yet' }}</p>
        <p v-if="!viewMode" class="empty-subtitle">Click "Add Checklist Item" to get started</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import Dropdown from 'primevue/dropdown'

const props = defineProps({
  checklistItems: {
    type: Array,
    default: () => []
  },
  viewMode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:checklistItems'])

const isAddingChecklistItem = ref(false)
const newChecklistItem = ref({
  title: '',
  description: '',
  pic: ''
})

const checklistItems = computed({
  get: () => props.checklistItems,
  set: (val) => emit('update:checklistItems', val)
})

const picOptions = [
  { label: 'HR Admin', value: 'HR Admin' },
  { label: 'IT Department', value: 'IT Department' },
  { label: 'Finance Department', value: 'Finance Department' },
  { label: 'Department Manager', value: 'Department Manager' },
  { label: 'Direct Supervisor', value: 'Direct Supervisor' },
  { label: 'Security Team', value: 'Security Team' },
  { label: 'Facilities Manager', value: 'Facilities Manager' },
  { label: 'Payroll Administrator', value: 'Payroll Administrator' }
]

const handleAddChecklistItem = () => {
  if (newChecklistItem.value.title.trim() && newChecklistItem.value.description.trim() && newChecklistItem.value.pic) {
    const newItem = {
      id: `checklist-${Date.now()}`,
      title: newChecklistItem.value.title,
      description: newChecklistItem.value.description,
      pic: newChecklistItem.value.pic
    }
    checklistItems.value.push(newItem)
    cancelAddItem()
  }
}

const cancelAddItem = () => {
  isAddingChecklistItem.value = false
  newChecklistItem.value = {
    title: '',
    description: '',
    pic: ''
  }
}

const handleChecklistItemChange = (itemId, field, value) => {
  const itemIndex = checklistItems.value.findIndex(item => item.id === itemId)
  if (itemIndex !== -1) {
    checklistItems.value[itemIndex][field] = value
  }
}

const handleRemoveChecklistItem = (itemId) => {
  checklistItems.value = checklistItems.value.filter(item => item.id !== itemId)
}
</script>

<style scoped>
.config-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-3);
  background-color: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-4);
}

.header-content {
  display: flex;
  gap: var(--spacing-2);
  align-items: flex-start;
  flex: 1;
}

.header-icon {
  width: 32px;
  height: 32px;
  background-color: #cbd5e1;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #475569;
  flex-shrink: 0;
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

.add-item-form {
  padding: var(--spacing-4);
  background-color: white;
  border: 1px solid #e2e8f0;
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-4);
}

.form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-4);
}

.form-fields {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.field-group {
  display: flex;
  flex-direction: column;
}

.field-row {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.flex-1 {
  flex: 1;
}

.form-label {
  display: block;
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  margin-bottom: var(--spacing-1);
}

.required {
  color: var(--color-danger);
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-2);
  padding-top: var(--spacing-3);
  border-top: 1px solid #e2e8f0;
  margin-top: var(--spacing-4);
}

.checklist-items-section {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.items-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.items-count {
  font-size: 12px;
  color: var(--color-gray-500);
}

.items-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.checklist-item-card {
  padding: var(--spacing-4);
  background-color: white;
  border: 1px solid #e2e8f0;
  border-radius: var(--radius-md);
}

.item-content {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-3);
}

.item-fields {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.item-badge {
  background-color: white;
  border: 1px solid #e2e8f0;
  padding: 4px 10px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
  color: var(--color-gray-700);
}

.item-title-input :deep(.p-inputtext) {
  font-weight: 500;
}

.assigned-info {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-size: 13px;
  color: var(--color-gray-600);
}

.assigned-info .pi {
  font-size: 12px;
}

.assigned-info strong {
  color: var(--color-gray-900);
}

.remove-btn {
  margin-top: 4px;
}

.info-note {
  padding: var(--spacing-2);
  background-color: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: var(--radius-md);
  font-size: 12px;
  color: var(--color-gray-700);
}

.info-note p {
  margin: 0;
}

.empty-state {
  text-align: center;
  padding: var(--spacing-6) var(--spacing-4);
  color: #64748b;
}

.empty-icon {
  width: 48px;
  height: 48px;
  background-color: #f1f5f9;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto var(--spacing-3);
}

.empty-icon .pi {
  font-size: 24px;
  color: #94a3b8;
}

.empty-title {
  font-weight: 500;
  font-size: 14px;
  margin: 0 0 4px 0;
  color: var(--color-gray-900);
}

.empty-subtitle {
  font-size: 13px;
  margin: 0;
}

.w-full {
  width: 100%;
}
</style>
