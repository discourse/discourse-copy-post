# frozen_string_literal: true

module PageObjects
  module Components
    class CopyPostButton < PageObjects::Components::Base
      POST_BUTTON_SELECTOR = ".post-controls .post-action-menu__copy-post"

      def click_copy_post_button(post_number)
        find("#post_#{post_number} #{POST_BUTTON_SELECTOR}").click
      end

      def has_copy_post_button?(post_number)
        page.has_css?("#post_#{post_number} #{POST_BUTTON_SELECTOR}")
      end

      def has_no_copy_post_button?(post_number)
        page.has_no_css?("#post_#{post_number} #{POST_BUTTON_SELECTOR}")
      end
    end
  end
end
