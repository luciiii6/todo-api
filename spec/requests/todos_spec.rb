# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Todos', type: :request do
  describe 'GET /index' do
    subject(:get_todos) { get todos_path }
    let(:params) do
      {
        todo: {
          content: 'test'
        }
      }
    end

    before(:each) do
      2.times { post todos_path, params: params }
    end

    context 'successful get after calling post endpoint' do
      it 'returns status 200' do
        get_todos
        expect(response).to have_http_status(:ok)
      end

      it 'returns 2 todos' do
        get_todos
        expect(JSON.parse(response.body, symbolize_names: true)[:todos].length).to eq 2
      end
    end
  end

  describe 'POST /create' do
    subject(:post_todos) { post todos_path, params: params }
    context 'request with valid parameters' do
      let(:params) do
        {
          todo: {
            content: 'test'
          }
        }
      end

      it 'responds with status code 201' do
        post_todos
        expect(response).to have_http_status(:created)
      end

      it 'increases the count of records by 1' do
        expect { post_todos }.to change { Todo.count }.by(1)
      end
    end

    context 'request with missing content' do
      let(:params) do
        {
          todo: {
          }
        }
      end

      it 'responds with status code 400' do
        post_todos
        expect(response).to have_http_status(400)
      end

      it 'responds with error message Content missing' do
        post_todos
        expect(JSON.parse(response.body, symbolize_names: true)[:error]).to eq 'Content missing'
      end
    end

    context 'request with missing/empty body' do
      let(:params) do
        {}
      end
      it 'responds with status code 400' do
        post_todos
        expect(response).to have_http_status(400)
      end
    end

    context 'request with empty string content' do
      let(:params) do
        {
          todo: {
            content: ''
          }
        }
      end

      it 'responds with status code 400' do
        post_todos
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'PUT /update' do
    subject(:put_todos) { put "/todos/#{todo_id}", params: params }
    let(:params) do
      {
        todo: {
          content: 'testeeeed',
          completed: true
        }
      }
    end
    let(:todo_id) do
      Todo.create(content: 'test', completed: false).id
    end

    it 'responds with status code 200' do
      put_todos
      expect(response).to have_http_status(:ok)
    end

    context 'when marking the todo as completed' do
      let(:params) do
        {
          todo: {
            completed: true
          }
        }
      end
      it 'responds with status code 200' do
        put_todos
        expect(response).to have_http_status(200)
      end
    end

    context 'request with non existent id' do
      let(:todo_id) do
        rand(1_203_223)
      end

      it 'responds with status code 404' do
        put_todos
        expect(response).to have_http_status(404)
      end
    end
    context 'request with unaccepted value for :completed' do
      let(:params) do
        {
          todo: {
            content: 'testeeeed',
            completed: 1_232_142_512
          }
        }
      end
      it 'responds with status code 400' do
        put_todos
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:delete_todo) { delete "/todos/#{todo_id}" }
    let(:todo_id) do
      Todo.create(content: 'test', completed: false).id
    end
    context 'request with good id' do
      it 'responds with status code 200' do
        delete_todo
        expect(response).to have_http_status(:ok)
      end
    end
    context 'request with non existent id' do
      let(:todo_id) do
        rand(12_032_213_213)
      end
      it 'responds with status code 404' do
        delete_todo
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /destroy_all' do
    subject(:delete_todos) { delete '/todos' }
    before(:each) do
      3.times { Todo.create(content: 'test', completed: false) }
    end

    context 'request to delete all todos' do
      it 'responds with status code 200' do
        delete_todos
        expect(response).to have_http_status(:ok)
      end

      it 'shows the total number of records is 0' do
        delete_todos
        expect(Todo.all.length).to eq 0
      end
    end
  end
end
