ActiveRecordQueryTrace.enabled = true if Rails.env.development? && ENV.fetch('QUERY_TRACE', false)
