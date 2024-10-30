module Api
  module V1
    class AuthController < ApplicationController
      def sign
        if session[:user_session_id].present?
          render json: { message: "already signed in" }, status: :ok
          return
        end

        username, password = params[:username], params[:password]
        if username.blank? || password.blank?
          render json: { message: "missing credentials" }, status: :bad_request
          return
        end

        user = User.find_by(username: username)
        if user.nil?
          ActiveRecord::Base.transaction do
            user = User.new(username: username, password: password)
              unless user.save
                if user.errors[:password_digest].include?("must include at least one lowercase letter, one uppercase letter, one digit, and one special character")
                  render json: { errors: user.errors[:password_digest][0] }, status: :bad_request
                  raise ActiveRecord::Rollback
                end
                  render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
                  raise ActiveRecord::Rollback
              end

              wallet = Wallet.create(reference_id: user.id, balance: 0, reference_type: "user")
              unless wallet.save
                render json: { errors: "failed to create entity" }, status: :unprocessable_entity
                raise ActiveRecord::Rollback
              end
          end
        elsif !user&.authenticate(password)
          render json: { message: "invalid credentials" }, status: :unauthorized
          return
        end

        session[:user_session_id] = user.id
        render json: { message: "signed in" }, status: :ok
      end

      def signout
        session.delete(:user_session_id)
        render json: { message: "ok" }, status: :ok
      end

      private

      def auth_params
        params.permit(:username, :password)
      end
    end
  end
end
