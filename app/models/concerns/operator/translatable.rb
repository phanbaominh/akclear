module Operator::Translatable
  extend ActiveSupport::Concern

  included do
    extend Mobility
    translates :name, type: :string
  end

  class_methods do
    def build_translations_cache(scope)
      @translations ||= {}
      @translations[I18n.locale] ||= {}
      # works on the assumpation that operator in db does not change either id or name during the process lifetime
      scope.i18n.pluck(:id, :name).each do |id, name|
        @translations[I18n.locale][id] = name
      end
    end

    def get_cached_name(id)
      @translations ||= {}
      @translations.dig(I18n.locale, id)
    end
  end

  def cached_name
    self.class.get_cached_name(id)
  end
end
