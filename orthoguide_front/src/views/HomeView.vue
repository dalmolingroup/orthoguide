<template>
  <main class="analysis-card">
    <h2>Rooting Analysis</h2>
    <div class="form-grid">
      <div class="form-group">
        <label for="gene-ids">Input Gene IDs:</label>
        <textarea id="gene-ids" v-model="geneIds" placeholder="Ex: TP53, BRCA1, EGFR..."></textarea>
        <p class="input-hint">Insert one HGNC Gene ID per line.</p>
      </div>

      <div class="form-group">
        <label for="organism-db">Organism</label>
        <select id="organism-db" v-model="selectedOrganism">
          <option value="hsa">Homo sapiens</option>
          <option value="mmu">Mus musculus</option>
          <option value="dme">Drosophila melanogaster</option>
          <option value="cel">Caenorhabditis elegans</option>
          <option value="atl">Arabidopsis thaliana</option>
          <option value="sce">Saccharomyces cerevisiae</option>
        </select>

        <button class="infer-button" @click="inferRoots">
          <svg
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
          Infer Roots
        </button>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref } from 'vue'

const geneIds = ref('')
const selectedOrganism = ref('hsa')

// Method to handle the button click
const inferRoots = () => {
  const genes = geneIds.value.split('\n').filter((id) => id.trim() !== '')
  console.log('Inferring roots with the following data:')
  console.log('Gene IDs:', genes)
  console.log('Organism', selectedOrganism.value)
}
</script>

<style scoped>
.analysis-card {
  background-color: white;
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid #e9ecef;
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

label {
  font-weight: 600;
  margin-bottom: 8px;
  font-size: 0.9rem;
}

textarea {
  width: 100%;
  padding: 12px;
  border-radius: 8px;
  border: 1px solid #ced4da;
  font-family: 'Poppins', sans-serif;
  font-size: 0.95rem;
  resize: vertical;
  box-sizing: border-box;
}

textarea:focus {
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
  font-family: 'Poppins', sans-serif;
  font-size: 0.95rem;
  background-color: white;
  appearance: none;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
  background-position: right 0.5rem center;
  background-repeat: no-repeat;
  background-size: 1.5em 1.5em;
}

select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
}

.infer-button {
  display: flex;
  justify-content: center;
  align-items: center;
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
  margin-top: 25px;
}

.infer-button:hover {
  background-color: #1d4ed8;
}

.infer-button svg {
  margin-right: 8px;
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
