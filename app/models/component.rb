class Component < ActiveRecord::Base
  attr_accessible :name
  attr_accessible :description

  belongs_to :course
  
  validates :name, :presence => true,
                   :length => { :maximum => 134}, 
                   :uniqueness => true 
  validates :course_id, :presence => true
  
  has_many :step_components, :dependent => :destroy
  has_many :steps, :through => :step_components
  has_many :videos
  has_many :memories, :dependent => :destroy
  has_many :quiz_components, :dependent => :destroy
  has_many :quizzes, :through => :quiz_components

  after_create :add_to_each_student

  def add_to_each_student
    course.students.each do |student|
      student.remember(self)
    end
  end

  def to_s
    name
  end

end
