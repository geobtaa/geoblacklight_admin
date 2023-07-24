# frozen_string_literal: true

# Admin::UsersController
module Admin
  class UsersController < Admin::AdminController
    def index
      @users = User.where(admin: true)
    end
  end
end
