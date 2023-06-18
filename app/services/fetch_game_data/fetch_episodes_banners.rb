# frozen_string_literal: true

module FetchGameData
  class FetchEpisodesBanners < ApplicationService
    include ImageStorable
    BANNERS_PAGE_URL = 'https://arknights.fandom.com/wiki/Story/Main_Theme'

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
      @episodes ||= Episode.all
    end

    def build_episode_game_id_to_banner_url
      episode_game_id_to_banner_url = {}
      log_info('Fetching banners page...')
      doc = Nokogiri::HTML(URI.parse(BANNERS_PAGE_URL).open)
      doc.css('th > a > img').each do |img|
        img_episode_name = extract_episode_name(img[:alt])

        game_id = episodes.find { |episode| episode.name.casecmp(img_episode_name).zero? }&.game_id
        next if game_id.nil?

        episode_game_id_to_banner_url[game_id] = img[:src].start_with?('http') ? img[:src] : img['data-src']
      end
      episode_game_id_to_banner_url
    end

    def extract_episode_name(img_alt)
      img_alt.split(':').last.strip
    end

    def image_storable
      :episode
    end
  end
end
