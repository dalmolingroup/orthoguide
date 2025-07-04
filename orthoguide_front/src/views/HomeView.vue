<template>
  <div class="space-y-8">
    <AnalysisCard :is-loading="isLoading" @start-analysis="handleAnalysis" />
    <transition name="fade">
      <ResultsCard
        v-if="results !== null"
        :results="results"
        :api-error-message="apiErrorMessage"
        :chart-data="chartData"
        :network-data="networkData"
        :filtered-network-data="filteredNetworkData"
        :clade-list="cladeList"
        v-model:selectedCladeIndex="selectedCladeIndex"
        @export="exportToCSV"
      />
    </transition>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import AnalysisCard from '../components/AnalysisCard.vue'
import ResultsCard from '../components/ResultsCard.vue'

const isLoading = ref(false)
const results = ref(null)
const networkData = ref([])
const apiErrorMessage = ref('')
const selectedCladeIndex = ref(0)

const chartData = computed(() => {
  if (!results.value || results.value.length === 0) {
    return { labels: [], datasets: [] }
  }

  const cladeCounts = results.value.reduce((acc, result) => {
    const clade = result.clade_name || 'Unknown'
    if (!acc[clade]) {
      acc[clade] = { count: 0, rootId: result.root }
    }
    acc[clade].count += 1
    return acc
  }, {})

  // Order clades in decreasing order
  const sortedClades = Object.entries(cladeCounts).sort(([, a], [, b]) => b.rootId - a.rootId)

  // Calculate cumulative sum
  let cumulativeCount = 0
  const cumulativeData = sortedClades.map(([, { count }]) => {
    cumulativeCount += count
    return cumulativeCount
  })

  const labels = sortedClades.map(([clade]) => clade)

  return {
    labels,
    datasets: [
      {
        label: 'Cumulative Number of Genes',
        data: cumulativeData,
        backgroundColor: 'rgba(128, 0, 255, 0.5)',
        borderColor: 'rgba(128, 0, 128, 1)',
        borderWidth: 1,
        categoryPercentage: 1.0,
        barPercentage: 0.95,
      },
    ],
  }
})

const cladeList = computed(() => {
  if (!results.value || results.value.length === 0) return []
  const uniqueClades = results.value.reduce((acc, result) => {
    const name = result.clade_name || 'Unknown'
    if (!acc.has(name)) {
      acc.set(name, { name, rootId: result.root })
    }
    return acc
  }, new Map())
  return Array.from(uniqueClades.values()).sort((a, b) => b.rootId - a.rootId)
})

const filteredNetworkData = computed(() => {
  if (!networkData.value || networkData.value.length === 0 || !cladeList.value.length) return []

  const selectedClade = cladeList.value[selectedCladeIndex.value]
  if (!selectedClade) return []

  const selectedRootId = selectedClade.rootId

  // Only genes in the selected clade and more ancient clades
  const genesInScope = new Set(
    results.value.filter((r) => r.root >= selectedRootId).map((r) => r.queryItem),
  )

  return networkData.value.filter(
    (link) => genesInScope.has(link.preferredName_A) && genesInScope.has(link.preferredName_B),
  )
})

const getPPINet = async (genes, species) => {
  if (!genes || genes.length === 0) return
  const speciesMap = { hsa: 9606, mmu: 10090, dme: 7227, cel: 6239, atl: 3702, sce: 4932 }
  const speciesId = speciesMap[species] || 9606

  try {
    const geneQueryString = genes.join('%0d')
    const apiUrl = `https://string-db.org/api/json/network?identifiers=${geneQueryString}&species=${speciesId}&show_query_node_labels=1`

    const response = await fetch(apiUrl)
    if (!response.ok) {
      throw new Error(`STRING-DB API error! Status: ${response.status}`)
    }
    const data = await response.json()
    networkData.value = data
  } catch (error) {
    console.error('Failed to fetch PPI network:', error)
    networkData.value = []
  }
}

const inferRoots = async (genes, species) => {
  results.value = null
  networkData.value = []
  apiErrorMessage.value = ''
  selectedCladeIndex.value = 0

  if (!genes || genes.length === 0) {
    alert('Please enter at least one Gene ID.')
    return
  }

  isLoading.value = true

  try {
    const geneQueryString = genes.join(',')
    const apiUrl = `http://localhost:8000/get_roots?genes=${encodeURIComponent(geneQueryString)}&species=${encodeURIComponent(species)}`
    const response = await fetch(apiUrl)

    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.detail || `HTTP error! Status: ${response.status}`)
    }

    const data = await response.json()
    results.value = data

    if (data.length > 0) {
      selectedCladeIndex.value = cladeList.value.length - 1
      const resultGenes = data.map((r) => r.queryItem)
      await getPPINet(resultGenes, species)
    }
  } catch (error) {
    console.error('Failed to fetch rooting data:', error)
    apiErrorMessage.value = error.message
    results.value = []
  } finally {
    isLoading.value = false
  }
}

const handleAnalysis = (genes, species) => {
  inferRoots(genes, species)
}
const exportToCSV = () => {
  if (!results.value || results.value.length === 0) return

  const headers = ['Gene', 'Root Clade', 'Root ID', 'COG ID']
  const rows = results.value.map((row) =>
    [
      `"${row.queryItem || ''}"`,
      `"${row.clade_name || ''}"`,
      `"${row.root || ''}"`,
      `"${row.cog_id || ''}"`,
    ].join(','),
  )

  const csvContent = [headers.join(','), ...rows].join('\n')
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.setAttribute('download', 'orthoguide_results.csv')
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}
</script>

<style>
.space-y-8 > :not([hidden]) ~ :not([hidden]) {
  --tw-space-y-reverse: 0;
  margin-top: calc(2rem * calc(1 - var(--tw-space-y-reverse)));
  margin-bottom: calc(2rem * var(--tw-space-y-reverse));
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.4s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
