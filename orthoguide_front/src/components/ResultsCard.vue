<template>
  <section class="results-card">
    <div class="results-header">
      <h3>Analysis Results</h3>
    </div>

    <div v-if="apiErrorMessage" class="error-message">
      <strong>Error:</strong> {{ apiErrorMessage }}
    </div>

    <div v-if="results && results.length > 0" class="table-section">
      <span class="chart-section-header"
        >Detailed Results
        <button v-if="results && results.length > 0" @click="$emit('export')" class="export-button">
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
            <polyline points="7 10 12 15 17 10"></polyline>
            <line x1="12" y1="15" x2="12" y2="3"></line>
          </svg>
          <span>Export to CSV</span>
        </button></span
      >
      <ResultsTable :results="results" />
    </div>

    <div v-if="chartData.labels && chartData.labels.length > 0" class="chart-section">
      <span class="chart-section-header"
        >Root Clade Distribution
        <button
          v-if="results && results.length > 0"
          @click="handleExportChart"
          class="export-button"
        >
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M3 3h7v9H3z"></path>
            <path d="M14 3h7v5h-7z"></path>
            <path d="M14 12h7v9h-7z"></path>
            <path d="M3 16h7v5H3z"></path>
          </svg>
          <span>Export Chart</span>
        </button>
      </span>
      <BarChart ref="barChartRef" :chart-data="chartData" />
    </div>

    <div v-if="networkData && networkData.length > 0" class="chart-section">
      <span class="chart-section-header">
        Protein Interaction Network
        <button
          v-if="filteredNetworkData.length > 0"
          @click="handleExportNetwork"
          class="export-button"
        >
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
            <polyline points="7 10 12 15 17 10"></polyline>
            <line x1="12" y1="15" x2="12" y2="3"></line>
          </svg>
          <span>Export Network</span>
        </button>
      </span>
      <CladeSlider
        v-if="cladeList.length > 1"
        :clades="cladeList"
        :modelValue="selectedCladeIndex"
        @update:modelValue="$emit('update:selectedCladeIndex', $event)"
      />
      <NetworkGraph ref="networkGraphRef" :network-data="filteredNetworkData" />
    </div>

    <div v-if="results && results.length === 0 && !apiErrorMessage" class="no-results-message">
      <p>No rooting data found for the submitted genes.</p>
    </div>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import ResultsTable from './ResultsTable.vue'
import BarChart from './BarChart.vue'
import NetworkGraph from './NetworkGraph.vue'
import CladeSlider from './CladeSlider.vue'

defineProps({
  results: Array,
  apiErrorMessage: String,
  chartData: Object,
  networkData: Array,
  cladeList: Array,
  filteredNetworkData: Array,
  selectedCladeIndex: Number,
})

defineEmits(['export', 'update:selectedCladeIndex'])

const barChartRef = ref(null)
const networkGraphRef = ref(null)

const handleExportChart = () => {
  if (barChartRef.value) {
    barChartRef.value.exportChart()
  }
}

const handleExportNetwork = () => {
  if (networkGraphRef.value) {
    networkGraphRef.value.exportSVG()
  }
}
</script>

<style scoped>
.results-card {
  background-color: white;
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid #e9ecef;
}
.results-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.results-header h3 {
  font-size: 1.75rem;
  font-weight: 600;
  margin: 0;
}
.chart-section,
.table-section {
  margin-top: 40px;
}

.chart-section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.chart-section-header,
.chart-section h4,
.table-section h4 {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 20px;
  border-bottom: 1px solid #e9ecef;
  padding-bottom: 10px;
}
.export-button {
  display: flex;
  align-items: center;
  gap: 8px;
  background-color: #f9fafb;
  color: #374151;
  border: 1px solid #d1d5db;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition:
    background-color 0.2s,
    border-color 0.2s;
}
.export-button:hover {
  background-color: #f3f4f6;
  border-color: #9ca3af;
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
@media (max-width: 768px) {
  .results-card {
    padding: 20px;
  }
  .results-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
}
</style>
