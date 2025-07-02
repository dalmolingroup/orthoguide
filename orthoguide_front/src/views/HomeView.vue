<template>
  <div class="space-y-8">
    <AnalysisCard :is-loading="isLoading" @start-analysis="inferRoots" />
    <transition name="fade">
      <ResultsCard
        v-if="results !== null"
        :results="results"
        :api-error-message="apiErrorMessage"
        :chart-data="chartData"
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
const apiErrorMessage = ref('')

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

const inferRoots = async (genes, species) => {
  results.value = null
  apiErrorMessage.value = ''
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
  } catch (error) {
    console.error('Failed to fetch rooting data:', error)
    apiErrorMessage.value = error.message
    results.value = []
  } finally {
    isLoading.value = false
  }
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
