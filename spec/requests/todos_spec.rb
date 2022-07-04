require 'rails_helper'

RSpec.describe "Todos", type: :request do
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end

  describe "POST /todo" do
    context "with valid parameters" do
      let(:params) do
        {
          todo: {
            content: "test"
          }
        }
      end

      it "it responds 201" do
        post todos_path, params: params

        expect(response).to have_http_status(:created)
      end
    end

    context "with missing content" do
      let(:params) do
        {
          todo: {
          }
        }
      end

      it "responds with 400" do
        post todos_path, params: params
        expect(response).to have_http_status(400)
      end

      it "responds with Content missing" do
        post todos_path, params: params
        expect(JSON.parse(response.body, :symbolize_names => true)[:error]).to eq "Content missing"
      end
    end

    context "with null content" do
      let(:params) do
        {
          todo: {
            content: ""
          }
        }
      end

      it "responds with 400" do
        post todos_path, params: params
        expect(response).to have_http_status(400)
      end
    end

  end
end