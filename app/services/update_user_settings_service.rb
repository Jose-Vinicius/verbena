class UpdateUserSettingsService
  Result = Struct.new(:success?, :user, :errors)

  def self.call(user:, gemini_model:, custom_prompt:, restore_default: false)
    new(user: user, gemini_model: gemini_model, custom_prompt: custom_prompt, restore_default: restore_default).call
  end

  def initialize(user:, gemini_model:, custom_prompt:, restore_default: false)
    @user = user
    @gemini_model = gemini_model
    @custom_prompt = custom_prompt
    @restore_default = restore_default
  end

  def call
    attrs = {}
    attrs[:gemini_model] = @gemini_model.to_s.strip if @gemini_model.present?

    if @restore_default
      attrs[:custom_prompt] = nil
    elsif @custom_prompt.present?
      stripped = @custom_prompt.to_s.strip
      if stripped == GeminiClient.default_prompt.strip
        attrs[:custom_prompt] = nil
      else
        attrs[:custom_prompt] = stripped
      end
    else
      attrs[:custom_prompt] = nil
    end

    if @user.update(attrs)
      Result.new(true, @user, nil)
    else
      Result.new(false, @user, @user.errors.full_messages)
    end
  rescue StandardError => e
    Result.new(false, @user, [ e.message ])
  end
end
