import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import AnalysisCard from '../AnalysisCard.vue'

describe('AnalysisCard.vue', () => {
  it('renders the form elements correctly', () => {
    const wrapper = mount(AnalysisCard)

    expect(wrapper.find('h2').text()).toBe('Rooting Analysis')
    expect(wrapper.find('textarea#gene-ids').exists()).toBe(true)
    expect(wrapper.find('select#organism-db').exists()).toBe(true)
    expect(wrapper.find('button.infer-button').exists()).toBe(true)
  })

  it('emits "start-analysis" with parsed gene IDs when the button is clicked', async () => {
    const wrapper = mount(AnalysisCard)

    const textarea = wrapper.find('textarea#gene-ids')
    await textarea.setValue('TP53\nBRCA1\n\nEGFR ') // Inclui espaços e linhas vazias para testar o parsing

    await wrapper.find('.infer-button').trigger('click')

    expect(wrapper.emitted()).toHaveProperty('start-analysis')

    // Verifica se o payload do evento está correto (parsed)
    const emittedEvent = wrapper.emitted('start-analysis')
    expect(emittedEvent[0][0]).toEqual(['TP53', 'BRCA1', 'EGFR'])
  })

  it('does not emit "start-analysis" if the gene input is empty', async () => {
    const wrapper = mount(AnalysisCard)

    await wrapper.find('textarea#gene-ids').setValue('')

    await wrapper.find('.infer-button').trigger('click')

    expect(wrapper.emitted('start-analysis')).toBeUndefined()
  })

  it('disables the button and shows a loading state when isLoading is true', async () => {
    const wrapper = mount(AnalysisCard, {
      props: {
        isLoading: true,
      },
    })

    const button = wrapper.find('.infer-button')

    expect(button.attributes('disabled')).toBeDefined()

    // Verifica se o texto do botão é "Loading..."
    expect(button.text()).toContain('Loading...')

    // Verifica se o ícone de spinner está presente
    expect(wrapper.find('svg.animate-spin').exists()).toBe(true)
  })
})
