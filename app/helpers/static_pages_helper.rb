module StaticPagesHelper
  def get_member_name(member_id)
    member = Member.find_by_id(member_id)
    return member.last_name + " " + member.first_name
  end
end
