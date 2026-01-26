import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ResultsCard from '../ResultsCard.vue'

describe('ResultsCard.vue - State Reset on New Analysis', () => {
  const mockResults = [
    {
      preferred_name: 'GENE1',
      protein_id: 'PROT1',
      clade_name: 'Clade A',
      root: 1,
      cog_id: 'COG1',
    },
  ]

  const mockCladeList = [{ name: 'Clade A', rootId: 1 }]

  const defaultProps = {
    results: mockResults,
    apiErrorMessage: '',
    chartData: { labels: [], datasets: [] },
    networkData: [],
    cladeList: mockCladeList,
    filteredNetworkData: [],
    selectedCladeIndex: 0,
    tableHeaders: [
      { title: 'Gene', data: 'preferred_name' },
      { title: 'Protein ID', data: 'protein_id' },
    ],
    genesInSelectedClade: new Set(['GENE1']),
    missingGenes: [],
  }

  it('resets nodeCoordinates and isSliderDisabled when results transition from non-null to null', async () => {
    const wrapper = mount(ResultsCard, {
      props: defaultProps,
      global: {
        stubs: {
          ResultsTable: true,
          BarChart: true,
          NetworkGraph: true,
          CladeSlider: true,
        },
      },
    })

    // Simulate simulation end which sets nodeCoordinates
    const mockCoords = new Map([
      ['GENE1', { x: 100, y: 200 }],
      ['GENE2', { x: 150, y: 250 }],
    ])

    // Access the component's internal state through vm
    wrapper.vm.handleSimulationEnd(mockCoords)

    // Verify state is set
    expect(wrapper.vm.nodeCoordinates.size).toBe(2)
    expect(wrapper.vm.isSliderDisabled).toBe(false)

    // Simulate a new analysis by setting results to null (transition from non-null to null)
    await wrapper.setProps({ results: null })

    // Wait for the watcher to trigger
    await wrapper.vm.$nextTick()

    // Verify state is reset
    expect(wrapper.vm.nodeCoordinates.size).toBe(0)
    expect(wrapper.vm.isSliderDisabled).toBe(true)
  })

  it('does not reset state when results change from one set to another', async () => {
    const wrapper = mount(ResultsCard, {
      props: defaultProps,
      global: {
        stubs: {
          ResultsTable: true,
          BarChart: true,
          NetworkGraph: true,
          CladeSlider: true,
        },
      },
    })

    // Simulate simulation end which sets nodeCoordinates
    const mockCoords = new Map([['GENE1', { x: 100, y: 200 }]])

    wrapper.vm.handleSimulationEnd(mockCoords)

    // Verify state is set
    expect(wrapper.vm.nodeCoordinates.size).toBe(1)
    expect(wrapper.vm.isSliderDisabled).toBe(false)

    // Change results to a different set (not null)
    const newResults = [
      {
        preferred_name: 'GENE3',
        protein_id: 'PROT3',
        clade_name: 'Clade C',
        root: 3,
        cog_id: 'COG3',
      },
    ]

    await wrapper.setProps({ results: newResults })
    await wrapper.vm.$nextTick()

    // Verify state is NOT reset (should remain the same)
    expect(wrapper.vm.nodeCoordinates.size).toBe(1)
    expect(wrapper.vm.isSliderDisabled).toBe(false)
  })

  it('does not reset state on initial mount with null results', async () => {
    const wrapper = mount(ResultsCard, {
      props: {
        ...defaultProps,
        results: null, // Start with null
      },
      global: {
        stubs: {
          ResultsTable: true,
          BarChart: true,
          NetworkGraph: true,
          CladeSlider: true,
        },
      },
    })

    await wrapper.vm.$nextTick()

    // Verify initial state is maintained (not reset since there's no transition)
    expect(wrapper.vm.nodeCoordinates.size).toBe(0)
    expect(wrapper.vm.isSliderDisabled).toBe(true)
  })
})
