# frozen_string_literal: true

module FetchGameData
  class FetchEpisodesBanners < ApplicationService
    include ImageStorable
    BANNERS_PAGE_URL = 'https://arknights.wiki.gg/wiki/Operation/Main_Theme'
    IMAGE_HOST = 'https://arknights.wiki.gg'

    def self.images_path
      Rails.root.join('app/javascript/images/banners')
    end

    def initialize(overwrite: false)
      @overwrite = overwrite
    end

    def call
      episode_game_id_to_banner_url = build_episode_game_id_to_banner_url
      store_images(episode_game_id_to_banner_url)
    end

    private

    attr_reader :overwrite

    def episodes
      @episodes ||= FetchLatestEpisodesData.call(json: true).value!
    end

    def build_episode_game_id_to_banner_url
      episode_game_id_to_banner_url = {}
      log_info('Fetching banners page...')
      doc = Nokogiri::HTML(URI.parse(BANNERS_PAGE_URL).open)
      doc.css('th > a > img').each do |img|
        img_episode_number = extract_episode_number(img[:alt])

        game_id = episodes.find { |episode| episode[:number].to_i == img_episode_number.to_i }&.dig(:game_id)
        next if game_id.nil?

        episode_game_id_to_banner_url[game_id] = "#{IMAGE_HOST}#{img[:src]}"
      end
      episode_game_id_to_banner_url
    end

    def extract_episode_number(img_alt)
      # e.g Episode 12.png
      img_alt.split('.').first.split(' ').last
    end

    def image_storable
      :episode
    end
  end
end
