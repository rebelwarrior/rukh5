# Default Action Cable Connection (Application Cable inherits)
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    before_action :authenticate_user!
    identified_by :current_user
    
    def connect 
      assign_current_user
    end
    
    private

    def assign_current_user
      @user = current_user
    end
  end
end
