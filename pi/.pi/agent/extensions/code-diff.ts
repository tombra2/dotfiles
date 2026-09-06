import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createWriteTool } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, join, resolve } from "node:path";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const MAX_VISIBLE_LINES = 80;

type Diff = { text: string; truncated: boolean };

async function readExistingFile(path: string): Promise<string> {
	try {
		return await readFile(path, "utf8");
	} catch (error: unknown) {
		if ((error as NodeJS.ErrnoException).code === "ENOENT") return "";
		throw error;
	}
}

type DiffTheme = { fg(color: "toolDiffAdded" | "toolDiffRemoved" | "toolDiffContext", text: string): string };

async function createDiff(path: string, before: string, after: string): Promise<Diff | undefined> {
	if (before === after || before.includes("\0") || after.includes("\0")) return undefined;

	const dir = await mkdtemp(join(tmpdir(), "pi-code-diff-"));
	const oldFile = join(dir, "before");
	const newFile = join(dir, "after");
	const label = basename(path);

	try {
		await Promise.all([writeFile(oldFile, before), writeFile(newFile, after)]);
		try {
			await execFileAsync("diff", ["-u", "--label", `${label} (before)`, oldFile, "--label", `${label} (after)`, newFile], {
				maxBuffer: 1024 * 1024,
			});
			return undefined;
		} catch (error: unknown) {
			const result = error as { code?: number; stdout?: string };
			if (result.code !== 1 || !result.stdout) return undefined;
			const lines = result.stdout.split("\n");
			return {
				text: lines.slice(0, MAX_VISIBLE_LINES).join("\n"),
				truncated: lines.length > MAX_VISIBLE_LINES,
			};
		}
	} finally {
		await rm(dir, { recursive: true, force: true });
	}
}

function renderDiff(diff: Diff, theme: DiffTheme): string {
	return diff.text
		.split("\n")
		.map((line) => {
			if (line.startsWith("+") && !line.startsWith("+++")) return theme.fg("toolDiffAdded", line);
			if (line.startsWith("-") && !line.startsWith("---")) return theme.fg("toolDiffRemoved", line);
			return theme.fg("toolDiffContext", line);
		})
		.join("\n");
}

export default function (pi: ExtensionAPI) {
	const diffs = new Map<string, Diff>();

	pi.registerTool({
		...createWriteTool(process.cwd()),
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			const path = resolve(ctx.cwd, params.path);
			let before: string;
			try {
				before = await readExistingFile(path);
			} catch {
				return createWriteTool(ctx.cwd).execute(toolCallId, params, signal, onUpdate);
			}

			const tool = createWriteTool(ctx.cwd);
			const result = await tool.execute(toolCallId, params, signal, onUpdate);
			const message = result.content.find((item) => item.type === "text");
			if (message?.type !== "text" || !message.text.startsWith("Error")) {
				const diff = await createDiff(path, before, params.content);
				if (diff) diffs.set(toolCallId, diff);
			}
			return result;
		},
		renderResult(result, { isPartial }, theme, context) {
			if (isPartial) return new Text(theme.fg("warning", "Writing..."), 0, 0);

			const diff = diffs.get(context.toolCallId);
			if (!diff) {
				const text = result.content.find((item) => item.type === "text");
				return new Text(text?.type === "text" ? theme.fg("toolOutput", text.text) : "", 0, 0);
			}

			let text = renderDiff(diff, theme);
			if (diff.truncated) {
				text += `\n${theme.fg("muted", "Diff-Vorschau auf 80 Zeilen begrenzt.")}`;
			}
			return new Text(text, 0, 0);
		},
	});
}
