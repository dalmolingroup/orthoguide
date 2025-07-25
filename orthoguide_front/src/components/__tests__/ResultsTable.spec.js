// tests/ResultsTable.test.js

import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ResultsTable from '../ResultsTable.vue'

describe('ResultsTable.vue with DataTables.net', () => {
  // Configuração dos cabeçalhos, como definido no App.vue
  const mockColumns = [
    { title: 'Gene', data: 'preferred_name' },
    { title: 'Root Clade', data: 'clade_name' },
    { title: 'Root ID', data: 'root' },
    { title: 'COG ID', data: 'cog_id' },
  ]

  // Dados de exemplo
  const mockItems = [
    { preferred_name: 'CDK6', clade_name: 'Metamonada', root: 37.0, cog_id: 'KOG0594' },
    { preferred_name: 'NRP1', clade_name: 'Ambulacraria', root: 23.0, cog_id: 'NOG06579' },
  ]

  it('renders table headers correctly from the columns prop', async () => {
    const wrapper = mount(ResultsTable, {
      props: {
        items: mockItems,
        columns: mockColumns,
      },
    })

    // Aguarda o próximo ciclo para garantir que o DataTables renderizou
    await wrapper.vm.$nextTick()

    const headers = wrapper.findAll('thead th')
    expect(headers.length).toBe(mockColumns.length)
    expect(headers[0].text()).toBe('Gene')
    expect(headers[1].text()).toBe('Root Clade')
    expect(headers[2].text()).toBe('Root ID')
    expect(headers[3].text()).toBe('COG ID')
  })

  it('renders the correct number of rows based on the items prop', async () => {
    const wrapper = mount(ResultsTable, {
      props: {
        items: mockItems,
        columns: mockColumns,
      },
    })

    await wrapper.vm.$nextTick()

    const rows = wrapper.findAll('tbody tr')
    expect(rows.length).toBe(mockItems.length)
  })

  it('displays the correct data in table cells for each row', async () => {
    const wrapper = mount(ResultsTable, {
      props: {
        items: mockItems,
        columns: mockColumns,
      },
    })

    await wrapper.vm.$nextTick()

    const firstRowCells = wrapper.findAll('tbody tr:first-child td')
    expect(firstRowCells.length).toBe(mockColumns.length)
    expect(firstRowCells[0].text()).toBe(mockItems[0].preferred_name)
    expect(firstRowCells[1].text()).toBe(mockItems[0].clade_name)
    expect(firstRowCells[2].text()).toBe(String(mockItems[0].root))
    expect(firstRowCells[3].text()).toBe(mockItems[0].cog_id)
  })
})
