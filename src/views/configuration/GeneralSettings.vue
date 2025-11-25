<template>
  <div class="page-container">
      <div class="page-header">
        <h1 class="text-h1">General Settings</h1>
        <p class="page-description">Configure global onboarding and offboarding behavior</p>
      </div>

      <div class="settings-card">
        <form @submit.prevent="saveSettings">
          <div class="settings-section">
            <h2 class="section-title">Duration Settings</h2>
            <div class="form-grid">
              <div class="form-field">
                <label class="form-label">
                  Onboarding Duration (days)
                  <span class="required">*</span>
                </label>
                <InputNumber
                  v-model="settings.onboardingDuration"
                  :min="1"
                  :max="365"
                  showButtons
                  class="w-full"
                />
                <small class="form-help">Default: 30 days</small>
              </div>

              <div class="form-field">
                <label class="form-label">
                  Offboarding Duration (days)
                  <span class="required">*</span>
                </label>
                <InputNumber
                  v-model="settings.offboardingDuration"
                  :min="1"
                  :max="90"
                  showButtons
                  class="w-full"
                />
                <small class="form-help">Default: 14 days</small>
              </div>
            </div>
          </div>

          <div class="settings-section">
            <h2 class="section-title">Reminder Settings</h2>
            <div class="form-grid">
              <div class="form-field">
                <label class="form-label">Reminder Cadence</label>
                <Dropdown
                  v-model="settings.reminderCadence"
                  :options="reminderOptions"
                  optionLabel="label"
                  optionValue="value"
                  placeholder="Select frequency"
                  class="w-full"
                  @change="onReminderCadenceChange"
                />
                <div v-if="settings.reminderCadence === 'custom'" class="custom-days-input">
                  <InputNumber
                    v-model="settings.customReminderDays"
                    :min="1"
                    :max="365"
                    placeholder="Enter number of days"
                    suffix=" days"
                    class="w-full"
                  />
                  <small class="form-help">Enter a custom number of days (1-365)</small>
                </div>
              </div>

              <div class="form-field">
                <label class="form-label">Business Days Only</label>
                <div class="toggle-field">
                  <InputSwitch v-model="settings.businessDaysOnly" />
                  <span class="toggle-label">{{ settings.businessDaysOnly ? 'Enabled' : 'Disabled' }}</span>
                </div>
                <small class="form-help">Skip weekends and public holidays</small>
              </div>
            </div>
          </div>

          <div class="settings-section">
            <h2 class="section-title">Default Templates</h2>
            <div class="form-grid">
              <div class="form-field">
                <label class="form-label">Default Appraisal Template</label>
                <Dropdown
                  v-model="settings.defaultAppraisalTemplate"
                  :options="appraisalTemplates"
                  optionLabel="name"
                  optionValue="name"
                  placeholder="Select template"
                  class="w-full"
                />
              </div>
            </div>
          </div>

          <div class="settings-section">
            <h2 class="section-title">Localization</h2>
            <div class="form-grid">
              <div class="form-field">
                <label class="form-label">Timezone</label>
                <Dropdown
                  v-model="settings.timezone"
                  :options="timezones"
                  optionLabel="label"
                  optionValue="value"
                  placeholder="Select timezone"
                  class="w-full"
                  filter
                />
              </div>

              <div class="form-field">
                <label class="form-label">Locale</label>
                <Dropdown
                  v-model="settings.locale"
                  :options="locales"
                  optionLabel="label"
                  optionValue="value"
                  placeholder="Select locale"
                  class="w-full"
                />
              </div>
            </div>
          </div>

          <!-- Communication Templates Section -->
          <div class="settings-section templates-section-inner">
            <div class="section-header-with-icon">
              <span class="pi pi-send section-icon-small"></span>
              <div>
                <h2 class="section-title">Communication Templates</h2>
                <p class="section-subtitle">Manage email and SMS templates for notifications</p>
              </div>
            </div>

            <div class="templates-grid">
              <!-- Email Templates Card -->
              <div class="template-card email-card">
                <div class="template-card-header">
                  <div class="template-card-title">
                    <span class="pi pi-envelope template-icon email"></span>
                    <div>
                      <h3>Email Templates</h3>
                      <span class="template-count">{{ emailTemplates.length }} templates</span>
                    </div>
                  </div>
                  <Button
                    icon="pi pi-plus"
                    label="Add New"
                    size="small"
                    outlined
                    @click="createEmailTemplate"
                  />
                </div>
                <div class="template-list">
                  <div
                    v-for="template in emailTemplates"
                    :key="template.id"
                    class="template-item"
                    @click="openEmailTemplate(template)"
                  >
                    <div class="template-item-left">
                      <div class="template-item-icon email">
                        <span class="pi pi-envelope"></span>
                      </div>
                      <div class="template-item-info">
                        <h4 class="template-name">{{ template.name }}</h4>
                        <div class="template-meta">
                          <Tag
                            :value="template.status"
                            :severity="template.status === 'active' ? 'success' : 'warn'"
                            class="template-status"
                          />
                          <span class="template-date">Updated {{ formatDate(template.lastUpdated) }}</span>
                        </div>
                      </div>
                    </div>
                    <div class="template-item-actions">
                      <Button
                        icon="pi pi-pencil"
                        text
                        rounded
                        size="small"
                        @click.stop="openEmailTemplate(template, true)"
                      />
                      <Button
                        icon="pi pi-eye"
                        text
                        rounded
                        size="small"
                        @click.stop="openEmailTemplate(template)"
                      />
                    </div>
                  </div>
                </div>
              </div>

              <!-- SMS Templates Card -->
              <div class="template-card sms-card">
                <div class="template-card-header">
                  <div class="template-card-title">
                    <span class="pi pi-comments template-icon sms"></span>
                    <div>
                      <h3>SMS Templates</h3>
                      <span class="template-count">{{ smsTemplates.length }} templates</span>
                    </div>
                  </div>
                  <Button
                    icon="pi pi-plus"
                    label="Add New"
                    size="small"
                    outlined
                    @click="createSMSTemplate"
                  />
                </div>
                <div class="template-list">
                  <div
                    v-for="template in smsTemplates"
                    :key="template.id"
                    class="template-item"
                    @click="openSMSTemplate(template)"
                  >
                    <div class="template-item-left">
                      <div class="template-item-icon sms">
                        <span class="pi pi-comments"></span>
                      </div>
                      <div class="template-item-info">
                        <h4 class="template-name">{{ template.name }}</h4>
                        <div class="template-meta">
                          <Tag
                            :value="template.status"
                            :severity="template.status === 'active' ? 'success' : 'warn'"
                            class="template-status"
                          />
                          <span class="template-date">Updated {{ formatDate(template.lastUpdated) }}</span>
                        </div>
                      </div>
                    </div>
                    <div class="template-item-actions">
                      <Button
                        icon="pi pi-pencil"
                        text
                        rounded
                        size="small"
                        @click.stop="openSMSTemplate(template, true)"
                      />
                      <Button
                        icon="pi pi-eye"
                        text
                        rounded
                        size="small"
                        @click.stop="openSMSTemplate(template)"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="form-actions">
            <Button label="Cancel" severity="secondary" @click="resetSettings" outlined />
            <Button label="Save Changes" type="submit" :loading="saving" />
          </div>
        </form>
      </div>

      <!-- Email Template Drawer -->
      <EmailTemplateDrawer
        v-model="showEmailDrawer"
        :template="selectedEmailTemplate"
        @save="handleEmailTemplateSave"
      />

      <!-- SMS Template Drawer -->
      <SMSTemplateDrawer
        v-model="showSMSDrawer"
        :template="selectedSMSTemplate"
        @save="handleSMSTemplateSave"
      />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useToast } from 'primevue/usetoast'
