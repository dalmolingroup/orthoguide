<template>
  <main class="analysis-card">
    <h2>Rooting Analysis</h2>
    <div class="form-grid">
      <div class="form-group">
        <div class="label-with-button">
          <label for="gene-ids">Input Gene IDs: <span class="required">*</span></label>
          <div class="action-buttons">
            <button @click="loadExampleData" class="example-button">Use Example Data</button>
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
          placeholder="Ex: NRP1, CDK6, ITGB7..."
          rows="8"
        ></textarea>
        <input
          type="file"
          ref="fileInput"
          @change="handleFileUpload"
          accept=".txt"
          style="display: none"
        />
        <p class="input-hint">Insert one Gene Symbol ID per line or upload a .txt file.</p>
      </div>

      <div class="form-group">
        <label for="organism-db">Organism <span class="required">*</span></label>
        <select id="organism-db" v-model="selectedOrganism" @change="clearInput">
          <option value="9606">Homo sapiens</option>
          <option value="10090">Mus musculus</option>
          <option value="10116">Rattus norvegicus</option>
          <option value="7227">Drosophila melanogaster</option>
          <option value="6239">Caenorhabditis elegans</option>
          <option value="3702">Arabidopsis thaliana</option>
          <option value="4932">Saccharomyces cerevisiae</option>
        </select>

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
          <span>{{ isLoading ? 'Loading...' : 'Infer Roots' }}</span>
        </button>
      </div>
    </div>
    <span id="version-statement">OrthoGuide v2.5.0</span>
  </main>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { hsa, mmu, rno, dme, cel, ath, sce } from '../data/exampleGenes.js'

const props = defineProps({
  isLoading: Boolean,
})

const emit = defineEmits(['start-analysis'])

const geneIds = ref('')
const selectedOrganism = ref('9606')
const validationError = ref('')
const fileInput = ref(null)
const showNetwork = ref(true)

const geneCount = computed(() => {
  return geneIds.value
    .split('\n')
    .map((id) => id.trim())
    .filter((id) => id !== '').length
})

const clearInput = () => {
  geneIds.value = ''
}

const loadExampleData = () => {
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

  emit('start-analysis', genes, selectedOrganism.value, showNetwork.value)
}

const clearValidationError = () => {
  validationError.value = ''
}
</script>

<style scoped>
.analysis-card {
  background-color: white;
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid #e9ecef;
  padding-bottom: 20px;
}
.analysis-card h2 {
  font-size: 1.75rem;
  font-weight: 600;
  margin-top: 0;
  margin-bottom: 30px;
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
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background-color: #f9fafb;
  cursor: pointer;
  transition: background-color 0.2s;
}
.upload-button:hover,
.example-button:hover {
  background-color: #f3f4f6;
}
label {
  font-weight: 600;
  margin-bottom: 8px;
  font-size: 0.9rem;
}
label .required {
  color: #ef4444;
}
textarea {
  width: 100%;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #ced4da;
  font-family: inherit;
  font-size: 0.95rem;
  min-height: 120px;
  resize: vertical;
  box-sizing: border-box;
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
.input-hint {
  font-size: 0.8rem;
  color: #6c757d;
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
  border: 1px solid #ced4da;
  font-family: inherit;
  font-size: 0.95rem;
  background-color: white;
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
  background-color: #ccc;
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
  background-color: #e5e7eb;
  cursor: not-allowed;
}
#version-statement {
  text-align: center;
  width: 100%;
  display: block;
  color: #9ca3af;
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
</style>
