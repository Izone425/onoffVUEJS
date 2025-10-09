<template>
  <div class="workflow-form-container">
    <!-- Header -->
    <div class="workflow-header">
      <div class="header-left">
        <Button
          icon="pi pi-arrow-left"
          label="Back to Workflow"
          text
          @click="handleBack"
        />
        <div class="header-title">
          <h1 class="text-h1">
            {{ isEditMode ? 'Edit' : 'Create' }} {{ workflowTypeLabel }} Workflow
          </h1>
          <p class="page-description">
            {{ isEditMode ? 'Modify an existing workflow' : 'Build a new workflow with tasks and triggers' }}
          </p>
        </div>
      </div>

      <div class="header-actions">
        <Button label="Cancel" severity="secondary" outlined @click="handleBack" />
        <Button :label="isEditMode ? 'Update' : 'Save' + ' Workflow'" @click="handleSaveWorkflow" />
      </div>
    </div>

    <!-- Workflow Details Card -->
    <Card class="workflow-card">
      <template #title>Workflow Details</template>
      <template #content>
        <div class="form-grid">
          <!-- Workflow Name -->
          <div class="form-field">
            <label for="workflow-name" class="form-label">Workflow Name</label>
            <InputText
              id="workflow-name"
              v-model="workflowName"
              :placeholder="`Enter ${workflowTypeLabel.toLowerCase()} workflow name`"
              class="w-full"
            />
          </div>

          <!-- Copy From Template (Create Mode Only) -->
          <div v-if="!isEditMode" class="form-field">
            <label for="copy-from" class="form-label">Copy Template From (Optional)</label>
            <Dropdown
              id="copy-from"
              v-model="copyFromWorkflow"
              :options="existingWorkflows"
              optionLabel="label"
              optionValue="value"
              placeholder="Select an existing workflow template"
              showClear
              class="w-full"
              @change="handleCopyFromChange"
            />
          </div>
        </div>
      </template>
    </Card>

    <!-- Tasks Configuration Card -->
    <Card class="workflow-card">
      <template #title>Tasks Configuration</template>
      <template #content>
        <!-- Phase-based layout -->
        <div class="phases-container">
          <div
            v-for="phase in currentPhases"
            :key="phase.id"
            class="phase-section"
          >
            <!-- Phase Header -->
            <div class="phase-header">
              <div class="phase-info">
                <h3 class="phase-title">{{ phase.name }}</h3>
                <p class="phase-description">{{ phase.description }}</p>
              </div>
              <Button
                label="Add Task"
                icon="pi pi-plus"
                outlined
                size="small"
                @click="handleAddTask(phase.id)"
              />
            </div>

            <!-- Task Grid Header -->
            <div class="task-grid-header">
              <div class="col-drag"></div>
              <div class="col-task">Task</div>
              <div class="col-assignee">Person in Charge</div>
              <div class="col-trigger">Task Trigger</div>
              <div class="col-actions"></div>
            </div>

            <!-- Phase Tasks -->
            <div class="tasks-list">
              <div
                v-for="(task, index) in getTasksByPhase(phase.id)"
                :key="task.id"
                class="task-row"
                draggable="true"
                @dragstart="handleDragStart($event, task.id, phase.id)"
                @dragover="handleDragOver($event)"
                @drop="handleDrop($event, task.id, phase.id)"
                @dragend="handleDragEnd"
              >
                <!-- Drag Handle -->
                <div class="task-drag">
                  <i class="pi pi-bars"></i>
                </div>

                <!-- Task Selection -->
                <div class="task-select">
                  <Dropdown
                    v-model="task.task"
                    :options="taskTemplateNames"
                    optionLabel="label"
                    optionValue="value"
                    placeholder="Select a task template"
                    class="w-full"
                    @change="handleTaskChange(task.id, 'task', $event.value)"
                  />
                </div>

                <!-- Person in Charge -->
                <div class="task-assignee">
                  <Dropdown
                    v-model="task.assignee"
                    :options="assigneeOptions"
                    optionLabel="label"
                    optionValue="value"
                    placeholder="Select assignee"
                    class="w-full"
                    @change="handleTaskChange(task.id, 'assignee', $event.value)"
                  />
                </div>

                <!-- Task Trigger -->
                <div class="task-trigger">
                  <Button
                    :label="task.triggerLabel || 'Set Trigger'"
                    icon="pi pi-clock"
                    outlined
                    size="small"
                    class="w-full"
                    @click="handleOpenTriggerModal(task.id)"
                  />
                </div>

                <!-- Actions -->
                <div class="task-actions">
                  <Button
                    icon="pi pi-trash"
                    text
                    rounded
                    severity="danger"
                    size="small"
                    @click="handleDeleteTask(task.id)"
                  />
                </div>
              </div>

              <!-- Empty State -->
              <div v-if="getTasksByPhase(phase.id).length === 0" class="empty-state">
                <p>No tasks in this phase. Click "Add Task" to get started.</p>
              </div>
            </div>
          </div>
        </div>
      </template>
    </Card>

    <!-- Trigger Configuration Dialog -->
    <Dialog
      v-model:visible="isTriggerModalOpen"
      modal
      :header="'Configure Task Trigger'"
      :style="{ width: '600px' }"
      class="trigger-dialog"
    >
      <div class="trigger-config-content">
        <!-- Trigger Type Selection -->
        <div class="config-section">
          <h4 class="config-title">Trigger Type</h4>
          <Dropdown
            v-model="selectedTriggerValue"
            :options="filteredTriggerOptions"
            optionLabel="label"
            optionValue="value"
            placeholder="Select when this task should start"
            class="w-full"
          >
            <template #option="{ option }">
              <div class="trigger-option">
                <span class="trigger-label">{{ option.label }}</span>
                <span class="trigger-description">{{ option.description }}</span>
              </div>
            </template>
          </Dropdown>
        </div>

        <!-- Date Offset Configuration -->
        <div v-if="selectedTriggerValue === 'date_offset'" class="config-section date-offset-config">
          <div class="offset-controls">
            <span class="offset-text">Start this task</span>
            <InputNumber
              v-model="dateOffsetConfig.days"
              :min="0"
              showButtons
              class="offset-input"
            />
            <Dropdown
              v-model="dateOffsetConfig.timeUnit"
              :options="timeUnitOptions"
              optionLabel="label"
              optionValue="value"
              class="offset-dropdown"
            />
            <Dropdown
              v-model="dateOffsetConfig.beforeAfter"
              :options="beforeAfterOptions"
              optionLabel="label"
              optionValue="value"
              class="offset-dropdown"
            />
            <Dropdown
              v-model="dateOffsetConfig.referenceDate"
              :options="referenceDateOptions"
              optionLabel="label"
              optionValue="value"
              placeholder="select date"
              class="offset-dropdown-wide"
            />
          </div>

          <div class="offset-preview">
            <i class="pi pi-calendar"></i>
            <div>
              <p class="preview-title">Task will start:</p>
              <p class="preview-text">{{ dateOffsetPreview }}</p>
            </div>
          </div>
        </div>

        <!-- Previous Task Dependency Configuration -->
        <div v-if="selectedTriggerValue === 'previous_task'" class="config-section previous-task-config">
          <h4 class="config-title">Previous Task Dependency</h4>
          <div class="form-field">
            <label for="dependent-task" class="form-label">Select Previous Task</label>
            <Dropdown
              id="dependent-task"
              v-model="previousTaskConfig.dependentTaskId"
              :options="availablePreviousTasks"
              optionLabel="label"
              optionValue="value"
              placeholder="Choose previous task"
              class="w-full"
            />
          </div>
          <div class="previous-task-preview">
            <p class="preview-text">Preview: <strong>{{ previousTaskPreview }}</strong></p>
          </div>
        </div>

        <!-- Completion Needed Configuration -->
        <div class="config-section completion-config">
          <div class="completion-header">
            <div>
              <h4 class="config-title">Completion Needed</h4>
              <p class="config-description">Set deadline for task completion after it's triggered</p>
            </div>
            <InputSwitch v-model="completionDeadlineConfig.enabled" />
          </div>

          <div v-if="completionDeadlineConfig.enabled" class="completion-settings">
            <!-- Timing Mode Selection -->
            <div class="timing-mode-selector">
              <Button
                :label="'After Trigger Date'"
                :class="['mode-button', { active: completionDeadlineConfig.timingMode === 'after_trigger' }]"
                @click="completionDeadlineConfig.timingMode = 'after_trigger'"
              />
              <Button
                :label="'Before a Specific Date'"
                :class="['mode-button', { active: completionDeadlineConfig.timingMode === 'before_date' }]"
                @click="completionDeadlineConfig.timingMode = 'before_date'"
              />
            </div>

            <!-- After Trigger Configuration -->
            <div v-if="completionDeadlineConfig.timingMode === 'after_trigger'" class="timing-config after-trigger">
              <span class="timing-text">Complete within</span>
              <InputNumber
                v-model="completionDeadlineConfig.timeValue"
                :min="1"
                showButtons
                class="timing-input"
              />
              <Dropdown
                v-model="completionDeadlineConfig.timeUnit"
                :options="completionTimeUnitOptions"
                optionLabel="label"
                optionValue="value"
                class="timing-dropdown"
              />
              <span class="timing-text">after trigger</span>
            </div>

            <!-- Before Date Configuration -->
            <div v-if="completionDeadlineConfig.timingMode === 'before_date'" class="timing-config before-date">
              <span class="timing-text">Complete</span>
              <InputNumber
                v-model="completionDeadlineConfig.timeValue"
                :min="1"
                showButtons
                class="timing-input"
              />
              <Dropdown
                v-model="completionDeadlineConfig.timeUnit"
                :options="completionTimeUnitOptions"
                optionLabel="label"
                optionValue="value"
                class="timing-dropdown"
              />
              <span class="timing-text">before</span>
              <Dropdown
                v-model="completionDeadlineConfig.specificDate"
                :options="specificDateOptions"
                optionLabel="label"
                optionValue="value"
                class="timing-dropdown"
              />
            </div>

            <!-- Warning Message -->
            <div class="completion-warning">
              <i class="pi pi-check-circle"></i>
              <span>{{ completionWarningText }}</span>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <Button label="Cancel" severity="secondary" outlined @click="isTriggerModalOpen = false" />
        <Button
          label="Save"
          :disabled="!selectedTriggerValue"
          @click="handleSetTrigger"
        />
      </template>
    </Dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import Button from 'primevue/button'
