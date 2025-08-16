<template>
  <div class="chart-container" ref="chartContainer">
    <svg ref="svgRef"></svg>
    <div ref="tooltipRef" class="tooltip"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, onBeforeUnmount } from 'vue'
import * as d3 from 'd3'

const props = defineProps({
  chartData: {
    type: Object,
    required: true,
  },
})

const chartContainer = ref(null)
const svgRef = ref(null)
const tooltipRef = ref(null)

const renderChart = () => {
  const svg = d3.select(svgRef.value)
  svg.selectAll('*').remove()

  if (!chartContainer.value || !props.chartData.labels || props.chartData.labels.length === 0) {
    return
  }

  const data = props.chartData.labels.map((label, i) => ({
    label: label,
    value: props.chartData.datasets[0].data[i],
  }))

  const margin = { top: 20, right: 20, bottom: 150, left: 60 }
  const containerWidth = chartContainer.value.clientWidth
  const containerHeight = chartContainer.value.clientHeight

  const width = containerWidth - margin.left - margin.right
  const height = containerHeight - margin.top - margin.bottom

  const chart = svg
    .attr('width', containerWidth)
    .attr('height', containerHeight)
    .append('g')
    .attr('transform', `translate(${margin.left},${margin.top})`)

  const x = d3
    .scaleBand()
    .range([0, width])
    .domain(data.map((d) => d.label))
    .padding(0.1)

  chart
    .append('g')
    .attr('transform', `translate(0, ${height})`)
    .call(d3.axisBottom(x))
    .selectAll('text')
    .attr('transform', 'translate(-10,0)rotate(-45)')
    .style('text-anchor', 'end')

  const yMax = d3.max(data, (d) => d.value)
  const y = d3.scaleLinear().domain([0, yMax]).range([height, 0])

  chart.append('g').call(d3.axisLeft(y).tickFormat(d3.format('d')))

  chart
    .append('text')
    .attr('text-anchor', 'middle')
    .attr('transform', 'rotate(-90)')
    .attr('y', -margin.left + 20)
    .attr('x', -height / 2)
    .text('Number of Genes')

  const tooltip = d3.select(tooltipRef.value)

  const mouseover = (event, d) => {
    tooltip.style('visibility', 'visible').html(`${d.label}<br><strong>${d.value}</strong> genes`)
  }

  const mousemove = (event) => {
    tooltip.style('top', event.offsetY - 10 + 'px').style('left', event.offsetX + 10 + 'px')
  }

  const mouseout = () => {
    tooltip.style('visibility', 'hidden')
  }

  chart
    .selectAll('rect')
    .data(data)
    .join('rect')
    .attr('x', (d) => x(d.label))
    .attr('y', (d) => y(d.value))
    .attr('height', (d) => height - y(d.value))
    .attr('width', x.bandwidth())
    .attr('fill', 'rgba(128, 0, 255, 0.5)')
    .on('mouseover', mouseover)
    .on('mousemove', mousemove)
    .on('mouseout', mouseout)
}

const exportSVG = () => {
  if (!svgRef.value) return

  const svgNode = svgRef.value.cloneNode(true)
  d3.select(svgNode)
    .attr('style', 'background-color: white;')
    .selectAll('text')
    .attr('font-family', 'sans-serif')

  const svgData = new XMLSerializer().serializeToString(svgNode)
  const blob = new Blob([svgData], { type: 'image/svg+xml;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = 'orthoguide_bar_chart.svg'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

defineExpose({
  exportChart: exportSVG,
})

let resizeObserver
onMounted(() => {
  renderChart()
  if (chartContainer.value) {
    resizeObserver = new ResizeObserver(renderChart)
    resizeObserver.observe(chartContainer.value)
  }
})

watch(() => props.chartData, renderChart, { deep: true })

onBeforeUnmount(() => {
  if (resizeObserver) {
    resizeObserver.disconnect()
  }
})
</script>

<style scoped>
.chart-container {
  position: relative;
  height: 450px;
  width: 100%;
  font-family: sans-serif;
}
.tooltip {
  position: absolute;
  visibility: hidden;
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 12px;
  pointer-events: none;
  line-height: 1.4;
  z-index: 10;
}
</style>
