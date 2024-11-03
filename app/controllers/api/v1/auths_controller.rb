module Api
  module V1
    class AuthsController < ApplicationController
      def sign
        if session[:user_session_id].present?
          standard_json_response("already signed in", 200)
          return
        end

        @payload = CredentialProp.new(auth_params)

        unless @payload.valid?
          standard_json_response("missing parameters", 400)
          return
        end

        username, password = @payload.values_at(:username, :password)
        if username.blank? || password.blank?
          standard_json_response("missing credentials", 400)
          return
        end

        code = 200
        message = "signed in"
        user = User.find_by(username: username)
        if user.nil?
          ActiveRecord::Base.transaction do
            begin
              user = User.new(username: username, password: password)
              unless user.save
                raise BadRequestError.new(user.errors[:password_digest][0]) if user.errors[:password_digest].include?("must include at least one lowercase letter, one uppercase letter, one digit, and one special character")

                raise UnprocessableEntityError.new("failed to create entity")
              end

              raise UnprocessableEntityError.new("failed to create entity") unless Wallet.create(
                reference_id: user.id,
                balance: 0,
                reference_type: "user"
                ).save

            rescue HttpError => e
              code = e.status_code
              message = e.message
              raise ActiveRecord::Rollback
              return
            end
            rescue => e
              code = 500
              message = e.message
              raise ActiveRecord::Rollback
              return
          end
        elsif !user&.authenticate(password)
          code = 401
          message = "invalid credentials"
        end

        session[:user_session_id] = user.id if code == 200
        standard_json_response(message, code)
      end

      def signout
        session.delete(:user_session_id)
        standard_json_response("ok", 200)
      end

      private

      def auth_params
        params.permit(:username, :password)
      end
    end
  end
end
