class Debug::TimeController < ApplicationController
    def test
      # user = User.find(params[:id])
      render json: { ok: TimeLib::date }, status: :ok
    # rescue ActiveRecord::RecordNotFound
    #   render json: { error: 'User not found' }, status: :not_found
    end

    def instanceTest
        time = TimeLib.new()
        render json: { ok: time.instanceDate }, status: :ok
      end
  end
