# app/services/psychologist_matcher.rb
class ProfileMatcher
  def self.match_for_labels(predicted_labels)
    return [] if predicted_labels.blank?

    labels_array = predicted_labels.map { |l| l[:label] }

    matching_psychologists = PsychologistProfile
      .joins(psychologist_issues: :issue)
      .with_profile_img
      .not_hidden 
      .where(issues: { category: labels_array })
      .distinct
      .includes(psychologist_issues: :issue)

    matching_psychologists.map do |p|
      covered_categories = p.psychologist_issues.map { |pi| pi.issue.category } & labels_array
      score = covered_categories.sum { |cat| predicted_labels.find { |l| l[:label] == cat }[:score] }
      { psychologist: p, score: score, matched_categories: covered_categories }
    end.sort_by { |h| -h[:score] }
  end
end
