<template>
  <main class="analysis-card">
    <h2>Rooting Analysis</h2>
    <div class="form-grid">
      <div class="form-group">
        <div class="label-with-button">
          <label for="gene-ids">Input Gene IDs: <span class="required">*</span></label>
          <div class="action-buttons">
            <button
              @click="loadExampleData"
              class="example-button"
              :disabled="!hasExampleData"
              :title="hasExampleData ? '' : 'No example data is available for this species'"
            >
              Use Example Data
            </button>
            <button @click="triggerFileUpload" class="upload-button">
              <svg
                width="14"
                height="14"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2.5"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="17 8 12 3 7 8"></polyline>
                <line x1="12" y1="3" x2="12" y2="15"></line>
              </svg>
              <span>Upload .txt</span>
            </button>
          </div>
        </div>
        <textarea
          id="gene-ids"
          v-model="geneIds"
          :placeholder="placeholderText"
          rows="8"
        ></textarea>
        <input
          type="file"
          ref="fileInput"
          @change="handleFileUpload"
          accept=".txt"
          style="display: none"
        />
        <p class="input-hint">
          Insert one
          {{
            identifierType === 'preferred_name'
              ? 'Gene Symbol'
              : identifierType === 'protein_id'
                ? 'Protein'
                : 'COG'
          }}
          ID per line or upload a .txt file.
        </p>
        <details class="input-docs">
          <summary>Supported Input Formats</summary>
          <div class="docs-content">
            <p>
              <strong>Gene Symbol:</strong> Standard gene symbols (e.g., <em>NRP1</em>,
              <em>CDK6</em>).
            </p>
            <p>
              <strong>Protein ID:</strong> Ensembl Protein IDs (e.g., <em>ENSP00000223177</em>).
            </p>
            <p>
              <strong>COG ID:</strong> Orthologous Group IDs (e.g., <em>KOG0018</em>,
              <em>NOG106405</em>).
            </p>
          </div>
        </details>
      </div>

      <div class="form-group">
        <div class="organism-identifier-wrapper">
          <div class="form-group-small">
            <label for="organism-db">Organism <span class="required">*</span></label>
            <select id="organism-db" ref="organismSelect" v-model="selectedOrganism">
              <option v-for="org in organismList" :key="org.value" :value="org.value">
                {{ org.text }}
              </option>
            </select>
          </div>
          <div class="form-group-small">
            <label for="identifier-type">Identifier Type <span class="required">*</span></label>
            <select id="identifier-type" v-model="identifierType" @change="clearInput">
              <option value="preferred_name">Gene Symbol</option>
              <option value="protein_id">Protein ID</option>
              <option value="cog_id">Orthologous Group ID</option>
            </select>
          </div>
        </div>

        <div class="switch-wrapper">
          <div class="switch-container">
            <label for="network-switch" class="switch-label">Show Protein Network</label>
            <label class="switch">
              <input
                type="checkbox"
                id="network-switch"
                v-model="showNetwork"
                :disabled="isNetworkSwitchDisabled"
              />
              <span class="slider round"></span>
            </label>
          </div>
          <p v-if="isNetworkSwitchDisabled" class="input-hint-warning">Disabled for > 200 genes.</p>
        </div>

        <button class="infer-button" @click="handleInferRoots" :disabled="isLoading">
          <svg
            v-if="!isLoading"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M5 12h14"></path>
            <path d="M12 5l7 7-7 7"></path>
          </svg>
          <svg
            v-if="isLoading"
            class="animate-spin"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              opacity="0.2"
              fill-rule="evenodd"
              clip-rule="evenodd"
              d="M12 19C15.866 19 19 15.866 19 12C19 8.13401 15.866 5 12 5C8.13401 5 5 8.13401 5 12C5 15.866 8.13401 19 12 19ZM12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22Z"
              fill="currentColor"
            />
            <path
              d="M2 12C2 6.47715 6.47715 2 12 2V5C8.13401 5 5 8.13401 5 12H2Z"
              fill="currentColor"
            />
          </svg>
          <span>{{ isLoading ? 'Loading...' : 'Get Roots' }}</span>
        </button>
      </div>
    </div>
    <span id="version-statement">OrthoGuide v2.11.0</span>
  </main>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { hsa, mmu, rno, dme, cel, ath, sce, dre } from '../data/exampleGenes.js'
import TomSelect from 'tom-select'
import 'tom-select/dist/css/tom-select.default.css'

const props = defineProps({
  isLoading: Boolean,
  speciesList: {
    type: Array,
    default: () => [],
  },
})

const emit = defineEmits(['start-analysis'])

