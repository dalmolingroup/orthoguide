<template>
  <div class="results-table-wrapper">
    <DataTable :columns="columns" :data="items" class="display" width="100%">
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
</script>

<style>
@import 'datatables.net-dt';
</style>
