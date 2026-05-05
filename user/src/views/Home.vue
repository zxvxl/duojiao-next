<template>
  <div class="home-page min-h-screen theme-page">
    <section
      v-if="topNoticeSectionVisible"
      class="relative z-10 pt-24 pb-5"
    >
      <div class="container mx-auto px-4">
        <div class="home-announcement-shell overflow-hidden rounded-xl border">
          <div class="p-4 sm:p-5">
            <div class="mb-4 flex items-center gap-3">
              <div class="home-announcement-icon flex h-12 w-12 shrink-0 items-center justify-center rounded-lg">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.75"
                    d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                </svg>
              </div>
              <div class="min-w-0 flex-1">
                <span class="home-announcement-label">{{ t('home.notice.label') }}</span>
                <h2 class="mt-1 text-xl font-bold theme-text-primary sm:text-2xl">{{ t('home.notice.title') }}</h2>
              </div>
            </div>

            <div v-if="topNotices.length > 0" class="space-y-3">
              <article
                v-for="notice in topNotices"
                :key="notice.id"
                class="home-announcement-item"
              >
                <div class="mb-2 flex flex-wrap items-center gap-2">
                  <h3 class="text-base font-bold theme-text-primary sm:text-lg">
                    {{ getLocalizedText(notice.title) || t('home.notice.untitled') }}
                  </h3>
                  <time v-if="notice.published_at" class="text-xs theme-text-muted">
                    {{ formatDate(notice.published_at) }}
                  </time>
                </div>
                <div
                  v-if="getNoticeContentHtml(notice)"
                  class="home-announcement-body"
                  v-html="getNoticeContentHtml(notice)"
                ></div>
                <p v-else class="text-sm leading-relaxed theme-text-secondary">
                  {{ getLocalizedText(notice.summary) || t('home.notice.description') }}
                </p>
              </article>
            </div>
            <div v-else class="space-y-2">
              <div class="h-6 w-48 rounded theme-skeleton"></div>
              <div class="h-4 w-full max-w-xl rounded theme-skeleton"></div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ==================== LIST MODE ==================== -->
    <template v-if="templateMode === 'list'">
      <!-- Hero Banner (shared with card mode) -->
      <section v-if="showHeroSection" class="relative z-10 pb-8" :class="topNoticeSectionVisible ? 'pt-4' : 'pt-24'">
        <div class="container mx-auto px-4">
          <div class="theme-hero-shell relative overflow-hidden rounded-2xl border"
            @touchstart="onBannerTouchStart"
            @touchend="onBannerTouchEnd">
            <Transition name="banner-fade" mode="out-in">
              <img v-if="!bannerLoading && heroImage" :src="heroImage" :key="heroImage" class="absolute inset-0 h-full w-full object-cover" />
            </Transition>
            <div class="theme-hero-vignette absolute inset-0"></div>
            <div v-if="bannerLoading" class="relative flex min-h-[200px] flex-col justify-between p-5 sm:min-h-[240px] sm:p-6 md:min-h-[320px] md:p-10">
              <div class="space-y-3">
                <div class="h-5 w-24 theme-skeleton rounded-full" style="background: rgba(255,255,255,0.35)"></div>
                <div class="h-8 max-w-3xl theme-skeleton rounded-xl md:h-10" style="background: rgba(255,255,255,0.35)"></div>
                <div class="h-4 max-w-2xl theme-skeleton rounded-lg" style="background: rgba(255,255,255,0.3)"></div>
              </div>
            </div>
            <div v-else class="relative flex min-h-[200px] flex-col justify-between p-5 sm:min-h-[240px] sm:p-6 md:min-h-[320px] md:p-10">
              <div v-if="bannerCount > 1" class="mb-3 flex items-center justify-end gap-2">
                <button type="button"
                  class="theme-hero-control md:h-9 md:w-9"
                  @click="handlePrevHeroBanner" :aria-label="t('common.previousBanner')">
                  <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                  </svg>
                </button>
                <button type="button"
                  class="theme-hero-control md:h-9 md:w-9"
                  @click="handleNextHeroBanner" :aria-label="t('common.nextBanner')">
                  <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                  </svg>
                </button>
              </div>
              <div class="space-y-2 sm:space-y-3">
                <span class="theme-badge theme-badge-inverse gap-2 text-xs font-semibold uppercase tracking-wider">
                  <span class="h-2 w-2 rounded-full bg-emerald-300"></span>
                  {{ heroBadge }}
                </span>
                <h1 class="theme-hero-title max-w-4xl">
                  {{ heroTitle }}
                </h1>
                <p class="max-w-3xl text-xs leading-relaxed text-gray-100 sm:text-sm">
                  {{ heroSubtitle }}
                </p>
                <div class="grid max-w-2xl grid-cols-3 gap-2 pt-2">
                  <div class="theme-hero-stat">
                    <div class="text-sm font-bold text-white sm:text-base">24/7</div>
                    <div class="mt-1 text-[10px] text-white/70 sm:text-xs">{{ t('home.stats.support') }}</div>
                  </div>
                  <div class="theme-hero-stat">
                    <div class="text-sm font-bold text-white sm:text-base">99.9%</div>
                    <div class="mt-1 text-[10px] text-white/70 sm:text-xs">{{ t('home.stats.uptime') }}</div>
                  </div>
                  <div class="theme-hero-stat">
                    <div class="text-sm font-bold text-white sm:text-base">Auto</div>
                    <div class="mt-1 text-[10px] text-white/70 sm:text-xs">{{ t('products.fulfillmentType.auto') }}</div>
                  </div>
                </div>
              </div>
              <div v-if="bannerCount > 1" class="mt-4 flex items-center gap-2">
                <button v-for="(_, bIdx) in banners" :key="`list-dot-${bIdx}`" type="button"
                  class="h-2 rounded-full transition-all"
                  :class="bIdx === currentBannerIndex ? 'w-6 bg-white' : 'w-2 bg-white/45 hover:bg-white/70'"
                  @click="selectHeroBanner(bIdx)"></button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Main: Left Categories + Right Product List -->
      <section class="relative z-10 pb-6" :class="showHeroSection || topNoticeSectionVisible ? 'pt-6' : 'pt-24'">
        <div class="container mx-auto px-4">
          <div class="flex flex-col lg:flex-row gap-6">

            <CategorySidebar
              :categories="listCategoryGroups"
              :selected-category="listSelectedCategory"
              :expanded-parent-ids="listExpandedParentIds"
              :show-drawer="listShowFilterDrawer"
              compact
              @select-category="listSelectCategory"
              @toggle-parent="listToggleParentCategory"
              @update:show-drawer="listShowFilterDrawer = $event"
            />

            <!-- Right: Product List -->
            <main class="flex-1 min-w-0">
              <!-- Search Bar -->
              <div class="theme-page-shell mb-5">
                <div class="relative">
                  <div class="absolute inset-y-0 left-3.5 flex items-center pointer-events-none">
                    <svg class="w-4 h-4 theme-text-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                  </div>
                  <input
                    v-model="listSearchQuery"
                    type="text"
                    class="w-full h-11 pl-10 pr-10 rounded-xl border theme-surface-soft text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 theme-text-primary placeholder:theme-text-muted transition-shadow"
                    :placeholder="t('products.searchBoxPlaceholder')"
                    @keydown.enter="listOnSearch"
                  />
                  <button
                    v-if="listSearchQuery"
                    type="button"
                    class="absolute inset-y-0 right-3 flex items-center theme-text-muted hover:theme-text-primary transition-colors"
                    @click="listClearSearch"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>
              </div>

              <!-- Loading Skeleton -->
              <div v-if="listLoading" class="space-y-6">
                <div v-for="i in 3" :key="i">
                  <div class="flex items-center gap-2 mb-3 px-0.5">
                    <div class="h-5 w-5 rounded theme-skeleton"></div>
                    <div class="h-4 w-28 rounded theme-skeleton"></div>
                  </div>
                  <div class="space-y-2">
                    <div v-for="j in 3" :key="j"
                      class="theme-panel rounded-xl border flex items-center h-[72px]">
                      <div class="w-14 h-14 m-2 rounded-lg theme-skeleton flex-shrink-0"></div>
                      <div class="flex-1 px-3 py-2 space-y-2">
                        <div class="h-3.5 w-1/3 rounded theme-skeleton"></div>
                        <div class="h-3 w-1/4 rounded theme-skeleton"></div>
                      </div>
                      <div class="px-4 py-2">
                        <div class="h-4 w-14 rounded theme-skeleton"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Grouped Product List -->
              <div v-else-if="listProductGroups.length > 0" class="space-y-6">
                <div v-for="group in listProductGroups" :key="group.categoryId ?? 'uncategorized'">
                  <!-- Category Header -->
                  <div class="flex items-center gap-2 mb-3 px-0.5">
                    <span class="w-1 h-5 rounded-full theme-accent-stick flex-shrink-0"></span>
                    <img v-if="group.categoryIcon" :src="getImageUrl(group.categoryIcon)"
                      :alt="group.categoryName" loading="lazy" class="h-5 w-5 rounded object-cover flex-shrink-0" />
                    <span class="text-sm font-semibold theme-text-primary truncate">{{ group.categoryName }}</span>
                    <span class="text-xs theme-text-muted">({{ group.products.length }})</span>
                  </div>
                  <!-- Products in this category -->
                  <div class="space-y-2">
                    <ProductListItem
                      v-for="(product, idx) in group.products"
                      :key="product.id"
                      :product="product"
                      :index="idx"
                      :animation-step="20"
                      @click="goToProduct"
                      @quick-buy="openQuickBuy"
                    />
                  </div>
                </div>

                <PaginationNav
                  :current-page="listCurrentPage"
                  :total-pages="listTotalPages"
                  :loading="listLoading"
                  compact
                  @change-page="listChangePage"
                />
              </div>

              <!-- Empty State -->
              <EmptyState
                v-else
                icon="search"
                variant="soft"
                size="md"
                :title="listHasActiveFilter ? t('products.emptyFiltered') : t('products.empty')"
                :description="listHasActiveFilter ? t('products.clearFilters') : t('products.subtitle')"
                :action-label="listHasActiveFilter ? t('products.clearFilters') : undefined"
                @action="listResetFilters"
              />
            </main>
          </div>
        </div>
      </section>
    </template>

    <!-- ==================== CARD MODE (default) ==================== -->
    <template v-else>
    <section v-if="showHeroSection" class="relative z-10 pb-10" :class="topNoticeSectionVisible ? 'pt-4' : 'pt-24'">
      <div class="container mx-auto px-4">
        <div class="theme-hero-shell relative overflow-hidden rounded-2xl border"
          @touchstart="onBannerTouchStart"
          @touchend="onBannerTouchEnd">
          <!-- Banner image with fade transition -->
          <Transition name="banner-fade" mode="out-in">
            <img v-if="!bannerLoading && heroImage" :src="heroImage" :key="heroImage" class="absolute inset-0 h-full w-full object-cover" />
          </Transition>
          <div class="theme-hero-vignette absolute inset-0"></div>

            <div v-if="bannerLoading" class="relative flex min-h-[260px] flex-col justify-between p-5 sm:min-h-[320px] sm:p-6 md:min-h-[420px] md:p-12">
            <div class="mb-4 flex items-center justify-end">
              <span class="theme-badge theme-badge-inverse text-xs font-medium">
                {{ t('common.loading') }}
              </span>
            </div>

            <div class="space-y-4">
              <div class="h-6 w-28 theme-skeleton rounded-full" style="background: rgba(255,255,255,0.35)"></div>
              <div class="h-10 max-w-4xl theme-skeleton rounded-xl md:h-14" style="background: rgba(255,255,255,0.35)"></div>
              <div class="h-5 max-w-3xl theme-skeleton rounded-lg" style="background: rgba(255,255,255,0.3)"></div>
            </div>

            <div class="flex flex-wrap items-center gap-3 pt-6">
              <div class="h-11 w-36 theme-skeleton rounded-lg" style="background: rgba(255,255,255,0.35)"></div>
              <div class="h-11 w-28 theme-skeleton rounded-lg" style="background: rgba(255,255,255,0.25)"></div>
            </div>
          </div>

          <div v-else class="relative flex min-h-[260px] flex-col justify-between p-5 sm:min-h-[320px] sm:p-6 md:min-h-[420px] md:p-12">
            <div v-if="bannerCount > 1" class="mb-4 flex items-center justify-end gap-2">
              <button
                type="button"
                class="theme-hero-control"
                @click="handlePrevHeroBanner"
                :aria-label="t('common.previousBanner')"
              >
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              <button
                type="button"
                class="theme-hero-control"
                @click="handleNextHeroBanner"
                :aria-label="t('common.nextBanner')"
              >
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                </svg>
              </button>
            </div>

            <div class="space-y-3 sm:space-y-4">
              <span class="theme-badge theme-badge-inverse gap-2 text-xs font-semibold uppercase tracking-wider">
                <span class="h-2 w-2 rounded-full bg-emerald-300"></span>
                {{ heroBadge }}
              </span>
              <h1 class="theme-hero-title max-w-4xl">
                {{ heroTitle }}
              </h1>
              <p class="max-w-3xl text-xs leading-relaxed text-gray-100 sm:text-sm md:text-base">
                {{ heroSubtitle }}
              </p>
              <div class="grid max-w-3xl grid-cols-3 gap-2 pt-2 sm:gap-3">
                <div class="theme-hero-stat">
                  <div class="text-base font-bold text-white sm:text-xl">24/7</div>
                  <div class="mt-1 text-[10px] text-white/70 sm:text-xs">{{ t('home.stats.support') }}</div>
                </div>
                <div class="theme-hero-stat">
                  <div class="text-base font-bold text-white sm:text-xl">99.9%</div>
                  <div class="mt-1 text-[10px] text-white/70 sm:text-xs">{{ t('home.stats.uptime') }}</div>
                </div>
                <div class="theme-hero-stat">
                  <div class="text-base font-bold text-white sm:text-xl">Auto</div>
                  <div class="mt-1 text-[10px] text-white/70 sm:text-xs">{{ t('products.fulfillmentType.auto') }}</div>
                </div>
              </div>
            </div>

            <div class="flex flex-wrap items-center gap-3 pt-5 sm:pt-6">
              <button
                type="button"
                @click="goToHeroLink"
                class="theme-hero-action-primary"
              >
                {{ heroPrimaryButtonText }}
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
              </button>
              <router-link
                v-if="!hasHeroLink"
                to="/products"
                class="theme-hero-action-secondary"
              >
                {{ t('home.featured.viewAll') }}
              </router-link>
            </div>

            <div v-if="bannerCount > 1" class="mt-5 flex items-center gap-2">
              <button
                v-for="(_, index) in banners"
                :key="`hero-dot-${index}`"
                type="button"
                class="h-2.5 rounded-full transition-all"
                :class="index === currentBannerIndex ? 'w-7 bg-white' : 'w-2.5 bg-white/45 hover:bg-white/70'"
                @click="selectHeroBanner(index)"
                :aria-label="t('common.switchBanner', { n: index + 1 })"
              ></button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="featured" class="relative z-10 pb-14" :class="showHeroSection ? 'pt-14' : topNoticeSectionVisible ? 'pt-8' : 'pt-32 md:pt-36'">
      <div class="container mx-auto px-4">
        <div class="theme-section-toolbar mb-5">
          <div>
            <p class="theme-kicker mb-1.5">{{ t('home.hero.badge') }}</p>
            <h2 class="theme-section-heading text-2xl md:text-[1.75rem]">{{ t('home.featured.title') }}</h2>
            <p class="mt-1.5 text-sm theme-text-secondary">{{ t('home.featured.description') }}</p>
          </div>
          <router-link
                v-if="!hasHeroLink"
                to="/products"
            class="text-sm font-semibold theme-link-muted"
          >
            {{ t('home.featured.viewAll') }}
          </router-link>
        </div>

        <div v-if="products.length > 0" class="grid grid-cols-2 gap-3 md:gap-5 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
          <ProductCard
            v-for="(product, idx) in products"
            :key="product.id"
            :product="product"
            :index="idx"
            :animation-step="60"
            @click="goToProduct"
            @quick-buy="openQuickBuy"
          />
        </div>
        <EmptyState
          v-else
          icon="package"
          variant="soft"
          size="md"
          :title="t('home.featured.empty')"
          :description="t('home.featured.description')"
          :action-label="t('home.featured.viewAll')"
          action-to="/products"
        />
      </div>
    </section>

    <template v-if="latestSectionVisible">
    <hr class="theme-section-divider mx-4 md:mx-auto md:max-w-6xl" />

    <section class="relative z-10 py-12">
      <div class="container mx-auto px-4">
        <div class="theme-section-toolbar mb-6">
          <div>
            <h2 class="theme-section-heading text-2xl md:text-[1.65rem]">{{ t('home.latest.title') }}</h2>
            <p class="mt-1 text-sm theme-text-secondary">{{ t('home.latest.description') }}</p>
          </div>
          <div class="flex items-center gap-3 text-sm">
            <router-link v-if="blogEnabled" to="/blog" class="theme-link-muted">{{ t('nav.blog') }}</router-link>
          </div>
        </div>

        <div v-if="posts.length > 0" class="grid grid-cols-1 gap-5 md:grid-cols-3">
          <article
            v-for="post in posts"
            :key="post.id"
            class="cursor-pointer rounded-xl border theme-panel p-5 transition theme-card-interactive"
            @click="goToPost(post.slug)"
          >
            <div class="mb-2 text-xs theme-text-muted">{{ formatDate(post.published_at) }}</div>
            <h3 class="line-clamp-2 text-base font-semibold">{{ getLocalizedText(post.title) }}</h3>
            <p class="mt-2 line-clamp-2 text-sm theme-text-secondary">{{ getLocalizedText(post.summary) }}</p>
            <div class="mt-4 text-sm font-medium theme-link">{{ t('blog.readMore') }}</div>
          </article>
        </div>
        <EmptyState
          v-else
          icon="inbox"
          variant="soft"
          size="sm"
          :title="t('blog.empty')"
          :description="t('home.latest.description')"
        />
      </div>
    </section>
    </template>
    </template>

    <ProductQuickBuy
      v-if="quickBuyProduct"
      :product="quickBuyProduct"
      :visible="quickBuyVisible"
      @update:visible="quickBuyVisible = $event"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { postAPI, productAPI } from '../api'