import InputNumber from 'primevue/inputnumber'
import Dropdown from 'primevue/dropdown'
import InputSwitch from 'primevue/inputswitch'
import Button from 'primevue/button'
import Tag from 'primevue/tag'
import { generalSettings, appraisalTemplates } from '../../data/mockData'
import EmailTemplateDrawer from '../../components/drawers/config/EmailTemplateDrawer.vue'
import SMSTemplateDrawer from '../../components/drawers/config/SMSTemplateDrawer.vue'

const toast = useToast()
const saving = ref(false)
const settings = ref({
  ...generalSettings,
  customReminderDays: 5 // Default custom value
})

// Email Templates
const emailTemplates = ref([
  {
    id: 1,
    name: 'Welcome Email',
    status: 'active',
    lastUpdated: '2025-08-15',
    category: 'Onboarding',
    triggerEvent: 'new_hire',
    subject: 'Welcome to {{company_name}}, {{employee_name}}!',
    body: `Dear {{employee_name}},

Welcome to {{company_name}}! We are thrilled to have you join our team as {{position}} in the {{department}} department.

Your start date is {{start_date}}. Please arrive at 9:00 AM and ask for {{manager_name}} at the reception.

Before your first day, please complete the following tasks in our employee portal:
{{portal_link}}

If you have any questions, please don't hesitate to reach out to HR at {{hr_contact}}.

We look forward to seeing you!

Best regards,
The HR Team
{{company_name}}`,
    ccHR: true,
    ccManager: true,
    includeAttachments: true,
    trackOpens: true
  },
  {
    id: 2,
    name: 'Task Reminder',
    status: 'active',
    lastUpdated: '2025-08-10',
    category: 'Notification',
    triggerEvent: 'task_reminder',
    subject: 'Reminder: {{task_name}} is due on {{due_date}}',
    body: `Hi {{employee_name}},

This is a friendly reminder that the following task requires your attention:

Task: {{task_name}}
Due Date: {{due_date}}

Please complete this task as soon as possible. You can access it through the employee portal:
{{portal_link}}

If you have any questions, please contact your manager {{manager_name}}.

Best regards,
TimeTec HR System`,
    ccHR: false,
    ccManager: false,
    includeAttachments: false,
    trackOpens: true
  },
  {
    id: 3,
    name: 'Escalation Notice',
    status: 'draft',
    lastUpdated: '2025-08-20',
    category: 'Escalation',
    triggerEvent: 'escalation',
    subject: 'URGENT: Escalation - {{task_name}} for {{employee_name}}',
    body: `Dear {{manager_name}},

This is an escalation notice regarding an overdue task that requires immediate attention.

Employee: {{employee_name}}
Task: {{task_name}}
Original Due Date: {{due_date}}
Department: {{department}}

Please take appropriate action to ensure this task is completed.

View details: {{portal_link}}

Best regards,
HR System`,
    ccHR: true,
    ccManager: false,
    includeAttachments: false,
    trackOpens: true
  },
  {
    id: 4,
    name: 'Exit Interview Invite',
    status: 'active',
    lastUpdated: '2025-07-25',
    category: 'Offboarding',
    triggerEvent: 'exit_interview',
    subject: 'Exit Interview Invitation - {{company_name}}',
    body: `Dear {{employee_name}},

As part of our offboarding process, we would like to invite you to an exit interview.

This is an opportunity for you to share your feedback and experiences during your time at {{company_name}}.

Please coordinate with HR at {{hr_contact}} to schedule a convenient time.

We appreciate your contributions and wish you all the best in your future endeavors.

Best regards,
The HR Team
{{company_name}}`,
    ccHR: true,
    ccManager: false,
    includeAttachments: false,
    trackOpens: true
  }
])

