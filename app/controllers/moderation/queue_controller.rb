module Moderation
  class QueueController < BaseController
    def index
      authorize :moderation, :index?
      @queue_entries = Queue.pending
    end
  end
end
