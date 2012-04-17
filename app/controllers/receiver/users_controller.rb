class Receiver::UsersController < ApplicationController
  before_filter :check_receiver

  def index
    @current_user=current_user
  end
end
