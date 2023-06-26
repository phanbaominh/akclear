# frozen_string_literal: true

class Clears::LikeBigComponent < ApplicationComponent
    attr_reader :clear

    delegate :liked?, :likes_count, to: :clear
  
    def post_initialize(clear:)
      @clear = clear
    end
end
