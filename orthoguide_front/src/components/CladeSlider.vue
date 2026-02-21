<template>
  <div class="slider-container">
    <label for="clade-slider" class="slider-label">Filter by Root Clade:</label>
    
    <!-- Upper ticks: Clade names (rotated) -->
    <div class="ticks-upper-container">
      <div class="ticks-upper-row">
        <div 
          v-for="(clade, index) in clades" 
          :key="'upper-' + index"
          class="tick-item-upper"
          :style="{ left: getTickPosition(index) }"
        >
          <span class="tick-label-upper" :title="clade.name">{{ clade.name }}</span>
        </div>
      </div>
    </div>

    <!-- Slider with tick marks -->
    <div class="slider-track-container">
      <!-- Upper tick marks -->
      <div class="tick-marks-row">
        <div 
          v-for="(clade, index) in clades" 
          :key="'mark-upper-' + index"
          class="tick-mark-upper"
          :style="{ left: getTickPosition(index) }"
        ></div>
      </div>
      
      <!-- Slider -->
      <div class="slider-track-wrapper" :class="{ 'has-tooltip': disabled }">
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
          :aria-describedby="disabled ? 'clade-slider-disabled-message' : undefined"
        />
        <div 
          v-if="disabled" 
          id="clade-slider-disabled-message"
          class="tooltip"
          role="tooltip"
          aria-live="polite"
        >
          Please wait for the layout to stabilize
        </div>
      </div>

      <!-- Lower tick marks -->
      <div class="tick-marks-row">
        <div 
          v-for="(clade, index) in clades" 
          :key="'mark-lower-' + index"
          class="tick-mark-lower"
          :style="{ left: getTickPosition(index) }"
        ></div>
      </div>
    </div>

    <!-- Lower ticks: Root IDs -->
    <div class="ticks-lower-row">
      <div 
        v-for="(clade, index) in clades" 
        :key="'lower-' + index"
        class="tick-item-lower"
        :style="{ left: getTickPosition(index) }"
      >
        <span class="tick-label-lower">{{ clade.rootId }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
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

const getTickPosition = (index) => {
  if (props.clades.length <= 1) return '0%'
  const percentage = (index / (props.clades.length - 1)) * 100
  return `${percentage}%`
}
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

/* Upper ticks container with rotated labels */
.ticks-upper-container {
  position: relative;
  width: 100%;
  height: 140px;
  margin-bottom: 4px;
}

.ticks-upper-row {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 100%;
}

.tick-item-upper {
  position: absolute;
  bottom: 0;
  transform: translateX(-50%);
  height: 100%;
  display: flex;
  align-items: flex-end;
}

.tick-label-upper {
  writing-mode: vertical-rl;
  transform: rotate(180deg);
  white-space: nowrap;
  font-size: 0.7rem;
  color: var(--color-text);
  max-height: 130px;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Slider track container */
.slider-track-container {
  position: relative;
  width: 100%;
}

/* Tick marks rows */
.tick-marks-row {
  position: relative;
  width: 100%;
  height: 6px;
}

.tick-mark-upper,
.tick-mark-lower {
  position: absolute;
  width: 1px;
  height: 6px;
  background-color: var(--color-border);
  transform: translateX(-50%);
}

/* Slider track wrapper */
.slider-track-wrapper {
  position: relative;
  width: 100%;
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

.slider-disabled {
  opacity: 0.4 !important;
  cursor: not-allowed;
  pointer-events: none;
}

/* Lower ticks row with root IDs */
.ticks-lower-row {
  position: relative;
  width: 100%;
  height: 20px;
  margin-top: 4px;
}

.tick-item-lower {
  position: absolute;
  top: 0;
  transform: translateX(-50%);
}

.tick-label-lower {
  display: block;
  font-size: 0.65rem;
  color: var(--color-text);
  font-weight: 500;
  text-align: center;
}

/* Tooltip styles */
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
