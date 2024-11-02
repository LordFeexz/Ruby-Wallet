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

class ConflictError < HttpError
  def initialize(message)
    super(409, message, :conflict)
  end
end

class UnauthorizedError < HttpError
  def initialize(message)
    super(401, message, :unauthorized)
  end
end

class ForbiddenError < HttpError
  def initialize(message)
    super(403, message, :forbidden)
  end
end

class TooManyRequestsError < HttpError
  def initialize(message)
    super(429, message, :too_many_requests)
  end
end

class UnprocessableEntityError < HttpError
  def initialize(message)
    super(422, message, :unprocessable_entity)
  end
end

class BadGatewayError < HttpError
  def initialize(message)
    super(502, message, :bad_gateway)
  end
end
