# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Todos', type: :request do
  describe 'GET /index' do
    let(:params) do
      {
        todo: {
          content: 'test'
        }
      }
    end

    before(:each) do
      post todos_path, params: params
    end

    it 'returns status 200' do
      get todos_path
      expect(response).to have_http_status(:ok)
    end

    it 'returns 2 todos' do
      post todos_path, params: params
      get todos_path
      expect(JSON.parse(response.body, symbolize_names: true)[:todos].length).to eq 2
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      let(:params) do
        {
          todo: {
            content: 'test'
          }
        }
      end

      it 'it responds 201' do
        post todos_path, params: params

        expect(response).to have_http_status(:created)
      end
    end

    context 'with missing content' do
      let(:params) do
        {
          todo: {
          }
        }
      end

      it 'responds with 400' do
        post todos_path, params: params
        expect(response).to have_http_status(400)
      end

      it 'responds with Content missing' do
        post todos_path, params: params
        expect(JSON.parse(response.body, symbolize_names: true)[:error]).to eq 'Content missing'
      end

      it 'it responds 400 from an empty body' do
        params = {}
        post todos_path, params: params

        expect(response).to have_http_status(400)
      end
    end

    context 'with empty string content' do
      let(:params) do
        {
          todo: {
            content: ''
          }
        }
      end

      it 'responds with 400' do
        post todos_path, params: params
        expect(response).to have_http_status(400)
      end
    end
  end

  describe 'PUT /update' do
    let(:params) do
      {
        todo: {
          content: 'testeeeed',
          completed: true
        }
      }
    end

    def todo
      Todo.create(content: 'test', completed: false)
    end

    it 'returns status 200' do
      put "/todos/#{todo.id}", params: params
      expect(response).to have_http_status(:ok)
    end

    it 'returns status 200 only with parameter :completed' do
      params = {
        todo: {
          completed: true
        }
      }
      put "/todos/#{todo.id}", params: params

      expect(response).to have_http_status(200)
    end

    it "doesn't find id and returns 404" do
      put "/todos/#{rand(12_032)}", params: params

      expect(response).to have_http_status(404)
    end

    it 'responds 400 because parameter :completed has unaccepted value' do
      params[:todo][:completed] = 213_124_215
      put "/todos/#{todo.id}", params: params

      expect(response).to have_http_status(400)
    end
  end

  describe 'DELETE /destroy' do
    def todo
      Todo.create(content: 'test', completed: false)
    end

    it 'returns status 200' do
      delete "/todos/#{todo.id}"
      expect(response).to have_http_status(:ok)
    end

    it "doesn't find id and returns 404" do
      delete "/todos/#{rand(12_032)}"

      expect(response).to have_http_status(404)
    end
  end

  describe 'DELETE /destroy_all' do
    def todo
      Todo.create(content: 'test', completed: false)
    end

    before(:each) do
      3.times { todo }
    end

    it 'returns status 200' do
      delete '/todos'
      expect(response).to have_http_status(:ok)
      expect(Todo.all.length).to eq 0
    end

    it 'shows the total number of records is 0' do
      delete '/todos'
      expect(Todo.all.length).to eq 0
    end
  end
end
