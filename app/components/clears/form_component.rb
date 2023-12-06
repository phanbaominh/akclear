# frozen_string_literal: true

class Clears::FormComponent < ApplicationComponent
  include Turbo::StreamsHelper
  include Turbo::FramesHelper

  renders_one :header
  renders_one :footer

  attr_reader :clear_spec, :job_id

  delegate :operator_ids, to: :clear_spec

  def post_initialize(clear_spec:, job_id: false)
    @clear_spec = clear_spec
    @job_id = job_id
  end

  def edit_form
    clear_spec.persisted?
  end
end
