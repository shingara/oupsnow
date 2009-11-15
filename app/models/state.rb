class State

  include MongoMapper::Document

  key :name, String, :required => true, :unique => true #, :nullable => false, :unique => true
  key :closed, Boolean, :default => false

  class << self
    def closed
      all(:closed => true)
    end

    ##
    # Update all state with state define like closed only
    # state send in this array
    #
    # @params[Array] all state_ids closed. Other are not closed
    def update_all_closed(state_ids)
      State.all.each do |state|
        state.closed = state_ids.include?(state.id)
        state.save
      end
    end
  end

end
