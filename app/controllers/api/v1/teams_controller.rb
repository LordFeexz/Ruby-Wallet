module Api
  module V1
    class TeamsController < ApplicationController
      include Pagination
      include StandardResponse
      use Authenticator::Middleware

      def show
        standard_json_response(
          "ok",
          200,
          Team
          .limit(per_page).offset(paginate_offset),
        { page: page_no, limit: per_page }
        )
      end

      def detail
        team = Team.find_by(id: params[:id])
        if team.nil?
          standard_json_response("team not found", 404)
          return
        end
        standard_json_response("ok", 200, team)
      end

      def create
        @payload = CreateTeamProp.new(team_params)

        unless @payload.valid?
          standard_json_response("name #{@payload.errors[:name][0]}", 400)
          return
        end

        if Team.where(owner_id: request.env["user"].id).count >= AppConstant::MAX_TEAM_OWNED
          standard_json_response("maximum number of teams reached", 409)
          return
        end

        code = 201
        message = "created"

        ActiveRecord::Base.transaction do
          begin
            team = Team.new(name: @payload.name, owner_id: request.env["user"].id)
            raise UnprocessableEntityError.new("failed to create entity") unless team.save

            raise UnprocessableEntityError.new("failed to create entity") unless TeamMember.new(
              team_id: team.id,
              user_id: request.env["user"].id,
              role: 0
            ).save

          rescue HttpError => e
            code = e.status_code
            message = e.message
            raise ActiveRecord::Rollback
            return
          rescue => e
            code = 500
            message = e.message
            raise ActiveRecord::Rollback
            return
          end
        end

        standard_json_response(message, code, nil)
      end

      def update
        @payload = CreateTeamProp.new(team_params)

        unless @payload.valid?
          standard_json_response("name #{@payload.errors[:name][0]}", 400)
          return
        end
        team = Team.find_by(id: params[:id])

        if team.nil?
          standard_json_response("team not found", 404)
          return
        end

        if team.owner_id != request.env["user"].id
          standard_json_response("unauthorized", 401)
          return
        end

        if team.name == @payload.name
          standard_json_response("change nothing", 200, team)
          return
        end

        if Team.find_by(name: @payload.name)
          standard_json_response("name already exists", 409)
          return
        end

        unless team.update(name: @payload.name)
          standard_json_response("failed to update entity", 500)
          return
        end

        standard_json_response("ok", 200, team)
      end

      def destroy
        team = Team.find_by(id: params[:id])

        if team.nil?
          standard_json_response("team not found", 404)
          return
        end

        if team.owner_id != request.env["user"].id
          standard_json_response("unauthorized", 401)
          return
        end

        unless team.destroy
          standard_json_response("failed to delete entity", 500)
          return
        end

        standard_json_response("ok", 200)
      end

      private

      def team_params
        params.permit(:name)
      end
    end
  end
end
