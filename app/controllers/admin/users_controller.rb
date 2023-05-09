# frozen_string_literal: true

# Admin::UsersController
module Admin
  class UsersController < ApplicationController
    def index
      @users = User.all
    end
  end
end