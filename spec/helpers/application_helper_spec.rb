require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#render_markdown" do
    it "returns an empty string for blank input" do
      expect(helper.render_markdown(nil)).to eq("")
      expect(helper.render_markdown("   ")).to eq("")
    end

    it "renders a container with markdown stimulus controller and content value" do
      html = helper.render_markdown("Texto **com** $x^2$", class: "text-lg")

      expect(html).to include('data-controller="markdown"')
      expect(html).to include('data-markdown-inline-value="false"')
      expect(html).to include("markdown-content")
      expect(html).to include("whitespace-pre-wrap")
      expect(html).to include("text-lg")
      expect(html).to include("Texto **com** $x^2$")
    end

    it "supports inline mode and custom tag" do
      html = helper.render_markdown("Opção $H_2O$", inline: true, tag: :span, class: "text-sm")

      expect(html).to start_with("<span ")
      expect(html).to include('data-markdown-inline-value="true"')
      expect(html).to include("text-sm")
    end
  end
end
