<template>
  <footer class="text-center py-8 text-xs text-gray-400 border-t border-gray-100">
    <p>&copy; {{ currentYear }} {{ brandSiteName }}</p>
    <p class="mt-1.5 flex items-center justify-center gap-3">
      <router-link to="/about" class="hover:text-gray-600 transition-colors">{{ t('nav.about') }}</router-link>
      <span class="text-gray-200">|</span>
      <router-link to="/terms" class="hover:text-gray-600 transition-colors">{{ t('footer.terms') }}</router-link>
      <span class="text-gray-200">|</span>
      <router-link to="/privacy" class="hover:text-gray-600 transition-colors">{{ t('footer.privacy') }}</router-link>
    </p>
    <p class="mt-1.5">
      <a href="https://github.com/dujiao-next" target="_blank" rel="noopener noreferrer"
        class="hover:text-gray-600 transition-colors">
        Powered by Dujiao-Next
      </a>
    </p>
  </footer>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useAppStore } from '../stores/app'

const { t } = useI18n()
const appStore = useAppStore()

const brandSiteName = computed(() => {
  const siteName = appStore.config?.brand?.site_name
  return typeof siteName === 'string' && siteName.trim() ? siteName.trim() : 'Dujiao-Next'
})

const currentYear = new Date().getFullYear()
</script>
