class AddStatusAndSourceToClientInfos < ActiveRecord::Migration[8.0]
  def change
    add_column :client_infos, :status, :integer, default: 0, null: false
    add_column :client_infos, :lead_source, :string
    add_column :client_infos, :referrer_url, :string
    add_column :client_infos, :landing_page, :string
    add_column :client_infos, :referred_by, :string
  end
end