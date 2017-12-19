ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveRecord::FixtureSet
  class << self
    alias :orig_create_fixtures :create_fixtures
  end

  def self.create_fixtures f_dir, fs_names, *args
    # Make sure user is loaded first
    fs_names = %w(users posts comrades) & fs_names | fs_names
    orig_create_fixtures f_dir, fs_names, *args
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

def get_profile_pic_regex(user)
  file = user.profile_pic.url

  parts = file.split('.')

  '\/assets\/' + parts[0] + '\-.*\.' + parts[1]
end
