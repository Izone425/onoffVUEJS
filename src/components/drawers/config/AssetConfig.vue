<template>
  <div class="form-section">
    <div class="config-header orange">
      <div class="header-content">
        <div class="header-icon orange">
          <span class="pi pi-box"></span>
        </div>
        <div class="header-text">
          <label class="form-label">Asset Management</label>
          <p class="header-description">Configure which assets need to be issued or collected for this task</p>
        </div>
      </div>
    </div>

    <div class="config-body">
      <div class="section-header">
        <label class="form-label">Assets to Manage</label>
        <Button
          v-if="!viewMode"
          label="Add Asset"
          icon="pi pi-plus"
          size="small"
          outlined
          @click="handleAddAsset"
        />
      </div>

      <p class="form-help">Add assets that need to be issued to employees or collected during this task</p>

      <!-- Assets List -->
      <div v-if="localAssetItems.length > 0" class="assets-list">
        <div v-for="(asset, index) in localAssetItems" :key="asset.id" class="asset-card">
          <div class="asset-header">
            <span class="asset-number">#{{ index + 1 }}</span>
            <Button
              v-if="!viewMode"
              icon="pi pi-trash"
              text
              rounded
              severity="danger"
              size="small"
              @click="handleRemoveAsset(asset.id)"
            />
          </div>

          <div class="asset-body">
            <div class="field-group">
              <label class="field-label">Asset Name {{ viewMode ? '' : '*' }}</label>
              <InputText
                v-model="asset.name"
                placeholder="e.g., Laptop Computer, Employee ID Card, Mobile Phone"
                class="w-full"
                :disabled="viewMode"
              />
            </div>

            <div class="field-group">
              <label class="field-label">Description {{ viewMode ? '' : '*' }}</label>
              <Textarea
                v-model="asset.description"
                placeholder="Brief description of the asset and any special instructions..."
                :rows="2"
                class="w-full"
                :disabled="viewMode"
              />
            </div>

            <div class="handover-toggle">
              <div class="toggle-content">
                <label class="toggle-label">Upload Hand-over Letter</label>
                <p class="toggle-description">{{ viewMode ? (asset.handoverLetter ? 'Hand-over letter is required' : 'No hand-over letter required') : 'Enable if this asset requires a hand-over letter to be uploaded' }}</p>
              </div>
              <InputSwitch v-model="asset.handoverLetter" :disabled="viewMode" />
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <div class="empty-icon">
          <span class="pi pi-box"></span>
        </div>
        <p class="empty-title">No assets configured yet</p>
        <p class="empty-text">Click "Add Asset" to get started</p>
      </div>

      <div v-if="localAssetItems.length > 0" class="info-box">
        <p><strong>Example:</strong> For onboarding tasks, you might add: Laptop → Employee ID Card → Mobile Phone, each with specific handover requirements and assigned PICs.</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Textarea from 'primevue/textarea'
import InputSwitch from 'primevue/inputswitch'

const props = defineProps({
  assetItems: {
    type: Array,
    default: () => []
  },
  viewMode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:assetItems'])

const localAssetItems = computed({
  get: () => props.assetItems,
  set: (val) => emit('update:assetItems', val)
})

const handleAddAsset = () => {
  const newAsset = {
    id: `asset-${Date.now()}`,
    name: '',
    description: '',
    handoverLetter: false
  }
  localAssetItems.value.push(newAsset)
}

const handleRemoveAsset = (assetId) => {
  localAssetItems.value = localAssetItems.value.filter(a => a.id !== assetId)
}
</script>

<style scoped>
.config-header {
  padding: var(--spacing-3);
  border-radius: var(--radius-md);
  margin-bottom: var(--spacing-4);
}

.config-header.orange {
  background-color: #fff7ed;
  border: 1px solid #fed7aa;
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

.header-icon.orange {
  background-color: #fdba74;
  color: #c2410c;
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

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-2);
}

.assets-list {
  margin-top: var(--spacing-3);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.asset-card {
  background-color: white;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: var(--spacing-3);
}

.asset-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-3);
}

.asset-number {
  font-size: 12px;
  font-weight: 600;
  color: var(--color-gray-600);
  padding: 4px 8px;
  background-color: var(--color-gray-100);
  border-radius: var(--radius-sm);
}

.asset-body {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-3);
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-1);
}

.field-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.handover-toggle {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-3);
  background-color: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: var(--radius-md);
}

.toggle-content {
  flex: 1;
}

.toggle-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  display: block;
}

.toggle-description {
  font-size: 12px;
  color: var(--color-gray-600);
  margin-top: 2px;
}

.empty-state {
  text-align: center;
  padding: var(--spacing-6) var(--spacing-3);
  color: var(--color-gray-500);
}

.empty-icon {
  width: 48px;
  height: 48px;
  background-color: var(--color-gray-100);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto var(--spacing-2);
}

.empty-icon .pi {
  font-size: 24px;
}

.empty-title {
  font-weight: 500;
  color: var(--color-gray-900);
  margin-bottom: var(--spacing-1);
}

.empty-text {
  font-size: 13px;
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
