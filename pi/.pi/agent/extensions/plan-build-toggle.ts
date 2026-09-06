import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const WRITE_TOOLS = new Set(["edit", "write"]);
const UNSAFE_BASH = /(?:^|[;&|]\s*|\b)(?:rm|rmdir|mv|cp|mkdir|touch|chmod|chown|tee|truncate|dd|shred|sudo|su|kill|pkill|reboot|shutdown)\b|(?:^|\s)>{1,2}(?!&)|\b(?:git\s+(?:add|commit|push|pull|merge|rebase|reset|checkout|stash)|(?:npm|pnpm|yarn)\s+(?:install|add|remove|update|run|test|build)|systemctl\s+(?:start|stop|restart|enable|disable))\b/i;

export default function planBuildToggle(pi: ExtensionAPI): void {
  let mode: "plan" | "build" = "build";
  let buildTools: string[] | undefined;

  function setMode(nextMode: "plan" | "build", ctx: ExtensionContext): void {
    if (nextMode === mode) return;

    if (nextMode === "plan") {
      buildTools = pi.getActiveTools();
      pi.setActiveTools(buildTools.filter((tool) => !WRITE_TOOLS.has(tool)));
      mode = "plan";
      ctx.ui.setStatus("plan-build", ctx.ui.theme.fg("warning", "plan"));
      ctx.ui.notify("Plan mode: write tools are disabled.", "info");
      return;
    }

    pi.setActiveTools(buildTools ?? pi.getActiveTools());
    buildTools = undefined;
    mode = "build";
    ctx.ui.setStatus("plan-build", ctx.ui.theme.fg("success", "build"));
    ctx.ui.notify("Build mode: write tools are enabled.", "info");
  }

  function toggle(ctx: ExtensionContext): void {
    setMode(mode === "plan" ? "build" : "plan", ctx);
  }

  pi.registerShortcut("tab", {
    description: "Toggle plan/build mode",
    handler: async (ctx) => toggle(ctx),
  });

  pi.registerCommand("plan-build", {
    description: "Toggle plan/build mode",
    handler: async (_args, ctx) => toggle(ctx),
  });

  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.setStatus("plan-build", ctx.ui.theme.fg("success", "build"));
  });

  pi.on("tool_call", async (event) => {
    if (mode !== "plan") return;

    if (WRITE_TOOLS.has(event.toolName)) {
      return { block: true, reason: "Plan mode blocks file changes. Press Tab to switch to build mode." };
    }

    if (event.toolName === "bash" && UNSAFE_BASH.test(String(event.input.command ?? ""))) {
      return { block: true, reason: "Plan mode blocks modifying shell commands. Press Tab to switch to build mode." };
    }
  });

  pi.on("before_agent_start", async () => {
    if (mode !== "plan") return;

    return {
      message: {
        customType: "plan-build-mode",
        content: "[PLAN MODE]\nExplore and explain only. Do not modify files, install dependencies, run tests or builds, or execute commands that change state. Produce a concrete implementation plan. The user can press Tab to switch to build mode when ready.",
        display: false,
      },
    };
  });
}
