<template>
  <div class="form-section">
    <div class="config-header">
      <div class="header-content">
        <div class="header-icon">
          <span class="pi pi-question-circle"></span>
        </div>
        <div class="header-text">
          <label class="form-label">Questions</label>
          <p class="header-description">Add and configure questions for your questionnaire</p>
        </div>
      </div>
      <span class="question-count-badge">{{ questions.length }} questions</span>
    </div>

    <div class="config-body">
      <!-- Add Question Buttons - Hidden in view mode -->
      <div v-if="!viewMode" class="add-question-buttons">
        <Button
          label="Add Question"
          icon="pi pi-plus"
          outlined
          class="add-question-btn"
          @click="handleAddQuestion"
        />
        <Button
          label="AI Assisted"
          icon="pi pi-sparkles"
          outlined
          class="ai-assisted-btn"
          @click="handleAIAssistedGeneration"
          :disabled="!taskName || !taskName.trim()"
        />
      </div>

      <!-- AI Assistance Note - Hidden in view mode -->
      <div v-if="!viewMode && (!taskName || !taskName.trim())" class="info-note warning">
        <p><strong>Note:</strong> Enter a task name first to enable AI-assisted question generation. The AI will analyze your task name and create relevant questions automatically.</p>
      </div>

      <!-- Questions List -->
      <div class="questions-list">
        <div v-for="(question, index) in questions" :key="question.id" class="question-card">
          <div class="question-header" @click="toggleQuestionExpanded(question.id)">
            <div class="question-header-left">
              <div class="question-order">
                <span class="pi pi-bars"></span>
                <span class="question-badge">Q{{ index + 1 }}</span>
              </div>
              <div class="question-preview">
                <p class="question-text">{{ question.question || `Question ${index + 1}` }}</p>
                <div class="question-meta">
                  <span class="meta-badge type-badge">{{ getResponseTypeLabel(question.responseType) }}</span>
                  <span :class="['meta-badge', question.required ? 'required-badge' : 'optional-badge']">
                    {{ question.required ? 'Required' : 'Optional' }}
                  </span>
                </div>
              </div>
            </div>
            <div class="question-header-right">
              <Button
                v-if="!viewMode"
                icon="pi pi-trash"
                text
                rounded
                severity="danger"
                size="small"
                @click.stop="handleDeleteQuestion(question.id)"
              />
              <span :class="['pi', expandedQuestions.has(question.id) ? 'pi-chevron-up' : 'pi-chevron-down']"></span>
            </div>
          </div>

          <div v-if="expandedQuestions.has(question.id)" class="question-content">
            <div class="form-grid-2">
              <div class="field-group">
                <label class="form-label">Response Type</label>
                <Dropdown
                  v-model="question.responseType"
                  :options="responseTypeOptions"
                  optionLabel="label"
                  optionValue="value"
                  @change="handleQuestionChange(question.id, 'responseType', question.responseType)"
                  class="w-full"
                  :disabled="viewMode"
                />
              </div>

              <div class="field-group">
                <label class="form-label">Required</label>
                <div class="required-toggle">
                  <InputSwitch
                    v-model="question.required"
                    @change="handleQuestionChange(question.id, 'required', question.required)"
                    :disabled="viewMode"
                  />
                  <span class="toggle-label">{{ question.required ? 'Required' : 'Optional' }}</span>
                </div>
              </div>
            </div>

            <div class="field-group">
              <label class="form-label">Question</label>
              <Textarea
                v-if="question.responseType === 'text-multiline'"
                v-model="question.question"
                @input="handleQuestionChange(question.id, 'question', question.question)"
                placeholder="Enter your question here..."
                :rows="3"
                class="w-full"
                :disabled="viewMode"
              />
              <InputText
                v-else
                v-model="question.question"
                @input="handleQuestionChange(question.id, 'question', question.question)"
                placeholder="Enter your question here..."
                class="w-full"
                :disabled="viewMode"
              />
            </div>

            <!-- Picklist Options Section -->
            <div v-if="question.responseType === 'picklist-single' || question.responseType === 'picklist-multiple'" class="picklist-section">
              <div class="picklist-header">
                <label class="form-label">Answer Options</label>
                <Button
                  v-if="!viewMode"
                  label="Add Option"
                  icon="pi pi-plus"
                  size="small"
                  outlined
                  @click="addPicklistOption(question.id)"
                />
              </div>

              <div class="info-note primary">
                <p>
                  <strong>Note:</strong> For questionnaires with scoring, check the correct answer option(s).
                  <span v-if="question.responseType === 'picklist-single'" class="info-detail">
                    <strong>Single Selection:</strong> Users can only select one option.
                  </span>
                  <span v-else class="info-detail">
                    <strong>Multiple Selection:</strong> Users can select multiple options.
                  </span>
                </p>
              </div>

              <div class="picklist-options">
                <div v-for="(option, optionIndex) in question.picklistOptions" :key="option.id" class="picklist-option">
                  <div class="option-content">
                    <div class="option-checkbox">
                      <Checkbox
                        v-model="option.isCorrectAnswer"
                        :binary="true"
                        @change="handlePicklistOptionChange(question.id, option.id, 'isCorrectAnswer', option.isCorrectAnswer)"
                        :disabled="viewMode"
                      />
                      <span :class="['correct-label', option.isCorrectAnswer ? 'active' : '']">
                        {{ option.isCorrectAnswer ? '✓ Correct' : 'Correct' }}
                      </span>
                    </div>
                    <InputText
                      v-model="option.text"
                      @input="handlePicklistOptionChange(question.id, option.id, 'text', option.text)"
                      :placeholder="`Option ${optionIndex + 1}`"
                      class="option-input"
                      :disabled="viewMode"
                    />
                    <Button
                      v-if="question.picklistOptions && question.picklistOptions.length > 2 && !viewMode"
                      icon="pi pi-times"
                      text
                      rounded
                      severity="danger"
                      size="small"
                      @click="removePicklistOption(question.id, option.id)"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="questions.length === 0" class="empty-state">
        <div class="empty-icon">
          <span class="pi pi-question-circle"></span>
        </div>
        <p class="empty-title">No questions added yet</p>
        <p class="empty-subtitle">Click "Add Question" to get started</p>
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
import InputSwitch from 'primevue/inputswitch'
import Checkbox from 'primevue/checkbox'

