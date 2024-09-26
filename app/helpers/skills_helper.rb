module SkillsHelper
  def skill_type_class(skill_type)
    case skill_type
    when 1
      "bg-amber-100" 
    when 2
      "bg-purple-300"  
    when 3
      "bg-yellow-600 text-white"
    when 4
      "bg-purple-950 text-white"
    when 5
      "bg-rose-950 text-white"
    else 
      "bg-black text-yellow-600"
    end
  end
end
