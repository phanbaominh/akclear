class ClearImage::TestResult
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Presentable

  DATA_FILENAME = 'data.json'
  STATUSES = [
    PASSED = :passed,
    FAILED = :failed,
    COMPUTING = :computing,
    PENDING = :pending
  ]

  attribute :test_case_id, :integer
  attribute :test_run_id, :integer
  attribute :test_run
  attr_reader :data
  attr_writer :latest_test_runs, :test_case

  def self.preload_test_case(test_results)
    test_run = test_results.first.test_run
    case_to_result = test_results.index_by(&:test_case_id)
    test_run.test_cases.each do |test_case|
      case_to_result[test_case.id].test_case = test_case
    end
  end

  STATUSES.each do |status|
    define_method("#{status}?") do
      self.status == status.to_s
    end
  end

  def initialize(attributes = {})
    super
    self.test_run_id = test_run.id if attributes[:test_run]
    @data = {}
    read_from_file
  end

  def has_started?
    data_path.exist?
  end

  def status
    data[:status] || PENDING
  end

  def language
    data[:language]&.to_sym
  end

  def used_operators_data
    data[:used_operators_data] || []
  end

  def error_message
    data[:error_message]
  end

  def test_case_operator_data
    test_case.used_operators_data
  end

  def test_case_operator_ids
    test_case_operator_data.map { |used_operator_data| used_operator_data['operator_id'] }
  end

  delegate :used_operators_data, to: :test_case, prefix: true

  def passed_operators
    @passed_operators ||= test_case_operator_data.select do |used_operator_data|
      used_operators_data.include?(used_operator_data)
    end.map { |used_operator_data| UsedOperator.new(used_operator_data) }
  end

  def failed_operators
    return @failed_operators if defined?(@failed_operators)

    id_to_used_operator_data = used_operators_data.index_by { |used_operator_data| used_operator_data[:operator_id] }
    id_to_test_case_operator_data = test_case_operator_data.index_by do |used_operator_data|
      used_operator_data['operator_id']
    end

    @failed_operators = id_to_used_operator_data.select do |id, used_operator_data|
      used_operator_data != id_to_test_case_operator_data[id]
    end.map do |id, used_operator_data|
      [UsedOperator.new(id_to_test_case_operator_data[id]),
       UsedOperator.new(used_operator_data)]
    end
  end

  def missing_operators
    return @missing_operators if defined?(@missing_operators)

    used_operator_ids = used_operators_data.map { |used_operator_data| used_operator_data[:operator_id] }
    @missing_operators = test_case_operator_data.select do |used_operator_data|
      used_operator_ids.exclude?(used_operator_data['operator_id'])
    end.map { |used_operator_data| UsedOperator.new(used_operator_data) }
  end

  def all_operators
    passed_operators + failed_operators.flatten + missing_operators
  end

  def correct_ratio
    ((passed_operators.count.to_f + (failed_operators.count * 0.5)) / test_case_operator_data.count * 100).round(2)
  end

  def compute!
    return unless ClearImage::TestCase.enabled?
    return if has_started?

    FileUtils.mkdir_p(data_folder_path)
    File.write(data_path, { status: COMPUTING }.to_json)
    result = Clears::GetClearImageFromVideo.call(test_case.video, clear_image_path:)
    if result.success?
      clear_image = ClearImage.new(clear_image_path, test_run.configuration)
      used_operators_data = clear_image.used_operators_data
      language = clear_image.language
      File.write(data_path, { status: PASSED, used_operators_data:, language: }.to_json)
    else
      File.write(data_path, { status: FAILED, error_message: result.failure }.to_json)
    end
  rescue StandardError => e
    File.write(data_path, { status: FAILED, error_message: e.message }.to_json)
  end

  def read_from_file
    return unless has_started?

    @data = JSON.parse(File.read(data_path)).with_indifferent_access
  end

  def data_folder_path
    @data_folder_path ||= test_run.data_folder_path.join(test_case_id.to_s)
  end

  def data_path
    @data_path ||= data_folder_path.join(DATA_FILENAME)
  end

  def clear_image_path
    @clear_image_path ||= data_folder_path.join('clear.jpg')
  end

  def test_case
    return nil unless test_case_id

    @test_case ||= ClearImage::TestCase.find_by(id: test_case_id)
  end

  def test_run
    return super if super
    return unless test_run_id

    @test_run ||= ClearImage::TestRun.find_by(id: test_run_id)
  end
  def rerun!
    destroy_data_folder
    compute!
    read_from_file
  end

  def destroy_data_folder
    FileUtils.rm_rf(data_folder_path)
  end

  def current_test_case_index
    @current_test_case_index ||= test_run.test_case_ids.find_index(test_case_id)
  end

  def next_result_test_case_id
    next_index = (current_test_case_index + 1)
    return nil if next_index >= test_run.test_case_ids.count

    test_run.test_case_ids[next_index]
  end

  def prev_result_test_case_id
    prev_index = (current_test_case_index - 1)
    return nil if prev_index < 0

    test_run.test_case_ids[prev_index]
  end

  def artifact_image_srcs
    Dir[data_folder_path.join('*.png')].map do |file_path|
      file_path.gsub(Rails.public_path.to_s, '')
    end.reject { |path| path.include?(ClearImage::Logger::NAME_BOX) }
  end

  def name_box_file_paths
    Dir[data_folder_path.join("#{ClearImage::Logger::NAME_BOX}_*.png")]
  end

  def name_box_image_srcs
    name_box_file_paths.map do |file_path|
      file_path.gsub(Rails.public_path.to_s, '')
    end
  end

  def clear_image_src
    clear_image_path.to_s.gsub(Rails.public_path.to_s, '')
  end

  def configuration_path
    data_folder_path.join(ClearImage::Logger::CONFIG_FILE)
  end

  def configuration
    return @configuration if defined?(@configuration)

    @configuration = (configuration_path.exist? && JSON.parse(File.read(configuration_path)).with_indifferent_access).presence
  end

  def log_path
    data_folder_path.join(ClearImage::Logger::LOG_FILE)
  end

  def log_text
    return unless log_path.exist?

    @log_text ||= File.read(log_path)
  end

  delegate :latest_test_runs, to: :test_run

  def latest_test_results
    @latest_test_results ||= latest_test_runs.filter_map { |test_run| test_run.get_test_result(test_case) }
  end

  def max_latest_correct_ratio
    return @max_latest_correct_ratio if @max_latest_correct_ratio

    latest_ratios = latest_test_results.map(&:correct_ratio)
    ap({ "#{test_case_id}" => latest_ratios })
    @max_latest_correct_ratio = latest_ratios.max
  end
end
