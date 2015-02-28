require 'rails_helper'

describe Project do

  it 'validates the presence of a name' do
    project = Project.create()
    expect(project.errors.any?).to eq(true)
  end

end
