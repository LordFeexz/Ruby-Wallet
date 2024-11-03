module Api
  module V1
    class TeamMembersController < ApplicationController
      include StandardResponse
      use Authenticator::Middleware

      before_action :numeric_params_id, only: [ :join, :leave ]

      def join
        team = Team.find_by(id: params[:id])
        if team.nil?
          standard_json_response("team not found", 404)
          return
        end

        if team.owner_id == request.env["user"].id
          standard_json_response("you are the owner this team", 409)
          return
        end

        if TeamMember.exists?(team_id: team.id, user_id: request.env["user"].id)
          standard_json_response("you are already a member of this team", 409)
          return
        end

        unless TeamMember.new(
          team_id: team.id,
          user_id: request.env["user"].id,
          role: 1
        ).save
          standard_json_response("failed to create entity", 422)
          return
        end

        standard_json_response("ok", 200)
      end

      def leave
        team = Team.find_by(id: params[:id])
        if team.nil?
          standard_json_response("team not found", 404)
          return
        end

        if team.owner_id == request.env["user"].id
          standard_json_response("you are the owner this team", 409)
          return
        end

        member = TeamMember.find_by(team_id: team.id, user_id: request.env["user"].id)
        if member.nil?
          standard_json_response("you are not a member of this team", 409)
          return
        end

        unless member.destroy
          standard_json_response("failed to delete entity", 422)
          return
        end

        standard_json_response("ok", 200)
      end

      private

      def numeric_params_id
        standard_json_response("id must be a number", 400) unless params[:id] =~ /^\d+$/
      end
    end
  end
end