import { getImageUrl } from '../utils/image'
import { processHtmlForDisplay } from '../utils/content'
import { useLocalized } from '../composables/useProduct'
import { useBannerCarousel } from '../composables/useBannerCarousel'
import { useProductList } from '../composables/useProductList'
import { useProductListGroups } from '../composables/useProductListGroups'
import { useAppStore } from '../stores/app'
import ProductCard from '../components/ProductCard.vue'
import ProductListItem from '../components/ProductListItem.vue'
import ProductQuickBuy from '../components/ProductQuickBuy.vue'
import CategorySidebar from '../components/CategorySidebar.vue'
import PaginationNav from '../components/PaginationNav.vue'
import EmptyState from '../components/EmptyState.vue'

const router = useRouter()
const { t } = useI18n()
const { getLocalizedText } = useLocalized()
const appStore = useAppStore()

const templateMode = computed(() => appStore.config?.template_mode || 'card')
const navBuiltin = computed(() => (appStore.config?.nav_config as { builtin?: Record<string, boolean> } | undefined)?.builtin)
const blogEnabled = computed(() => navBuiltin.value?.blog !== false)
const noticeEnabled = computed(() => navBuiltin.value?.notice !== false)
const latestSectionVisible = computed(() => blogEnabled.value)

// ==================== Shared State ====================
const products = ref<any[]>([])
const posts = ref<any[]>([])
const topNotices = ref<any[]>([])
const topNoticesLoading = ref(true)
const quickBuyProduct = ref<any>(null)
const quickBuyVisible = ref(false)
const topNoticeSectionVisible = computed(() => noticeEnabled.value && (topNoticesLoading.value || topNotices.value.length > 0))

