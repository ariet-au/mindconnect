class PageView < ApplicationRecord
  belongs_to :user, optional: true
  has_many :page_view_events

end
