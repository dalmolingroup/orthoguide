<template>
  <div class="network-container" ref="networkContainer">
    <svg v-if="networkData && networkData.length > 0" ref="svgRef"></svg>
    <div v-else class="no-data-placeholder">
      <p>No network data for this clade is available</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, onBeforeUnmount } from 'vue'
import * as d3 from 'd3'

const props = defineProps({
  networkData: {
    type: Array,
    required: true,
  },
})

const networkContainer = ref(null)
const svgRef = ref(null)
let simulation

const renderNetwork = () => {
  const svg = d3.select(svgRef.value)
  svg.selectAll('*').remove()

  if (
    !props.networkData ||
    props.networkData.length === 0 ||
    !svgRef.value ||
    !networkContainer.value
  ) {
    return
  }

  const nodesMap = new Map()
  const links = props.networkData.map((d) => {
    if (!nodesMap.has(d.preferredName_A)) nodesMap.set(d.preferredName_A, { id: d.preferredName_A })
    if (!nodesMap.has(d.preferredName_B)) nodesMap.set(d.preferredName_B, { id: d.preferredName_B })
    return { source: d.preferredName_A, target: d.preferredName_B, score: d.score }
  })
  const nodes = Array.from(nodesMap.values())

  const linkedByIndex = {}
  links.forEach((d) => {
    linkedByIndex[`${d.source},${d.target}`] = 1
  })

  function isConnected(a, b) {
    return linkedByIndex[`${a.id},${b.id}`] || linkedByIndex[`${b.id},${a.id}`] || a.id === b.id
  }

  const width = networkContainer.value.clientWidth
  const height = 500
  svg
    .attr('width', width)
    .attr('height', height)
    .attr('viewBox', [-width / 2, -height / 2, width, height])
    .attr('style', 'max-width: 100%; height: auto;')

  simulation = d3
    .forceSimulation(nodes)
    .force(
      'link',
      d3
        .forceLink(links)
        .id((d) => d.id)
        .distance((d) => 100 - d.score * 50),
    )
    .force('charge', d3.forceManyBody().strength(-200))
    .force('center', d3.forceCenter())
    .force('x', d3.forceX().strength(0.05))
    .force('y', d3.forceY().strength(0.05))
    .force('collide', d3.forceCollide().radius(12))

  const link = svg
    .append('g')
    .attr('stroke', '#999')
    .attr('stroke-opacity', 0.6)
    .selectAll('line')
    .data(links)
    .join('line')
    .attr('stroke-width', (d) => Math.sqrt(d.score) * 2)

  const node = svg
    .append('g')
    .attr('stroke', '#fff')
    .attr('stroke-width', 1.5)
    .selectAll('circle')
    .data(nodes)
    .join('circle')
    .attr('r', 8)
    .attr('fill', '#2563eb')
    .call(drag(simulation))

  const text = svg
    .append('g')
    .selectAll('text')
    .data(nodes)
    .join('text')
    .text((d) => d.id)
    .attr('font-size', '12px')
    .attr('paint-order', 'stroke')
    .attr('stroke', 'white')
    .attr('stroke-width', '3px')
    .attr('visibility', 'hidden')

  function fade(opacity) {
    return (event, d) => {
      node.style('opacity', function (o) {
        return isConnected(d, o) ? 1 : opacity
      })

      text.style('visibility', function (o) {
        return o.id === d.id ? 'visible' : 'hidden'
      })

      link.style('stroke-opacity', (o) => (o.source === d || o.target === d ? 1 : opacity))

      if (opacity === 1) {
        node.style('opacity', 1)
        text.style('visibility', 'hidden')
        link.style('stroke-opacity', 0.6)
      }
    }
  }

  node.on('mouseover.fade', fade(0.1)).on('mouseout.fade', fade(1))

  simulation.on('tick', () => {
    link
      .attr('x1', (d) => d.source.x)
      .attr('y1', (d) => d.source.y)
      .attr('x2', (d) => d.target.x)
      .attr('y2', (d) => d.target.y)

    node.attr('cx', (d) => d.x).attr('cy', (d) => d.y)

    text.attr('x', (d) => d.x + 12).attr('y', (d) => d.y + 4)
  })
}

const drag = (simulation) => {
  function dragstarted(event, d) {
    if (!event.active) simulation.alphaTarget(0.3).restart()
    d.fx = d.x
    d.fy = d.y
  }
  function dragged(event, d) {
    d.fx = event.x
    d.fy = event.y
  }
  function dragended(event, d) {
    if (!event.active) simulation.alphaTarget(0)
    d.fx = null
    d.fy = null
  }
  return d3.drag().on('start', dragstarted).on('drag', dragged).on('end', dragended)
}

const exportSVG = () => {
  if (!svgRef.value) return
  const svgData = new XMLSerializer().serializeToString(svgRef.value)
  const blob = new Blob([svgData], { type: 'image/svg+xml;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = 'orthoguide_network.svg'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

defineExpose({
  exportSVG,
})

let resizeObserver
onMounted(() => {
  renderNetwork()
  if (networkContainer.value) {
    resizeObserver = new ResizeObserver(renderNetwork)
    resizeObserver.observe(networkContainer.value)
  }
})

watch(() => props.networkData, renderNetwork)

onBeforeUnmount(() => {
  if (simulation) {
    simulation.stop()
  }
  if (resizeObserver) {
    resizeObserver.disconnect()
  }
})
</script>

<style scoped>
.network-container {
  position: relative;
  width: 100%;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  overflow: hidden;
  min-height: 500px;
}
.network-container text {
  pointer-events: none;
  text-shadow:
    -1px -1px 0 #fff,
    1px -1px 0 #fff,
    -1px 1px 0 #fff,
    1px 1px 0 #fff;
}
.no-data-placeholder {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 500px;
  color: #6b7280;
  font-style: italic;
  background-color: #f9fafb;
}
</style>
