require 'rails_helper'

describe Task do
  it 'validates the presence of a description' do
    task = Task.create(due_date: '2015-04-04')
    expect(task.errors.any?).to eq(true)
  end

end
