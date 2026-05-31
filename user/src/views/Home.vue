<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-50">
    <main class="max-w-7xl mx-auto px-4 sm:px-6 py-6 space-y-6">

      <!-- Notice / Announcement -->
      <section v-if="topNoticeSectionVisible" class="theme-notice-card p-5 md:p-6">
        <div class="flex items-start gap-3">
          <div class="bg-orange-500 text-white p-2 rounded-xl shrink-0 mt-0.5">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="10" stroke-width="2" />
              <line x1="12" x2="12" y1="8" y2="12" stroke-width="2" stroke-linecap="round" />
              <line x1="12" x2="12.01" y1="16" y2="16" stroke-width="2" stroke-linecap="round" />
            </svg>
          </div>
          <div class="space-y-2 min-w-0 flex-1">
            <h3 class="font-bold text-gray-900 text-base">{{ t('home.notice.title') }}</h3>
            <div v-if="topNotices.length > 0" class="space-y-2">
              <div v-for="notice in topNotices" :key="notice.id"
                class="text-sm text-gray-600 leading-relaxed">
                <span class="font-semibold text-gray-800">{{ getLocalizedText(notice.title) }}</span>
                <span v-if="notice.published_at" class="text-xs text-gray-400 ml-2">
                  {{ formatDate(notice.published_at) }}
                </span>
              </div>
            </div>
            <div v-else class="space-y-2">
              <div class="h-4 w-48 rounded theme-skeleton"></div>
              <div class="h-4 w-full max-w-md rounded theme-skeleton"></div>
            </div>
          </div>
        </div>
      </section>


      <!-- Category Pills -->
      <section class="flex flex-wrap gap-2.5 pb-2">
        <button
          v-for="cat in categoryList"
          :key="cat.id"
          class="theme-category-pill"
          :class="{ active: selectedCategory === cat.id }"
          @click="selectCategory(cat.id)"
        >
          <span class="truncate">{{ cat.name }}</span>
        </button>
      </section>

      <!-- Header -->
      <div class="flex items-center justify-between">
        <h2 class="text-xl font-bold text-gray-900 flex items-center gap-2">
          {{ t('home.featured.title') }}
        </h2>
        <span class="text-xs text-gray-400 bg-gray-100 px-3 py-1.5 rounded-lg">
          {{ t('products.total', { count: products.length }) }}
        </span>
      </div>

      <!-- Product Grid -->
      <section v-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-5">
        <div v-for="i in 8" :key="i" class="theme-product-card">
          <div class="h-36 theme-skeleton rounded-t-xl"></div>
          <div class="p-4 space-y-3">
            <div class="h-4 w-3/4 theme-skeleton rounded"></div>
            <div class="h-3 w-full theme-skeleton rounded"></div>
            <div class="h-5 w-1/3 theme-skeleton rounded"></div>
          </div>
        </div>
      </section>

      <section v-else-if="products.length > 0"
        class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-5">
        <ProductCard
          v-for="(product, idx) in products"
          :key="product.id"
          :product="product"
          :index="idx"
          @click="goToProduct"
          @quick-buy="openQuickBuy"
        />
      </section>

      <!-- Empty State -->
      <EmptyState
        v-else
        icon="package"
        :title="t('products.empty')"
        :description="t('products.subtitle')"
        action-to="/products"
      />

      <!-- Pagination -->
      <PaginationNav
        v-if="totalPages > 1"
        :current-page="currentPage"
        :total-pages="totalPages"
        :loading="loading"
        @change-page="changePage"
      />
    </main>

    <!-- Quick Buy Modal -->
    <ProductQuickBuy
      v-if="quickBuyProduct"
      :product="quickBuyProduct"
      :visible="quickBuyVisible"
      @update:visible="quickBuyVisible = $event"
    />
  </div>
</template>


<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { productAPI, categoryAPI, postAPI } from '../api'
import { useLocalized } from '../composables/useProduct'
import { useAppStore } from '../stores/app'
import ProductCard from '../components/ProductCard.vue'
import ProductQuickBuy from '../components/ProductQuickBuy.vue'
import PaginationNav from '../components/PaginationNav.vue'
import EmptyState from '../components/EmptyState.vue'

const router = useRouter()
const { t } = useI18n()
const { getLocalizedText } = useLocalized()
const appStore = useAppStore()

// State
const loading = ref(true)
const products = ref<any[]>([])
const categories = ref<any[]>([])
const selectedCategory = ref<number | null>(null)
const currentPage = ref(1)
const totalPages = ref(0)
const topNotices = ref<any[]>([])
const topNoticesLoading = ref(true)
const quickBuyProduct = ref<any>(null)
const quickBuyVisible = ref(false)

// Computed
const navBuiltin = computed(() => (appStore.config?.nav_config as any)?.builtin)
const noticeEnabled = computed(() => navBuiltin.value?.notice !== false)
const topNoticeSectionVisible = computed(() => noticeEnabled.value && (topNoticesLoading.value || topNotices.value.length > 0))

const categoryList = computed(() => {
  const all = { id: null as number | null, name: t('products.allCategories') }
  const cats = categories.value.map((c: any) => ({
    id: c.id,
    name: getLocalizedText(c.name) || c.slug
  }))
  return [all, ...cats]
})


// Methods
const selectCategory = (id: number | null) => {
  selectedCategory.value = id
  currentPage.value = 1
  loadProducts()
}

const changePage = (page: number) => {
  currentPage.value = page
  loadProducts()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const goToProduct = (slug: string) => {
  router.push(`/products/${slug}`)
}

const openQuickBuy = (product: any) => {
  quickBuyProduct.value = product
  quickBuyVisible.value = true
}

const formatDate = (dateString: string) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString()
}

const loadProducts = async () => {
  loading.value = true
  try {
    const params: any = { page: currentPage.value, page_size: 20 }
    if (selectedCategory.value) {
      params.category_id = selectedCategory.value
    }
    const response = await productAPI.list(params)
    products.value = response.data.data || []
    if (response.data.pagination) {
      totalPages.value = response.data.pagination.total_page || 0
    }
  } catch (error) {
    console.error('Failed to load products:', error)
  } finally {
    loading.value = false
  }
}

const loadCategories = async () => {
  try {
    const response = await categoryAPI.list()
    categories.value = response.data.data || []
  } catch (error) {
    console.error('Failed to load categories:', error)
  }
}

const loadTopNotices = async () => {
  if (!noticeEnabled.value) return
  topNoticesLoading.value = true
  try {
    const response = await postAPI.list({ type: 'notice', page: 1, page_size: 3 })
    topNotices.value = response.data.data || []
  } catch (error) {
    console.error('Failed to load notices:', error)
  } finally {
    topNoticesLoading.value = false
  }
}

// Lifecycle
onMounted(async () => {
  await Promise.all([loadCategories(), loadTopNotices(), loadProducts()])
})
</script>
