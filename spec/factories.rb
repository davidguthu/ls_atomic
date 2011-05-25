Factory.define :user do |user|
  user.email                 "foo@bar.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.define :course do |course|
  course.name         "TestCourse"
  course.description  "CoolCourse"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :component do |component|
  component.name            "Newton's First Law"
  component.description     "An object in motion tends to remain in motion, etc."
end
