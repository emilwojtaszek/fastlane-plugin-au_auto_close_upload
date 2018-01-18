module Fastlane
  module Helper
    class AuAutoCloseUploadHelper
      # class methods that you define here become available in your action
      # as `Helper::AuAutoCloseUploadHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the au_auto_close_upload plugin helper!")
      end
    end
  end
end