const openQuickBuy = (product: any) => {
  quickBuyProduct.value = product
  quickBuyVisible.value = true
}

// ==================== Banner Carousel ====================
const {
  banners,
  bannerLoading,
  currentBannerIndex,
  bannerCount,
  showHeroSection,
  heroImage,
  heroBadge,
  heroTitle,
  heroSubtitle,
  hasHeroLink,
  heroPrimaryButtonText,
  loadBanners,
  handleNextHeroBanner,
  handlePrevHeroBanner,
  selectHeroBanner,
  goToHeroLink,
  onBannerTouchStart,
  onBannerTouchEnd,
  stopHeroAutoPlay,
} = useBannerCarousel()

// ==================== List Mode ====================
const {
  loading: listLoading,
  products: listProducts,
  selectedCategory: listSelectedCategory,
  searchQuery: listSearchQuery,
  currentPage: listCurrentPage,
  totalPages: listTotalPages,
  showFilterDrawer: listShowFilterDrawer,
  expandedParentIds: listExpandedParentIds,
  categoryGroups: listCategoryGroups,
  categoryMap: listCategoryMap,
  selectCategory: listSelectCategory,
  toggleParentCategory: listToggleParentCategory,
  changePage: listChangePage,
  clearSearch: listClearSearch,
  onSearch: listOnSearch,
  initialize: listInitialize,
  cleanup: listCleanup,
} = useProductList({ pageSize: 20, homeRouteName: 'home' })

