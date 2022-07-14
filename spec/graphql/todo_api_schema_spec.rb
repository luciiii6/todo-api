# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodoApiSchema do
  subject(:execute_query) { described_class.execute(query_string, variables: variables) }

  let(:query_string) do
    <<-GRAPHQL
      query {
        todos {
          id,
          title,
          completed
        }
      }
    GRAPHQL
  end

  let(:variables) do
    {}
  end

  before do
    2.times { Todo.create(title: 'testdasd') }
  end

  def todo
    Todo.create(title: 'testsaidjwdkaskdjas', completed: false).id
  end

  it 'return an hash that contains an array of 2 todos' do
    expect(execute_query.to_h['data']['todos'].length).to eq 2
  end

  context 'when creating a todo' do
    subject(:execute_query) { described_class.execute(query_string, variables: variables) }

    let(:query_string) do
      <<-GRAPHQL
      mutation ($input: TodoCreateInput!) {
        todoCreate(input: $input) {
          todo {
            title
            completed
          }
        }
      }
      GRAPHQL
    end

    let(:variables) do
      {
        input: {
          todoInput: {
            title: 'test',
            completed: false
          }
        }
      }
    end

    it 'creates the todo and returns it' do
      expect(execute_query.to_h['data']['todoCreate']['todo']['title']).to eq 'test'
    end
  end

  context 'when updating a todo' do
    subject(:execute_query) { described_class.execute(query_string, variables: variables) }

    let(:query_string) do
      <<-GRAPHQL
      mutation ($input: TodoUpdateInput!) {
        todoUpdate(input: $input) {
          todo {
            title
            completed
          }
        }
      }
      GRAPHQL
    end

    let(:variables) do
      {
        input: {
          id: todo,
          todoInput: {
            title: 'test',
            completed: true
          }
        }
      }
    end

    it 'updates the todo and returns it with updated title' do
      expect(execute_query.to_h['data']['todoUpdate']['todo']['title']).to eq 'test'
    end

    it 'updates the todo and returns it with updated completed status' do
      expect(execute_query.to_h['data']['todoUpdate']['todo']['completed']).to be true
    end
  end

  context 'when deleting a todo' do
    subject(:execute_query) { described_class.execute(query_string, variables: variables) }

    let(:query_string) do
      <<-GRAPHQL
      mutation ($input: TodoDeleteInput!) {
        todoDelete(input: $input) {
          todo {
            id
            title
            completed
          }
        }
      }
      GRAPHQL
    end

    let(:variables) do
      {
        input: {
          id: todo
        }
      }
    end

    it "deletes the todo and returns it but won't find it anymore in database" do
      expect { Todo.find(execute_query.to_h['data']['todoDelete']['todo']['id']) }
        .to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
