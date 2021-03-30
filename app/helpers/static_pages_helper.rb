module StaticPagesHelper
  def get_member_name(member_id)
    member = Member.find_by_id(member_id)
    return member.last_name + " " + member.first_name
  end

  def get_member_english_name(member_id)
    member = Member.find_by_id(member_id)
    return member.first_name_alphabet + " " + member.last_name_alphabet
  end

end
