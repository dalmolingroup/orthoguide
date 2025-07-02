<template>
  <div class="chart-container">
    <canvas ref="chartCanvas"></canvas>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { Chart, registerables } from 'chart.js'

Chart.register(...registerables)

const props = defineProps({
  chartData: {
    type: Object,
    required: true,
  },
})

const chartCanvas = ref(null)
let chartInstance = null

const customPlugin = {
  id: 'customCanvasBackgroundColor',
  beforeDraw: (chart, args, options) => {
    const { ctx } = chart
    ctx.save()
    ctx.globalCompositeOperation = 'destination-over'
    ctx.fillStyle = options.color || '#99ffff'
    ctx.fillRect(0, 0, chart.width, chart.height)
    ctx.restore()
  },
}

const renderChart = () => {
  if (chartInstance) {
    chartInstance.destroy()
  }
  if (chartCanvas.value && props.chartData.labels.length) {
    const ctx = chartCanvas.value.getContext('2d')
    chartInstance = new Chart(ctx, {
      type: 'bar',
      data: props.chartData,
      plugins: [customPlugin],
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false,
          },
          customCanvasBackgroundColor: {
            color: 'white',
          },
          tooltip: {
            callbacks: {
              label: function (context) {
                let label = context.dataset.label || ''
                if (label) {
                  label += ': '
                }
                if (context.parsed.y !== null) {
                  label += context.parsed.y
                }
                return label
              },
            },
          },
        },
        scales: {
          x: {
            grid: {
              display: false,
            },
            ticks: {
              font: {
                size: 10,
              },
            },
          },
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Number of Genes',
            },
            ticks: {
              precision: 0,
            },
          },
        },
      },
    })
  }
}

const exportChart = () => {
  if (chartInstance) {
    const link = document.createElement('a')
    link.href = chartInstance.toBase64Image()
    link.download = 'orthoguide_bar_chart.png'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }
}

defineExpose({
  exportChart,
})

onMounted(renderChart)
watch(() => props.chartData, renderChart, { deep: true })
</script>

<style scoped>
.chart-container {
  position: relative;
  height: 400px;
  width: 100%;
}
</style>
