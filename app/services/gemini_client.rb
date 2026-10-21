require "net/http"
require "uri"
require "json"

class GeminiClient
  AVAILABLE_MODELS = [
    # Família Gemini 3
    {
      id: "gemini-3.8-flash",
      name: "Gemini 3.8 Flash",
      family: "Família Gemini 3 (Nova Geração)",
      description: "Máxima performance, raciocínio avançado e velocidade extrema."
    },
    {
      id: "gemini-3.5-flash",
      name: "Gemini 3.5 Flash",
      family: "Família Gemini 3 (Nova Geração)",
      description: "Inteligência de fronteira com execução rápida para tarefas complexas."
    },
    {
      id: "gemini-3.5-flash-lite",
      name: "Gemini 3.5 Flash Lite",
      family: "Família Gemini 3 (Nova Geração)",
      description: "Ultra-rápido e econômico para alto volume de questões."
    },
    {
      id: "gemini-3.5-pro",
      name: "Gemini 3.5 Pro",
      family: "Família Gemini 3 (Nova Geração)",
      description: "Raciocínio profundo e análise aprofundada de materiais densos."
    },
    {
      id: "gemini-3-flash",
      name: "Gemini 3 Flash",
      family: "Família Gemini 3 (Nova Geração)",
      description: "Rápido, preciso e adaptado para geração contextualizada."
    },
    {
      id: "gemini-3-pro",
      name: "Gemini 3 Pro",
      family: "Família Gemini 3 (Nova Geração)",
      description: "Alta profundidade multimodal e lógica refinada."
    },
    # Família Gemini 2.5 / 2.0
    {
      id: "gemini-2.5-flash",
      name: "Gemini 2.5 Flash",
      family: "Família Gemini 2.5 & 2.0",
      description: "Excelente balanço entre velocidade, raciocínio e estabilidade."
    },
    {
      id: "gemini-2.5-flash-lite",
      name: "Gemini 2.5 Flash Lite",
      family: "Família Gemini 2.5 & 2.0",
      description: "Mais rápido e econômico — ideal para lotes grandes ou menor latência."
    },
    {
      id: "gemini-2.0-flash",
      name: "Gemini 2.0 Flash",
      family: "Família Gemini 2.5 & 2.0",
      description: "Versão 2.0 de alta performance e rápida resposta."
    },
    {
      id: "gemini-2.0-flash-lite",
      name: "Gemini 2.0 Flash Lite",
      family: "Família Gemini 2.5 & 2.0",
      description: "Versão ultra-leve da série 2.0."
    },
    # Família Gemini 1.5
    {
      id: "gemini-1.5-flash",
      name: "Gemini 1.5 Flash",
      family: "Família Gemini 1.5",
      description: "Geração anterior estável com ampla janela de contexto."
    },
    {
      id: "gemini-1.5-pro",
      name: "Gemini 1.5 Pro",
      family: "Família Gemini 1.5",
      description: "Maior capacidade analítica para materiais densos."
    }
  ].freeze

  DEFAULT_MODEL = "gemini-2.5-flash".freeze
  MODELS = AVAILABLE_MODELS.map { |m| m[:id] }.freeze
  RETRYABLE_STATUS_CODES = %w[429 404 408 500 502 503 504 529].freeze

  def self.default_prompt
    File.read(Rails.root.join("lib", "prompts", "generate_questions.txt"))
  end

  def self.available_models
    AVAILABLE_MODELS
  end

  def self.available_model_ids
    MODELS
  end

  def self.models_with_fallback(preferred_model = nil)
    preferred = preferred_model.presence || DEFAULT_MODEL
    # Put preferred first, followed by remaining available models without duplicates
    [ preferred ] + (MODELS - [ preferred ])
  end

  def self.generate_questions(prompt:, content:, count:, default_model: nil)
    api_key = ENV["AI_API_KEY"] || Rails.application.credentials.ai_api_key
    raise "AI_API_KEY is not set" if api_key.blank?

    effective_prompt = prompt.presence || default_prompt
    user_prompt = "Por favor, leia o texto abaixo e crie #{count} perguntas de acordo com as instruções do sistema.\n\nTexto de estudo:\n#{content}"

    models_to_try = models_with_fallback(default_model)
    last_error = nil
    errors_by_model = {}

    models_to_try.each_with_index do |model_name, index|
      begin
        uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{model_name}:generateContent?key=#{api_key}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 15
        http.read_timeout = 45

        request = Net::HTTP::Post.new(uri.request_uri, { "Content-Type" => "application/json" })
        request.body = {
          systemInstruction: {
            parts: [ { text: effective_prompt } ]
          },
          contents: [
            { parts: [ { text: user_prompt } ] }
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
                required: [ "statement", "options", "correct_index", "explanation" ]
              }
            }
          }
        }.to_json

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          data = JSON.parse(response.body)
          result_text = data.dig("candidates", 0, "content", "parts", 0, "text")

          if result_text.blank?
            raise "Gemini API (#{model_name}) retornou resposta vazia"
          end

          result_text = result_text.gsub(/\A```json\n?/, "").gsub(/\n?```\z/, "").strip
          questions = JSON.parse(result_text)

          if index > 0
            Rails.logger.info "Gemini fallback teve sucesso usando modelo: #{model_name} (após falha nos anteriores)"
          end

          return questions
        else
          last_error = "Gemini API Error (#{model_name}): #{response.code} - #{response.body}"
          errors_by_model[model_name] = "#{response.code}: #{response.message}"

          if should_fallback?(response.code)
            next_model = models_to_try[index + 1]
            Rails.logger.warn "Gemini fallback: Modelo #{model_name} falhou (#{response.code}). Tentando próximo modelo (#{next_model || 'nenhum restante'})..."
            next
          else
            # Erros de autenticação (401, 403) não adiantam tentar outros modelos
            raise last_error
          end
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError => e
        last_error = "Gemini API Network Error (#{model_name}): #{e.message}"
        errors_by_model[model_name] = e.message
        next_model = models_to_try[index + 1]
        Rails.logger.warn "Gemini fallback: Modelo #{model_name} rede/timeout (#{e.class.name}: #{e.message}). Tentando próximo modelo (#{next_model || 'nenhum restante'})..."
        next
      rescue JSON::ParserError => e
        last_error = "Gemini API JSON Parse Error (#{model_name}): #{e.message}"
        errors_by_model[model_name] = "JSON Parse Error: #{e.message}"
        next_model = models_to_try[index + 1]
        Rails.logger.warn "Gemini fallback: Modelo #{model_name} retornou JSON inválido. Tentando próximo modelo (#{next_model || 'nenhum restante'})..."
        next
      end
    end

    raise "Gemini API falhou em todos os modelos tentados (#{models_to_try.join(', ')}). Detalhes: #{errors_by_model.to_json}. Último erro: #{last_error}"
  end

  def self.should_fallback?(code)
    code_str = code.to_s
    code_str.start_with?("5") || RETRYABLE_STATUS_CODES.include?(code_str)
  end
end
