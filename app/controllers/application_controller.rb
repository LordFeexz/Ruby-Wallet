class ApplicationController < ActionController::API
  # i include module pagination and standard response here, so i can standarize my responses and help me with pagination
  include Pagination
  include StandardResponse
end
