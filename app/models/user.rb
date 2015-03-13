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
end
