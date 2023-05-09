module Admin
  class AdminController < ApplicationController
    include Devise::Controllers::Helpers
    include Pagy::Backend
    layout 'admin/layouts/application'

    before_action :authenticate_admin!

    protected

    def authenticate_admin!
      authenticate_user!
      redirect_to :somewhere, status: :forbidden unless current_user.admin?
    end
  end
end