import { reactive, toRefs, watch } from 'vue'

export const useRouter = () => {
  const state = reactive({
    route: null,
  })

  const routeWatcher = watch(
    () => state.route,
    (newValue) => {
      state.route = newValue
    }
  )

  return { ...toRefs(state), routeWatcher }
}
