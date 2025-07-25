<template>
  <div class="results-table-wrapper">
    <table class="results-table">
      <thead>
        <tr>
          <th>Gene</th>
          <th>Root Clade</th>
          <th>Root ID</th>
          <th>COG ID</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in results" :key="item.preferred_name">
          <td>{{ item.preferred_name }}</td>
          <td>{{ item.clade_name }}</td>
          <td>{{ item.root }}</td>
          <td>{{ item.cog_id }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
defineProps({
  results: {
    type: Array,
    required: true,
  },
})
</script>

<style scoped>
.results-table-wrapper {
  overflow-x: auto;
}
.results-table {
  width: 100%;
  border-collapse: collapse;
}
.results-table th,
.results-table td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #e9ecef;
}
.results-table thead th {
  background-color: #f9fafb;
  font-size: 0.75rem;
  text-transform: uppercase;
  color: #6c757d;
}
.results-table tbody tr:last-child td {
  border-bottom: none;
}
.results-table td:first-child {
  font-weight: 600;
}
</style>