import Card from 'primevue/card'
import InputText from 'primevue/inputtext'
import Dropdown from 'primevue/dropdown'
import Dialog from 'primevue/dialog'
import InputSwitch from 'primevue/inputswitch'
import InputNumber from 'primevue/inputnumber'
import { workflows, taskTemplates } from '../../data/mockData'

const router = useRouter()
const route = useRoute()
const toast = useToast()

// Route params
const workflowType = ref(route.query.type || 'onboarding') // 'onboarding' or 'offboarding'
const isEditMode = ref(!!route.params.id)

// Workflow data
const workflowName = ref('')
const copyFromWorkflow = ref(null)
const taskRows = ref([])

// UI state
const isTriggerModalOpen = ref(false)
const selectedTriggerRowId = ref(null)
const draggedTaskId = ref(null)
const draggedFromPhase = ref(null)

// Trigger configuration
const selectedTriggerValue = ref(null)
const dateOffsetConfig = ref({
  days: 0,
  timeUnit: 'days',
  beforeAfter: 'after',
  referenceDate: null
})
const previousTaskConfig = ref({
  dependentTaskId: null
})
const completionDeadlineConfig = ref({
  enabled: false,
  timingMode: 'after_trigger',
  timeValue: 1,
  timeUnit: 'days',
  specificDate: null
})

