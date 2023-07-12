# frozen_string_literal: true

# GeoblacklightAdmin::UsersController
module GeoblacklightAdmin
  class UsersController < GeoblacklightAdmin::AdminController
    def index
      @users = User.all
    end
  end
end
