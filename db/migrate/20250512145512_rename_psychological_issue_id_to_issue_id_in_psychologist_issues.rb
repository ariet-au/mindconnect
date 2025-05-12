class RenamePsychologicalIssueIdToIssueIdInPsychologistIssues < ActiveRecord::Migration[8.0]
  def change
       rename_column :psychologist_issues, :psychological_issue_id, :issue_id
  end
end
