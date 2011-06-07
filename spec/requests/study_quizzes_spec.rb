require 'spec_helper'

describe "StudyQuizzes" do

  before(:each) do
    @user = Factory(:user)
    @course = Factory(:course)
    @user.enroll!(@course)

    @component = Factory(:component, :course_id => @course)

    @problem = Factory(:problem, :course_id => @course)
    @step1 = @problem.steps.create(:text => "do this first", :order_number => 1)
    @step2 = @problem.steps.create(:text => "do this next", :order_number => 2) 
    @step3 = @problem.steps.create(:text => "finally do this", :order_number => 3)

    @quiz = Factory(:quiz, :problem_id => @problem)
    @quiz.steps = ["1", "2"]
    @quiz.components << @component

    integration_sign_in(@user) 
  end

  it "should be accessible from the course page" do
    visit course_path(@course)
    click_link "Study"
    page.should have_content("Studying #{@course.name}")
  end

  describe "in study mode" do
    before(:each) do
      visit course_study_index_path(@course)
    end

    it "should show the question" do
      page.should have_css("div", :content => @quiz.question)
    end

    it "should show the appropriate steps" do
      page.should have_css("li", :content => @step1.text)
      page.should have_css("li", :content => @step2.text)
    end

    it "should show the problem" do
      page.should have_css("div", :content => @problem.statement)
    end

    it "should have a Check Answer button" do
      page.should have_css("a", :content => "Check answer")
    end

    describe "for text input questions" do

      before(:each) do
        @quiz.answer_input = "text"
        @quiz.save 
      end

      it "should have a box for text input" do
        visit course_study_index_path(@course)
        page.should have_css("input#response_answer")
      end
    end

    describe "for self-rated questions" do

      before(:each) do
        @quiz.answer_input = "self-rate"
        @quiz.save
      end

      it "should not have a box for text input" do
        visit course_study_index_path(@course)
        page.should_not have_css("input#response_answer")
      end
    end

    describe "after submitting the response" do

      it "should show the correct answer" do
        visit course_study_index_path(@course)
        fill_in :input, :with => "41"
        click_button "Check answer"
        page.should have_content("42")
      end

      it "should display help for the problem" do
        visit course_study_index_path(@course)
        fill_in :input, :with => "41"
        click_button "Check answer"
        page.should have_css("div#help")
      end

      describe "for text input" do

        describe "for correct answers" do

          it "should say the answer was correct" do 
            visit course_study_index_path(@course)
            fill_in :input, :with => "42"
            click_button "Check answer"
            page.should have_content("correct")
          end

          it "should have a self rating panel" do
            visit course_study_index_path(@course)
            fill_in :input, :with => @quiz.answer
            click_button "Check answer"
            page.should have_css("a#rate-hard")
            page.should have_css("a#rate-good")
            page.should have_css("a#rate-easy")
          end

          it "should not allow the user to select a miss" do
            visit course_study_index_path(@course)
            fill_in :input, :with => @quiz.answer
            click_button "Check answer"
            page.should_not have_css("a#rate-miss")
          end
        end

        describe "for incorrect answers" do 

          it "should say the answer was incorrect" do
            visit course_study_index_path(@course)
            fill_in :input, :with => "wrong asnwfaerw"
            click_button "Check answer"
            page.should have_content("incorrect")
          end

          it "should have a next button" do
            visit course_study_index_path(@course)
            fill_in :input, :with => "wrong asnwfaerw"
            click_button "Check answer"
            page.should have_content("Next")
          end
        end
      end

      describe "for self-rating" do

        before(:each) do
          @quiz.answer_input = "self-rate"
          @quiz.save
        end

        it "should not judge the answer" do
          visit course_study_index_path(@course)
          click_button "Check answer"
          page.should_not have_css("p.flash")
        end

        it "should have a full self rating panel" do
          visit course_study_index_path(@course)
          click_button "Check answer"
          page.should have_css("a#rate-miss")
          page.should have_css("a#rate-hard")
          page.should have_css("a#rate-good")
          page.should have_css("a#rate-easy")
        end
      end
    end

    describe "rating panel" do
      it "should redirect to the study page for the course" do
        visit course_study_index_path(@course)
        fill_in :input, :with => @quiz.answer
        click_button "Check answer"
        click_link "Good"
        page.should have_content("Studying " + @course.name)
      end
    end
  end
end