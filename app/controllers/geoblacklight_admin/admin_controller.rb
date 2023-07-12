# frozen_string_literal: true

# GeoblacklightAdmin::AdminController
module GeoblacklightAdmin
  class AdminController < ApplicationController
    include Devise::Controllers::Helpers
    include Pagy::Backend
    layout "geoblacklight_admin/layouts/application"

    before_action :authenticate_admin!

    protected

    def authenticate_admin!
      authenticate_user!
      redirect_to :somewhere, status: :forbidden unless current_user.admin?
    end
  end
end
