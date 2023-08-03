module FetchGameData
  class FetchLogger
    def initialize(entity_class)
      @entity_class = entity_class
      @new_count = 0
      @update_count = 0
    end

    def log_write(entity, entity_id)
      if entity.previously_new_record?
        log_info("#{entity_class} #{entity_id} created successfully!")
        @new_count += 1
      # TODO: does not log translation changes yet
      elsif entity.previous_changes.present?
        log_info("#{entity_class} #{entity_id} updated successfully!")
        @update_count += 1
      end
    end

    def log_summary
      log_info(
        <<~SUMMARY.strip
          #{new_count} new #{entity_class.pluralize(new_count)} created, #{update_count} #{entity_class.pluralize(update_count)} updated!
        SUMMARY
      )
    end

    private

    attr_reader :new_count, :update_count, :entity_class

    def log_info(info)
      Rails.logger.info(info)
    end
  end
end
