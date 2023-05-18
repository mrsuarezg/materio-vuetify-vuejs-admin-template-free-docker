<template>
  <component :is="resolveLayout">
    <router-view></router-view>
    <upgrade-to-pro></upgrade-to-pro>
  </component>
</template>

<script>
import { useRouter } from '@/utils'
import LayoutBlank from '@/layouts/Blank.vue'
import LayoutContent from '@/layouts/Content.vue'
import UpgradeToPro from './components/UpgradeToPro.vue'
import { computed } from 'vue'

export default {
  components: {
    LayoutBlank,
    LayoutContent,
    UpgradeToPro,
  },
  setup() {
    const { route } = useRouter()
    console.log(route)

    const resolveLayout = computed(() => {
      // Handles initial route
      if (route.value?.name === null) return null

      if (route.value?.meta?.layout === 'blank') return 'layout-blank'

      return 'layout-content'
    })

    return {
      resolveLayout,
    }
  },
}
</script>
