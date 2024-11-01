module StandardResponse
  extend ActiveSupport::Concern

  def standard_json_response(message = "Success", status_code = 200, data = nil, metadata = {})
    response_data = {
      status_code: status_code,
      message: message,
      data: data
    }

    status = nil
    case status_code
    when 201
      status = :created
    when 400
      status = :bad_request
    when 200
      status = :ok
    when 409
      status = :conflict
    when 401
      status = :unauthorized
    when 404
      status = :not_found
    when 422
      status = :unprocessable_entity
    when 429
      status = :too_many_requests
    when 403
      status = :forbidden
    else
      status = :internal_server_error
    end

    unless metadata.empty?
      response_data[:page] = metadata[:page]
      response_data[:limit] = metadata[:limit]
    end

    render json: response_data, status: status
  end
end
