# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :hide_role_field, only: [:edit, :update]

  protected


   protected

  def after_sign_up_path_for(resource)
    if resource.psychologist?
      #resource.create_psychologist_profile! unless resource.psychologist_profile
      edit_psychologist_profile_path(resource.psychologist_profile)
    else
      root_path
    end
  end



  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end

  def configure_account_update_params
    # Only allow admin to change roles
    if current_user.admin?
      devise_parameter_sanitizer.permit(:account_update, keys: [:role])
    else
      devise_parameter_sanitizer.permit(:account_update, keys: [])
    end
  end

  def hide_role_field
    # Hide role field unless admin
    return if current_user&.admin?

    params[:user].delete(:role) if params[:user]&.key?(:role)
    resource.role = resource.role_was if resource.role_changed?
  end

  def after_update_path_for(resource)
    if resource.psychologist? && resource.psychologist_profile.nil?
      resource.create_psychologist_profile!
      new_psychologist_profile_path
    else
      super
    end
  end
end