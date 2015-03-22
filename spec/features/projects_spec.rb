require 'rails_helper'

feature 'Projects' do

  before :each do
    user = User.create!(first_name: 'Rick',
                last_name: 'Grimes',
                email: 'walkingdead@email.com',
                password: 'karl')
    visit root_path
    click_on 'Sign In'
    fill_in 'Email', with: 'walkingdead@email.com'
    fill_in 'Password', with: 'karl'
    within('.sign-in-form') { click_on 'Sign In' }
    project = Project.create!(name: 'Project Rebirth')
    Membership.create!(user_id: user.id, project_id: project.id, role_id: 2)
  end

  scenario 'User can create a project' do
    visit root_path
    click_on 'Projects'
    within('.page-header') { click_on 'New Project' }
    fill_in 'Name', with: 'Project Wide Awake'
    click_on 'Create Project'

    expect(page).to have_content('Project was successfully created')
    expect(page).to have_content('Project Wide Awake')
  end

  scenario 'User can see a show page for a project' do
    Project.create(name: 'Alpha')
    visit projects_path
    within('.table') { click_on 'Project Rebirth' }

    expect(page).to have_content('Project Rebirth')
    expect(page).to have_content('Edit')
    expect(page).to have_content('Delete')
    expect(page).to have_no_content('Alpha')
  end

  scenario 'User can edit a Project' do
    visit projects_path
    within('.table') { click_on 'Project Rebirth' }
    click_on 'Edit'
    fill_in 'Name', with: 'Super Soldier Project'
    click_on 'Update Project'

    expect(page).to have_content('Project was successfully updated')
    expect(page).to have_content('Super Soldier Project')
    expect(page).to have_no_content('Project Rebirth')
  end

  scenario 'User can delete a project' do
    visit projects_path
    within('.table') { click_on 'Project Rebirth' }
    click_on 'Delete'

    expect(page).to have_content('Project was successfully deleted')
    expect(page).to have_no_content('Project Rebirth')
  end

  scenario 'Projects must have a name' do
    visit projects_path
    within('.page-header') { click_on 'New Project' }
    click_on 'Create Project'

    expect(page).to have_no_content('Project was successfully created')
    expect(page).to have_content('1 error prohibited this form from being saved')
    expect(page).to have_content('Name can\'t be blank')
  end


end
