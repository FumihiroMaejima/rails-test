class DebugController < ApplicationController
    def test
      # user = User.find(params[:id])
      render json: { ok: 'test api connection' }, status: :ok
    # rescue ActiveRecord::RecordNotFound
    #   render json: { error: 'User not found' }, status: :not_found
    end
  end
