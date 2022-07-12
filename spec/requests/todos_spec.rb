# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Todos', type: :request do
  describe 'GET /index' do
    subject(:get_todos) { get todos_path, headers: headers }

    let(:headers) do
      { 'Accept' => 'application/json' }
    end
    let(:params) do
      {
        todo: {
          title: 'test'
        }
      }
    end

    before do
      2.times { post todos_path, params: params, as: :json }
    end

    it 'returns status 200' do
      get_todos
      expect(response).to have_http_status(:ok)
    end

    it 'returns 2 todos' do
      get_todos
      expect(JSON.parse(response.body, symbolize_names: true).length).to eq 2
    end

    it 'has the response content-type as json' do
      get_todos
      expect(response.headers['Content-Type']).to include 'application/json'
    end

    context 'when accept type needs to be as xml' do
      let(:headers) do
        { 'Accept' => 'application/xml' }
      end

      it 'responds with body as xml' do
        get_todos
        expect(response.headers['Content-Type']).to include 'application/xml'
      end
    end
  end

  describe 'POST /create' do
    subject(:post_todos) { post todos_path, params: params, headers: headers, as: type}

    let(:type) do
      :json
    end

    context 'when request has valid parameters' do
      let(:params) do
        {
          todo: {
            title: 'test'
          }
        }
      end

      it 'responds with status code 201' do
        post_todos
        expect(response).to have_http_status(:created)
      end

      it 'increases the count of records by 1' do
        expect { post_todos }.to change(Todo, :count).by(1)
      end

      it 'has the same title with the request' do
        post_todos
        expect(JSON.parse(response.body, symbolize_names: true)[:title]).to eq('test')
      end

      it 'generates url for todo with the id contained' do
        post_todos
        response_json = JSON.parse(response.body, symbolize_names: true)
        expect(response_json[:url]).to include(response_json[:id].to_s).once
      end
    end

    context 'when creating a todo with order' do
      let(:params) do
        {
          todo: {
            title: 'test',
            order: 10
          }
        }
      end

      it 'has the correct order number' do
        post_todos
        expect(JSON.parse(response.body, symbolize_names: true)[:order]).to eq 10
      end
    end

    context 'when request has missing title' do
      let(:params) do
        {
          todo: {
          }
        }
      end

      it 'responds with status code 400' do
        post_todos
        expect(response).to have_http_status(:bad_request)
      end

      it 'responds with error message Content missing' do
        post_todos
        expect(JSON.parse(response.body, symbolize_names: true)[:error]).to eq 'Content missing'
      end
    end

    context 'when request has missing/empty body' do
      let(:params) do
        {}
      end

      it 'responds with status code 400' do
        post_todos
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when request has empty string title' do
      let(:params) do
        {
          todo: {
            title: ''
          }
        }
      end

      it 'responds with status code 400' do
        post_todos
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when request is json and accepts xml as response' do
      let(:headers) do
        {
          'Accept' => 'application/xml'
        }
      end
      let(:params) do
        {
          todo: {
            title: 'test'
          }
        }
      end

      it 'has the accept type as xml' do
        post_todos
        expect(response.headers['Content-Type']).to include 'application/xml'
      end
    end

    context 'when request is xml and accepts xml as response' do
      let(:headers) do
        {
          'Accept' => 'application/xml',
          'CONTENT-TYPE' => 'application/xml'
        }
      end
      let(:params) do
        {
          todo: {
            title: 'test'
          }
        }.to_xml
      end
      let(:type) do
        :xml
      end

      it 'has the accept type as xml' do
        post_todos
        expect(response.headers['Content-Type']).to include 'application/xml'
      end
    end
  end

  describe 'PATCH /update' do
    subject(:patch_todos) { patch "/todos/#{todo_id}", params: params, as: :json }

    let(:params) do
      {
        todo: {
          title: 'testeeeed',
          completed: true
        }
      }
    end
    let(:todo_id) do
      Todo.create(title: 'test', completed: false).id
    end

    it 'responds with status code 200' do
      patch_todos
      expect(response).to have_http_status(:ok)
    end

    it 'has the updated title' do
      patch_todos
      expect(JSON.parse(response.body, symbolize_names: true)[:title]).to eq 'testeeeed'
    end

    it 'has the updated completed status' do
      patch_todos
      expect(JSON.parse(response.body, symbolize_names: true)[:completed]).to be true
    end

    context 'when marking the todo as completed as boolean' do
      let(:params) do
        {
          todo: {
            completed: true
          }
        }
      end

      it 'responds with status code 200' do
        patch_todos
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when marking the todo as completed as string' do
      let(:params) do
        {
          todo: {
            completed: 'true'
          }
        }
      end

      it 'responds with status code 400' do
        patch_todos
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when changing the order number' do
      let(:params) do
        {
          todo: {
            order: 22
          }
        }
      end

      it 'responds with status code 200' do
        patch_todos
        expect(response).to have_http_status(:ok)
      end

      it 'has the updated order number' do
        patch_todos
        expect(JSON.parse(response.body, symbolize_names: true)[:order]).to eq 22
      end
    end

    context 'when request has non existent id' do
      let(:todo_id) do
        rand(1_203_223)
      end

      it 'responds with status code 404' do
        patch_todos
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:delete_todo) { delete "/todos/#{todo_id}" }

    let(:todo_id) do
      Todo.create(title: 'test', completed: false).id
    end

    it 'responds with status code 200' do
      delete_todo
      expect(response).to have_http_status(:ok)
    end

    context 'when request has non existent id' do
      let(:todo_id) do
        rand(12_032_213_213)
      end

      it 'responds with status code 404' do
        delete_todo
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /destroy_all' do
    subject(:delete_todos) { delete '/todos' }

    before do
      3.times { Todo.create(title: 'test', completed: false) }
    end

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
