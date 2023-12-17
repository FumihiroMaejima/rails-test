class UsersController < ApplicationController
    def show
      user = User.find(params[:id])
      render json: user, only: [:id, :name, :gender, :address], status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end
  end
