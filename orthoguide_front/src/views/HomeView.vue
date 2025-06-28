<template>
  <div class="space-y-8">
    <main class="analysis-card">
      <h2>Rooting Analysis</h2>
      <div class="form-grid">
        <div class="form-group">
          <label for="gene-ids">Input Gene IDs: <span class="required">*</span></label>
          <textarea
            id="gene-ids"
            v-model="geneIds"
            placeholder="Ex: NRP1, CDK6, ITGB7..."
            rows="8"
          ></textarea>
          <p v-if="validationError" class="input-error-hint">{{ validationError }}</p>
          <p v-else class="input-hint">Insert one HGNC Gene ID per line.</p>
        </div>

        <div class="form-group">
          <label for="organism-db">Organism <span class="required">*</span></label>
          <select id="organism-db" v-model="selectedOrganism">
            <option value="hsa">Homo sapiens</option>
          </select>

          <button class="infer-button" @click="inferRoots" :disabled="isLoading">
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
    </main>

    <transition name="fade">
      <section v-if="results !== null" class="results-card">
        <h3>Analysis Results</h3>

        <div v-if="errorMessage" class="error-message">
          <strong>Error:</strong> {{ errorMessage }}
        </div>

        <div v-if="results && results.length > 0" class="results-table-wrapper">
          <table class="results-table">
            <thead>
              <tr>
                <th>Gene</th>
                <th>Root Clade</th>
                <th>Root ID</th>
                <th>COG ID</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in results" :key="item.queryItem">
                <td>{{ item.queryItem }}</td>
                <td>{{ item.clade_name }}</td>
                <td>{{ item.root }}</td>
                <td>{{ item.cog_id }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="results && results.length === 0 && !errorMessage" class="no-results-message">
          <p>No rooting data found for the submitted genes.</p>
        </div>
      </section>
    </transition>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const geneIds = ref('')
const selectedOrganism = ref('hsa')
const isLoading = ref(false)
const results = ref(null)
const validationError = ref('')
const apiErrorMessage = ref('')

const inferRoots = async () => {
  results.value = null
  validationError.value = ''
  apiErrorMessage.value = ''

  const genes = geneIds.value
    .split('\n')
    .map((id) => id.trim())
    .filter((id) => id !== '')
  if (genes.length === 0) {
    validationError.value = 'Please enter at least one Gene ID.'
    return
  }

  isLoading.value = true

  try {
    const geneQueryString = genes.join(',')
    const apiUrl = `http://localhost:8000/get_roots?genes=${encodeURIComponent(geneQueryString)}`
    const response = await fetch(apiUrl)

    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.detail || `HTTP error! Status: ${response.status}`)
    }

    const data = await response.json()
    results.value = data
  } catch (error) {
    console.error('Failed to fetch rooting data:', error)
    apiErrorMessage.value = error.message
    results.value = []
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped>
/* Main component styles */
.space-y-8 > :not([hidden]) ~ :not([hidden]) {
  --tw-space-y-reverse: 0;
  margin-top: calc(2rem * calc(1 - var(--tw-space-y-reverse)));
  margin-bottom: calc(2rem * var(--tw-space-y-reverse));
}
.analysis-card,
.results-card {
  background-color: white;
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid #e9ecef;
}

.analysis-card h2,
.results-card h3 {
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
  margin-top: auto;
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

/* Results Section Styles */
.results-table-wrapper {
  overflow-x: auto;
}
.results-table {
  width: 100%;
  border-collapse: collapse;
}
.results-table th,
.results-table td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #e9ecef;
}
.results-table thead th {
  background-color: #f9fafb;
  font-size: 0.75rem;
  text-transform: uppercase;
  color: #6c757d;
}
.results-table tbody tr:last-child td {
  border-bottom: none;
}
.results-table td:first-child {
  font-weight: 600;
}
.error-message {
  background-color: #fee2e2;
  border-left: 4px solid #ef4444;
  color: #b91c1c;
  padding: 1rem;
  border-radius: 8px;
}
.no-results-message {
  text-align: center;
  background-color: #f9fafb;
  padding: 2rem;
  border-radius: 8px;
  color: #6c757d;
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.4s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

@media (max-width: 768px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
  .analysis-card,
  .results-card {
    padding: 20px;
  }
}
</style>
