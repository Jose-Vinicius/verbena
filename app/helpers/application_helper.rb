module ApplicationHelper
  def render_markdown(text, inline: false, tag: :div, **html_options)
    return "".html_safe if text.blank?

    css_classes = [ "markdown-content", "whitespace-pre-wrap", html_options.delete(:class) ].compact.join(" ")
    data_attrs = (html_options.delete(:data) || {}).merge(
      controller: "markdown",
      markdown_content_value: text.to_s,
      markdown_inline_value: inline
    )

    content_tag(tag, text.to_s, html_options.merge(class: css_classes, data: data_attrs))
  end
end