const geneIds = ref('')
const organismList = ref([])
const organismSelect = ref(null)
const exampleDataSpecies = ['9606', '10090', '10116', '7955', '7227', '6239', '3702', '4932']
const hasExampleData = computed(() => exampleDataSpecies.includes(selectedOrganism.value))
const selectedOrganism = ref('9606')
const identifierType = ref('preferred_name')
const validationError = ref('')
const fileInput = ref(null)
const showNetwork = ref(true)

const placeholderText = computed(() => {
  if (identifierType.value === 'preferred_name') {
    return 'Ex: NRP1, CDK6, ITGB7...'
  } else if (identifierType.value === 'protein_id') {
    return 'Ex: ENSP00000223177, ENSP00000266970...'
  } else {
    return 'Ex: NOG106405, KOG0018...'
  }
})

const geneCount = computed(() => {
  return geneIds.value
    .split('\n')
    .map((id) => id.trim())
    .filter((id) => id !== '').length
})

const clearInput = () => {
  geneIds.value = ''
}

let tomSelectInstance = null

onMounted(async () => {
  try {
    const response = await fetch(`${import.meta.env.BASE_URL}full_species_map.tsv`)
    if (response.ok) {
      const text = await response.text()
      const allOrganisms = text
        .trim()
        .split('\n')
        .map((line) => {
          const [id, name] = line.split('\t')
          return { value: id, text: name }
        })

      const topOrganisms = []
      const organismMap = new Map(allOrganisms.map((org) => [org.value, org]))

      exampleDataSpecies.forEach((id) => {
        if (organismMap.has(id)) {
          topOrganisms.push(organismMap.get(id))
          organismMap.delete(id)
        }
      })

      organismList.value = [...topOrganisms, ...organismMap.values()]
    }
  } catch (e) {
    console.error('Failed to load species map', e)
  }

  await nextTick()

  if (organismSelect.value) {
    tomSelectInstance = new TomSelect(organismSelect.value, {
      sortField: [{ field: '$order' }, { field: '$score' }],
      onChange: (value) => {
        selectedOrganism.value = value
        clearInput()
      },
    })
  }
})

onBeforeUnmount(() => {
  if (tomSelectInstance) {
    tomSelectInstance.destroy()
  }
})

const loadExampleData = () => {
  if (!hasExampleData.value) return
  identifierType.value = 'preferred_name'
  clearInput()
  switch (selectedOrganism.value) {
    case '9606':
      geneIds.value = hsa.join('\n')
      break
    case '10090':
      geneIds.value = mmu.join('\n')
      break
    case '10116':
      geneIds.value = rno.join('\n')
      break
    case '7955':
      geneIds.value = dre.join('\n')
      break
    case '7227':
      geneIds.value = dme.join('\n')
      break
    case '6239':
      geneIds.value = cel.join('\n')
      break
    case '3702':
      geneIds.value = ath.join('\n')
      break
    case '4932':
      geneIds.value = sce.join('\n')
      break
  }
}

const isNetworkSwitchDisabled = computed(() => geneCount.value > 200)

watch(isNetworkSwitchDisabled, (isDisabled) => {
  if (isDisabled) {
    showNetwork.value = false
  }
})

const triggerFileUpload = () => {
  fileInput.value.click()
}

