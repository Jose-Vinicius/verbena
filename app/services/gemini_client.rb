require 'net/http'
require 'uri'
require 'json'

class GeminiClient
  MODELS = %w[
    gemini-3.5-flash
    gemini-2.5-flash
    gemini-2.5-flash-lite
  ].freeze

  def self.generate_questions(prompt:, content:, count:)
    api_key = ENV['AI_API_KEY'] || Rails.application.credentials.ai_api_key
    raise "AI_API_KEY is not set" if api_key.blank?

    user_prompt = "Por favor, leia o texto abaixo e crie #{count} perguntas de acordo com as instruções do sistema.\n\nTexto de estudo:\n#{content}"

    last_error = nil

    MODELS.each do |model_name|
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{model_name}:generateContent?key=#{api_key}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
      request.body = {
        systemInstruction: {
          parts: [{ text: prompt }]
        },
        contents: [
          { parts: [{ text: user_prompt }] }
        ],
        generationConfig: {
          responseMimeType: "application/json",
          responseSchema: {
            type: "array",
            items: {
              type: "object",
              properties: {
                statement: { type: "string" },
                options: { type: "array", items: { type: "string" } },
                correct_index: { type: "integer" },
                explanation: { type: "string" }
              },
              required: ["statement", "options", "correct_index", "explanation"]
            }
          }
        }
      }.to_json

      response = http.request(request)
      
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        result_text = data.dig("candidates", 0, "content", "parts", 0, "text")
        
        # The API might sometimes return the JSON wrapped in markdown formatting
        result_text = result_text.gsub(/\A```json\n?/, '').gsub(/\n?```\z/, '').strip
        
        return JSON.parse(result_text)
      else
        last_error = "Gemini API Error (#{model_name}): #{response.code} - #{response.body}"
        
        # Faz fallback se for erro de demanda/servidor (503, 500) ou rate limit (429)
        if %w[503 500 429].include?(response.code)
          Rails.logger.warn "Gemini fallback: Modelo #{model_name} falhou (#{response.code}). Tentando próximo modelo..."
          next
        else
          # Se for erro de auth, bad request, etc, não adianta tentar outros modelos
          raise last_error
        end
      end
    end

    raise "Gemini API falhou em todos os modelos tentados. Último erro: #{last_error}"
  end
end
