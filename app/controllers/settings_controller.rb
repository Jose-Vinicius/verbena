class SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @available_models = GeminiClient.available_models
    @default_prompt = GeminiClient.default_prompt
    @current_prompt = @user.custom_prompt.presence || @default_prompt
  end

  def update
    result = UpdateUserSettingsService.call(
      user: current_user,
      gemini_model: settings_params[:gemini_model],
      custom_prompt: settings_params[:custom_prompt],
      restore_default: params[:restore_default].present?
    )

    if result.success?
      redirect_to settings_path, notice: "Configurações atualizadas com sucesso."
    else
      @user = current_user
      @available_models = GeminiClient.available_models
      @default_prompt = GeminiClient.default_prompt
      @current_prompt = settings_params[:custom_prompt].presence || @default_prompt
      flash.now[:alert] = result.errors.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  def restore_default_prompt
    result = UpdateUserSettingsService.call(
      user: current_user,
      gemini_model: current_user.gemini_model,
      custom_prompt: nil,
      restore_default: true
    )

    if result.success?
      redirect_to settings_path, notice: "Prompt padrão restaurado com sucesso."
    else
      redirect_to settings_path, alert: "Erro ao restaurar prompt padrão."
    end
  end

  private

  def settings_params
    params.require(:user).permit(:gemini_model, :custom_prompt)
  end
end
