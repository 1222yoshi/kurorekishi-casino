class SkillsController < ApplicationController
  skip_before_action :require_login, only: %i[index]

  def index
    @skills = Skill.all
  end

  def buy
    @skill = Skill.find(params[:id])

    if current_user.skills.include?(@skill)
      if current_user.equipped.present? && !(current_user.equipped.any? { |equipped_skill| equipped_skill.skill_type == 5 } && @skill.skill_type <= 4)
        EquippedSkill.where(user: current_user).destroy_all
      elsif (@skill.skill_type == 1 || @skill.skill_type == 3) && current_user.equipped.any? { |equipped_skill| equipped_skill.skill_type == 1 || equipped_skill.skill_type == 3 }
        EquippedSkill.joins(:skill).where(user: current_user, skill: { skill_type: [1, 3] }).destroy_all
      elsif (@skill.skill_type == 2 || @skill.skill_type == 4) && current_user.equipped.any? { |equipped_skill| equipped_skill.skill_type == 2 || equipped_skill.skill_type == 4 }
        EquippedSkill.joins(:skill).where(user: current_user, skill: { skill_type: [2, 4] }).destroy_all
      end
      EquippedSkill.create(user: current_user, skill: @skill)
      redirect_to skills_path, flash: { success: "#{@skill.name}を装備しました。" }
    else
      unless (@skill.skill_type == 3 && current_user.skills.where(skill_type: 1).count != 2) || (@skill.skill_type == 4 && current_user.skills.where(skill_type: 2).count != 2) || (@skill.skill_type == 5 && (current_user.skills.where(skill_type: 1).count + current_user.skills.where(skill_type: 2).count <= 2)) || (@skill.skill_type == 6 && current_user.skills.count <= 5) 
        if current_user.coin >= @skill.price
          current_user.coin -= @skill.price
          current_user.save
          BoughtSkill.create(user: current_user, skill: @skill)
          if current_user.equipped.present? && !(current_user.equipped.any? { |equipped_skill| equipped_skill.skill_type == 5 } && @skill.skill_type <= 4)
            EquippedSkill.where(user: current_user).destroy_all
          elsif (@skill.skill_type == 1 || @skill.skill_type == 3) && current_user.equipped.any? { |equipped_skill| equipped_skill.skill_type == 1 || equipped_skill.skill_type == 3 }
            EquippedSkill.joins(:skill).where(user: current_user, skill: { skill_type: [1, 3] }).destroy_all
          elsif (@skill.skill_type == 2 || @skill.skill_type == 4) && current_user.equipped.any? { |equipped_skill| equipped_skill.skill_type == 2 || equipped_skill.skill_type == 4 }
            EquippedSkill.joins(:skill).where(user: current_user, skill: { skill_type: [2, 4] }).destroy_all
          end
          EquippedSkill.create(user: current_user, skill: @skill)
          redirect_to skills_path, flash: { success: "#{@skill.name}を購入しました。" }
        else
          redirect_to skills_path
          flash[:danger] = 'コインが足りません。'
        end
      else
        redirect_to skills_path
        flash[:danger] = 'ズルはいけませんねぇ…'
      end
    end
  end
end
