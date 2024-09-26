class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
       auto_login(@user)
        redirect_to root_path, success: '会員登録いたしました…'
    else
        flash.now[:danger] = '会員登録に失敗しました。'
        render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