const listProductGroups = useProductListGroups(listProducts, listCategoryMap)
const listHasActiveFilter = computed(() => Boolean(listSearchQuery.value || listSelectedCategory.value))

const listResetFilters = () => {
  if (!listHasActiveFilter.value) return
  listClearSearch()
  listSelectCategory(null)
}

// ==================== Card Mode ====================
const formatDate = (dateString: string) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString()
}

const goToProduct = (slug: string) => {
  router.push(`/products/${slug}`)
}

const goToPost = (slug: string) => {
  router.push(`/blog/${slug}`)
}

const getNoticeContentHtml = (notice: any) => {
  const content = getLocalizedText(notice?.content)
  if (content) return processHtmlForDisplay(content)
  const summary = getLocalizedText(notice?.summary)
  return summary ? processHtmlForDisplay(summary) : ''
}

const loadFeaturedProducts = async () => {
  try {
    const response = await productAPI.list({ page: 1, page_size: 15 })
    products.value = response.data.data || []
  } catch (error) {
    console.error('Failed to load products:', error)
  }
}

const loadLatestPosts = async () => {
  if (!latestSectionVisible.value) return
  try {
    const response = await postAPI.list({ type: 'blog', page: 1, page_size: 3 })
    posts.value = response.data.data || []
  } catch (error) {
    console.error('Failed to load posts:', error)
  }
}

