require "pdf-reader"
require "zip"
require "nokogiri"
require "tempfile"

module Sources
  class ExtractTextService
    class ExtractionError < StandardError; end

    def self.call(study_source)
      new(study_source).call
    end

    def initialize(study_source)
      @study_source = study_source
    end

    def call
      segments = case @study_source.source_type.to_sym
      when :pdf then extract_pdf
      when :pptx then extract_pptx
      when :docx then extract_docx
      when :text then extract_text
      else
        raise ExtractionError, "Tipo de fonte não suportado: #{@study_source.source_type}"
      end

      cleaned = segments.filter_map do |segment|
        normalized = normalize_text(segment[:text])
        next if normalized.blank?

        { text: normalized, metadata: segment[:metadata] || {} }
      end

      raise ExtractionError, "Não foi possível extrair texto legível desta fonte." if cleaned.empty?

      cleaned
    end

    private

    def extract_pdf
      with_downloaded_file(".pdf") do |file_path|
        reader = PDF::Reader.new(file_path)
        pages = reader.pages.each_with_index.map do |page, idx|
          { text: page.text.to_s, metadata: { "page" => idx + 1 } }
        end

        if pages.all? { |p| normalize_text(p[:text]).blank? }
          raise ExtractionError, "O PDF não possui texto selecionável (pode ser um documento escaneado)."
        end

        pages
      end
    rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
      raise ExtractionError, "Não foi possível ler o PDF: #{e.message}"
    end

    def extract_pptx
      with_downloaded_file(".pptx") do |file_path|
        slides = []
        Zip::File.open(file_path) do |zip_file|
          slide_entries = zip_file.glob("ppt/slides/slide*.xml").sort_by do |entry|
            entry.name[/slide(\d+)\.xml/, 1].to_i
          end

          slide_entries.each_with_index do |entry, idx|
            slide_num = entry.name[/slide(\d+)\.xml/, 1].to_i
            slide_num = idx + 1 if slide_num.zero?

            xml = Nokogiri::XML(entry.get_input_stream.read)
            paragraphs = xml.xpath("//*[local-name()='p']").map do |p_node|
              p_node.xpath(".//*[local-name()='t']").map(&:text).join
            end.reject(&:blank?)

            slides << { text: paragraphs.join("\n"), metadata: { "slide" => slide_num } }
          end
        end

        if slides.all? { |s| normalize_text(s[:text]).blank? }
          raise ExtractionError, "Nenhum texto encontrado nos slides do PPTX."
        end

        slides
      end
    rescue Zip::Error => e
      raise ExtractionError, "Arquivo PPTX inválido ou corrompido: #{e.message}"
    end

    def extract_docx
      with_downloaded_file(".docx") do |file_path|
        Zip::File.open(file_path) do |zip_file|
          doc_entry = zip_file.find_entry("word/document.xml")
          raise ExtractionError, "Conteúdo principal não encontrado no DOCX." unless doc_entry

          xml = Nokogiri::XML(doc_entry.get_input_stream.read)
          paragraphs = xml.xpath("//*[local-name()='p']").map do |p_node|
            p_node.xpath(".//*[local-name()='t']").map(&:text).join
          end.reject(&:blank?)

          [ { text: paragraphs.join("\n"), metadata: {} } ]
        end
      end
    rescue Zip::Error => e
      raise ExtractionError, "Arquivo DOCX inválido ou corrompido: #{e.message}"
    end

    def extract_text
      raw = if @study_source.raw_text.present?
        @study_source.raw_text
      elsif @study_source.file.attached?
        @study_source.file.download
      else
        raise ExtractionError, "Nenhum conteúdo de texto ou arquivo foi enviado."
      end

      [ { text: raw.to_s, metadata: {} } ]
    end

    def with_downloaded_file(ext)
      raise ExtractionError, "Nenhum arquivo anexado à fonte." unless @study_source.file.attached?

      Tempfile.create([ "study_source", ext ]) do |tempfile|
        tempfile.binmode
        @study_source.file.download { |chunk| tempfile.write(chunk) }
        tempfile.flush
        yield tempfile.path
      end
    end

    def normalize_text(text)
      text.to_s
          .encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
          .gsub("\r\n", "\n")
          .gsub("\r", "\n")
          .gsub(/[ \t]+/, " ")
          .gsub(/\n{3,}/, "\n\n")
          .strip
    end
  end
end
