# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe '.create' do
    subject(:todo) { described_class.create(content: 'test', completed: true) }

    it { is_expected.to be_an_instance_of described_class }

    it 'has correct attribute value' do
      expect(todo.content).to eq 'test'
    end
  end
end
