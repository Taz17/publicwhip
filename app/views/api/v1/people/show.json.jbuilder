# frozen_string_literal: true

json.partial! "person", person: @person

# Extra information that's not on the index action

json.rebellions @person.rebellions
json.votes_attended @person.votes_attended
json.votes_possible @person.votes_possible

json.offices @person.current_offices, partial: "api/v1/offices/office", as: :office

json.policy_comparisons do
  json.array! @person.policy_person_distances.includes(:policy).published.order(:distance_a) do |ppd|
    json.policy do
      json.partial! "api/v1/policies/policy", policy: ppd.policy
    end
    json.agreement number_with_precision(ppd.agreement_fraction * 100, precision: 2, significant: true)
    json.voted ppd.voted?
  end
end
