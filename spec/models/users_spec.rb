require 'rails_helper'

describe User do

  before :each do
    @user = User.create(first_name: 'Matt',
                last_name: 'Murdock',
                email: 'iamnotdaredevil@email.com')
  end

  it 'validates the presence of a first name' do
    @user.update_attributes(first_name: nil)
    expect(@user.errors.any?).to eq(true)
  end

  it 'validates the presence of a last name' do
    @user.update_attributes(last_name: nil)
    expect(@user.errors.any?).to eq(true)
  end

  it 'validates the presence of an email' do
    @user.update_attributes(email: nil)
    expect(@user.errors.any?).to eq(true)
  end

  it 'validates the uniqueness of an email' do
    user2 = User.create(first_name: 'Daniel',
                        last_name: 'Rand',
                        email: 'iamnotdaredevil@email.com')
    expect(user2.errors.any?).to eq(true)
  end

end
