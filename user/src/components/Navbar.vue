<template>
  <nav class="sticky top-0 z-50 theme-nav-root border-b">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 py-3 flex items-center justify-between gap-4">
      <!-- Brand -->
      <div class="flex items-center gap-3 shrink-0">
        <router-link to="/" class="flex items-center gap-2" :title="brandSiteName">
          <div class="bg-gradient-to-br from-[#f97316] to-[#ea580c] p-1.5 rounded-lg">
            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <circle cx="8" cy="21" r="1" /><circle cx="19" cy="21" r="1" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M2.05 2.05h2l2.66 12.42a2 2 0 002 1.58h9.78a2 2 0 001.95-1.57l1.65-7.43H5.12" />
            </svg>
          </div>
          <span class="text-lg font-bold tracking-tight text-gray-900">{{ brandSiteName }}</span>
        </router-link>
      </div>

      <!-- Search (desktop) -->
      <div class="relative hidden sm:block flex-1 max-w-xs">
        <svg class="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <circle cx="11" cy="11" r="8" stroke-width="2" />
          <path stroke-linecap="round" stroke-width="2" d="m21 21-4.34-4.34" />
        </svg>
        <input
          v-model="searchQuery"
          type="text"
          :placeholder="t('products.searchBoxPlaceholder')"
          class="w-full bg-gray-100 border border-gray-200 text-sm rounded-lg pl-9 pr-4 py-2
                 outline-none focus:border-orange-500 focus:ring-1 focus:ring-orange-500
                 transition-all placeholder:text-gray-400"
          @keydown.enter="doSearch"
        />
      </div>


      <!-- Right Actions -->
      <div class="flex items-center gap-2 sm:gap-3 shrink-0">
        <!-- Cart -->
        <router-link to="/cart"
          class="relative flex items-center gap-1.5 px-3 py-2 bg-white border border-gray-200 text-gray-700
                 hover:bg-gray-50 text-sm font-bold rounded-lg transition-all shadow-sm whitespace-nowrap">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
            <circle cx="8" cy="21" r="1" /><circle cx="19" cy="21" r="1" />
            <path stroke-linecap="round" d="M2.05 2.05h2l2.66 12.42a2 2 0 002 1.58h9.78a2 2 0 001.95-1.57l1.65-7.43H5.12" />
          </svg>
          <span class="hidden sm:inline">{{ t('navbar.cart') }}</span>
          <span v-if="cartCount > 0"
            class="absolute -top-1.5 -right-1.5 bg-orange-500 text-white text-[10px] font-bold min-w-[18px] h-[18px] rounded-full flex items-center justify-center">
            {{ cartCount }}
          </span>
        </router-link>

        <!-- Guest Orders -->
        <router-link v-if="!userAuthStore.isAuthenticated" to="/guest/orders"
          class="hidden sm:flex items-center gap-1.5 px-3 py-2 bg-white border border-gray-200 text-gray-700
                 hover:bg-gray-50 text-sm font-bold rounded-lg transition-all shadow-sm whitespace-nowrap">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.75">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
          </svg>
          <span>{{ t('navbar.guestOrders') }}</span>
        </router-link>

        <!-- Login / Account -->
        <router-link v-if="!userAuthStore.isAuthenticated" to="/auth/login"
          class="flex items-center gap-1.5 px-3 py-2 bg-gradient-to-r from-orange-500 to-amber-600 text-white
                 text-sm font-bold rounded-lg transition-all hover:shadow-md hover:scale-[1.02] whitespace-nowrap">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.75">
            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
          <span class="hidden sm:inline">{{ t('navbar.login') }}</span>
        </router-link>

        <router-link v-else to="/me"
          class="flex items-center gap-1.5 px-3 py-2 bg-gradient-to-r from-orange-500 to-amber-600 text-white
                 text-sm font-bold rounded-lg transition-all hover:shadow-md hover:scale-[1.02] whitespace-nowrap">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.75">
            <path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
          <span class="hidden sm:inline">{{ t('navbar.personalCenter') }}</span>
        </router-link>
      </div>
    </div>
  </nav>
</template>


<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAppStore } from '../stores/app'
import { useUserAuthStore } from '../stores/userAuth'
import { useCartStore } from '../stores/cart'

const router = useRouter()
const { t } = useI18n()
const appStore = useAppStore()
const userAuthStore = useUserAuthStore()
const cartStore = useCartStore()

const searchQuery = ref('')
const cartCount = computed(() => cartStore.totalItems)

const brandSiteName = computed(() => {
  const siteName = appStore.config?.brand?.site_name
  return typeof siteName === 'string' && siteName.trim() ? siteName.trim() : 'Dujiao-Next'
})

const doSearch = () => {
  if (searchQuery.value.trim()) {
    router.push({ path: '/products', query: { search: searchQuery.value.trim() } })
  }
}
</script>