// Phase definitions
const onboardingPhases = [
  { id: 'pre-onboarding', name: 'Pre-Onboarding', description: 'Tasks before the employee starts' },
  { id: 'first-day-onboarding', name: 'First-day Onboarding', description: 'Welcome and orientation tasks' },
  { id: 'next-day-onboarding', name: 'Next day Onboarding', description: 'Follow-up tasks after first day' }
]

const offboardingPhases = [
  { id: 'notice-period', name: 'Notice Period', description: 'Tasks during notice period' },
  { id: 'last-week', name: 'Last Week', description: 'Handover and knowledge transfer' },
  { id: 'last-day', name: 'Last Day', description: 'Exit formalities' },
  { id: 'post-exit', name: 'Post Exit', description: 'Follow-up after departure' }
]

// Trigger options
const triggerOptions = [
  { value: 'hire_date', label: 'Hire Date', description: 'When employee hire date is set' },
  { value: 'confirmed_status', label: 'Confirmed Status', description: 'When employee is confirmed' },
  { value: 'resignation_accepted', label: 'Resignation Accepted', description: 'When resignation is accepted' },
  { value: 'resignation_date', label: 'Resignation Date', description: 'When resignation date is set' },
  { value: 'termination_date', label: 'Termination Date', description: 'When termination date is set' },
  { value: 'date_offset', label: 'Date Offset', description: 'Specific days before/after a date' },
  { value: 'previous_task', label: 'Previous Task Completion', description: 'After another task is completed' }
]

