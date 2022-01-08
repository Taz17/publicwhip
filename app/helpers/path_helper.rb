# frozen_string_literal: true

module PathHelper
  def division_path_simple(division)
    division_path(division.url_params)
  end

  def division_url_simple(division)
    division_url(division.url_params)
  end

  def history_division_path_simple(division)
    history_division_path(division.url_params)
  end

  def edit_division_path_simple(division)
    edit_division_path(division.url_params)
  end

  def person_path_simple(person)
    member_path_simple(person.latest_member)
  end

  def member_path_simple(member)
    member_path(member.url_params)
  end

  def member_policy_path_simple(member, policy)
    member_policy_path(member.url_params.merge(id: policy.id))
  end

  def member_divisions_path_simple(member)
    member_divisions_path(member.url_params)
  end

  def friends_member_path_simple(member)
    friends_member_path(member.url_params)
  end
end
