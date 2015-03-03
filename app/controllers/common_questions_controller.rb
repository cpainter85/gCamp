class CommonQuestionsController < ApplicationController

  skip_before_action :ensure_current_user

  def index
    @question_and_answer = CommonQuestions.question_and_answer
  end
end
