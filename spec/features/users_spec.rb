require 'rails_helper'

feature 'Users' do

  before :each do
    User.create(first_name: 'Matt',
                  last_name: 'Murdock',
                  email: 'iamnotdaredevil@email.com',
                  password: 'bornagain')
    visit root_path
    click_on 'Sign In'
    fill_in 'Email', with: 'iamnotdaredevil@email.com'
    fill_in 'Password', with: 'bornagain'
    within('.sign-in-form') { click_on 'Sign In' }

  end

  scenario 'User can create a new user' do
    visit root_path
    click_on 'Users'
    click_on 'New User'
    fill_in 'First name', with: 'Peter'
    fill_in 'Last name', with: 'Parker'
    fill_in 'Password', with: 'uncleben'
    fill_in 'Password confirmation', with: 'uncleben'
    fill_in 'Email', with: 'spiderman@email.com'
    click_on 'Create User'

    expect(page).to have_content('User was successfully created')
    expect(page).to have_content('Peter Parker')
    expect(page).to have_content('spiderman@email.com')
  end

  scenario 'User can see a show page for a user' do
    visit root_path
    click_on 'Users'
    within('.table') { click_on 'Matt Murdock' }

    expect(page).to have_content('First name Matt')
    expect(page).to have_content('Last name Murdock')
    expect(page).to have_content('Email iamnotdaredevil@email.com')

  end

  scenario 'User can edit a user' do
    visit root_path
    click_on 'Users'
    within('.table') { click_on 'Matt Murdock' }
    click_on 'Edit'
    fill_in 'First name', with: 'Daniel'
    fill_in 'Last name', with: 'Rand'
    fill_in 'Email', with: 'theimmortalironfist@email.com'
    click_on 'Update User'

    expect(page).to have_content('User was successfully updated.')
    expect(page).to have_content('Daniel Rand')
    expect(page).to have_content('theimmortalironfist@email.com')

    expect(page).to have_no_content('Matt Murdock')
    expect(page).to have_no_content('iamnotdaredevil@email.com')
  end

  scenario 'Users can delete themselves' do
    visit root_path
    click_on 'Users'
    within('.table') { click_on 'Matt Murdock'}
    click_on 'Edit'
    click_on 'Delete User'

    expect(page).to have_content('User was successfully deleted.')
    expect(page).to have_no_content('Matt Murdock')
    expect(page).to have_no_content('iamnotdaredevil@email.com')
  end

  scenario 'Users must have a first name, last name, an email, and a password' do
    visit users_path
    click_on 'New User'
    click_on 'Create User'

    expect(page).to have_no_content('Task was successfully created.')
    expect(page).to have_content('errors prohibited this form from being saved')
    expect(page).to have_content('First name can\'t be blank')
    expect(page).to have_content('Last name can\'t be blank')
    expect(page).to have_content('Email can\'t be blank')
    expect(page).to have_content('Password can\'t be blank')
  end


end
