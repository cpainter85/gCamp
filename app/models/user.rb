class User < ActiveRecord::Base
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  has_secure_password
  has_many :memberships, dependent: :destroy
  has_many :projects, through: :memberships
  has_many :comments

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def set_user_id_nil_on_comments
    self.comments.update_all(user_id: nil)
  end

  def admin_or_project_member(project)
    self.admin || self.memberships.find_by(project_id: project.id) != nil
  end

  def project_owner_or_admin(project)
    self.admin || self.memberships.find_by(project_id: project.id).role_id == 2
  end

  def members_of_same_project(user)
    self.projects.map{|x| x.users}.flatten.include?(user)
  end
end
