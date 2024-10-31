class HttpError < StandardError
  attr_reader :status_code, :message, :status

  def initialize(status_code, message, status = :internal_server_error)
    super(message)

    @message = message
    @status_code = status_code
    @status = status
  end
end
