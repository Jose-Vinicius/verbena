require 'rails_helper'
require 'zip'

RSpec.describe Sources::ExtractTextService do
  let(:user) { create(:user) }
  let(:subject_record) { create(:subject, user: user) }

  describe '.call' do
    it 'extracts text from raw_text sources' do
      source = create(:study_source, user: user, subject: subject_record, source_type: :text, raw_text: "Linha 1\r\n\r\nLinha 2")
      segments = described_class.call(source)

      expect(segments.size).to eq(1)
      expect(segments.first[:text]).to eq("Linha 1\n\nLinha 2")
    end

    it 'extracts slides in order from PPTX files' do
      source = create(:study_source, user: user, subject: subject_record, source_type: :pptx, title: 'aula.pptx')
      pptx_data = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry('ppt/slides/slide2.xml')
        zio.write('<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:p><a:t>Segundo slide</a:t></a:p></p:sld>')
        zio.put_next_entry('ppt/slides/slide1.xml')
        zio.write('<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:p><a:t>Primeiro slide</a:t></a:p></p:sld>')
      end.string
      source.file.attach(io: StringIO.new(pptx_data), filename: 'aula.pptx', content_type: 'application/vnd.openxmlformats-officedocument.presentationml.presentation')

      segments = described_class.call(source)

      expect(segments.size).to eq(2)
      expect(segments[0]).to eq({ text: 'Primeiro slide', metadata: { 'slide' => 1 } })
      expect(segments[1]).to eq({ text: 'Segundo slide', metadata: { 'slide' => 2 } })
    end

    it 'extracts paragraphs from DOCX files' do
      source = create(:study_source, user: user, subject: subject_record, source_type: :docx, title: 'apostila.docx')
      docx_data = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry('word/document.xml')
        zio.write('<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:t>Parágrafo 1</w:t></w:r></w:p><w:p><w:r><w:t>Parágrafo 2</w:t></w:r></w:p></w:body></w:document>')
      end.string
      source.file.attach(io: StringIO.new(docx_data), filename: 'apostila.docx', content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')

      segments = described_class.call(source)

      expect(segments.size).to eq(1)
      expect(segments.first[:text]).to eq("Parágrafo 1\nParágrafo 2")
    end

    it 'extracts pages from PDF files via PDF::Reader' do
      source = create(:study_source, user: user, subject: subject_record, source_type: :pdf, title: 'livro.pdf')
      source.file.attach(io: StringIO.new('%PDF-1.4 dummy'), filename: 'livro.pdf', content_type: 'application/pdf')

      fake_page1 = instance_double(PDF::Reader::Page, text: 'Conteúdo página 1')
      fake_page2 = instance_double(PDF::Reader::Page, text: 'Conteúdo página 2')
      fake_reader = instance_double(PDF::Reader, pages: [ fake_page1, fake_page2 ])
      allow(PDF::Reader).to receive(:new).and_return(fake_reader)

      segments = described_class.call(source)

      expect(segments.size).to eq(2)
      expect(segments[0]).to eq({ text: 'Conteúdo página 1', metadata: { 'page' => 1 } })
      expect(segments[1]).to eq({ text: 'Conteúdo página 2', metadata: { 'page' => 2 } })
    end
  end
end
