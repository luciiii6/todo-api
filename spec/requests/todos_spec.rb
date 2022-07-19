# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Todos', type: :request do
  describe 'GET /index' do
    subject(:get_todos) { get todos_path, headers: headers, params: params }

    let(:headers) do
      { 'Accept' => 'application/json' }
    end
    let(:params) {}
    let(:schema) do
      {
        'type' => 'object',
        'required' => %w[todos],
        'properties' => {
          'todos' => {
            'type' => 'array',
            'required' => %w[title url completed],
            'properties' => {
              'title' => { 'type' => 'string' },
              'url' => { 'type' => 'string' },
              'completed' => { 'type' => 'bool' }
            }
          }
        }
      }
    end

    def valid?(body)
      xsd = Nokogiri::XML::Schema(File.read('./spec/requests/todo_schema_get.xsd'))
      doc = Nokogiri::XML(body)

      return true if xsd.validate(doc).empty?

      false
    end

    before do
      create_list(:todo, 25)
    end

    it 'returns status 200' do
      get_todos
      expect(response).to have_http_status(:ok)
    end

    it 'returns 2 todos' do
      get_todos
      expect(JSON.parse(response.body, symbolize_names: true)[:todos].length).to eq 25
    end

    it 'has the response content-type as json' do
      get_todos
      expect(response.headers['Content-Type']).to include 'application/json'
    end

    it 'has the body as the schema for json type' do
      get_todos
      expect(JSON::Validator.validate!(schema, JSON.parse(response.body))).to be true
    end

    context 'when accept type needs to be as xml' do
      let(:headers) do
        { 'Accept' => 'application/xml' }
      end

      it 'responds with body as xml' do
        get_todos
        expect(response.headers['Content-Type']).to include 'application/xml'
      end

      it 'has the response as the defined XML schema' do
        get_todos
        expect(valid?(response.body)).to be true
      end
    end

    context 'when requesting with pagination' do
      let(:params) { { page: { size: 20 } } }

      it 'returns a list of todos within a size' do
        get_todos
        expect(JSON.parse(response.body)['todos'].length).to eq 20
      end
    end

    context 'when requesting with wrong pagination parameters' do
      let(:params) { { page: { size: 20, after: 'dsad', before: ' dasd' } } }

      it 'respond with error' do
        get_todos
        expect(JSON.parse(response.body)['errors']).to eq "Can't have before and after in the same request"
      end
    end

    context 'when requesting with good cursor' do
      let(:todos) { create_list(:todo, 5) }
      let(:params) { { page: { size: 3, after: CursorEncoder.encode(todos[0].id.to_s) } } }

      it 'respond with a list of 3 todos' do
        get_todos
        expect(JSON.parse(response.body)['todos'].length).to eq 3
      end

      it 'responds with correct metadata(hasNextPage)' do
        get_todos
        expect(JSON.parse(response.body)['metadata']['hasNextPage']).to be true
      end

      it 'responds with correct metadata(hasPreviousPage)' do
        get_todos
        expect(JSON.parse(response.body)['metadata']['hasPreviousPage']).to be true
      end
    end


    context 'when requesting with after: cursor of the first todo' do
      let(:first_todo) { CursorEncoder.encode(Todo.all.order(:created_at).first.id.to_s) }
      let(:params) { { page: { size: 3, after: first_todo } } }

      it 'respond with previous page as true' do
        get_todos
        expect(JSON.parse(response.body)['metadata']['hasPreviousPage']).to be true
      end
    end
  end

  describe 'POST /create' do
    subject(:post_todos) { post todos_path, params: params, headers: headers, as: type }

    let(:type) do
      :json
    end

    let(:schema) do
      {
        'type' => 'object',
        'required' => %w[todo],
        'properties' => {
          'todo' => {
            'type' => 'object',
            'required' => %w[title url completed],
            'properties' => {
              'title' => { 'type' => 'string' },
              'url' => { 'type' => 'string' },
              'completed' => { 'type' => 'bool' }
            }
          }
        }
      }
    end

    def valid?(body)
      xsd = Nokogiri::XML::Schema(File.read('./spec/requests/todo_schema_post.xsd'))
      doc = Nokogiri::XML(body)

      return true if xsd.validate(doc).empty?

      false
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
        expect(JSON.parse(response.body, symbolize_names: true)[:todo][:title]).to eq('test')
      end

      it 'generates url for todo with the id contained' do
        post_todos
        response_json = JSON.parse(response.body, symbolize_names: true)[:todo]
        expect(Todo.find(response_json[:url].split('/')[-1])).to be_an_instance_of(Todo)
      end

      it 'responds with a valid json schema' do
        post_todos
        expect(JSON::Validator.validate!(schema, JSON.parse(response.body))).to be true
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
        expect(JSON.parse(response.body, symbolize_names: true)[:todo][:order]).to eq 10
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

      it 'responds the same as the accept type (xml)' do
        post_todos
        expect(response.headers['Content-Type']).to include 'application/xml'
      end

      it 'has the correct title' do
        post_todos
        expect(Hash.from_xml(response.body)['todo']['title']).to eq 'test'
      end

      it 'has the response as the defined XML schema' do
        post_todos
        expect(valid?(response.body)).to be true
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
        { title: 'test' }.to_xml(root: :todo)
      end
      let(:type) { :xml }

      it 'responds the same as the accept type (xml)' do
        post_todos
        expect(response.headers['Content-Type']).to include 'application/xml'
      end

      it 'has the correct title' do
        post_todos
        expect(Hash.from_xml(response.body)['todo']['title']).to eq 'test'
      end
    end

    context 'when request is xml and accepts json as response' do
      let(:headers) do
        {
          'Accept' => 'application/json',
          'CONTENT-TYPE' => 'application/xml'
        }
      end
      let(:params) do
        { title: 'test' }.to_xml(root: :todo)
      end
      let(:type) { :xml }

      it 'responds the same as the accept type (json)' do
        post_todos
        expect(response.headers['Content-Type']).to include 'application/json'
      end

      it 'has the correct title' do
        post_todos
        expect(JSON.parse(response.body)['todo']['title']).to eq 'test'
      end
    end

    context 'when request does not have the accepted types as xml or json' do
      let(:headers) do
        {
          'Accept' => 'image/gif',
          'CONTENT-TYPE' => 'application/xml'
        }
      end
      let(:params) do
        { title: 'test' }.to_xml(root: :todo)
      end
      let(:type) { :xml }

      it 'responds with json as default' do
        post_todos
        expect(response.headers['CONTENT-TYPE']).to include('application/json')
      end
    end
  end

  describe 'PATCH /update' do
    subject(:patch_todos) { patch "/todos/#{todo_id}", params: params, headers: headers, as: type }

    let(:params) do
      {
        todo: {
          title: 'testeeeed',
          completed: true
        }
      }
    end
    let(:todo_id) do
      create(:todo)[:id]
    end
    let(:type) do
      :json
    end
    let(:schema) do
      {
        'type' => 'object',
        'required' => %w[todo],
        'properties' => {
          'todo' => {
            'type' => 'object',
            'required' => %w[title url completed],
            'properties' => {
              'title' => { 'type' => 'string' },
              'url' => { 'type' => 'string' },
              'completed' => { 'type' => 'bool' }
            }
          }
        }
      }
    end

    def valid?(body)
      xsd = Nokogiri::XML::Schema(File.read('./spec/requests/todo_schema_post.xsd'))
      doc = Nokogiri::XML(body)
      return true if xsd.validate(doc).empty?

      false
    end

    it 'responds with status code 200' do
      patch_todos
      expect(response).to have_http_status(:ok)
    end

    it 'has the updated title' do
      patch_todos
      expect(JSON.parse(response.body, symbolize_names: true)[:todo][:title]).to eq 'testeeeed'
    end

    it 'has the updated completed status' do
      patch_todos
      expect(JSON.parse(response.body, symbolize_names: true)[:todo][:completed]).to be true
    end

    it 'responds with a valid json schema' do
      patch_todos
      expect(JSON::Validator.validate!(schema, JSON.parse(response.body))).to be true
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
        expect(JSON.parse(response.body, symbolize_names: true)[:todo][:order]).to eq 22
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

    context 'when request is json and accepts xml as response' do
      let(:headers) do
        {
          'Accept' => 'application/xml',
          'CONTENT-TYPE' => 'application/json'
        }
      end
      let(:params) do
        {
          todo: {
            title: 'no more test'
          }
        }
      end

      it 'responds the same as the accept type (xml)' do
        patch_todos
        expect(response.headers['Content-Type']).to include 'application/xml'
      end

      it 'has the correct title' do
        patch_todos
        expect(Hash.from_xml(response.body)['todo']['title']).to eq 'no more test'
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
        { title: 'no more test', completed: true }.to_xml(root: :todo)
      end

      let(:type) { :xml }

      it 'responds the same as the accept type (xml)' do
        patch_todos
        expect(response.headers['Content-Type']).to include 'application/xml'
      end

      it 'has the correct title' do
        patch_todos
        expect(Hash.from_xml(response.body)['todo']['title']).to eq 'no more test'
      end

      it 'has the correct completed status' do
        patch_todos
        expect(Hash.from_xml(response.body)['todo']['completed']).to be true
      end

      it 'has the response as the defined XML schema' do
        patch_todos
        expect(valid?(response.body)).to be true
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:delete_todo) { delete "/todos/#{todo_id}" }

    let(:todo_id) do
      create(:todo)[:id]
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
      create_list(:todo, 3)
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
