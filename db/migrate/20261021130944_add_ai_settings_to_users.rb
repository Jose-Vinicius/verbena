class AddAiSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :gemini_model, :string, default: "gemini-2.5-flash"
    add_column :users, :custom_prompt, :text
  end
end
