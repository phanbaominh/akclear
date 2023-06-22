# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'

def params_for_1_and_2_stars_operator
  {
    level: Faker::Number.between(from: 1, to: 30)
  }
end

def params_for_3_stars_operator
  params = {}
  params[:elite] = Faker::Number.between(from: 0, to: 1)
  if params[:elite] == 0
    params.merge!(
      level: Faker::Number.between(from: 1, to: 40),
      skill: 1,
      skill_level: Faker::Number.between(from: 1, to: 4)
    )
  else
    params.merge!(
      level: Faker::Number.between(from: 1, to: 55),
      skill: 1,
      skill_level: Faker::Number.between(from: 1, to: 7)
    )
  end
end

def params_for_4_stars_operator
  params = {}
  params[:elite] = Faker::Number.between(from: 0, to: 2)
  case params[:elite]
  when 0
    params.merge!(
      level: Faker::Number.between(from: 1, to: 45),
      skill: 1,
      skill_level: Faker::Number.between(from: 1, to: 4)
    )
  when 1
    params.merge!(
      level: Faker::Number.between(from: 1, to: 60),
      skill: Faker::Number.between(from: 1, to: 2),
      skill_level: Faker::Number.between(from: 1, to: 7)
    )
  when 2
    params.merge!(
      level: Faker::Number.between(from: 1, to: 70),
      skill: Faker::Number.between(from: 1, to: 2),
      skill_level: Faker::Number.between(from: 1, to: 7),
      used_module: Faker::Number.between(from: 0, to: 1)
    )
    params[:skill_mastery] = Faker::Number.between(from: 0, to: 3) if params[:skill_level] == 7
    params[:module_level] = Faker::Number.between(from: 1, to: 3) if params[:used_module] == 1
    params
  end
end

def params_for_5_stars_operator
  params = {}
  params[:elite] = Faker::Number.between(from: 0, to: 2)
  case params[:elite]
  when 0
    params.merge!(
      level: Faker::Number.between(from: 1, to: 50),
      skill: 1,
      skill_level: Faker::Number.between(from: 1, to: 4)
    )
  when 1
    params.merge!(
      level: Faker::Number.between(from: 1, to: 70),
      skill: Faker::Number.between(from: 1, to: 2),
      skill_level: Faker::Number.between(from: 1, to: 7)
    )
  when 2
    params.merge!(
      level: Faker::Number.between(from: 1, to: 80),
      skill: Faker::Number.between(from: 1, to: 2),
      skill_level: Faker::Number.between(from: 1, to: 7),
      used_module: Faker::Number.between(from: 0, to: 1)
    )
    params[:skill_mastery] = Faker::Number.between(from: 0, to: 3) if params[:skill_level] == 7
    params[:module_level] = Faker::Number.between(from: 1, to: 3) if params[:used_module] == 1
    params
  end
end

def params_for_6_stars_operator
  params = {}
  params[:elite] = Faker::Number.between(from: 0, to: 2)
  case params[:elite]
  when 0
    params.merge!(
      level: Faker::Number.between(from: 1, to: 50),
      skill: 1,
      skill_level: Faker::Number.between(from: 1, to: 4)
    )
  when 1
    params.merge!(
      level: Faker::Number.between(from: 1, to: 80),
      skill: Faker::Number.between(from: 1, to: 2),
      skill_level: Faker::Number.between(from: 1, to: 7)
    )
  when 2
    params.merge!(
      level: Faker::Number.between(from: 1, to: 90),
      skill: Faker::Number.between(from: 1, to: 3),
      skill_level: Faker::Number.between(from: 1, to: 7),
      used_module: Faker::Number.between(from: 0, to: 2)
    )
    params[:skill_mastery] = Faker::Number.between(from: 0, to: 3) if params[:skill_level] == 7
    params[:module_level] = Faker::Number.between(from: 1, to: 3) if params[:used_module].positive?
    params
  end
end

def params_for_used_operator(operator)
  if operator.rarity < 3
    params_for_1_and_2_stars_operator
  elsif operator.rarity == 3
    params_for_3_stars_operator
  elsif operator.rarity == 4
    params_for_4_stars_operator
  elsif operator.rarity == 5
    params_for_5_stars_operator
  else
    params_for_6_stars_operator
  end.merge(operator:)
end

def operators
  @operators ||= Operator.all
end

def stages
  @stages ||= Stage.all
end

def create_clear(user)
  num_of_operators = Faker::Number.between(from: 1, to: 13)
  params = { used_operators_attributes: [] }
  operators.sample(num_of_operators).each do |operator|
    params[:used_operators_attributes] << params_for_used_operator(operator)
  end
  params.merge!(
    stage: stages.sample,
    name: Faker::Lorem.sentence,
    link: 'https://www.youtube.com/watch?v=FNCWoNnFUdc',
    submitter: user
  )
  Clear.create!(params)
end

if Rails.env.development?
  user = User.first || User.create!(email: 'test@mail.com', password: 'Password1@', role: :admin, username: 'admin')
  FetchGameData::FetchLatestOperatorsData.call
  FetchGameData::FetchLatestEventsData.call
  FetchGameData::FetchLatestEpisodesData.call
  FetchGameData::FetchLatestStagesData.call
  FetchGameData::FetchAnnihilationsData.call
  FetchGameData::FetchEventBanners.call
  FetchGameData::FetchEpisodesBanners.call
  100.times { create_clear(user) }
end