const loadTopNotices = async () => {
  if (!noticeEnabled.value) return
  topNoticesLoading.value = true
  try {
    const response = await postAPI.list({ type: 'notice', page: 1, page_size: 3 })
    topNotices.value = response.data.data || []
  } catch (error) {
    console.error('Failed to load top notices:', error)
  } finally {
    topNoticesLoading.value = false
  }
}

// ==================== Lifecycle ====================
onMounted(async () => {
  if (templateMode.value === 'list') {
    await Promise.all([loadTopNotices(), loadBanners(), listInitialize()])
  } else {
    await Promise.all([loadTopNotices(), loadBanners(), loadFeaturedProducts(), loadLatestPosts()])
  }
})

onUnmounted(() => {
  stopHeroAutoPlay()
  listCleanup()
})
</script>

<style scoped>
.banner-fade-enter-active,
.banner-fade-leave-active {
  transition: opacity 300ms ease;
}
.banner-fade-enter-from,
.banner-fade-leave-to {
  opacity: 0;
}

.home-announcement-shell {
  border-color: color-mix(in oklab, var(--ui-warning) 34%, var(--ui-border));
  background:
    linear-gradient(135deg, color-mix(in oklab, var(--ui-warning-soft) 56%, var(--ui-bg-elevated)) 0%, var(--ui-bg-elevated) 58%),
    var(--ui-bg-elevated);
  box-shadow: 0 22px 44px -34px color-mix(in oklab, var(--ui-warning) 38%, rgba(0, 0, 0, 0.22));
}

