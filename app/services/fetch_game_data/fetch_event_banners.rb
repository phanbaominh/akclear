# frozen_string_literal: true

module FetchGameData
  class FetchEventBanners < ApplicationService
    CN_EVENTS_DATA_URL = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/activity_table.json'
    BANNERS_PAGE_URL = 'https://prts.wiki/w/%E6%B4%BB%E5%8A%A8%E4%B8%80%E8%A7%88'
    IMAGE_HOST = 'https://prts.wiki'
    BANNERS_PAGE_EVENTS_SPECIAL_NAMES = {
      '理想城：长夏狂欢季' => '夏活2022', # Ideal City
      '密林悍将归来' => '夏活2020', # Gavial the Great Chief Return
      '多索雷斯假日' => '多索雷斯假日2022', # Dossoles Holiday
      '踏寻往昔之风' => '金秋2020', # Rewinding Breeze
      '午间逸话' => '午间逸话活动预告01', # Stories of afternoon
      '喧闹法则' => '喧闹法则-限时活动', # Code of Brawl
      '火蓝之心' => '活动预告-火蓝之心活动', # Heart of Surging Flame
      '战地秘闻' => '活动预告-战地秘闻活动', # Operational Intel
      '骑兵与猎人' => '骑兵与猎人-预告公告' # Grani
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
      BANNERS_PAGE_EVENTS_SPECIAL_NAMES[original_name] || original_name
    end

    def build_cn_event_name_to_game_id(cn_events_data)
      events.each_with_object({}) do |event, mapping|
        original_event_name = cn_events_data['basicInfo'][event.game_id]['name']
        event_name = banners_page_event_name(original_event_name)
        mapping[event_name] = event.game_id
      end
    end

    def build_event_game_id_to_banner_url(cn_event_name_to_game_id)
      event_game_id_to_banner_url = {}
      event_day = {}
      log_info('Fetching banners page...')
      doc = Nokogiri::HTML(URI.parse(BANNERS_PAGE_URL).open)
      doc.css('td > a > img').each do |img|
        img_event_name, day = extract_event_name_and_day(img[:alt])
        current_event_day = event_day[img_event_name]

        next if !day.nil? && !current_event_day.nil? && day > current_event_day

        game_id = cn_event_name_to_game_id[img_event_name]
        next if game_id.nil?

        event_game_id_to_banner_url[game_id] = img['data-src'].gsub('650', '1300')
        event_day[img_event_name] = day
      end
      event_game_id_to_banner_url
    end

    def extract_event_name_and_day(img_alt)
      parts = img_alt.split(' ')
      if parts.size == 3
        _, img_event_name, day_with_extension = parts
        [img_event_name, day_with_extension.split('.').first.to_i]
      elsif parts.size == 2
        _, img_event_name_with_extension = parts
        [img_event_name_with_extension.split('.').first, nil]
      else
        [parts.first.split('.').first, nil]
      end
    end

    def store_images(event_game_id_to_banner_url)
      log_info('Storing images...')
      folder_path = self.class.images_path
      event_game_id_to_banner_url.each do |game_id, banner_url|
        path = folder_path.join("#{game_id}.jpg")
        if path.exist? && !overwrite
          log_info("Skipping image for event #{game_id}, already exist at #{path}")
          next
        end

        log_info("Storing image for event #{game_id} at #{path}...")
        IO.copy_stream(URI.parse("#{IMAGE_HOST}#{banner_url}").open, path.to_s)
      rescue StandardError => e
        log_info("Failed to store image for event #{game_id} at #{path}: #{e.message}")
      end
      Success()
    end
  end
end
