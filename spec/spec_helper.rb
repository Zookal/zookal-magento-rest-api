# ENV["RAILS_ENV"] ||= 'test'
require "zookal_magento_rest_api"
require "pry"
require "webmock/rspec"


RSpec.configure do |config|  
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  
  # when a focus tag is present in RSpec, only run tests with focus tag: http://railscasts.com/episodes/285-spork
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true  
end

# http://stackoverflow.com/questions/19075907/clean-solution-for-resetting-class-variables-in-between-rspec-tests/19079701#19079701
def reset_class_variables(cl)
  cl.class_variables.each do |var|
    cl.class_variable_set var, nil
  end
end