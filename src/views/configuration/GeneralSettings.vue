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
                />
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

          <div class="form-actions">
            <Button label="Cancel" severity="secondary" @click="resetSettings" outlined />
            <Button label="Save Changes" type="submit" :loading="saving" />
          </div>
        </form>
      </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useToast } from 'primevue/usetoast'
import InputNumber from 'primevue/inputnumber'
import Dropdown from 'primevue/dropdown'
import InputSwitch from 'primevue/inputswitch'
import Button from 'primevue/button'
import { generalSettings, appraisalTemplates } from '../../data/mockData'

const toast = useToast()
const saving = ref(false)
const settings = ref({ ...generalSettings })

const reminderOptions = [
  { label: 'Never', value: 'never' },
  { label: 'Daily', value: 'daily' },
  { label: 'Every 3 days', value: 'every_3_days' },
  { label: 'Weekly', value: 'weekly' }
]

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
  saving.value = true
  // Simulate API call
  setTimeout(() => {
    saving.value = false
    toast.add({
      severity: 'success',
      summary: 'Settings Saved',
      detail: 'General settings have been updated successfully',
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
