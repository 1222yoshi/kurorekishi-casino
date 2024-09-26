class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new; end

  def create
    @user = login(params[:name], params[:password])

    if @user
      redirect_to root_path, success: 'おかえりなさいませ…'
    else
      flash.now[:danger] = '会員登録はお済みですか？'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, success: 'またのお越しをお待ちしております…', status: :see_other
  end
end
