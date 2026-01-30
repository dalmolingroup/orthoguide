<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import ThemeToggle from './components/ThemeToggle.vue'

const isDark = ref(false)

const toggleTheme = () => {
  isDark.value = !isDark.value
  const newTheme = isDark.value ? 'dark' : 'light'
  localStorage.setItem('orthoguide-theme', newTheme)
  document.documentElement.setAttribute('data-theme', newTheme)
}

onMounted(() => {
  const savedTheme = localStorage.getItem('orthoguide-theme')
  if (savedTheme) {
    isDark.value = savedTheme === 'dark'
    document.documentElement.setAttribute('data-theme', savedTheme)
  } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    // Optional: Respect system preference if no saved preference
    isDark.value = true
    document.documentElement.setAttribute('data-theme', 'dark')
  }
})
</script>

<template>
  <!-- Header Section -->
  <header class="header">
    <!-- Logo SVG -->
    <svg
      width="300"
      height="60"
      viewBox="0 0 300 80"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      font-family="Poppins, sans-serif"
    >
      <g transform="translate(10, 5) scale(0.6)">
        <circle cx="50" cy="50" r="45" stroke="#3b82f6" stroke-width="10" />
        <path
          d="M 75 50 A 25 25 0 1 1 50 25"
          stroke="#16a34a"
          stroke-width="10"
          stroke-linecap="round"
        />
        <line
          x1="25"
          y1="50"
          x2="50"
          y2="50"
          stroke="#16a34a"
          stroke-width="10"
          stroke-linecap="round"
        />
      </g>
      <text x="80" y="48" font-size="40" font-weight="bold">
        <tspan class="logo-text" fill="#3b82f6">Ortho</tspan>
        <tspan class="logo-text" fill="#16a34a">Guide</tspan>
      </text>
    </svg>
    <RouterLink to="/">Home</RouterLink>
    <RouterLink to="/about">About</RouterLink>
    <div class="tagline">So crossing the bridge is easier.</div>
    <ThemeToggle :is-dark="isDark" @toggle="toggleTheme" />
  </header>
  <RouterView />
</template>

<style scoped>
#body {
  display: flex;
  flex-direction: column;
  justify-content: space-around;
}

/* Header Styling */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  margin-bottom: 40px;
  gap: 1rem;
}

.tagline {
  font-size: 0.8rem;
  color: var(--color-text);
  opacity: 0.8;
}

.logo-text {
  font-weight: 700;
}

/* Responsive design for smaller screens */
@media (max-width: 768px) {
  .header {
    flex-direction: column;
    align-items: center;
    gap: 1rem;
  }
}
</style>
