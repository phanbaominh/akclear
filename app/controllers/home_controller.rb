# frozen_string_literal: true

class HomeController < ApplicationController
  include ClearFilterable
  skip_before_action :authenticate!

  def index
    delete_clear_spec_session
    @clear_spec = Clear.new
    @newest_clears = Clear.includes(:channel, :likes, stage: :stageable,
                                                      used_operators: :operator).order(created_at: :desc).limit(6)
    @trending_clears = Clear.preload(:channel, :likes, stage: :stageable)
                            .joins(:likes)
                            .where(likes: { created_at: 1.day.ago... })
                            .group(:id)
                            .select('clears.*',
                                    'count(clears.id) as likes_count')
                            .order(likes_count: :desc).limit(6)
    Operator.build_translations_cache(Operator.from_clear_ids((@trending_clears + @newest_clears).map(&:id)))
  end
end
