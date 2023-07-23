class ChannelsController < ApplicationController
  include ClearFilterable
  include Pagy::Backend

  def index
  end

  def show
    @pagy, @clears = pagy(Clear.all)
  end
end
