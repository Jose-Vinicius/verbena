require 'net/http'
require 'uri'
require 'json'

class GeminiClient
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

  def self.generate_questions(prompt:, content:, count:)
    api_key = ENV['AI_API_KEY'] || Rails.application.credentials.ai_api_key
    raise "AI_API_KEY is not set" if api_key.blank?

    uri = URI("#{API_URL}?key=#{api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    user_prompt = "Por favor, leia o texto abaixo e crie #{count} perguntas de acordo com as instruções do sistema.\n\nTexto de estudo:\n#{content}"

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
      
      # The API might sometimes return the JSON wrapped in markdown formatting (```json ... ```)
      # We strip it if present to ensure valid parsing.
      result_text = result_text.gsub(/\A```json\n?/, '').gsub(/\n?```\z/, '').strip
      
      JSON.parse(result_text)
    else
      raise "Gemini API Error: #{response.code} - #{response.body}"
    end
  end
end
