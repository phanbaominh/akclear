# frozen_string_literal: true

module FetchGameData
  class FetchEventBanners < ApplicationService
    CN_EVENTS_DATA_URL = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/activity_table.json'
    BANNERS_PAGE_URL = 'https://prts.wiki/w/%E6%B4%BB%E5%8A%A8%E4%B8%80%E8%A7%88'
    IMAGE_HOST = 'https://prts.wiki'
    SUMMER_EVENTS = {
      '理想城：长夏狂欢季' => '夏活2022', # Ideal City
      '密林悍将归来' => '夏活2020' # Gavial the Great Chief Return
    }.freeze

    def self.images_path
      Rails.root.join('app/javascript/images/banners')
    end

    def initialize(overwrite: false)
      @overwrite = overwrite
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

    def banners_page_event_name(original_name)
      SUMMER_EVENTS[original_name] || original_name
    end

    def build_cn_event_name_to_game_id(cn_events_data)
      events.each_with_object({}) do |event, mapping|
        original_event_name = cn_events_data['basicInfo'][event.game_id]['name']
        event_name = banners_page_event_name(original_event_name)
        mapping[event_name] = event.game_id
      end
    end

    def build_event_game_id_to_banner_url(cn_event_name_to_game_id)
      mapping = {}
      number_mapping = {}
      log_info('Fetching banners page...')
      doc = Nokogiri::HTML(URI.parse(BANNERS_PAGE_URL).open)
      doc.css('td > a > img').each do |img|
        _, img_event_name, number = img[:alt].split(' ')
        if number
          number = number.split('.').first.to_i
        elsif img_event_name
          img_event_name = img_event_name.split('.').first
        else
          next
        end
        next if !number.nil? && !number_mapping[img_event_name].nil? && number > number_mapping[img_event_name]

        game_id = cn_event_name_to_game_id[img_event_name]
        next if game_id.nil?

        mapping[game_id] = img['data-src'].gsub('650', '1300')
        number_mapping[img_event_name] = number
      end
      mapping
    end

    def extract_event_name(img_alt); end

    def store_images(event_game_id_to_banner_url)
      log_info('Storing images...')
      folder_path = self.class.images_path
      event_game_id_to_banner_url.each do |game_id, banner_url|
        path = folder_path.join("#{game_id}.jpg")
        next if path.exist? && !overwrite

        log_info("Storing image for event #{game_id} at #{path}...")
        IO.copy_stream(URI.parse("#{IMAGE_HOST}#{banner_url}").open, path.to_s)
      rescue StandardError => e
        log_info("Failed to store image for event #{game_id} at #{path}: #{e.message}")
      end
      Success()
    end
  end
end
