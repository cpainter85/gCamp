require 'rails_helper'

feature 'User sign out' do

  before :each do
    user = User.create(first_name: 'Matt',
                  last_name: 'Murdock',
                  email: 'iamnotdaredevil@email.com',
                  password: 'bornagain')
    visit root_path
    click_link 'Sign In'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign In'
  end

  scenario 'User can sign out' do
    visit root_path
    expect(page).to have_content 'Matt Murdock'
    expect(page).to have_content 'Sign Out'

    click_link 'Sign Out'
    expect(current_path).to eq '/'
    expect(page).to have_content 'You have successfully signed out'
    expect(page).to have_no_content 'Sign Out'
    expect(page).to have_no_content 'Matt Murdock'
    expect(page).to have_content 'Sign In'
  end


end