// Dropdown options
const timeUnitOptions = [
  { value: 'days', label: 'days' },
  { value: 'weeks', label: 'weeks' },
  { value: 'months', label: 'months' }
]

const beforeAfterOptions = [
  { value: 'before', label: 'before' },
  { value: 'after', label: 'after' }
]

const completionTimeUnitOptions = [
  { value: 'hours', label: 'hours' },
  { value: 'days', label: 'days' },
  { value: 'weeks', label: 'weeks' }
]

const taskTemplateNames = computed(() => {
  return taskTemplates
    .filter(t => t.indicator === workflowType.value)
    .map(t => ({ value: t.id, label: t.name }))
})

const assigneeOptions = [
  { value: 'hr_admin', label: 'HR Admin' },
  { value: 'it_admin', label: 'IT Admin' },
  { value: 'line_manager', label: 'Line Manager' },
  { value: 'hr_coordinator', label: 'HR Coordinator' }
]

const existingWorkflows = computed(() => {
  return workflows
    .filter(w => w.category === workflowType.value)
    .map(w => ({ value: w.id, label: w.name }))
})

const currentPhases = computed(() => {
  return workflowType.value === 'onboarding' ? onboardingPhases : offboardingPhases
})

const workflowTypeLabel = computed(() => {
  return workflowType.value === 'onboarding' ? 'Onboarding' : 'Offboarding'
})

const filteredTriggerOptions = computed(() => {
  return triggerOptions.filter(option => {
    if (workflowType.value === 'onboarding') {
      return !['resignation_accepted', 'resignation_date', 'termination_date'].includes(option.value)
    } else {
      return !['hire_date', 'confirmed_status'].includes(option.value)
    }
  })
})

const referenceDateOptions = computed(() => {
  if (workflowType.value === 'onboarding') {
    return [
      { value: 'hire_date', label: 'Hire Date' },
      { value: 'confirmed_status', label: 'Confirmed Status Date' }
    ]
  } else {
    return [
      { value: 'resignation_accepted', label: 'Resignation Accepted' },
      { value: 'termination_date', label: 'Termination Date' }
    ]
  }
})

const specificDateOptions = computed(() => {
  if (workflowType.value === 'onboarding') {
    return [
      { value: 'hire_date', label: 'Hire Date' },
      { value: 'confirmed_status', label: 'Confirmed Status Date' }
    ]
  } else {
    return [
      { value: 'last_work_date', label: 'Last Work Date' },
      { value: 'resignation_date', label: 'Resignation Date' },
      { value: 'termination_date', label: 'Termination Date' }
    ]
  }
})

