class MembersController < ApplicationController
  def index
    @title = "Representatives &#8212; Current &#8212; The Public Whip".html_safe
    @register_url = "/account/register.php?r=#{CGI.escape(request.fullpath)}"
    @login_url = "/account/settings.php?r=#{CGI.escape(request.fullpath)}"
    @sort = params[:sort]
    # By default sort by last name
    @sort = "lastname" if @sort.nil?

    order = case @sort
    when "constituency"
      ["constituency"]
    when "party"      
      ["party", "last_name", "first_name"]
    when "lastname"
      ["last_name", "first_name"]
    else
      raise "Unexpected value"
    end

    @members = Member.current.where(house: "commons").order(order)
  end
end
