class ClientType < ApplicationRecord
    has_many :psychologist_client_types, dependent: :destroy
    has_many :psychologist_profiles, through: :psychologist_client_types

    has_and_belongs_to_many :issues
end
