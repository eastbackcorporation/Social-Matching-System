class Sender::UsersController < ApplicationController
  before_filter :require_user
  before_filter :check_sender

  def index

  end
end
