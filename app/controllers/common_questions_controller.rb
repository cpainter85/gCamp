class CommonQuestionsController < ApplicationController
  def index
    @question_and_answer = CommonQuestions.question_and_answer
  end
end
