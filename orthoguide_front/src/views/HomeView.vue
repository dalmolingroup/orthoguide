<template>
  <div class="space-y-8">
    <AnalysisCard :is-loading="isLoading || isDbLoading" @start-analysis="handleAnalysis" />
    <div v-if="isDbLoading" class="loading-db-message">
      <p>Loading database, please wait...</p>
    </div>
    <transition name="fade">
      <ResultsCard
        v-if="results !== null"
        :results="results"
        :api-error-message="apiErrorMessage"
        :chart-data="chartData"
        :network-data="networkData"
        :filtered-network-data="filteredNetworkData"
        :clade-list="cladeList"
        :table-headers="tableHeaders"
        :genes-in-selected-clade="genesInSelectedClade"
        v-model:selectedCladeIndex="selectedCladeIndex"
        @export="exportToCSV"
      />
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import initSqlJs from 'sql.js'
import AnalysisCard from '../components/AnalysisCard.vue'
import ResultsCard from '../components/ResultsCard.vue'

const isLoading = ref(false)
const isDbLoading = ref(true)
const db = ref(null)
const results = ref(null)
const networkData = ref([])
const apiErrorMessage = ref('')
const selectedCladeIndex = ref(0)

const tableHeaders = ref([
  { title: 'Gene', data: 'preferred_name' },
  { title: 'Root Clade', data: 'clade_name' },
  { title: 'Root ID', data: 'root' },
  { title: 'COG ID', data: 'cog_id' },
])

onMounted(async () => {
  try {
    const SQL = await initSqlJs({
      locateFile: (file) => `${import.meta.env.BASE_URL}${file}`,
    })

    const response = await fetch(`${import.meta.env.BASE_URL}orthoguide_data.db`)
    const buffer = await response.arrayBuffer()

    db.value = new SQL.Database(new Uint8Array(buffer))
    console.log('Database loaded successfully!')
  } catch (error) {
    console.error('Failed to load database:', error)
    apiErrorMessage.value = 'Could not load the application database.'
  } finally {
    isDbLoading.value = false
  }
})

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

  const sortedClades = Object.entries(cladeCounts).sort(([, a], [, b]) => b.rootId - a.rootId)

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

const genesInSelectedClade = computed(() => {
  if (!results.value || !cladeList.value.length) return new Set()
  const selectedClade = cladeList.value[selectedCladeIndex.value]
  if (!selectedClade) return new Set()
  return new Set(
    results.value.filter((r) => r.clade_name === selectedClade.name).map((r) => r.preferred_name),
  )
})

const filteredNetworkData = computed(() => {
  if (!networkData.value || networkData.value.length === 0 || !cladeList.value.length) return []

  const selectedClade = cladeList.value[selectedCladeIndex.value]
  if (!selectedClade) return []

  const selectedRootId = parseInt(selectedClade.rootId)

  const genesInScope = new Set(
    results.value.filter((r) => r.root >= selectedRootId).map((r) => r.preferred_name),
  )

  return networkData.value.filter(
    (link) => genesInScope.has(link.preferredName_A) && genesInScope.has(link.preferredName_B),
  )
})

const getPPINet = async (genes, speciesId) => {
  if (!genes || genes.length === 0) return
  if (genes.length >= 500) {
    networkData.value = []
    return
  }

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

const inferRoots = async (genes, species, fetchNetwork) => {
  results.value = null
  networkData.value = []
  apiErrorMessage.value = ''
  selectedCladeIndex.value = 0

  if (!genes || genes.length === 0) {
    alert('Please enter at least one Gene ID.')
    return
  }
  if (!db.value) {
    apiErrorMessage.value = 'Database is not loaded yet. Please wait.'
    results.value = []
    return
  }

  isLoading.value = true

  try {
    const allowedTableNames = ['9606', '10090', '10116', '7227', '6239', '3702', '4932']

    if (!allowedTableNames.includes(species)) {
      throw new Error(`Organism ID '${species}' is not supported.`)
    }

    const CHUNK_SIZE = 600
    let allResults = []

    for (let i = 0; i < genes.length; i += CHUNK_SIZE) {
      const chunk = genes.slice(i, i + CHUNK_SIZE)
      const placeholders = chunk.map(() => '?').join(',')
      const stmt = db.value.prepare(
        `SELECT preferred_name, clade_name, root, cog_id FROM "${species}" WHERE preferred_name IN (${placeholders})`,
      )

      stmt.bind(chunk)
      while (stmt.step()) {
        allResults.push(stmt.getAsObject())
      }
      stmt.free()
    }

    results.value = allResults

    if (fetchNetwork && allResults.length > 0) {
      selectedCladeIndex.value = cladeList.value.length - 1
      const resultGenes = allResults.map((r) => r.preferred_name)
      await getPPINet(resultGenes, species)
    }
  } catch (error) {
    console.error('Failed to query database:', error)
    apiErrorMessage.value = error.message
    results.value = []
  } finally {
    isLoading.value = false
  }
}

const handleAnalysis = (genes, species, fetchNetwork) => {
  inferRoots(genes, species, fetchNetwork)
}
const exportToCSV = () => {
  if (!results.value || results.value.length === 0) return

  const headers = tableHeaders.value.map((h) => h.title)
  const rows = results.value.map((row) =>
    tableHeaders.value.map((header) => `"${row[header.data] || ''}"`).join(','),
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
.loading-db-message {
  text-align: center;
  padding: 1rem;
  font-style: italic;
  color: #6b7280;
}
</style>
