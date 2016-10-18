require_relative 'class_detector'

module Presenter
  module ControllerHelper
    def present(object, presenter_class = nil)
      ClassDetector.presenter_class(object).new(object, view_context)
    end
  end
end