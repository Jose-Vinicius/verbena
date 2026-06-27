class AddColorAndIconToSubjects < ActiveRecord::Migration[8.0]
  def change
    add_column :subjects, :color, :string
    add_column :subjects, :icon, :string
  end
end
