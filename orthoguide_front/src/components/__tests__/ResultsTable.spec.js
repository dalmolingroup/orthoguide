import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ResultsTable from '../ResultsTable.vue'

describe('ResultsTable.vue', () => {
  const mockResults = [
    { queryItem: 'NRP1', clade_name: 'Ambulacraria', root: 23.0, cog_id: 'NOG06579' },
    { queryItem: 'CDK6', clade_name: 'Metamonada', root: 37.0, cog_id: 'KOG0594' },
  ]

  it('renders table headers correctly', () => {
    const wrapper = mount(ResultsTable, {
      props: {
        results: [], // Passa um array vazio para testar apenas os cabeçalhos
      },
    })

    const headers = wrapper.findAll('th')
    expect(headers.length).toBe(4)
    expect(headers[0].text()).toBe('Gene')
    expect(headers[1].text()).toBe('Root Clade')
    expect(headers[2].text()).toBe('Root ID')
    expect(headers[3].text()).toBe('COG ID')
  })

  it('renders the correct number of rows based on the results prop', () => {
    const wrapper = mount(ResultsTable, {
      props: {
        results: mockResults,
      },
    })

    // Procura por todas as linhas no corpo da tabela (tbody)
    const rows = wrapper.findAll('tbody tr')
    expect(rows.length).toBe(mockResults.length)
  })

  it('displays the correct data in table cells for each row', () => {
    const wrapper = mount(ResultsTable, {
      props: {
        results: mockResults,
      },
    })

    const firstRowCells = wrapper.findAll('tbody tr:first-child td')
    expect(firstRowCells.length).toBe(4)
    expect(firstRowCells[0].text()).toBe(mockResults[0].queryItem)
    expect(firstRowCells[1].text()).toBe(mockResults[0].clade_name)
    expect(firstRowCells[2].text()).toBe(String(mockResults[0].root))
    expect(firstRowCells[3].text()).toBe(mockResults[0].cog_id)
  })

  it('renders an empty table body when no results are provided', () => {
    const wrapper = mount(ResultsTable, {
      props: {
        results: [],
      },
    })

    const tbody = wrapper.find('tbody')
    expect(tbody.exists()).toBe(true)
    // Verifica se não há linhas (tr) dentro do tbody
    expect(tbody.findAll('tr').length).toBe(0)
  })
})