// SMS Templates
const smsTemplates = ref([
  {
    id: 1,
    name: 'Task Due Reminder',
    status: 'active',
    lastUpdated: '2025-08-12',
    triggerEvent: 'task_reminder',
    message: 'Hi {{name}}, reminder: "{{task}}" is due {{due}}. Complete it now: {{link}} - {{company}}',
    urgent: false,
    deliveryReport: true,
    businessHoursOnly: true
  },
  {
    id: 2,
    name: 'Urgent Action Required',
    status: 'active',
    lastUpdated: '2025-08-18',
    triggerEvent: 'urgent_action',
    message: 'URGENT: {{name}}, task "{{task}}" requires immediate action. Due: {{due}}. Act now: {{link}}',
    urgent: true,
    deliveryReport: true,
    businessHoursOnly: false
  },
  {
    id: 3,
    name: 'Welcome SMS',
    status: 'active',
    lastUpdated: '2025-08-05',
    triggerEvent: 'welcome',
    message: 'Welcome to {{company}}, {{name}}! We are excited to have you. Check your email for details. - HR Team',
    urgent: false,
    deliveryReport: true,
    businessHoursOnly: true
  }
])

// Template drawer states
const showEmailDrawer = ref(false)
const showSMSDrawer = ref(false)
const selectedEmailTemplate = ref(null)
const selectedSMSTemplate = ref(null)

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-MY', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

