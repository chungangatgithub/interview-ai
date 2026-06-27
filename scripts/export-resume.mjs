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
      // 渲染后处理（通用）：移除「无表头」表格语法（| | / |--|--|）产生的空表头行
      script: [
        {
          content: `(function () {
            document.querySelectorAll('table thead').forEach(function (thead) {
              var ths = Array.prototype.slice.call(thead.querySelectorAll('th'));
              if (ths.length && ths.every(function (th) { return th.textContent.trim() === ''; })) {
                thead.parentNode.removeChild(thead);
              }
            });
          })();`,
        },
      ],
      pdf_options: {
        format: "A4",
        margin: { top: "18mm", right: "18mm", bottom: "16mm", left: "18mm" },
        printBackground: true,
        displayHeaderFooter: true,
        headerTemplate: "<div></div>",
        footerTemplate:
          '<div style="width:100%;font-size:8px;color:#9aa0a6;text-align:center;">' +
          '<span class="pageNumber"></span> / <span class="totalPages"></span></div>',
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