const availablePreviousTasks = computed(() => {
  return taskRows.value
    .filter(task => task.id !== selectedTriggerRowId.value && task.task)
    .map(task => {
      const template = taskTemplateNames.value.find(t => t.value === task.task)
      return { value: task.id, label: template?.label || task.task }
    })
})

const dateOffsetPreview = computed(() => {
  return generateDateOffsetLabel(dateOffsetConfig.value)
})

const previousTaskPreview = computed(() => {
  return generatePreviousTaskLabel(taskRows.value, previousTaskConfig.value.dependentTaskId)
})

const completionWarningText = computed(() => {
  if (completionDeadlineConfig.value.timingMode === 'after_trigger') {
    return `Task will be marked overdue if not completed within ${completionDeadlineConfig.value.timeValue} ${completionDeadlineConfig.value.timeUnit} after trigger`
  } else {
    return `Task must be completed ${completionDeadlineConfig.value.timeValue} ${completionDeadlineConfig.value.timeUnit} before the selected date`
  }
})

// Methods
const getTasksByPhase = (phaseId) => {
  return taskRows.value.filter(task => task.phase === phaseId)
}

const handleBack = () => {
  router.push({ name: 'Workflow' })
}

const handleAddTask = (phaseId) => {
  taskRows.value.push({
    id: `task-${Date.now()}`,
    phase: phaseId,
    task: null,
    assignee: null,
    trigger: null,
    triggerLabel: null
  })
}

const handleTaskChange = (taskId, field, value) => {
  const task = taskRows.value.find(t => t.id === taskId)
  if (task) {
    task[field] = value
  }
}

const handleDeleteTask = (taskId) => {
  const index = taskRows.value.findIndex(t => t.id === taskId)
  if (index > -1) {
    taskRows.value.splice(index, 1)
  }
}

const handleDragStart = (event, taskId, phaseId) => {
  draggedTaskId.value = taskId
  draggedFromPhase.value = phaseId
  event.target.classList.add('dragging')
}

const handleDragOver = (event) => {
  event.preventDefault()
  event.dataTransfer.dropEffect = 'move'
}

const handleDrop = (event, targetTaskId, targetPhaseId) => {
  event.preventDefault()

  if (!draggedTaskId.value || draggedTaskId.value === targetTaskId) {
    return
  }

  const draggedTaskIndex = taskRows.value.findIndex(t => t.id === draggedTaskId.value)
  const targetTaskIndex = taskRows.value.findIndex(t => t.id === targetTaskId)

  if (draggedTaskIndex === -1 || targetTaskIndex === -1) {
    return
  }

  // Get the dragged task
  const draggedTask = taskRows.value[draggedTaskIndex]

  // Remove the dragged task from its current position
  taskRows.value.splice(draggedTaskIndex, 1)

  // Find the new target index after removal
  const newTargetIndex = taskRows.value.findIndex(t => t.id === targetTaskId)

  // Update the phase of the dragged task
  draggedTask.phase = targetPhaseId

  // Insert the dragged task at the target position
  taskRows.value.splice(newTargetIndex, 0, draggedTask)
}

const handleDragEnd = (event) => {
  event.target.classList.remove('dragging')
  draggedTaskId.value = null
  draggedFromPhase.value = null
}

const handleOpenTriggerModal = (taskId) => {
  selectedTriggerRowId.value = taskId
  const task = taskRows.value.find(t => t.id === taskId)

  // Reset configurations
  selectedTriggerValue.value = task?.trigger || null
  isTriggerModalOpen.value = true
}

