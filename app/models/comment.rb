class Comment < ActiveRecord::Base
  validates :content, presence: true
  belongs_to :user
  belongs_to :task

  def time_ago_in_words
    time_ago = (Time.now - self.created_at)/60
    "#{time_ago.to_i} minutes ago"
  end
end
