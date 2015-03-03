require 'rails_helper'

feature 'User sign in' do

  before :each do
    @user = User.create(first_name: 'Matt',
                  last_name: 'Murdock',
                  email: 'iamnotdaredevil@email.com',
                  password: 'bornagain')
  end

  scenario 'User can sign in with valid credentials' do
    visit root_path
    expect(page).to have_content 'Sign In'
    expect(page).to have_no_content 'Sign Out'

    click_link 'Sign In'
    expect(current_path).to eq '/sign-in'
    expect(page).to have_content 'Sign into gCamp'

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Sign In'

    expect(current_path).to eq '/'
    expect(page).to have_content 'You have successfully signed in'
    expect(page).to have_content 'Matt Murdock'
    expect(page).to have_content 'Sign Out'
  end

  scenario 'User cannot sign in with invalid credentials' do
    visit root_path
    click_link 'Sign In'
    click_button 'Sign In'

    expect(current_path).to eq '/sign-in'
    expect(page).to have_no_content 'You have successfully signed in'
    expect(page).to have_content 'Email / Password combination is invalid'
    expect(page).to have_no_content 'Sign Out'
  end
end
