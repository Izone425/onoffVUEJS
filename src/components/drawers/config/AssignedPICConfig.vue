<template>
  <div class="form-section">
    <div class="config-header green">
      <div class="header-content">
        <div class="header-icon green">
          <span class="pi pi-user"></span>
        </div>
        <div class="header-text">
          <label class="form-label">Assigned Person in Charge (PIC) based on project</label>
          <p class="header-description">Select the person or role responsible for completing or overseeing this task</p>
        </div>
      </div>
    </div>

    <div class="config-body">
      <div class="field-group">
        <label class="field-label">Select PIC {{ viewMode ? '' : '*' }}</label>
        <p class="field-description">Choose from department, designation, or specific employee</p>

        <Dropdown
          v-model="localSelectedPIC"
          :options="groupedPICOptions"
          optionLabel="label"
          optionValue="value"
          optionGroupLabel="label"
          optionGroupChildren="items"
          placeholder="Select PIC responsible for this task"
          class="w-full dropdown-large"
          :disabled="viewMode"
          :showClear="!viewMode"
          filter
          filterPlaceholder="Search PIC..."
        >
          <template #optiongroup="slotProps">
            <div class="pic-group-header">
              <span :class="['group-icon pi', getGroupIcon(slotProps.option.label)]"></span>
              <span class="group-label">{{ slotProps.option.label }}</span>
            </div>
          </template>
          <template #option="slotProps">
            <div class="pic-option">
              <span :class="['pic-badge', getPICBadgeClass(slotProps.option.value)]">
                {{ getPICPrefix(slotProps.option.value) }}
              </span>
              <span class="pic-label">{{ slotProps.option.label }}</span>
            </div>
          </template>
          <template #value="slotProps">
            <div v-if="slotProps.value" class="pic-selected">
              <span :class="['pic-badge', getPICBadgeClass(slotProps.value)]">
                {{ getPICPrefix(slotProps.value) }}
              </span>
              <span>{{ getPICDisplayLabel(slotProps.value) }}</span>
            </div>
            <span v-else class="placeholder-text">{{ slotProps.placeholder }}</span>
          </template>
        </Dropdown>
      </div>

      <!-- Selected PIC Info -->
      <div v-if="localSelectedPIC" class="selected-pic-info">
        <span class="pi pi-check-circle"></span>
        <span>Assigned to: <strong>{{ getPICDisplayLabel(localSelectedPIC) }}</strong></span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import Dropdown from 'primevue/dropdown'

