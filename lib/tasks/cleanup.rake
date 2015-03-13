namespace :cleanup do
  desc 'Fix invalid data'
  task data: :environment do
    Membership.where.not(user_id: User.pluck(:id)).destroy_all
    Membership.where.not(project_id: Project.pluck(:id)).destroy_all
    Task.where.not(project_id: Project.pluck(:id)).destroy_all
    Comment.where.not(task_id: Task.pluck(:id)).destroy_all
    Comment.where.not(user_id: User.pluck(:id)).update_all(user_id: nil)
    Task.where(project_id: nil).destroy_all
    Comment.where(task_id: nil).destroy_all
    Membership.where(project_id: nil).destroy_all
    Membership.where(user_id: nil).destroy_all
  end
end
