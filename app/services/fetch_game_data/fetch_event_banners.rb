# frozen_string_literal: true

module FetchGameData
  class FetchEventBanners < ApplicationService
    include ImageStorable
    CN_EVENTS_DATA_URL = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/activity_table.json'
    BANNERS_PAGE_URL = 'https://prts.wiki/w/%E6%B4%BB%E5%8A%A8%E4%B8%80%E8%A7%88'
    IMAGE_HOST = 'https://prts.wiki'

    def self.images_path
      Rails.root.join('app/javascript/images/banners')
    end

    def call
      log_info('Fetching CN events data...')
      cn_events_data = yield FetchJson.call(CN_EVENTS_DATA_URL)
      cn_event_name_to_game_id = build_cn_event_name_to_game_id(cn_events_data)
      event_game_id_to_banner_url = build_event_game_id_to_banner_url(cn_event_name_to_game_id)
      store_images(event_game_id_to_banner_url)
    end

    private

    attr_reader :overwrite

    def events
      @events ||= Event.all
    end

    def build_cn_event_name_to_game_id(cn_events_data)
      events.each_with_object({}) do |event, mapping|
        event_name = cn_events_data['basicInfo'][event.game_id]['name']
        mapping[event_name] = event.game_id
      end
    end

    def build_event_game_id_to_banner_url(cn_event_name_to_game_id)
      event_game_id_to_banner_url = {}
      log_info('Fetching banners page...')
      doc = Nokogiri::HTML(URI.parse(BANNERS_PAGE_URL).open)
      doc.css('tr').each do |cell|
        links = cell.css('td > a')

        next unless links.size >= 3

        img_event_name = links.first.text

        game_id = cn_event_name_to_game_id[img_event_name]
        next if game_id.nil?

        img = links.last.css('img').first

        p img

        next if img.nil?

        event_game_id_to_banner_url[game_id] = "#{IMAGE_HOST}#{img['data-src'].gsub('650', '1300')}"
      end
      event_game_id_to_banner_url
    end

    def image_storable
      :event
    end
  end
end
