class Project < ActiveRecord::Base
  validates :name, presence: true
  has_many :tasks, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  # def project_owner
  #   self.memberships.find_by(role_id: 2).user
  # end
end
