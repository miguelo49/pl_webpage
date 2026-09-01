require "rails_helper"

RSpec.describe "Political context", type: :request do
  describe "GET /political_contexts" do
    it "redirects to the home feed" do
      get political_contexts_path

      expect(response).to redirect_to(root_path)
    end
  end
end
