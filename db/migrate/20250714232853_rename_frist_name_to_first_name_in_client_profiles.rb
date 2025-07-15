class RenameFristNameToFirstNameInClientProfiles < ActiveRecord::Migration[8.0]
  def change
    rename_column :client_profiles, :frist_name, :first_name
  end
end
