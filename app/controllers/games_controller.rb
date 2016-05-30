require 'open-uri'

class GamesController < ApplicationController

  def game
    @grid = generate_grid(10)
  end

  def score
    @input = params[:word]
    @grid = params[:grid]
    @end_time = Time.now
    @start_time = params[:start_time]
    if included?(@input, @grid)
      @result = run_game(@input, @grid, @start_time, @end_time)
    end
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end


  private



  def included?(guess, grid)
    grid = @grid.downcase.split('')
    letter_check = @input.downcase.split('').map { |letter| grid.include?(letter) }
    letter_check.include?(false) ? false : true
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - Time.parse(start_time) }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def score_and_message(attempt, translation, grid, time)
    if translation
      if included?(attempt.upcase, grid)
        score = compute_score(attempt, time)
        [score, "Well done"]
      else
        [0, "Not in the grid"]
      end
    else
      [0, "Not an english word"]
    end
  end


  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]

  end


end
