class BadRequestError < HttpError
  def initialize(message)
    super(400, message, :bad_request)
  end
end

class NotFoundError < HttpError
  def initialize(message)
    super(404, message, :not_found)
  end
end

class InternalServerError < HttpError
  def initialize(message)
    super(500, message, :internal_server_error)
  end
end
