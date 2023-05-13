module FetchGameData
  module FetchLoggable
    def log_write(entity, entity_id)
      entity_type = entity.class.name
      if entity.previously_new_record?
        log_info("#{entity_type} #{entity_id} created successfully!")
      elsif entity.previous_changes.present?
        log_info("#{entity_type} #{entity_id} updated successfully!")
      end
    end
  end
end
