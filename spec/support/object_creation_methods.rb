def create_user(overrides = {})
  User.create!({
    first_name: 'Dominic',
    last_name: 'Toretto',
    email: 'vindiesel@email.com',
    password: 'fastandfurious',
    admin: false
  }.merge(overrides))
end

def create_project(overrides = {})
  Project.create!({
    name: 'Furious 7'
  }.merge(overrides))
end

def create_membership(user, project, overrides = {})
  Membership.create!({
    user_id: user.id,
    project_id: project.id,
    role_id: 1
  }.merge(overrides))
end

def create_task(overrides ={})
  Task.create!({
    description: 'Race Cars Fast and Furiously',
    complete: false,
    due_date: '2015-04-03',
    project_id: create_project.id
  }.merge(overrides))
end