const props = defineProps({
  selectedPIC: {
    type: String,
    default: ''
  },
  viewMode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:selectedPIC'])

const localSelectedPIC = computed({
  get: () => props.selectedPIC,
  set: (val) => emit('update:selectedPIC', val)
})

// Grouped PIC options - Department, Designation, Employee
const groupedPICOptions = [
  {
    label: 'Department',
    items: [
      { label: 'Human Resources', value: 'dept-hr' },
      { label: 'Information Technology', value: 'dept-it' },
      { label: 'Finance & Accounting', value: 'dept-finance' },
      { label: 'Operations', value: 'dept-operations' },
      { label: 'Marketing', value: 'dept-marketing' },
      { label: 'Sales', value: 'dept-sales' },
      { label: 'Legal & Compliance', value: 'dept-legal' },
      { label: 'Administration', value: 'dept-admin' }
    ]
  },
  {
    label: 'Designation',
    items: [
      { label: 'Manager', value: 'desig-manager' },
      { label: 'Supervisor', value: 'desig-supervisor' },
      { label: 'Coordinator', value: 'desig-coordinator' },
      { label: 'Specialist', value: 'desig-specialist' },
      { label: 'Admin', value: 'desig-admin' },
      { label: 'Executive', value: 'desig-executive' },
      { label: 'Team Lead', value: 'desig-team-lead' },
      { label: 'Director', value: 'desig-director' }
    ]
  },
  {
    label: 'Employee',
    items: [
      { label: 'Sarah Ahmad (HR Admin)', value: 'emp-sarah-ahmad' },
      { label: 'Michael Chen (HR Coordinator)', value: 'emp-michael-chen' },
      { label: 'David Kim (IT Admin)', value: 'emp-david-kim' },
      { label: 'Emily Rodriguez (Manager)', value: 'emp-emily-rodriguez' },
      { label: 'James Wilson (Finance Admin)', value: 'emp-james-wilson' },
      { label: 'Lisa Patel (Operations Coordinator)', value: 'emp-lisa-patel' },
      { label: 'John Smith (IT Specialist)', value: 'emp-john-smith' },
      { label: 'Maria Garcia (Marketing Executive)', value: 'emp-maria-garcia' },
      { label: 'Robert Brown (Sales Manager)', value: 'emp-robert-brown' },
      { label: 'Jennifer Lee (Legal Counsel)', value: 'emp-jennifer-lee' }
    ]
  }
]

const getGroupIcon = (groupLabel) => {
  const iconMap = {
    'Department': 'pi-building',
    'Designation': 'pi-id-card',
    'Employee': 'pi-user'
  }
  return iconMap[groupLabel] || 'pi-users'
}

const getPICBadgeClass = (value) => {
  if (!value) return ''
  if (value.startsWith('dept-')) return 'department'
  if (value.startsWith('desig-')) return 'designation'
  if (value.startsWith('emp-')) return 'employee'
  return ''
}

const getPICPrefix = (value) => {
  if (!value) return ''
  if (value.startsWith('dept-')) return 'DEPT'
  if (value.startsWith('desig-')) return 'ROLE'
  if (value.startsWith('emp-')) return 'EMP'
  return ''
}

const getPICDisplayLabel = (value) => {
  if (!value) return ''
  for (const group of groupedPICOptions) {
    const item = group.items.find(i => i.value === value)
    if (item) return item.label
  }
  return value
}
</script>

<style scoped>
.config-header {
  padding: var(--spacing-3);
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-4);
}

.config-header.green {
  background-color: #f0fdf4;
  border: 1px solid #bbf7d0;
}

.header-content {
  display: flex;
  gap: var(--spacing-2);
  align-items: flex-start;
}

.header-icon {
  width: 32px;
  height: 32px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.header-icon.green {
  background-color: #86efac;
  color: #15803d;
}

.header-text {
  flex: 1;
}

.header-text .form-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
  display: block;
}

.header-description {
  font-size: 13px;
  color: var(--color-gray-600);
  margin-top: 4px;
  line-height: 1.4;
}

.config-body {
  padding: var(--spacing-3);
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.field-group {
  margin-bottom: var(--spacing-4);
}

.field-label {
  display: block;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
  margin-bottom: var(--spacing-1);
}

.field-description {
  font-size: 12px;
  color: var(--color-gray-500);
  margin-bottom: var(--spacing-2);
}

.dropdown-large :deep(.p-dropdown) {
  min-height: 44px;
}

/* PIC Group Header */
.pic-group-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-weight: 600;
  color: var(--color-gray-700);
  padding: var(--spacing-1) 0;
}

.group-icon {
  font-size: 14px;
}

.group-label {
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* PIC Option */
.pic-option {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  padding: var(--spacing-1) 0;
}

.pic-badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: var(--radius-sm);
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.pic-badge.department {
  background-color: #dbeafe;
  color: #1e40af;
}

.pic-badge.designation {
  background-color: #fef3c7;
  color: #92400e;
}

.pic-badge.employee {
  background-color: #dcfce7;
  color: #166534;
}

.pic-label {
  font-size: 14px;
  color: var(--color-gray-900);
}

/* Selected PIC Display */
.pic-selected {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.placeholder-text {
  color: var(--color-gray-400);
}

/* Selected PIC Info */
.selected-pic-info {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  font-size: 13px;
  color: #15803d;
}

.selected-pic-info .pi {
  font-size: 14px;
}

.w-full {
  width: 100%;
}
</style>
