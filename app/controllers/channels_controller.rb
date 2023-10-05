class ChannelsController < ApplicationController
  load_and_authorize_resource
  include ClearFilterable
  include Pagy::Backend

  def index
    @pagy, @channels = pagy(Channel.all)
  end

  def show; end
end
