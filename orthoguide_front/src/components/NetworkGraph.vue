<template>
  <div class="network-container" ref="networkContainer">
    <svg
      v-if="(networkData && networkData.length > 0) || (allGenes && allGenes.length > 0)"
      ref="svgRef"
    ></svg>
    <div
      v-if="(networkData && networkData.length > 0) || (allGenes && allGenes.length > 0)"
      class="legend"
    >
      <div class="legend-item">
        <span class="legend-color-box orange"></span>
        <span>Arose in this clade</span>
      </div>
      <div class="legend-item">
        <span class="legend-color-box blue"></span>
        <span>Previously present</span>
      </div>
    </div>
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
  allGenes: {
    type: Array,
    required: true,
  },
  genesInSelectedClade: {
    type: Set,
    required: true,
  },
  showGeneNames: {
    type: Boolean,
    default: false,
  },
  largeFont: {
    type: Boolean,
    default: false,
  },
  nodeCoordinates: {
    type: Map,
    default: () => new Map(),
  },
})

const emit = defineEmits(['simulation-end', 'node-dragged'])

const networkContainer = ref(null)
const svgRef = ref(null)
const currentZoomTransform = ref(null)
let simulation

const renderNetwork = () => {
  const svg = d3.select(svgRef.value)

  // Capture current zoom transform before clearing
  if (svg.node()) {
    const currentTransform = d3.zoomTransform(svg.node())
    // Only save if it's not the identity transform (default) or if we already have a saved transform
    // This check prevents overwriting a saved transform with identity on first render
    if (
      currentTransform &&
      (currentTransform.k !== 1 || currentTransform.x !== 0 || currentTransform.y !== 0)
    ) {
      currentZoomTransform.value = currentTransform
    }
  }

  svg.selectAll('*').remove()

  if (
    ((!props.networkData || props.networkData.length === 0) &&
      (!props.allGenes || props.allGenes.length === 0)) ||
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
  const nodes = Array.from(nodesMap.values()).map((n) => {
    if (props.nodeCoordinates && props.nodeCoordinates.has(n.id)) {
      const coords = props.nodeCoordinates.get(n.id)
      return { ...n, x: coords.x, y: coords.y, fx: coords.x, fy: coords.y }
    }
    return n
  })

  // If we have any coordinates stored, we know we have them for all nodes from the initial simulation.
  // The initial simulation always runs on the full dataset, so coordinates will be available for any subset.
  const hasCoordinates = props.nodeCoordinates.size > 0

  const connectedIds = new Set(nodesMap.keys())
  const unconnectedNodes = props.allGenes
    .filter((id) => !connectedIds.has(id))
    .sort()
    .map((id) => ({ id }))

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
    .attr('style', 'max-width: 100%; height: auto; cursor: grab;')

  simulation = d3.forceSimulation(nodes)

  if (!hasCoordinates) {
    simulation
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

    simulation.on('end', () => {
      const currentCoords = new Map()
      nodes.forEach((n) => {
        currentCoords.set(n.id, { x: n.x, y: n.y })
      })
      emit('simulation-end', currentCoords)
    })
  } else {
    // If we have coordinates, initialize simulation but with no forces
    // This allows drag behavior to still work via simulation.on('tick')
    simulation.force(
      'link',
      d3
        .forceLink(links)
        .id((d) => d.id)
        .strength(0),
    )
    // We trigger one tick to render initial positions
    simulation.tick()
  }

  const zoomRect = svg
    .append('rect')
    .attr('width', width)
    .attr('height', height)
    .attr('x', -width / 2)
    .attr('y', -height / 2)
    .style('fill', 'none')
    .style('pointer-events', 'all')

  const g = svg.append('g')

  const link = g
    .append('g')
    .attr('stroke', '#999')
    .attr('stroke-opacity', 0.6)
    .selectAll('line')
    .data(links)
    .join('line')
    .attr('stroke-width', (d) => Math.sqrt(d.score) * 2)

  const node = g
    .append('g')
    .attr('stroke', 'var(--color-background)')
    .attr('stroke-width', 1.5)
    .selectAll('circle')
    .data(nodes)
    .join('circle')
    .attr('r', 8)
    .attr('fill', (d) => (props.genesInSelectedClade.has(d.id) ? '#f97316' : '#2563eb'))
    .call(drag(simulation))

  const text = g
    .append('g')
    .selectAll('text')
    .data(nodes)
    .join('text')
    .text((d) => d.id)
    .attr('font-size', props.largeFont ? '16px' : '12px')
    .attr('paint-order', 'stroke')
    .attr('stroke', 'var(--color-background)')
    .attr('stroke-width', '3px')
    .attr('visibility', props.showGeneNames ? 'visible' : 'hidden')

  // Render unconnected nodes in a box
  if (unconnectedNodes.length > 0) {
    const colWidth = props.largeFont ? 180 : 130
    const boxWidth = colWidth + 40
    const rowHeight = props.largeFont ? 40 : 30
    const cols = 1
    const rows = unconnectedNodes.length
    const boxHeight = rows * rowHeight + 35

    // Position box in top-left of the view
    let boxX = -width / 2 + 20
    let boxY = -height / 2 + 20

    const boxGroup = g
      .append('g')
      .attr('transform', `translate(${boxX}, ${boxY})`)
      .style('cursor', 'move')

    boxGroup.call(
      d3.drag().on('drag', (event) => {
        boxX += event.dx
        boxY += event.dy
        boxGroup.attr('transform', `translate(${boxX}, ${boxY})`)
      }),
    )

    boxGroup
      .append('rect')
      .attr('width', boxWidth)
      .attr('height', boxHeight)
      .attr('fill', 'var(--color-background-soft)')
      .attr('stroke', 'var(--color-border)')
      .attr('rx', 6)

    boxGroup
      .append('text')
      .attr('x', 10)
      .attr('y', 20)
      .text('Unconnected Genes')
      .attr('font-size', '12px')
      .attr('font-weight', 'bold')
      .attr('fill', 'var(--color-text)')

    const dotsGroup = boxGroup.append('g').attr('transform', `translate(10, 35)`)

    dotsGroup
      .selectAll('circle')
      .data(unconnectedNodes)
      .join('circle')
      .attr('cx', (d, i) => (i % cols) * colWidth + 20)
      .attr('cy', (d, i) => Math.floor(i / cols) * rowHeight + rowHeight / 2)
      .attr('r', 5)
      .attr('fill', (d) => (props.genesInSelectedClade.has(d.id) ? '#f97316' : '#2563eb'))
      .attr('stroke', 'var(--color-background)')
      .attr('stroke-width', 1)
      .append('title')
      .text((d) => d.id)

    dotsGroup
      .selectAll('text')
      .data(unconnectedNodes)
      .join('text')
      .text((d) => d.id)
      .attr('x', (d, i) => (i % cols) * colWidth + 32)
      .attr(
        'y',
        (d, i) => Math.floor(i / cols) * rowHeight + rowHeight / 2 + (props.largeFont ? 5 : 4),
      )
      .attr('text-anchor', 'start')
      .attr('font-size', props.largeFont ? '16px' : '12px')
      .attr('paint-order', 'stroke')
      .attr('stroke', 'var(--color-background)')
      .attr('stroke-width', '3px')
      .attr('visibility', 'visible')
  }

  function fade(opacity) {
    return (event, d) => {
      node.style('opacity', function (o) {
        return isConnected(d, o) ? 1 : opacity
      })

      text.style('visibility', function (o) {
        return isConnected(d, o) ? 'visible' : 'hidden'
      })

      link.style('stroke-opacity', (o) =>
        o.source.id === d.id || o.target.id === d.id ? 1 : opacity,
      )

      if (opacity === 1) {
        node.style('opacity', 1)
        text.style('visibility', props.showGeneNames ? 'visible' : 'hidden')
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

  const zoom = d3
    .zoom()
    .scaleExtent([0.5, 4])
    .on('zoom', (event) => {
      g.attr('transform', event.transform)
    })

  svg.call(zoom)

  // Restore previous zoom if available
  if (currentZoomTransform.value) {
    svg.call(zoom.transform, currentZoomTransform.value)
  }
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
    emit('node-dragged', { id: d.id, x: d.x, y: d.y })
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

const exportPNG = () => {
  if (!svgRef.value) return

  const svgNode = svgRef.value.cloneNode(true)
  d3.select(svgNode)
    .attr('style', 'background-color: white;')
    .selectAll('text')
    .attr('font-family', 'sans-serif')

  const svgData = new XMLSerializer().serializeToString(svgNode)
  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')

  const width = parseInt(svgRef.value.getAttribute('width'))
  const height = parseInt(svgRef.value.getAttribute('height'))

  const scale = 2
  canvas.width = width * scale
  canvas.height = height * scale
  ctx.scale(scale, scale)

  const img = new Image()
  img.onload = () => {
    ctx.fillStyle = 'white'
    ctx.fillRect(0, 0, canvas.width, canvas.height)
    ctx.drawImage(img, 0, 0)
    const url = canvas.toDataURL('image/png')
    const link = document.createElement('a')
    link.href = url
    link.download = 'orthoguide_network.png'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    URL.revokeObjectURL(url)
  }
  img.src = `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svgData)}`
}

defineExpose({
  exportGraph: (format = 'svg') => {
    if (format === 'png') {
      exportPNG()
    } else {
      exportSVG()
    }
  },
})

let resizeObserver
onMounted(() => {
  renderNetwork()
  if (networkContainer.value) {
    resizeObserver = new ResizeObserver(renderNetwork)
    resizeObserver.observe(networkContainer.value)
  }
})

watch(
  [() => props.networkData, () => props.allGenes, () => props.showGeneNames, () => props.largeFont],
  renderNetwork,
)

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
  border: 1px solid var(--color-border);
  border-radius: 8px;
  overflow: hidden;
  min-height: 500px;
}
.network-container text {
  pointer-events: none;
  text-shadow:
    -1px -1px 0 var(--color-background),
    1px -1px 0 var(--color-background),
    -1px 1px 0 var(--color-background),
    1px 1px 0 var(--color-background);
}
.no-data-placeholder {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 500px;
  color: var(--color-text);
  font-style: italic;
  background-color: var(--color-background-soft);
}
.legend {
  position: absolute;
  bottom: 10px;
  left: 10px;
  background-color: var(--color-background);
  color: var(--color-text);
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid var(--color-border);
  font-size: 12px;
  pointer-events: none;
  opacity: 0.9;
}
.legend-item {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
}
.legend-item:last-child {
  margin-bottom: 0;
}
.legend-color-box {
  width: 12px;
  height: 12px;
  border-radius: 3px;
  margin-right: 8px;
  border: 1px solid rgba(0, 0, 0, 0.2);
}
.legend-color-box.orange {
  background-color: #f97316;
}
.legend-color-box.blue {
  background-color: #2563eb;
}
</style>