const handleSetTrigger = () => {
  const task = taskRows.value.find(t => t.id === selectedTriggerRowId.value)
  if (task) {
    task.trigger = selectedTriggerValue.value

    // Generate trigger label
    if (selectedTriggerValue.value === 'date_offset') {
      task.triggerLabel = dateOffsetPreview.value
    } else if (selectedTriggerValue.value === 'previous_task') {
      task.triggerLabel = previousTaskPreview.value
    } else {
      const option = triggerOptions.find(opt => opt.value === selectedTriggerValue.value)
      task.triggerLabel = option?.label || selectedTriggerValue.value
    }

    // Store completion config
    task.completionConfig = completionDeadlineConfig.value.enabled
      ? { ...completionDeadlineConfig.value }
      : null
  }

  isTriggerModalOpen.value = false
}

const handleCopyFromChange = () => {
  if (copyFromWorkflow.value) {
    toast.add({
      severity: 'info',
      summary: 'Template Copied',
      detail: 'Workflow template has been loaded',
      life: 3000
    })
  }
}

const handleSaveWorkflow = () => {
  if (!workflowName.value) {
    toast.add({
      severity: 'warn',
      summary: 'Validation Error',
      detail: 'Please enter a workflow name',
      life: 3000
    })
    return
  }

  if (taskRows.value.length === 0) {
    toast.add({
      severity: 'warn',
      summary: 'Validation Error',
      detail: 'Please add at least one task',
      life: 3000
    })
    return
  }

  // Save workflow logic here
  toast.add({
    severity: 'success',
    summary: 'Workflow Saved',
    detail: `Workflow "${workflowName.value}" has been ${isEditMode.value ? 'updated' : 'created'} successfully`,
    life: 3000
  })

  // Navigate back
  setTimeout(() => {
    handleBack()
  }, 1000)
}

const generateDateOffsetLabel = (config) => {
  const refDate = referenceDateOptions.value.find(opt => opt.value === config.referenceDate)
  return `${config.days} ${config.timeUnit} ${config.beforeAfter} ${refDate?.label || 'reference date'}`
}

const generatePreviousTaskLabel = (tasks, taskId) => {
  const task = tasks.find(t => t.id === taskId)
  if (!task) return 'No task selected'
  const template = taskTemplateNames.value.find(t => t.value === task.task)
  return `After "${template?.label || task.task}" is completed`
}

// Initialize
onMounted(() => {
  if (isEditMode.value) {
    // Load workflow data for editing
    workflowName.value = 'Sample Workflow'
  }
})
</script>

<style scoped>
.workflow-form-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: var(--spacing-4) 0;
}

.workflow-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: var(--spacing-4);
  margin: 0 14px 21px 14px;
}

.header-left {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-4);
  flex: 1;
}

.header-title h1 {
  margin: 0 0 var(--spacing-1) 0;
}

.header-actions {
  display: flex;
  gap: var(--spacing-3);
}

.workflow-card {
  margin: 0 14px 21px 14px;
}

.form-grid {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-4);
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.form-label {
  font-weight: 500;
  font-size: 14px;
  color: var(--color-gray-700);
}

.phases-container {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-6);
}

