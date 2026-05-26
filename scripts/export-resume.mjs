#!/usr/bin/env node
/**
 * Markdown 简历 → PDF（md-to-pdf）
 * 依赖：Node.js 18+；首次运行前在 scripts/ 目录执行 npm install
 */

import { readFile, mkdir } from "node:fs/promises";
import { dirname, join, basename, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));

function usage() {
  console.error(`用法: node export-resume.mjs -i <简历.md> [-o <输出目录>]`);
  process.exit(1);
}

function parseArgs(argv) {
  let input = "";
  let outputDir = "";
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === "-i" && argv[i + 1]) input = argv[++i];
    else if (a === "-o" && argv[i + 1]) outputDir = argv[++i];
    else if (a === "-h") usage();
  }
  if (!input) usage();
  return { input: resolve(input), outputDir: outputDir ? resolve(outputDir) : "" };
}

async function exportPdf(input, outPath) {
  const mod = await import("md-to-pdf");
  const mdToPdf = mod.mdToPdf ?? mod.default;
  if (typeof mdToPdf !== "function") {
    throw new Error("md-to-pdf 模块加载异常");
  }
  const css = join(__dirname, "resume-pdf.css");
  await mdToPdf(
    { path: input },
    {
      dest: outPath,
      stylesheet: css,
      pdf_options: {
        format: "A4",
        margin: { top: "20mm", right: "20mm", bottom: "20mm", left: "20mm" },
        printBackground: true,
      },
      launch_options: {
        args: ["--no-sandbox", "--disable-setuid-sandbox"],
      },
    }
  );
  console.log(`已生成: ${outPath}`);
}

async function main() {
  const { input, outputDir } = parseArgs(process.argv);

  try {
    await readFile(input);
  } catch {
    console.error(`错误: 文件不存在: ${input}`);
    process.exit(1);
  }

  const base = basename(input, ".md");
  const outDir = outputDir || dirname(input);
  await mkdir(outDir, { recursive: true });
  const outPath = join(outDir, `${base}.pdf`);

  await exportPdf(input, outPath);
}

main().catch((err) => {
  console.error("导出失败:", err.message || err);
  process.exit(1);
});
