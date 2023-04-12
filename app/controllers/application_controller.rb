class ApplicationController < ActionController::Base
    # skip before action for all controllers csrf errror
    skip_before_action :verify_authenticity_token
    
end