const openEmailTemplate = (template, editMode = false) => {
  selectedEmailTemplate.value = { ...template, editMode }
  showEmailDrawer.value = true
}

const openSMSTemplate = (template, editMode = false) => {
  selectedSMSTemplate.value = { ...template, editMode }
  showSMSDrawer.value = true
}

const createEmailTemplate = () => {
  const newTemplate = {
    id: Date.now(),
    name: 'New Email Template',
    status: 'draft',
    lastUpdated: new Date().toISOString().split('T')[0],
    category: 'Notification',
    triggerEvent: 'new_hire',
    subject: '',
    body: '',
    ccHR: false,
    ccManager: false,
    includeAttachments: false,
    trackOpens: true,
    editMode: true
  }
  selectedEmailTemplate.value = newTemplate
  showEmailDrawer.value = true
}

const createSMSTemplate = () => {
  const newTemplate = {
    id: Date.now(),
    name: 'New SMS Template',
    status: 'draft',
    lastUpdated: new Date().toISOString().split('T')[0],
    triggerEvent: 'task_reminder',
    message: '',
    urgent: false,
    deliveryReport: true,
    businessHoursOnly: true,
    editMode: true
  }
  selectedSMSTemplate.value = newTemplate
  showSMSDrawer.value = true
}

const handleEmailTemplateSave = (updatedTemplate) => {
  const index = emailTemplates.value.findIndex(t => t.id === updatedTemplate.id)
  if (index !== -1) {
    emailTemplates.value[index] = updatedTemplate
  } else {
    emailTemplates.value.push(updatedTemplate)
  }
}

const handleSMSTemplateSave = (updatedTemplate) => {
  const index = smsTemplates.value.findIndex(t => t.id === updatedTemplate.id)
  if (index !== -1) {
    smsTemplates.value[index] = updatedTemplate
  } else {
    smsTemplates.value.push(updatedTemplate)
  }
}

const reminderOptions = [
  { label: 'Never', value: 'never' },
  { label: 'Daily', value: 'daily' },
  { label: 'Weekly', value: 'weekly' },
  { label: 'Custom (Every X days)', value: 'custom' }
]

const onReminderCadenceChange = (event) => {
  // If custom is selected, ensure customReminderDays has a default value
  if (event.value === 'custom' && !settings.value.customReminderDays) {
    settings.value.customReminderDays = 5
  }
}

const timezones = [
  { label: 'Asia/Kuala Lumpur (GMT+8)', value: 'Asia/Kuala_Lumpur' },
  { label: 'Asia/Singapore (GMT+8)', value: 'Asia/Singapore' },
  { label: 'Asia/Bangkok (GMT+7)', value: 'Asia/Bangkok' },
  { label: 'UTC', value: 'UTC' }
]

const locales = [
  { label: 'English (Malaysia)', value: 'en-MY' },
  { label: 'English (US)', value: 'en-US' },
  { label: 'Bahasa Malaysia', value: 'ms-MY' }
]

