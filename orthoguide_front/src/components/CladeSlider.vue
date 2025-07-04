<template>
  <div class="slider-container">
    <label for="clade-slider" class="slider-label">Filter by Root Clade:</label>
    <div class="flex items-center gap-4">
      <input
        id="clade-slider"
        type="range"
        :min="0"
        :max="clades.length - 1"
        :value="modelValue"
        @input="$emit('update:modelValue', parseInt($event.target.value))"
        class="slider"
      />
      <span class="slider-value">{{ clades[modelValue] ? clades[modelValue].name : '' }}</span>
    </div>
  </div>
</template>

<script setup>
defineProps({
  clades: {
    type: Array,
    required: true,
  },
  modelValue: {
    type: Number,
    required: true,
  },
})
defineEmits(['update:modelValue'])
</script>

<style scoped>
.slider-container {
  padding: 1rem 0;
}
.slider-label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}
.slider {
  width: 100%;
  height: 8px;
  border-radius: 5px;
  background: #d1d5db;
  outline: none;
  opacity: 0.7;
  transition: opacity 0.2s;
}
.slider:hover {
  opacity: 1;
}
.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #2563eb;
  cursor: pointer;
}
.slider::-moz-range-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #2563eb;
  cursor: pointer;
}
.slider-value {
  font-weight: 600;
  min-width: 120px;
  text-align: left;
}
</style>
