import { tool } from "@opencode-ai/plugin";
import { readFile, realpath } from "node:fs/promises";
import path from "node:path";

const ALLOWED_ROOT =
  "/home/gabriel/project-tendril/bootstrap/experiments/harness-probe/allowed";

export default tool({
  description: "Read a file only if it resolves inside the allowed probe scope.",

  args: {
    relative_path: tool.schema.string().describe("Path relative to the allowed scope"),
  },

  async execute(args) {
    const allowedRootReal = await realpath(ALLOWED_ROOT);
    const requestedPath = path.resolve(ALLOWED_ROOT, args.relative_path);
    const requestedReal = await realpath(requestedPath);

    const insideAllowedScope =
      requestedReal === allowedRootReal ||
      requestedReal.startsWith(allowedRootReal + path.sep);

    if (!insideAllowedScope) {
      return "DENIED: requested path is outside the allowed scope";
    }

    const content = await readFile(requestedReal, "utf8");
    return content;
  },
});
