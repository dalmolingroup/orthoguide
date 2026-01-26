<script setup>
const props = defineProps({
  isDark: {
    type: Boolean,
    required: true,
  },
})

const emit = defineEmits(['toggle'])

const toggleTheme = () => {
  emit('toggle')
}
</script>

<template>
  <button
    class="theme-toggle"
    @click="toggleTheme"
    :title="isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'"
    :aria-label="isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'"
  >
    <!-- Sun Icon (for Light Mode) -->
    <svg
      v-if="!isDark"
      class="icon sun"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <circle cx="12" cy="12" r="5"></circle>
      <line x1="12" y1="1" x2="12" y2="3"></line>
      <line x1="12" y1="21" x2="12" y2="23"></line>
      <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
      <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
      <line x1="1" y1="12" x2="3" y2="12"></line>
      <line x1="21" y1="12" x2="23" y2="12"></line>
      <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
      <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
    </svg>

    <!-- Moon Icon (for Dark Mode) -->
    <svg
      v-else
      class="icon moon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
    </svg>
  </button>
</template>

<style scoped>
.theme-toggle {
  background: none;
  border: 1px solid var(--color-border);
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  color: var(--color-text);
  display: flex;
  align-items: center;
  justify-content: center;
  transition:
    background-color 0.3s,
    color 0.3s;
}

.theme-toggle:hover {
  background-color: var(--vt-c-divider-light-2);
}

[data-theme='dark'] .theme-toggle:hover {
  background-color: var(--vt-c-divider-dark-2);
}

.icon {
  width: 20px;
  height: 20px;
}
</style>
