<template>
  <div class="results-table-wrapper">
    <DataTable
      ref="dt"
      :columns="columns"
      :data="items"
      class="display"
      width="100%"
      :options="{ order: [] }"
    >
      <thead>
        <tr>
          <th>Gene</th>
          <th>Root Clade</th>
          <th>Root ID</th>
          <th>COG ID</th>
        </tr>
      </thead>
    </DataTable>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DataTable from 'datatables.net-vue3'
import DataTablesCore from 'datatables.net'

DataTable.use(DataTablesCore)

const props = defineProps({
  items: {
    type: Array,
    required: true,
  },
  columns: {
    type: Array,
    required: true,
  },
})

const dt = ref(null)

const getSortedData = () => {
  if (dt.value) {
    return dt.value.dt.rows({ order: 'current' }).data().toArray()
  }
  return props.items
}

defineExpose({
  getSortedData,
})
</script>

<style>
@import 'datatables.net-dt';
</style>
