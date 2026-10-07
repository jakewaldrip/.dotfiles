import { Plugin } from "@opencode/plugin"

const EXTERNAL = ["/.claude/", "/.agents/"]
const external = (path: string) => EXTERNAL.some((part) => path.includes(part))

export default Plugin.define({
  id: "no-external-skills",
  async setup(ctx) {
    const prune = () =>
      ctx.skill.transform((editor) => {
        for (const skill of editor.list()) if (external(skill.path)) editor.remove(skill.id)
      })

    let registration = await prune()
    let stopped = false

    // The built-in compatibility plugin registers its transform after plugin
    // setup, so a single prune loses the ordering race. Dispose and
    // re-register to move this transform to the end of the replay order.
    void (async () => {
      for (let attempt = 0; attempt < 10 && !stopped; attempt++) {
        await new Promise((resolve) => setTimeout(resolve, 1000))
        const listed = await ctx.skill.list()
        if (!(listed?.data ?? []).some((skill) => external(skill.path))) continue
        await registration.dispose()
        registration = await prune()
      }
    })()

    return () => {
      stopped = true
    }
  },
})
