class AddConfirmableToUsers < ActiveRecord::Migration[8.0] # Make sure your Rails version matches (e.g., 7.1 or 8.0)
  def change # <-- This is the ONLY 'def change' you should have
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string # This column is needed if reconfirmable is true (default)

    add_index :users, :confirmation_token, unique: true

    # Remove or comment out the User.update_all or User.find_each lines
    # if you intend for new sign-ups to require email confirmation.
    # These lines are for handling *existing* users when adding confirmable.
  end
end