const handleFileUpload = (event) => {
  const file = event.target.files[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = (e) => {
    geneIds.value = e.target.result
    clearValidationError()
  }
  reader.onerror = (e) => {
    console.error('File reading error:', e)
    alert('Error reading file.')
  }
  reader.readAsText(file)
  event.target.value = ''
}

const handleInferRoots = () => {
  const genes = geneIds.value
    .split('\n')
    .map((id) => id.trim())
    .filter((id) => id !== '')

  if (genes.length === 0) {
    validationError.value = 'Please enter at least one Gene ID.'
    return
  }

  emit('start-analysis', genes, selectedOrganism.value, showNetwork.value, identifierType.value)
}

const clearValidationError = () => {
  validationError.value = ''
}
</script>

<style scoped>
.analysis-card {
  background-color: var(--color-background);
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--color-border);
  padding-bottom: 20px;
}
.analysis-card h2 {
  font-size: 1.75rem;
  font-weight: 600;
  margin-top: 0;
  margin-bottom: 30px;
}
.organism-identifier-wrapper {
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.form-group-small {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
}
.form-group {
  display: flex;
  flex-direction: column;
}
.label-with-button {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.action-buttons {
  display: flex;
  gap: 8px;
}
.upload-button,
.example-button {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  padding: 4px 10px;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background-color: var(--color-background-soft);
  color: var(--color-text);
  cursor: pointer;
  transition: background-color 0.2s;
}
.upload-button:hover,
.example-button:hover {
  background-color: var(--color-background-mute);
}
.example-button:disabled {
  color: #9ca3af;
  cursor: not-allowed;
  opacity: 0.5;
}
.example-button:disabled:hover {
  background-color: transparent;
}
.example-button:disabled {
  color: #9ca3af;
  cursor: not-allowed;
}
.example-button:disabled:hover {
  background-color: #f9fafb;
}
label {
  font-weight: 600;
  margin-bottom: 8px;
  font-size: 0.9rem;
  color: var(--color-text);
}
label .required {
  color: #ef4444;
}
textarea {
  width: 100%;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid var(--color-border);
  font-family: inherit;
  font-size: 0.95rem;
  min-height: 120px;
  resize: vertical;
  box-sizing: border-box;
  background-color: var(--color-background);
  color: var(--color-text);
  transition:
    border-color 0.2s,
    box-shadow 0.2s;
}
textarea:focus,
select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
}
textarea::placeholder {
  color: var(--color-text);
  opacity: 0.4;
}
.input-hint {
  font-size: 0.8rem;
  color: var(--color-text);
  opacity: 0.7;
  margin-top: 8px;
}
.input-hint-warning {
  font-size: 0.8rem;
  color: #d97706;
  margin-top: 4px;
}
select {
  padding: 12px;
  border-radius: 8px;
  border: 1px solid var(--color-border);
  font-family: inherit;
  font-size: 0.95rem;
  background-color: var(--color-background);
  color: var(--color-text);
  appearance: none;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
  background-position: right 0.5rem center;
  background-repeat: no-repeat;
  background-size: 1.5em 1.5em;
}
.infer-button {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  background-color: #2563eb;
  color: white;
  border: none;
  padding: 14px 24px;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
  width: 100%;
  margin-top: 1rem;
}
.infer-button:hover:not(:disabled) {
  background-color: #1d4ed8;
}
.infer-button:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}
.animate-spin {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
.switch-wrapper {
  margin-top: auto;
  padding-top: 1rem;
}
.switch-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.switch-label {
  font-size: 0.9rem;
  font-weight: 600;
  margin-bottom: 0;
  color: var(--color-text);
}
.switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 28px;
}
.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}
.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: var(--vt-c-divider-dark-2);
  transition: 0.4s;
  border-radius: 28px;
}
.slider:before {
  position: absolute;
  content: '';
  height: 20px;
  width: 20px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  transition: 0.4s;
  border-radius: 50%;
}
input:checked + .slider {
  background-color: #2563eb;
}
input:focus + .slider {
  box-shadow: 0 0 1px #2563eb;
}
input:checked + .slider:before {
  transform: translateX(22px);
}
input:disabled + .slider {
  background-color: var(--color-background-mute);
  cursor: not-allowed;
  opacity: 0.5;
}
#version-statement {
  text-align: center;
  width: 100%;
  display: block;
  color: var(--color-text);
  opacity: 0.5;
  margin-top: 2rem;
}
@media (max-width: 768px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
  .analysis-card {
    padding: 20px;
  }
}

/* Tom Select Customization */
:deep(.ts-wrapper) {
  width: 100%;
}

:deep(.ts-control) {
  border-radius: 8px;
  border: 1px solid var(--color-border);
  padding: 12px 12px;
  padding-right: 2.5rem !important;
  font-size: 0.95rem;
  font-family: inherit;
  box-shadow: none;
  background-color: var(--color-background);
  color: var(--color-text);
  transition:
    border-color 0.2s,
    box-shadow 0.2s;
}

:deep(.ts-wrapper.single .ts-control) {
  padding-right: 2.5rem;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
  background-position: right 0.5rem center;
  background-repeat: no-repeat;
  background-size: 1.5em 1.5em;
}

:deep(.ts-control input) {
  color: var(--color-text) !important;
}

:deep(.ts-wrapper.focus .ts-control) {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
  background-color: var(--color-background) !important;
  color: var(--color-text) !important;
}

/* Hide default Tom Select caret to use our custom SVG */
:deep(.ts-wrapper.single .ts-control::after) {
  display: none !important;
}

:deep(.ts-dropdown) {
  border-radius: 8px;
  border: 1px solid var(--color-border);
  box-shadow:
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
  margin-top: 4px;
  z-index: 10;
  background-color: var(--color-background);
  color: var(--color-text);
}

:deep(.ts-dropdown .option) {
  color: var(--color-text);
}

:deep(.ts-dropdown .option.active) {
  background-color: var(--color-background-soft);
  color: var(--color-text);
}

.input-docs {
  margin-top: 12px;
  font-size: 0.85rem;
  color: var(--color-text);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background-color: var(--color-background-soft);
  overflow: hidden;
}

.input-docs summary {
  cursor: pointer;
  font-weight: 600;
  padding: 8px 12px;
  user-select: none;
  background-color: var(--color-background-mute);
  transition: background-color 0.2s;
}

.input-docs summary:hover {
  background-color: var(--color-border);
}

.docs-content {
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  border-top: 1px solid var(--color-border);
}

.docs-content p {
  margin: 0;
  line-height: 1.4;
}
</style>
