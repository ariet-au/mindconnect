# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController

  protected

  def after_resending_confirmation_instructions_path_for(resource_name)
    # Example: Redirect to the sign-in page, perhaps with a flash message
    # You could add `flash[:notice] = "Confirmation instructions sent! Check your email."`
    new_user_session_path
  end
  def after_confirmation_path_for(resource_name, resource)
    # Your custom path after confirmation
    sign_in(resource) # Optional: Automatically sign in after confirmation
    if resource.psychologist?
      psychologist_profile_edit_path
    else
      # Default path for non-psychologists
      root_path
    end
  end
end
