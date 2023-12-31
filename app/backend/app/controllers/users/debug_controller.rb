class Users::DebugController < ApplicationController
    def test
      # user = User.find(params[:id])
      render json: { ok: 'test api connection' }, status: :ok
    # rescue ActiveRecord::RecordNotFound
    #   render json: { error: 'User not found' }, status: :not_found
    end

    def user
        user = User.find(params[:id])
        render json: user, only: [:id, :name, :email, :updated_at], status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
    end

    def coin
        coin = Masters::Coin.find(params[:id])
        render json: coin, only: [:id, :name, :price, :updated_at], status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Coin not found' }, status: :not_found
    end

    def event
        event = Masters::Events.find(params[:id])
        render json: event, only: [:id, :name, :detail, :updated_at], status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Event not found' }, status: :not_found
    end

    def information
        information = Masters::Information.find(params[:id])
        render json: information, only: [:id, :name, :detail, :updated_at], status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Information not found' }, status: :not_found
    end
  end
