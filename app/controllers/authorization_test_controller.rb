class AuthorizationTestController < ApplicationController
  def index
    authorize :authorization_test, :index?
    head :ok
  end
end
