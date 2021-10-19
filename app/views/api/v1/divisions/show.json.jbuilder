# frozen_string_literal: true

json.partial! "division", division: @division

# Extra information that isn't in the summary
json.summary @division.motion
json.votes @division.votes.order(:vote).includes(:member), partial: "api/v1/votes/vote", as: :vote

json.policy_divisions do
  json.array! @division.policy_divisions.includes(:policy) do |pd|
    json.policy do
      json.partial! "api/v1/policies/policy", policy: pd.policy
    end
    json.vote PolicyDivision.vote_without_strong(pd.vote)
    json.strong pd.strong_vote?
  end
end

json.bills @division.bills, partial: "api/v1/bills/bill", as: :bill
