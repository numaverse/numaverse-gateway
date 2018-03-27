module Uuidable
  extend ActiveSupport::Concern

  included do
    before_validation :set_uuid
    validates_presence_of :uuid
    validates_uniqueness_of :uuid
  end

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end
end