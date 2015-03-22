require 'rails_helper'

feature 'Tasks' do

  before :each do
    user = User.create(first_name: 'Rick',
                  last_name: 'Grimes',
                  email: 'walkingdead@email.com',
                  password: 'karl')
    visit root_path
    click_on 'Sign In'
    fill_in 'Email', with: 'walkingdead@email.com'
    fill_in 'Password', with: 'karl'
    within('.sign-in-form') { click_on 'Sign In' }
    @project = Project.create(name: 'Example Project')
    Membership.create!(user_id: user.id, project_id: @project.id, role_id: 1)
    @task = @project.tasks.create(description: 'Example Task', due_date: '2015-04-15')
  end

  scenario 'User can create a new task' do
    visit root_path
    click_on 'Projects'
    within('.table') { click_link 'Example Project' }
    click_link 'Task'
    click_on 'New Task'
    fill_in 'Description', with: 'Test Task'
    fill_in 'Due date', with: '2015-03-03'
    click_on 'Create Task'
    expect(page).to have_content('Task was successfully created')
    expect(page).to have_content('Test Task')
    expect(page).to have_content('03/03/2015')
  end

  scenario 'User can see a show page for tasks' do

    visit project_tasks_path(@project)
    click_on 'Example Task'
    expect(page).to have_content 'Example Task'
    expect(page).to have_content 'Due On: 04/15/2015'
    expect(page).to have_no_content 'Delete'
  end

  scenario 'Users can edit a task from show page' do
    visit project_task_path(@project, @task)
    click_on 'Edit'
    fill_in 'Description', with: 'Updated Task'
    fill_in 'Due date', with: '2016-06-17'
    click_on 'Update Task'
    expect(page).to have_content('Task was successfully updated.')
    expect(page).to have_content('Updated Task')
    expect(page).to have_no_content('Example Task')
    expect(page).to have_content('06/17/2016')
    expect(page).to have_no_content('04/15/2015')
  end

  scenario 'User can delete a task' do
    visit project_tasks_path(@project)
    expect(page).to have_content('Example Task')
    page.find('.glyphicon-remove').click

    expect(page).to have_content('Task was successfully deleted.')
    expect(page).to have_no_content('Example Task')
  end

  scenario 'User sees error message if tries to create a task without a description' do
    visit project_tasks_path(@project)
    click_on 'New Task'
    click_on 'Create Task'

    expect(page).to have_no_content('Task was successfully created')
    expect(page).to have_content('1 error prohibited this form from being saved ')
    expect(page).to have_content('Description can\'t be blank')
  end

end
