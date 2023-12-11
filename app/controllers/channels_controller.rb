class ChannelsController < ApplicationController
  load_and_authorize_resource
  include ClearFilterable
  include Pagy::Backend

  def index
    @pagy, @channels = pagy(Channel.joins(:clears).group(:id).select('channels.*', 'COUNT(clears.id) as clear_count'))
  end

  def show; end
end
