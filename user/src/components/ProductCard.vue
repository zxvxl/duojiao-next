<template>
  <div
    class="group flex flex-col h-full theme-product-card"
    :class="isSoldOut(product) ? 'sold-out' : 'cursor-pointer'"
    :style="{ animationDelay: `${index * 40}ms` }"
    @click="!isSoldOut(product) && $emit('click', product.slug)"
  >
    <!-- Visual Header -->
    <div class="relative shrink-0 h-36 flex items-center justify-center overflow-hidden"
      :class="cardBgClass">
      <!-- Sold out ribbon -->
      <div v-if="isSoldOut(product)"
        class="absolute -left-[30px] top-[14px] -rotate-45 bg-gray-500 text-white text-[10px]
               tracking-widest font-bold py-1 w-[100px] text-center shadow-md z-20">
        {{ t('products.stockStatus.outOfStock') }}
      </div>

      <!-- Tags -->
      <div class="absolute top-3 left-3 flex gap-1.5 z-10">
        <span v-if="product.fulfillment_type === 'auto'"
          class="bg-orange-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-md shadow-sm">
          {{ t('products.fulfillmentType.auto') }}
        </span>
        <span v-if="product.tags && product.tags.length > 0"
          class="bg-red-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-md shadow-sm">
          {{ product.tags[0] }}
        </span>
      </div>

      <!-- Product icon/brand visual -->
      <div class="flex items-center justify-center gap-3 transition-transform duration-500"
        :class="isSoldOut(product) ? '' : 'group-hover:scale-110'">
        <img v-if="displayImageSrc && !imageErrored"
          :src="displayImageSrc" :alt="getLocalizedText(product.title)"
          class="w-12 h-12 object-contain rounded-lg"
          @error="imageErrored = true" />
        <svg v-else class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
            d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
        </svg>
        <span class="text-2xl font-black tracking-tight"
          :class="isSoldOut(product) ? 'text-gray-400' : 'text-gray-700'">
          {{ shortTitle }}
        </span>
      </div>
    </div>


    <!-- Content -->
    <div class="p-4 space-y-3 flex flex-col flex-1">
      <h3 class="font-bold text-gray-900 text-[15px] leading-snug line-clamp-2 min-h-[2.5rem]">
        {{ getLocalizedText(product.title) }}
      </h3>

      <!-- Description or out-of-stock hint -->
      <p v-if="isSoldOut(product)"
        class="text-[11px] text-gray-500 font-bold bg-gray-100 px-2 py-1.5 rounded-md">
        {{ t('products.stockStatus.outOfStock') }}
      </p>
      <p v-else-if="getLocalizedText(product.description)"
        class="text-xs text-gray-400 line-clamp-2 leading-relaxed">
        {{ getLocalizedText(product.description) }}
      </p>

      <!-- Price & Stats -->
      <div class="flex items-end justify-between pt-1 mt-auto">
        <div class="space-y-0.5">
          <div class="text-xl font-black text-orange-500">
            <span v-if="hasPromotionPrice(product)" class="text-xs font-semibold text-gray-400 mr-1">{{ t('products.promotionTag') }}</span>
            <span class="text-sm font-bold mr-0.5">¥</span>{{ displayPrice }}
          </div>
          <div v-if="hasPromotionPrice(product)" class="text-xs text-gray-400 line-through">
            {{ formatPrice(product.price_amount, siteCurrency) }}
          </div>
        </div>
        <div class="text-[11px] text-gray-400 text-right">
          <span>{{ stockDisplay }}</span>
        </div>
      </div>
    </div>
  </div>
</template>


<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { getFirstImageUrl } from '../utils/image'
import { useLocalized, useProductLabels } from '../composables/useProduct'

const props = withDefaults(defineProps<{
  product: any
  index?: number
}>(), { index: 0 })

defineEmits<{
  click: [slug: string]
  quickBuy: [product: any]
}>()

const { t } = useI18n()
const { getLocalizedText, siteCurrency, formatPrice } = useLocalized()
const { isSoldOut, hasPromotionPrice, getPromotionPriceAmount } = useProductLabels()

const imageErrored = ref(false)

const displayImageSrc = computed(() => getFirstImageUrl(props.product?.images) || '')

const shortTitle = computed(() => {
  const title = getLocalizedText(props.product?.title) || ''
  // Extract first meaningful word for the brand display
  const words = title.split(/[\s·\-|]+/)
  return words[0]?.slice(0, 8) || ''
})

const displayPrice = computed(() => {
  if (hasPromotionPrice(props.product)) {
    return getPromotionPriceAmount(props.product)
  }
  return props.product?.price_amount || '0.00'
})

const stockDisplay = computed(() => {
  if (isSoldOut(props.product)) return '0'
  const status = props.product?.stock_status
  if (status === 'unlimited') return t('products.stockStatus.unlimited')
  const count = props.product?.auto_stock_available || props.product?.manual_stock_available
  if (count) return String(count)
  return t('products.stockStatus.inStock')
})

// Color based on category or random
const cardBgClass = computed(() => {
  if (isSoldOut(props.product)) return 'bg-gradient-to-br from-gray-100 to-gray-200'
  const colors = [
    'bg-gradient-to-br from-orange-50 via-amber-50 to-red-50',
    'bg-gradient-to-br from-blue-50 via-sky-50 to-cyan-50',
    'bg-gradient-to-br from-emerald-50 via-green-50 to-teal-50',
    'bg-gradient-to-br from-purple-50 via-violet-50 to-fuchsia-50',
    'bg-gradient-to-br from-rose-50 via-pink-50 to-red-50',
    'bg-gradient-to-br from-indigo-50 via-blue-50 to-purple-50',
  ]
  const id = props.product?.id || props.index
  return colors[id % colors.length]
})
</script>
