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
      <div class="table-container">
        <ResultsTable :items="results" :columns="tableHeaders" :key="results.length" />
      </div>
    </div>

    <div v-if="missingGenes.length > 0" class="missing-genes-note">
      <p>
        <strong>Note:</strong> The following identifiers were not found in our database:
        {{ missingGenes.join(', ') }}
      </p>
    </div>

    <div v-if="chartData.labels && chartData.labels.length > 0" class="chart-section">
      <span class="chart-section-header"
        >Root Clade Distribution
        <div class="export-container">
          <button
            v-if="results && results.length > 0"
            @click="showChartExportOptions = !showChartExportOptions"
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
          <div v-if="showChartExportOptions" class="export-options">
            <button @click="handleExportChart('svg')">as SVG</button>
            <button @click="handleExportChart('png')">as PNG</button>
          </div>
        </div>
      </span>
      <BarChart ref="barChartRef" :chart-data="chartData" />
    </div>

    <div
      v-if="(networkData && networkData.length > 0) || (genesInScope && genesInScope.length > 0)"
      class="chart-section"
    >
      <span class="chart-section-header">
        Protein Interaction Network
        <div class="network-controls">
          <label class="checkbox-wrapper">
            <input type="checkbox" v-model="showGeneNames" />
            <span class="checkbox-text">Show Gene Names</span>
          </label>
          <label class="checkbox-wrapper" v-if="showGeneNames">
            <input type="checkbox" v-model="largeFont" />
            <span class="checkbox-text">Large Font</span>
          </label>
          <div class="export-container">
            <button
              v-if="filteredNetworkData.length > 0"
              @click="showNetworkExportOptions = !showNetworkExportOptions"
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
            <div v-if="showNetworkExportOptions" class="export-options">
              <button @click="handleExportNetwork('svg')">as SVG</button>
              <button @click="handleExportNetwork('png')">as PNG</button>
            </div>
          </div>
        </div>
      </span>
      <p>
        Results retrieved from the
        <a href="https://string-db.org/" target="_blank">STRING</a> database
      </p>

      <CladeSlider
        v-if="cladeList.length > 1"
        :clades="cladeList"
        :modelValue="selectedCladeIndex"
        :disabled="isSliderDisabled"
        @update:modelValue="$emit('update:selectedCladeIndex', $event)"
      />
      <NetworkGraph
        ref="networkGraphRef"
        :network-data="filteredNetworkData"
        :all-genes="genesInScope"
        :genes-in-selected-clade="genesInSelectedClade"
        :show-gene-names="showGeneNames"
        :large-font="largeFont"
        :node-coordinates="nodeCoordinates"
        @simulation-end="handleSimulationEnd"
        @node-dragged="handleNodeDragged"
      />
    </div>
    <div
      v-if="
        networkData.length == 0 &&
        genesInScope.length == 0 &&
        (results.length > 0 || missingGenes.length == 0)
      "
      class="no-data-placeholder"
    >
      <p>No network data is available</p>
    </div>
    <div
      v-if="results && results.length === 0 && !apiErrorMessage && missingGenes.length === 0"
      class="no-results-message"
    >
      <p>No rooting data found for the submitted genes.</p>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, toRefs } from 'vue'
import ResultsTable from './ResultsTable.vue'
import BarChart from './BarChart.vue'
import NetworkGraph from './NetworkGraph.vue'
import CladeSlider from './CladeSlider.vue'

const props = defineProps({
  results: Array,
  apiErrorMessage: String,
  chartData: Object,
  networkData: Array,
  cladeList: Array,
  filteredNetworkData: Array,
  selectedCladeIndex: Number,
  tableHeaders: Array,
  genesInSelectedClade: Set,
  missingGenes: Array,
})

const { results, cladeList, selectedCladeIndex } = toRefs(props)

defineEmits(['export', 'update:selectedCladeIndex'])

const barChartRef = ref(null)
const networkGraphRef = ref(null)
const showChartExportOptions = ref(false)
const showNetworkExportOptions = ref(false)
const showGeneNames = ref(false)
const largeFont = ref(false)
const isSliderDisabled = ref(true)
const nodeCoordinates = ref(new Map())

const handleSimulationEnd = (coords) => {
  isSliderDisabled.value = false
  nodeCoordinates.value = coords
}

const handleNodeDragged = ({ id, x, y }) => {
  if (nodeCoordinates.value) {
    nodeCoordinates.value.set(id, { x, y })
  }
}

const handleExportChart = (format) => {
  if (barChartRef.value) {
    barChartRef.value.exportChart(format)
  }
  showChartExportOptions.value = false
}

const handleExportNetwork = (format) => {
  if (networkGraphRef.value) {
    networkGraphRef.value.exportGraph(format)
  }
  showNetworkExportOptions.value = false
}

const genesInScope = computed(() => {
  if (!results.value || !cladeList.value.length) return []
  const selectedClade = cladeList.value[selectedCladeIndex.value]
  if (!selectedClade) return []
  const selectedRootId = parseInt(selectedClade.rootId)

  const uniqueGenes = new Set(
    results.value.filter((r) => r.root >= selectedRootId).map((r) => r.preferred_name),
  )
  return Array.from(uniqueGenes)
})
</script>

<style scoped>
.results-card {
  background-color: var(--color-background);
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--color-border);
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
  flex-wrap: wrap;
  gap: 12px;
}

.chart-section-header,
.chart-section h4,
.table-section h4 {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 20px;
  border-bottom: 1px solid var(--color-border);
  padding-bottom: 10px;
}
.table-container {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}
.export-button {
  display: flex;
  align-items: center;
  gap: 8px;
  background-color: var(--color-background-soft);
  color: var(--color-text);
  border: 1px solid var(--color-border);
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
  background-color: var(--color-background-mute);
  border-color: var(--color-border-hover);
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
  background-color: var(--color-background-soft);
  padding: 2rem;
  border-radius: 8px;
  color: var(--color-text);
  opacity: 0.7;
}
.no-data-placeholder {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 500px;
  color: var(--color-text);
  opacity: 0.7;
  font-style: italic;
  background-color: var(--color-background-soft);
}
.missing-genes-note {
  margin-top: 1.5rem;
  padding: 1rem;
  background-color: #fefce8;
  border-left: 4px solid #facc15;
  color: #713f12;
  font-size: 0.9rem;
  border-radius: 8px;
}
.network-controls {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}
.checkbox-wrapper {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.9rem;
  cursor: pointer;
  user-select: none;
}
.checkbox-text {
  font-weight: 500;
  color: var(--color-text);
}
.export-container {
  position: relative;
  display: inline-block;
}
.export-options {
  position: absolute;
  right: 0;
  background-color: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  margin-top: 4px;
  padding: 4px;
  z-index: 10;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
  width: max-content;
}
.export-options button {
  display: block;
  width: 100%;
  text-align: left;
  padding: 8px 12px;
  border: none;
  background: none;
  cursor: pointer;
  font-size: 0.9rem;
  border-radius: 6px;
  color: var(--color-text);
}
.export-options button:hover {
  background-color: var(--color-background-soft);
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
  .chart-section-header {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