const saveSettings = async () => {
  // Validate custom reminder days if custom is selected
  if (settings.value.reminderCadence === 'custom') {
    if (!settings.value.customReminderDays || settings.value.customReminderDays < 1) {
      toast.add({
        severity: 'error',
        summary: 'Validation Error',
        detail: 'Please enter a valid number of days (1-365)',
        life: 3000
      })
      return
    }
  }

  saving.value = true
  // Simulate API call
  setTimeout(() => {
    saving.value = false
    const reminderDetail = settings.value.reminderCadence === 'custom'
      ? `Every ${settings.value.customReminderDays} days`
      : reminderOptions.find(opt => opt.value === settings.value.reminderCadence)?.label

    toast.add({
      severity: 'success',
      summary: 'Settings Saved',
      detail: `Reminder cadence set to: ${reminderDetail}`,
      life: 3000
    })
  }, 1000)
}

const resetSettings = () => {
  settings.value = { ...generalSettings }
}
</script>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: var(--spacing-4);
}

.page-description {
  color: var(--color-gray-600);
  margin-top: var(--spacing-1);
}

/* Communication Templates Section */
.templates-section-inner {
  border-bottom: none !important;
}

.section-header-with-icon {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
  margin-bottom: var(--spacing-4);
}

.section-icon-small {
  font-size: 20px;
  color: var(--color-primary-600);
  padding: 10px;
  background-color: var(--color-primary-50);
  border-radius: var(--radius-md);
}

.section-subtitle {
  font-size: 12px;
  color: var(--color-gray-500);
  margin: 2px 0 0 0;
}

.templates-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-4);
}

@media (max-width: 900px) {
  .templates-grid {
    grid-template-columns: 1fr;
  }
}

.template-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.template-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--spacing-3) var(--spacing-4);
  background-color: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
}

.template-card-title {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
}

.template-card-title h3 {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.template-icon {
  font-size: 20px;
  padding: 10px;
  border-radius: var(--radius-md);
}

.template-icon.email {
  background-color: #dbeafe;
  color: #1d4ed8;
}

.template-icon.sms {
  background-color: #dcfce7;
  color: #16a34a;
}

.template-count {
  font-size: 12px;
  color: var(--color-gray-500);
}

.template-list {
  padding: var(--spacing-2);
  max-height: 320px;
  overflow-y: auto;
}

.template-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--spacing-3);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s;
}

.template-item:hover {
  background-color: var(--color-gray-50);
}

.template-item-left {
  display: flex;
  align-items: center;
  gap: var(--spacing-3);
  flex: 1;
  min-width: 0;
}

.template-item-icon {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.template-item-icon.email {
  background-color: #eff6ff;
  color: #3b82f6;
}

.template-item-icon.sms {
  background-color: #f0fdf4;
  color: #22c55e;
}

.template-item-icon .pi {
  font-size: 14px;
}

.template-item-info {
  flex: 1;
  min-width: 0;
}

.template-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
  margin: 0 0 4px 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.template-meta {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.template-status {
  font-size: 10px;
  padding: 2px 6px;
}

.template-date {
  font-size: 11px;
  color: var(--color-gray-500);
}

.template-item-actions {
  display: flex;
  gap: 2px;
  opacity: 0;
  transition: opacity 0.2s;
}

.template-item:hover .template-item-actions {
  opacity: 1;
}

.settings-card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  padding: var(--spacing-4);
}

.settings-section {
  padding: var(--spacing-4) 0;
  border-bottom: 1px solid var(--color-divider);
}

.settings-section:first-child {
  padding-top: 0;
}

.settings-section:last-of-type {
  border-bottom: none;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin-bottom: var(--spacing-3);
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: var(--spacing-4);
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-1);
}

.form-label {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.required {
  color: var(--color-danger);
}

.form-help {
  font-size: 12px;
  color: var(--color-gray-500);
}

.toggle-field {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.toggle-label {
  font-size: 14px;
  color: var(--color-gray-700);
}

.custom-days-input {
  margin-top: var(--spacing-2);
  padding: var(--spacing-2);
  background-color: var(--color-surface);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  animation: slideDown 0.2s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-2);
  margin-top: var(--spacing-4);
  padding-top: var(--spacing-4);
  border-top: 1px solid var(--color-divider);
}

.w-full {
  width: 100%;
}
</style>
