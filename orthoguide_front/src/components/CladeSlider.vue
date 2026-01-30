<template>
  <div class="slider-container">
    <label for="clade-slider" class="slider-label">Filter by Root Clade:</label>
    <div class="flex items-center gap-4">
      <div class="slider-wrapper" :class="{ 'has-tooltip': disabled }">
        <input
          id="clade-slider"
          type="range"
          :min="0"
          :max="clades.length - 1"
          :value="modelValue"
          :disabled="disabled"
          @input="$emit('update:modelValue', parseInt($event.target.value))"
          class="slider"
          :class="{ 'slider-disabled': disabled }"
        />
        <div v-if="disabled" class="tooltip">Please wait for the layout to stabilize</div>
      </div>
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
  disabled: {
    type: Boolean,
    default: false,
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
  color: var(--color-text);
}
.slider {
  width: 100%;
  height: 8px;
  border-radius: 5px;
  background: var(--color-border);
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
  min-width: 220px;
  text-align: left;
  color: var(--color-text);
}
.slider-disabled {
  opacity: 0.4 !important;
  cursor: not-allowed;
  pointer-events: none;
}
.slider-wrapper {
  position: relative;
  width: 100%;
}
.has-tooltip {
  cursor: not-allowed;
}
.tooltip {
  position: absolute;
  bottom: 150%;
  left: 50%;
  transform: translateX(-50%);
  background-color: var(--color-background-soft);
  color: var(--color-text);
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.8rem;
  white-space: nowrap;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.2s;
  z-index: 10;
  border: 1px solid var(--color-border);
}
.tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  margin-left: -5px;
  border-width: 5px;
  border-style: solid;
  border-color: var(--color-border) transparent transparent transparent;
}
.has-tooltip:hover .tooltip {
  opacity: 1;
}
.slider-disabled {
  opacity: 0.4 !important;
  cursor: not-allowed;
  pointer-events: none;
}
.slider-wrapper {
  position: relative;
  width: 100%;
}
.has-tooltip {
  cursor: not-allowed;
}
.tooltip {
  position: absolute;
  bottom: 150%;
  left: 50%;
  transform: translateX(-50%);
  background-color: #374151;
  color: white;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.8rem;
  white-space: nowrap;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.2s;
  z-index: 10;
}
.tooltip::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  margin-left: -5px;
  border-width: 5px;
  border-style: solid;
  border-color: #374151 transparent transparent transparent;
}
.has-tooltip:hover .tooltip {
  opacity: 1;
}
</style>
