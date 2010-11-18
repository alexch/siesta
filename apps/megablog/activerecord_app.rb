require 'active_record'
require 'siesta'

module ActiveRecordApp
  class Article < ActiveRecord::Base
    include Siesta::Resource
    be_root
  end
end
