class HealthzController < ApplicationController
  def index
    head :ok
  end
end
