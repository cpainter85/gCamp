class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :role
  validates :user_id, presence: true, uniqueness: {scope: :project_id, message: 'has already been added to this project'}
  validates :role_id, presence: true


end
