class FixIssueForeignKeyInPsychologistIssues < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :psychologist_issues, column: :issue_id

    # Add the correct FK (pointing to issues)
    add_foreign_key :psychologist_issues, :issues, column: :issue_id
  end
end
