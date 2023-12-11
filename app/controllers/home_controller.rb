# frozen_string_literal: true

class HomeController < ApplicationController
  include ClearFilterable
  skip_before_action :authenticate!

  def index
    delete_clear_spec_session
    base_scope = Clear.includes(:stage, used_operators: :operator)
    @clear_spec = Clear.new
    @newest_clears = base_scope.order(created_at: :desc).limit(6)
    @trending_clears = base_scope.joins(:likes)
                                 .where(likes: { created_at: 1.day.ago... })
                                 .group(:id)
                                 .select('clears.*',
                                         'count(id) as likes_count')
                                 .order(likes_count: :desc).limit(6)
  end
end
