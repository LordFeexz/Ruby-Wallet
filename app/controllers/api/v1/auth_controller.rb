module Api
  module V1
    class AuthController < ApplicationController
      def sign
        if session[:user_session_id].present?
          render json: { message: "already signed in" }, status: :ok
          return
        end

        username, password = auth_params.values_at(:username, :password)
        if username.blank? || password.blank?
          render json: { message: "missing credentials" }, status: :bad_request
          return
        end

        user = User.find_by(username: username)
        if user.nil?
          user = User.new(username: username, password: password)

          if !user.save
            if user.errors[:password_digest].include?("must include at least one lowercase letter, one uppercase letter, one digit, and one special character")
              render json: { errors: user.errors[:password_digest][0] }, status: :bad_request
              return
            end
              render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        elsif !user.authenticate(password)
          render json: { message: "invalid credentials" }, status: :unauthorized
          return
        end

        session[:user_session_id] = user.id
        render json: { message: "signed in" }, status: :ok
      end

      private

      def auth_params
        params.permit(:username, :password)
      end
    end
  end
end
