class State

  include Mongoid::Document

  field :name, :type => String, :required => true, :unique => true #, :nullable => false, :unique => true
  validates_uniqueness_of :name
  validates_presence_of :name
  field :closed, :type => Boolean, :default => false

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