.home-announcement-icon {
  color: var(--ui-warning);
  background: color-mix(in oklab, var(--ui-warning-soft) 72%, var(--ui-bg-elevated));
  border: 1px solid color-mix(in oklab, var(--ui-warning) 28%, transparent);
}

.home-announcement-label {
  display: inline-flex;
  align-items: center;
  border-radius: 0.5rem;
  padding: 0.25rem 0.625rem;
  color: var(--ui-warning);
  background: color-mix(in oklab, var(--ui-warning-soft) 74%, transparent);
  font-size: 0.75rem;
  font-weight: 700;
}

.home-announcement-item {
  border-radius: 0.625rem;
  border: 1px solid color-mix(in oklab, var(--ui-warning) 18%, var(--ui-border));
  background: color-mix(in oklab, var(--ui-bg-elevated) 84%, var(--ui-warning-soft) 16%);
  padding: 1rem;
}

.home-announcement-body {
  max-height: 14rem;
  overflow-y: auto;
  color: var(--ui-text-secondary);
  font-size: 0.875rem;
  line-height: 1.75;
  padding-right: 0.25rem;
}

.home-announcement-body :deep(p) {
  margin: 0.35rem 0;
}

.home-announcement-body :deep(a) {
  color: var(--ui-warning);
  text-decoration: underline;
  text-underline-offset: 0.2em;
}

.home-announcement-body :deep(img) {
  max-width: 100%;
  border-radius: 0.5rem;
}
</style>
