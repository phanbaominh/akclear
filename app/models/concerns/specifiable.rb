module Specifiable
  extend ActiveSupport::Concern

  attr_reader :spec_attributes

  included do
    scope :satisfy, lambda { |spec|
      spec.spec_attributes&.compact&.reduce(self) do |relation, (attribute, value)|
        relation.where(attribute => value)
      end
    }

    column_names.each do |column_name|
      # for storing raw attributes used to initialize the record
      # e.g j = Job.new , status is enum, j.attributes[:status] = 'pending', j.spec_attributes = nil
      define_method "#{column_name}=" do |value|
        super(value)
        @spec_attributes ||= {}
        @spec_attributes[column_name] = value
      end
    end
  end
end
