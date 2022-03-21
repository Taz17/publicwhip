# frozen_string_literal: true

module PoliciesHelper
  def quote(word)
    "“#{word}”"
  end

  def policy_version_sentence(version)
    changes = []

    case version.event
    when "create"
      name = version.changeset["name"].second
      description = version.changeset["description"].second
      result = "Created"
      result += version.changeset["private"].second == 2 ? " draft " : " "
      result += "policy #{quote(name)} with description #{quote(description)}."
      changes << result
    when "update"
      if version.changeset.key?("name")
        name1 = version.changeset["name"].first
        name2 = version.changeset["name"].second
        changes << "Name changed from #{quote(name1)} to #{quote(name2)}."
      end

      if version.changeset.key?("description")
        description1 = version.changeset["description"].first
        description2 = version.changeset["description"].second
        changes << "Description changed from #{quote(description1)} to #{quote(description2)}."
      end

      if version.changeset.key?("private")
        case version.changeset["private"].second
        when 0, "published"
          changes << "Changed status to not draft."
        when 2, "provisional"
          changes << "Changed status to draft."
        else
          raise "Unexpected value for private: #{version.changeset['private'].second}"
        end
      end
    else
      raise
    end

    safe_join(changes.map { |change| content_tag(:p, change, class: "change-action") })
  end

  def policy_version_sentence_text(version)
    case version.event
    when "create"
      name = version.changeset["name"].second
      description = version.changeset["description"].second
      result = "Created"
      result += version.changeset["private"].second == 2 ? " draft " : " "
      result += "policy #{quote(name)} with description #{quote(description)}"
      result += "."
    when "update"
      changes = []

      if version.changeset.key?("name")
        name1 = version.changeset["name"].first
        name2 = version.changeset["name"].second
        changes << "name from #{quote(name1)} to #{quote(name2)}"
      end

      if version.changeset.key?("description")
        description1 = version.changeset["description"].first
        description2 = version.changeset["description"].second
        changes << "description from #{quote(description1)} to #{quote(description2)}"
      end

      if version.changeset.key?("private")
        case version.changeset["private"].second
        when 0, "published"
          changes << "status to not draft"
        when 2, "provisional"
          changes << "status to draft"
        else
          raise
        end
      end

      result = changes.map do |change|
        "* Changed #{change}."
      end.join("\n")
    else
      raise
    end
    result
  end

  def policy_division_version_vote(version)
    case version.event
    when "create"
      policy_vote_display_with_class(version.changeset["vote"].second)
    when "destroy"
      policy_vote_display_with_class(version.reify.vote)
    when "update"
      text = policy_vote_display_with_class(version.changeset["vote"].first)
      text += " to ".html_safe
      text += policy_vote_display_with_class(version.changeset["vote"].second)
      text
    end
  end

  def policy_division_version_vote_text(version)
    case version.event
    when "create"
      vote_display(version.changeset["vote"].second)
    when "destroy"
      vote_display(version.reify.vote)
    when "update"
      "#{vote_display(version.changeset['vote'].first)} to #{vote_display(version.changeset['vote'].second)}"
    end
  end

  def policy_division_version_division(version)
    id = version.event == "create" ? version.changeset["division_id"].second : version.reify.division_id
    Division.find(id)
  end

  # This helper is both used in the main application as well as the mailer. Therefore the links
  # need to be full URLs including the host
  def policy_division_version_sentence(version)
    vote = policy_division_version_vote(version)
    division = policy_division_version_division(version)
    division_link = content_tag(:em, link_to(division.name, division_url_simple(division)))
    out = []

    case version.event
    when "update"
      out << "Changed vote from "
      out << vote
      out << " on division "
      out << division_link
    when "create"
      out = []
      out << "Added division "
      out << division_link
      out << ". Policy vote set to "
      out << vote
    when "destroy"
      out = []
      out << "Removed division "
      out << division_link
      out << ". Policy vote was "
      out << vote
    else
      raise
    end

    out << "."
    safe_join(out)
  end

  def policy_division_version_sentence_text(version)
    actions = { "create" => "Added", "destroy" => "Removed", "update" => "Changed" }
    vote = policy_division_version_vote_text(version)
    division = policy_division_version_division(version)

    case version.event
    when "update"
      "#{actions[version.event]} vote from #{vote} on division #{division.name}.\n#{division_url_simple(division)}"
    when "create", "destroy"
      tense = if version.event == "create"
                "set to "
              else
                "was "
              end
      "#{actions[version.event]} division #{division.name}. Policy vote #{tense}#{vote}.\n#{division_url_simple(division)}"
    else
      raise
    end
  end

  def version_policy(version)
    Policy.find(version.policy_id)
  end

  # TODO: Remove duplication between version_sentence and version_sentence_text and methods they call
  # This helper is both used in the main application as well as the mailer. Therefore the links
  # need to be full URLs including the host
  def version_sentence(version)
    case version.item_type
    when "Policy"
      policy_version_sentence(version)
    when "PolicyDivision"
      content_tag(:p, policy_division_version_sentence(version), class: "change-action")
    end
  end

  def version_sentence_text(version)
    case version.item_type
    when "Policy"
      policy_version_sentence_text(version)
    when "PolicyDivision"
      policy_division_version_sentence_text(version)
    end
  end

  def version_author(version)
    if version.is_a?(WikiMotion)
      version.user
    else
      User.find(version.whodunnit)
    end
  end

  def version_attribution_text(version)
    user = version_author(version)
    "By #{user.name} at #{version.created_at.strftime('%I:%M%p - %d %b %Y')}\n#{user_url(user, only_path: false)}"
  end

  def capitalise_initial_character(text)
    text[0].upcase + text[1..]
  end

  def policy_card_images(policy, categories)
    distances = policy.policy_person_distances.currently_in_parliament.includes(:person, person: :members)
    members_category_table = {}
    number_of_members = 0
    chosen_images = []
    max_images = 19
    image_limit = 0
    counter = 0
    i = 0

    # Insert members into each category
    categories.each do |category|
      relevant_distances = []
      ppd = distances.select{ |d| d.category == category }
      members_category_table[category] = ppd
      number_of_members += ppd.length
    end
    
    if number_of_members >= max_images
      image_limit = max_images
    else
      image_limit = number_of_members
    end

    keys = members_category_table.keys
    
    while image_limit > chosen_images.length
      if members_category_table[keys[i]].length != 0
        random_index = rand(members_category_table[keys[i]].length)
        chosen_images << members_category_table[keys[i]][random_index].person.latest_member.large_image_url
        members_category_table[keys[i]].delete_at(random_index)
      end
      i = (i + 1) % keys.length
    end

    # return the chosen images and the number of members not included
    return [chosen_images, number_of_members - image_limit]

  end
end