const props = defineProps({
  questions: {
    type: Array,
    default: () => []
  },
  taskName: {
    type: String,
    default: ''
  },
  viewMode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:questions'])

const expandedQuestions = ref(new Set())

const responseTypeOptions = [
  { label: 'Text', value: 'text-single' },
  { label: 'Text (Multiple Lines)', value: 'text-multiline' },
  { label: 'Picklist (Single)', value: 'picklist-single' },
  { label: 'Picklist (Multiple)', value: 'picklist-multiple' }
]

const questions = computed({
  get: () => props.questions,
  set: (val) => emit('update:questions', val)
})

const getResponseTypeLabel = (value) => {
  return responseTypeOptions.find(opt => opt.value === value)?.label || value
}

const toggleQuestionExpanded = (questionId) => {
  if (expandedQuestions.value.has(questionId)) {
    expandedQuestions.value.delete(questionId)
  } else {
    expandedQuestions.value.add(questionId)
  }
}

const handleAddQuestion = () => {
  const newQuestion = {
    id: `question-${Date.now()}`,
    question: '',
    responseType: 'text-single',
    required: false,
    picklistOptions: []
  }
  questions.value.push(newQuestion)
  expandedQuestions.value.add(newQuestion.id)
}

const handleAIAssistedGeneration = () => {
  if (!props.taskName || !props.taskName.trim()) {
    return
  }

  // AI-generated questions based on task name
  const taskName = props.taskName.toLowerCase()
  let generatedQuestions = []

  // Generate contextual questions based on common task keywords
  if (taskName.includes('orientation') || taskName.includes('onboarding')) {
    generatedQuestions = [
      {
        id: `question-${Date.now()}-1`,
        question: 'Did you receive and understand the company handbook?',
        responseType: 'picklist-single',
        required: true,
        picklistOptions: [
          { id: `option-${Date.now()}-1`, text: 'Yes', isCorrectAnswer: true },
          { id: `option-${Date.now()}-2`, text: 'No', isCorrectAnswer: false }
        ]
      },
      {
        id: `question-${Date.now()}-2`,
        question: 'What is your understanding of the company mission and values?',
        responseType: 'text-multiline',
        required: true,
        picklistOptions: []
      },
      {
        id: `question-${Date.now()}-3`,
        question: 'Have you completed all necessary documentation?',
        responseType: 'picklist-single',
        required: true,
        picklistOptions: [
          { id: `option-${Date.now()}-3`, text: 'Yes, all completed', isCorrectAnswer: true },
          { id: `option-${Date.now()}-4`, text: 'Some pending', isCorrectAnswer: false },
          { id: `option-${Date.now()}-5`, text: 'Not started', isCorrectAnswer: false }
        ]
      }
    ]
  } else if (taskName.includes('training') || taskName.includes('learning')) {
    generatedQuestions = [
      {
        id: `question-${Date.now()}-1`,
        question: 'Rate your understanding of the training content',
        responseType: 'picklist-single',
        required: true,
        picklistOptions: [
          { id: `option-${Date.now()}-1`, text: 'Excellent', isCorrectAnswer: true },
          { id: `option-${Date.now()}-2`, text: 'Good', isCorrectAnswer: false },
          { id: `option-${Date.now()}-3`, text: 'Fair', isCorrectAnswer: false },
          { id: `option-${Date.now()}-4`, text: 'Poor', isCorrectAnswer: false }
        ]
      },
      {
        id: `question-${Date.now()}-2`,
        question: 'What topics would you like more clarification on?',
        responseType: 'text-multiline',
        required: false,
        picklistOptions: []
      },
      {
        id: `question-${Date.now()}-3`,
        question: 'Can you apply what you learned to your role?',
        responseType: 'picklist-single',
        required: true,
        picklistOptions: [
          { id: `option-${Date.now()}-5`, text: 'Yes, fully', isCorrectAnswer: true },
          { id: `option-${Date.now()}-6`, text: 'Partially', isCorrectAnswer: false },
          { id: `option-${Date.now()}-7`, text: 'Not yet', isCorrectAnswer: false }
        ]
      }
    ]
  } else if (taskName.includes('feedback') || taskName.includes('survey') || taskName.includes('evaluation')) {
    generatedQuestions = [
      {
        id: `question-${Date.now()}-1`,
        question: 'How would you rate your overall experience?',
        responseType: 'picklist-single',
        required: true,
        picklistOptions: [
          { id: `option-${Date.now()}-1`, text: 'Excellent', isCorrectAnswer: true },
          { id: `option-${Date.now()}-2`, text: 'Very Good', isCorrectAnswer: false },
          { id: `option-${Date.now()}-3`, text: 'Good', isCorrectAnswer: false },
          { id: `option-${Date.now()}-4`, text: 'Fair', isCorrectAnswer: false },
          { id: `option-${Date.now()}-5`, text: 'Poor', isCorrectAnswer: false }
        ]
      },
      {
        id: `question-${Date.now()}-2`,
        question: 'What did you like most?',
        responseType: 'text-multiline',
        required: false,
        picklistOptions: []
      },
      {
        id: `question-${Date.now()}-3`,
        question: 'What areas need improvement?',
        responseType: 'text-multiline',
        required: false,
        picklistOptions: []
      }
    ]
  } else if (taskName.includes('exit') || taskName.includes('offboarding')) {
    generatedQuestions = [
      {
        id: `question-${Date.now()}-1`,
        question: 'What is your primary reason for leaving?',
        responseType: 'picklist-single',
        required: true,
        picklistOptions: [
          { id: `option-${Date.now()}-1`, text: 'Career advancement', isCorrectAnswer: false },
          { id: `option-${Date.now()}-2`, text: 'Better compensation', isCorrectAnswer: false },
          { id: `option-${Date.now()}-3`, text: 'Work-life balance', isCorrectAnswer: false },
          { id: `option-${Date.now()}-4`, text: 'Personal reasons', isCorrectAnswer: false },
          { id: `option-${Date.now()}-5`, text: 'Other', isCorrectAnswer: false }
        ]
      },
      {
        id: `question-${Date.now()}-2`,
        question: 'Would you recommend this company to others?',
        responseType: 'picklist-single',
        required: true,
        picklistOptions: [
          { id: `option-${Date.now()}-6`, text: 'Yes', isCorrectAnswer: true },
          { id: `option-${Date.now()}-7`, text: 'No', isCorrectAnswer: false },
          { id: `option-${Date.now()}-8`, text: 'Maybe', isCorrectAnswer: false }
        ]
      },
      {
        id: `question-${Date.now()}-3`,
        question: 'Any additional feedback or suggestions?',
        responseType: 'text-multiline',
        required: false,
        picklistOptions: []
      }
    ]
  } else {
    // Default generic questions
    generatedQuestions = [
      {
        id: `question-${Date.now()}-1`,
        question: `How would you rate your experience with ${props.taskName}?`,
        responseType: 'picklist-single',
        required: true,
        picklistOptions: [
          { id: `option-${Date.now()}-1`, text: 'Excellent', isCorrectAnswer: true },
          { id: `option-${Date.now()}-2`, text: 'Good', isCorrectAnswer: false },
          { id: `option-${Date.now()}-3`, text: 'Fair', isCorrectAnswer: false },
          { id: `option-${Date.now()}-4`, text: 'Poor', isCorrectAnswer: false }
        ]
      },
      {
        id: `question-${Date.now()}-2`,
        question: `What aspects of ${props.taskName} were most helpful?`,
        responseType: 'text-multiline',
        required: false,
        picklistOptions: []
      },
      {
        id: `question-${Date.now()}-3`,
        question: 'Do you have any suggestions for improvement?',
        responseType: 'text-multiline',
        required: false,
        picklistOptions: []
      }
    ]
  }

  // Add generated questions to the list and expand them
  generatedQuestions.forEach(q => {
    questions.value.push(q)
    expandedQuestions.value.add(q.id)
  })
}

const handleDeleteQuestion = (questionId) => {
  questions.value = questions.value.filter(q => q.id !== questionId)
  expandedQuestions.value.delete(questionId)
}

const handleQuestionChange = (questionId, field, value) => {
  const questionIndex = questions.value.findIndex(q => q.id === questionId)
  if (questionIndex !== -1) {
    questions.value[questionIndex][field] = value

    // Initialize picklist options if changing to picklist type
    if (field === 'responseType' && (value === 'picklist-single' || value === 'picklist-multiple')) {
      if (!questions.value[questionIndex].picklistOptions || questions.value[questionIndex].picklistOptions.length === 0) {
        questions.value[questionIndex].picklistOptions = [
          { id: `option-${Date.now()}-1`, text: '', isCorrectAnswer: false },
          { id: `option-${Date.now()}-2`, text: '', isCorrectAnswer: false }
        ]
      }
    }
  }
}

const addPicklistOption = (questionId) => {
  const questionIndex = questions.value.findIndex(q => q.id === questionId)
  if (questionIndex !== -1) {
    if (!questions.value[questionIndex].picklistOptions) {
      questions.value[questionIndex].picklistOptions = []
    }
    questions.value[questionIndex].picklistOptions.push({
      id: `option-${Date.now()}`,
      text: '',
      isCorrectAnswer: false
    })
  }
}

const removePicklistOption = (questionId, optionId) => {
  const questionIndex = questions.value.findIndex(q => q.id === questionId)
  if (questionIndex !== -1 && questions.value[questionIndex].picklistOptions) {
    questions.value[questionIndex].picklistOptions = questions.value[questionIndex].picklistOptions.filter(
      opt => opt.id !== optionId
    )
  }
}

const handlePicklistOptionChange = (questionId, optionId, field, value) => {
  const questionIndex = questions.value.findIndex(q => q.id === questionId)
  if (questionIndex !== -1 && questions.value[questionIndex].picklistOptions) {
    // If marking as correct answer and it's a single selection picklist
    if (field === 'isCorrectAnswer' && value === true && questions.value[questionIndex].responseType === 'picklist-single') {
      // Uncheck all other options first
      questions.value[questionIndex].picklistOptions.forEach(opt => {
        opt.isCorrectAnswer = false
      })
    }

    const optionIndex = questions.value[questionIndex].picklistOptions.findIndex(opt => opt.id === optionId)
    if (optionIndex !== -1) {
      questions.value[questionIndex].picklistOptions[optionIndex][field] = value
    }
  }
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

.question-count-badge {
  background-color: #e2e8f0;
  color: #1e293b;
  padding: 4px 12px;
  border-radius: var(--radius-sm);
  font-size: 12px;
  font-weight: 600;
}

.config-body {
  padding: var(--spacing-3);
  background-color: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.add-question-buttons {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-3);
  margin-bottom: var(--spacing-4);
}

.add-question-btn :deep(.p-button) {
  border: 2px dashed #cbd5e1;
}

.add-question-btn :deep(.p-button:hover) {
  border-color: #94a3b8;
  background-color: #f8fafc;
}

.ai-assisted-btn :deep(.p-button) {
  border: 2px dashed var(--primary-color);
  color: var(--primary-color);
}

.ai-assisted-btn :deep(.p-button:hover:not(:disabled)) {
  background-color: var(--primary-color);
  opacity: 0.1;
}

.info-note {
  padding: var(--spacing-3);
  border-radius: var(--radius-md);
  font-size: 12px;
  margin-bottom: var(--spacing-4);
}

.info-note.warning {
  background-color: #fffbeb;
  border: 1px solid #fcd34d;
  color: #92400e;
}

.info-note.primary {
  background-color: #eff6ff;
  border: 1px solid #93c5fd;
  color: #1e40af;
}

.info-note p {
  margin: 0;
}

.info-detail {
  display: block;
  margin-top: 4px;
}

.questions-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.question-card {
  border: 1px solid #e2e8f0;
  border-radius: var(--radius-md);
  background-color: white;
  overflow: hidden;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-3);
  cursor: pointer;
  transition: background-color 0.2s;
}

.question-header:hover {
  background-color: #f8fafc;
}

.question-header-left {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
  flex: 1;
}

.question-order {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.question-order .pi-bars {
  color: #94a3b8;
  font-size: 14px;
}

.question-badge {
  background-color: white;
  border: 1px solid #e2e8f0;
  padding: 2px 8px;
  border-radius: var(--radius-sm);
  font-size: 11px;
  font-weight: 600;
}

.question-preview {
  flex: 1;
}

.question-text {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  margin: 0 0 4px 0;
}

.question-meta {
  display: flex;
  gap: var(--spacing-2);
}

.meta-badge {
  padding: 2px 8px;
  border-radius: var(--radius-sm);
  font-size: 11px;
  font-weight: 600;
}

.type-badge {
  background-color: #e2e8f0;
  color: #475569;
}

.required-badge {
  background-color: var(--primary-color);
  color: white;
}

.optional-badge {
  background-color: #e2e8f0;
  color: #64748b;
}

.question-header-right {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.question-content {
  padding: var(--spacing-4);
  border-top: 1px solid #e2e8f0;
  background-color: #f8fafc;
}

.form-grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-3);
  margin-bottom: var(--spacing-3);
}

.field-group {
  margin-bottom: var(--spacing-3);
}

.field-group:last-child {
  margin-bottom: 0;
}

.required-toggle {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  margin-top: var(--spacing-2);
}

.toggle-label {
  font-size: 13px;
  color: var(--color-gray-600);
}

.picklist-section {
  margin-top: var(--spacing-4);
}

.picklist-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-3);
}

.picklist-options {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.picklist-option {
  border: 1px solid #e2e8f0;
  border-radius: var(--radius-md);
  padding: var(--spacing-3);
  background-color: white;
}

.option-content {
  display: flex;
  align-items: flex-start;
  gap: var(--spacing-3);
}

.option-checkbox {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
  margin-top: 8px;
}

.correct-label {
  font-size: 11px;
  color: #22c55e;
  white-space: nowrap;
}

.correct-label.active {
  font-weight: 600;
}

.option-input {
  flex: 1;
}

.empty-state {
  text-align: center;
  padding: var(--spacing-6) var(--spacing-4);
  color: #64748b;
}

.empty-icon {
  width: 64px;
  height: 64px;
  background-color: #f1f5f9;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto var(--spacing-3);
}

.empty-icon .pi {
  font-size: 32px;
  color: #94a3b8;
}

.empty-title {
  font-weight: 500;
  font-size: 14px;
  margin: 0 0 4px 0;
}

.empty-subtitle {
  font-size: 13px;
  margin: 0;
}

.w-full {
  width: 100%;
}
</style>
