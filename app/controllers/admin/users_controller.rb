# frozen_string_literal: true

# Admin::UsersController
module Admin
  class UsersController < Admin::AdminController
    def index
      @users = User.all
    end
  end
end
