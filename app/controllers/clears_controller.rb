# frozen_string_literal: true

class ClearsController < ApplicationController
  def new
    @clear = Clear.new
  end
end