.phase-section {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.phase-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.phase-title {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
  color: var(--color-gray-900);
}

.phase-description {
  font-size: 14px;
  color: var(--color-gray-600);
  margin: var(--spacing-1) 0 0 0;
}

.task-grid-header {
  display: grid;
  grid-template-columns: 40px 1fr 1fr 1fr 60px;
  gap: var(--spacing-2);
  padding: var(--spacing-2);
  background-color: #f9fafb;
  border-radius: var(--radius-md);
  font-size: 14px;
  font-weight: 600;
  color: var(--color-gray-700);
}

.tasks-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.task-row {
  display: grid;
  grid-template-columns: 40px 1fr 1fr 1fr 60px;
  gap: var(--spacing-2);
  align-items: center;
  padding: var(--spacing-2);
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  transition: all 0.2s ease;
}

.task-row:hover {
  border-color: var(--color-primary-300);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.task-row.dragging {
  opacity: 0.5;
  cursor: grabbing;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.task-drag {
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: grab;
  color: var(--color-gray-400);
  transition: color 0.2s;
}

.task-drag:hover {
  color: var(--color-gray-600);
}

.task-row.dragging .task-drag {
  cursor: grabbing;
}

.empty-state {
  padding: var(--spacing-4);
  text-align: center;
  border: 2px dashed var(--color-divider);
  border-radius: var(--radius-md);
  color: var(--color-gray-500);
}

.trigger-dialog .trigger-config-content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-4);
  padding: var(--spacing-2) 0;
}

.config-section {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.config-title {
  font-weight: 600;
  font-size: 14px;
  margin: 0;
}

.config-description {
  font-size: 13px;
  color: var(--color-gray-600);
  margin: var(--spacing-1) 0 0 0;
}

.trigger-option {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.trigger-label {
  font-weight: 600;
  font-size: 14px;
}

.trigger-description {
  font-size: 12px;
  color: var(--color-gray-600);
}

.date-offset-config {
  background-color: white;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: var(--spacing-3);
  margin: 0 14px;
}

.offset-controls {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  flex-wrap: wrap;
}

.offset-text {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-700);
}

.offset-input {
  width: 80px;
}

.offset-dropdown {
  width: 100px;
}

.offset-dropdown-wide {
  width: 180px;
}

.offset-preview {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-2);
  padding: var(--spacing-3);
  background-color: #dbeafe;
  border: 1px solid #bfdbfe;
  border-radius: var(--radius-md);
  margin-top: var(--spacing-3);
}

.offset-preview i {
  color: #1e40af;
  flex-shrink: 0;
  margin-top: 2px;
}

.preview-title {
  font-weight: 600;
  font-size: 14px;
  color: #1e3a8a;
  margin: 0;
}

.preview-text {
  font-size: 14px;
  color: #1e40af;
  margin: 4px 0 0 0;
}

.previous-task-config {
  background-color: #f9fafb;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: var(--spacing-3);
  margin: 0 14px;
}

.previous-task-preview {
  padding-top: var(--spacing-3);
  border-top: 1px solid var(--color-divider);
  margin-top: var(--spacing-3);
}

.completion-config {
  background-color: #f9fafb;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: var(--spacing-3);
  margin: 0 14px 21px 14px;
}

.completion-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.completion-settings {
  background-color: white;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: var(--spacing-3);
  margin-top: var(--spacing-3);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.timing-mode-selector {
  display: flex;
  gap: var(--spacing-1);
  background-color: #f1f5f9;
  padding: 4px;
  border-radius: var(--radius-md);
}

.mode-button {
  flex: 1;
  background: transparent;
  border: none;
  color: var(--color-gray-700);
}

.mode-button.active {
  background-color: white;
  color: var(--color-primary-600);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

.timing-config {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  padding: var(--spacing-3);
  border-radius: var(--radius-md);
}

.timing-config.after-trigger {
  background-color: #dbeafe;
  border: 1px solid #bfdbfe;
}

.timing-config.before-date {
  background-color: #d1fae5;
  border: 1px solid #6ee7b7;
}

.timing-text {
  font-size: 14px;
  color: var(--color-gray-700);
}

.timing-input {
  width: 100px;
}

.timing-dropdown {
  width: 120px;
}

.completion-warning {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  padding: var(--spacing-2);
  background-color: #fef3c7;
  border: 1px solid #fde68a;
  border-radius: var(--radius-md);
  font-size: 14px;
  color: #92400e;
}

.completion-warning i {
  flex-shrink: 0;
}

.w-full {
  width: 100%;
}

@media (max-width: 768px) {
  .workflow-header {
    flex-direction: column;
  }

  .header-left {
    flex-direction: column;
  }

  .task-grid-header {
    display: none;
  }

  .task-row {
    grid-template-columns: 1fr;
    gap: var(--spacing-2);
  }

  .offset-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .offset-input,
  .offset-dropdown,
  .offset-dropdown-wide {
    width: 100%;
  }
}
</style>
