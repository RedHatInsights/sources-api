module Pausable
  extend ActiveSupport::Concern

  included do
    include Discard::Model

    self.discard_column = :paused_at
  end
end
