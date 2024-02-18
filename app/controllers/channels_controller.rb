class ChannelsController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate!, only: %i[index show]
  include ClearFilterable
  include Pagy::Backend

  def index
    @pagy, @channels = pagy(
      Channel.left_outer_joins(:clears).group(:id).select('channels.*',
                                                          'COUNT(clears.id) as clear_count')
    )
    respond_to do |format|
      format.html
      format.turbo_stream unless params[:html]
    end
  end

  def show; end

  def new
    @channel = Channel.new
  end

  def edit; end

  def create
    @channel = Channel.from_external_id(@channel.external_id)
    @channel.clear_languages = channel_params[:clear_languages]
    if !@channel.persisted? && @channel.save
      respond_to do |format|
        format.html { redirect_to @channel, notice: t('.success') }
        format.turbo_stream
      end
    else
      @channel.errors.add(:external_id, :taken) if @channel.persisted?
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @channel.update(channel_params.except(:external_id))
      respond_to do |format|
        format.html { redirect_to @channel, notice: t('.success') }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @channel.destroy
      redirect_to channels_path(html: true), notice: t('.success')
    else
      redirect_to @channel, alert: t('.failed')
    end
  end

  private

  def channel_params
    params.require(:channel).permit(:external_id, clear_languages: [])
  end
end
