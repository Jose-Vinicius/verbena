require 'rails_helper'

RSpec.describe GeminiClient do
  let(:valid_prompt) { "Instruções do sistema para testes" }
  let(:valid_content) { "Texto de estudo para gerar questões" }
  let(:api_response_body) do
    {
      candidates: [
        {
          content: {
            parts: [
              {
                text: [
                  {
                    statement: "Qual é a capital da França?",
                    options: [ "Paris", "Londres", "Berlim", "Madri" ],
                    correct_index: 0,
                    explanation: "Paris é a capital da França."
                  }
                ].to_json
              }
            ]
          }
        }
      ]
    }.to_json
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('AI_API_KEY').and_return('fake-api-key')
  end

  describe '.available_models' do
    it 'includes the Gemini 3 family models' do
      ids = described_class.available_models.map { |m| m[:id] }
      expect(ids).to include(
        'gemini-3.8-flash',
        'gemini-3.5-flash',
        'gemini-3.5-flash-lite',
        'gemini-3.5-pro',
        'gemini-3-flash',
        'gemini-3-pro'
      )
    end
  end

  describe '.models_with_fallback' do
    it 'puts the preferred Gemini 3 model first and keeps others without duplicates' do
      chain = described_class.models_with_fallback('gemini-3.8-flash')
      expect(chain.first).to eq('gemini-3.8-flash')
      expect(chain).to include('gemini-3.5-flash', 'gemini-2.5-flash', 'gemini-1.5-flash')
      expect(chain.uniq.length).to eq(chain.length)
    end

    it 'uses DEFAULT_MODEL when preferred_model is nil' do
      chain = described_class.models_with_fallback(nil)
      expect(chain.first).to eq(described_class::DEFAULT_MODEL)
    end
  end

  describe '.generate_questions' do
    it 'successfully returns parsed questions when the first model succeeds' do
      fake_http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)

      success_response = Net::HTTPSuccess.new(1.0, '200', 'OK')
      allow(success_response).to receive(:body).and_return(api_response_body)
      allow(fake_http).to receive(:request).and_return(success_response)

      result = described_class.generate_questions(
        prompt: valid_prompt,
        content: valid_content,
        count: 1,
        default_model: 'gemini-2.5-flash'
      )

      expect(result).to be_an(Array)
      expect(result.first['statement']).to eq("Qual é a capital da França?")
    end

    it 'falls back to the second model when the first model returns 503 (server overloaded)' do
      fake_http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)

      error_response_503 = Net::HTTPServiceUnavailable.new(1.0, '503', 'Service Unavailable')
      allow(error_response_503).to receive_messages(body: 'The model is overloaded.', message: 'Service Unavailable')

      success_response = Net::HTTPSuccess.new(1.0, '200', 'OK')
      allow(success_response).to receive(:body).and_return(api_response_body)

      # First call returns 503, second call succeeds
      expect(fake_http).to receive(:request).and_return(error_response_503, success_response)

      result = described_class.generate_questions(
        prompt: valid_prompt,
        content: valid_content,
        count: 1,
        default_model: 'gemini-2.5-flash'
      )

      expect(result).to be_an(Array)
      expect(result.first['statement']).to eq("Qual é a capital da França?")
    end

    it 'falls back to the next model when receiving 429 (rate limit)' do
      fake_http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)

      error_response_429 = Net::HTTPTooManyRequests.new(1.0, '429', 'Too Many Requests')
      allow(error_response_429).to receive_messages(body: 'Resource exhausted', message: 'Too Many Requests')

      success_response = Net::HTTPSuccess.new(1.0, '200', 'OK')
      allow(success_response).to receive(:body).and_return(api_response_body)

      expect(fake_http).to receive(:request).and_return(error_response_429, success_response)

      result = described_class.generate_questions(
        prompt: valid_prompt,
        content: valid_content,
        count: 1
      )

      expect(result).to be_an(Array)
      expect(result.first['statement']).to eq("Qual é a capital da França?")
    end

    it 'falls back when encountering a network timeout' do
      fake_http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)

      success_response = Net::HTTPSuccess.new(1.0, '200', 'OK')
      allow(success_response).to receive(:body).and_return(api_response_body)

      expect(fake_http).to receive(:request).and_raise(Net::ReadTimeout.new("Read timed out"))
      expect(fake_http).to receive(:request).and_return(success_response)

      result = described_class.generate_questions(
        prompt: valid_prompt,
        content: valid_content,
        count: 1
      )

      expect(result).to be_an(Array)
      expect(result.first['statement']).to eq("Qual é a capital da França?")
    end

    it 'raises immediately on non-retryable 403 Forbidden errors' do
      fake_http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)

      forbidden_response = Net::HTTPForbidden.new(1.0, '403', 'Forbidden')
      allow(forbidden_response).to receive(:body).and_return('API key not valid')
      allow(fake_http).to receive(:request).and_return(forbidden_response)

      expect {
        described_class.generate_questions(
          prompt: valid_prompt,
          content: valid_content,
          count: 1
        )
      }.to raise_error(/Gemini API Error.*403/)
    end

    it 'strips markdown json fences from the response' do
      fake_http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)

      fenced_body = {
        candidates: [
          {
            content: {
              parts: [
                {
                  text: "```json\n[{\"statement\":\"Pergunta teste\",\"options\":[\"A\",\"B\"],\"correct_index\":0,\"explanation\":\"Explicação\"}]\n```"
                }
              ]
            }
          }
        ]
      }.to_json

      success_response = Net::HTTPSuccess.new(1.0, '200', 'OK')
      allow(success_response).to receive(:body).and_return(fenced_body)
      allow(fake_http).to receive(:request).and_return(success_response)

      result = described_class.generate_questions(
        prompt: valid_prompt,
        content: valid_content,
        count: 1
      )

      expect(result.first['statement']).to eq("Pergunta teste")
    end

    it 'raises error when all models fail' do
      fake_http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)

      error_response_500 = Net::HTTPInternalServerError.new(1.0, '500', 'Internal Server Error')
      allow(error_response_500).to receive_messages(body: 'Internal Error', message: 'Internal Server Error')
      allow(fake_http).to receive(:request).and_return(error_response_500)

      expect {
        described_class.generate_questions(
          prompt: valid_prompt,
          content: valid_content,
          count: 1
        )
      }.to raise_error(/Gemini API falhou em todos os modelos tentados/)
    end
  end
end
