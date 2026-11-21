import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"
import DOMPurify from "dompurify"
import katex from "katex"

export default class extends Controller {
  static values = {
    content: String,
    inline: { type: Boolean, default: false }
  }

  connect() {
    const raw = this.hasContentValue ? this.contentValue : this.element.textContent
    if (!raw || !raw.trim()) return

    this.element.classList.remove("whitespace-pre-wrap")
    this.element.innerHTML = this.renderMarkdownWithLatex(raw)
  }

  renderMarkdownWithLatex(input) {
    const codePlaceholders = []
    const mathPlaceholders = []

    // 1. Protect fenced code blocks and inline code so $ inside code is untouched
    let text = input.replace(/```[\s\S]*?```|`[^`\n]+`/g, (match) => {
      const token = `@@VERBENA_CODE_${codePlaceholders.length}@@`
      codePlaceholders.push(match)
      return token
    })

    // 2. Extract display math: $$...$$ and \[...\]
    text = text.replace(/\$\$([\s\S]+?)\$\$|\\\[([\s\S]+?)\\\]/g, (_, dollarExpr, bracketExpr) => {
      const expr = (dollarExpr ?? bracketExpr).trim()
      const token = `@@VERBENA_MATH_${mathPlaceholders.length}@@`
      mathPlaceholders.push({ expr, displayMode: true })
      return token
    })

    // 3. Extract inline math: \(...\) and $...$
    text = text.replace(/\\\((.+?)\\\)|(?<![\\$\w])\$(?!\s)([^$\n]+?)(?<!\s)\$(?!\d)/g, (_, parenExpr, dollarExpr) => {
      const expr = (parenExpr ?? dollarExpr).trim()
      const token = `@@VERBENA_MATH_${mathPlaceholders.length}@@`
      mathPlaceholders.push({ expr, displayMode: false })
      return token
    })

    // 4. Restore code blocks before Markdown parsing
    text = text.replace(/@@VERBENA_CODE_(\d+)@@/g, (_, idx) => codePlaceholders[Number(idx)])

    // 5. Parse Markdown with GFM line breaks
    const markdownOptions = { breaks: true, gfm: true }
    const parsedHtml = this.inlineValue
      ? marked.parseInline(text, markdownOptions)
      : marked.parse(text, markdownOptions)

    // 6. Sanitize HTML before injecting math
    let sanitizedHtml = DOMPurify.sanitize(parsedHtml)

    // 7. Render LaTeX placeholders with KaTeX
    sanitizedHtml = sanitizedHtml.replace(/@@VERBENA_MATH_(\d+)@@/g, (_, idx) => {
      const { expr, displayMode } = mathPlaceholders[Number(idx)]
      try {
        return katex.renderToString(expr, { displayMode, throwOnError: false })
      } catch {
        return expr
      }
    })

    return sanitizedHtml
  }
}
