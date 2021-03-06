class ResponsesController < ApplicationController
  before_filter :authenticate
  before_filter :correct_student, :only => [:show, :update]

  layout "study", :only => [:show]
  
  def create

    @response = Response.new(params[:response])
    @response.user = current_user
    
    @course = @response.quiz.course

    if params[:commit] == "Skip"
      @response.status = "skipped"
    end

    if @response.save
      if @response.status == "skipped"
        respond_to do |format|
          format.html do 
            redirect_to course_study_index_path(@course)
          end
          format.js { render 'load_next', :format => :js }
        end 
      else 
        respond_to do |format|
          format.html { redirect_to @response }
          format.js { 
            render 'show', :format => :js 
          }
        end
      end
    else
      flash[:error] = "Apologies, there was an error and your response was not saved."
      redirect_to course_study_index_path(@course)
    end
  end

  def update
    @response = Response.find(params[:id])
    @quiz = @response.quiz
    @course = @response.quiz.course
    
    if params[:quality] # self-rate a correct response
      @response.rate_components!(Integer(params[:quality]))
    elsif params[:response] # challenge a response labelled as incorrect
      @response.update_attributes(params[:response])
      if(params[:response][:status] == "correct") 
        @quiz.answers.create!(:text => @response.answer) 
        @quiz.save! 
        redirect_to course_quiz_path(@course,@quiz)
        return
      elsif( params[:response][:status] == "incorrect")
        redirect_to course_quiz_path(@course,@quiz)
        return
      end
    end

    @course = @response.quiz.course

    if @response.save
      respond_to do |format|
        format.html { 
          redirect_to course_study_index_path(@course) }
        format.json  
        format.js { render 'update', :format => :js }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to course_study_index_path(@course)
        }
        format.json 
      end
    end
  end

  def show
    @response = Response.find(params[:id])
    @course = @response.quiz.course

    respond_to do |format|
      format.html { render 'show' }
      format.js { render 'show', :format => :js }
    end
  end

  def index
  end

  def correct_student
    @response = Response.find(params[:id])
    if((@response.user != current_user) && (not current_user.can_edit?(@response.quiz.course)))
      flash[:error] = "You may not edit or view responses other than your own unless you are a teacher for this course."
      redirect_to course_path(@response.quiz.course)
    end
  end
end
