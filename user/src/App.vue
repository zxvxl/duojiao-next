<template>
  <div id="app" class="min-h-screen flex flex-col bg-white">
    <Navbar />
    <main class="flex-1">
      <ErrorBoundary>
        <RouterView v-slot="{ Component }">
          <Transition name="page-fade" mode="out-in">
            <component :is="Component" />
          </Transition>
        </RouterView>
      </ErrorBoundary>
    </main>
    <Footer />
    <Loading :loading="appStore.loading" />
    <Toast />
    <ConfirmDialog />
  </div>
</template>

<script setup lang="ts">
import { useAppStore } from './stores/app'
import Navbar from './components/Navbar.vue'
import Footer from './components/Footer.vue'
import Loading from './components/Loading.vue'
import Toast from './components/Toast.vue'
import ConfirmDialog from './components/ConfirmDialog.vue'
import ErrorBoundary from './components/ErrorBoundary.vue'

const appStore = useAppStore()
</script>

<style>
.page-fade-enter-active,
.page-fade-leave-active {
  transition: opacity 150ms ease;
}
.page-fade-enter-from,
.page-fade-leave-to {
  opacity: 0;
}
</style>
