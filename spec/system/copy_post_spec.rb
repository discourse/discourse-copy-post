# frozen_string_literal: true

require_relative "page_objects/components/copy_post_button"

RSpec.describe "Copy post spec", system: true do
  fab!(:category)
  fab!(:topic) { Fabricate(:topic, category: category) }
  fab!(:post) { Fabricate(:post_with_long_raw_content, topic: topic) }
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }

  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:copy_post_button) { PageObjects::Components::CopyPostButton.new }
  let(:cdp) { PageObjects::CDP.new }
  let!(:theme_component) { upload_theme_component }

  before do
    sign_in(user)
    cdp.allow_clipboard
  end

  context "when using markdown mode" do
    before do
      theme_component.update_setting(:copy_type, "markdown")
      theme_component.save!
    end

    it "should copy the post with markdown" do
      topic_page.visit_topic(topic)
      expect(copy_post_button).to have_copy_post_button(post.post_number)
      copy_post_button.click_copy_post_button(post.post_number)
      cdp.clipboard_has_text?(post.raw)
    end

    it "shows success only after the clipboard write succeeds" do
      topic_page.visit_topic(topic)
      expect(copy_post_button).to have_copy_post_button(post.post_number)

      page.execute_script(<<~JAVASCRIPT)
        const clipboardPrototype = Object.getPrototypeOf(
          window.navigator.clipboard
        );

        window.__copyPostOriginalWrite = clipboardPrototype.write;

        clipboardPrototype.write = function () {
          document.documentElement.dataset.copyPostClipboardPending = "true";

          return new Promise((resolve) => {
            window.__copyPostResolveClipboard = resolve;
          });
        };
      JAVASCRIPT

      copy_post_button.click_copy_post_button(post.post_number)

      expect(page).to have_css("html[data-copy-post-clipboard-pending='true']")

      expect(copy_post_button).to have_no_success_icon(post.post_number)

      page.execute_script("window.__copyPostResolveClipboard()")

      expect(copy_post_button).to have_success_icon(post.post_number)
    ensure
      page.execute_script(<<~JAVASCRIPT)
        window.__copyPostResolveClipboard?.();

        const clipboardPrototype = Object.getPrototypeOf(
          window.navigator.clipboard
        );

        if (window.__copyPostOriginalWrite) {
          clipboardPrototype.write = window.__copyPostOriginalWrite;
        }

        delete window.__copyPostOriginalWrite;
        delete window.__copyPostResolveClipboard;
        delete document.documentElement.dataset.copyPostClipboardPending;
      JAVASCRIPT
    end

    it "starts the clipboard write before the raw post request finishes" do
      topic_page.visit_topic(topic)
      expect(copy_post_button).to have_copy_post_button(post.post_number)

      page.execute_script(<<~JAVASCRIPT)
        const clipboardPrototype = Object.getPrototypeOf(
          window.navigator.clipboard
        );

        window.__copyPostOriginalWrite = clipboardPrototype.write;

        clipboardPrototype.write = function (items) {
          document.documentElement.dataset.copyPostClipboardWriteStarted =
            "true";

          return window.__copyPostOriginalWrite.call(this, items);
        };
      JAVASCRIPT

      cdp.with_paused_request(%r{/posts/#{post.id}\.json}) do |request|
        page.execute_script(<<~JAVASCRIPT)
          document
            .querySelector(
              "#post_#{post.post_number} .post-controls .post-action-menu__copy-post"
            )
            .click();
        JAVASCRIPT

        request.wait

        expect(page).to have_css("html[data-copy-post-clipboard-write-started='true']")

        expect(copy_post_button).to have_no_success_icon(post.post_number)

        request.resume
      end

      expect(copy_post_button).to have_success_icon(post.post_number)
      cdp.clipboard_has_text?(post.raw)
    ensure
      page.execute_script(<<~JAVASCRIPT)
        const clipboardPrototype = Object.getPrototypeOf(
          window.navigator.clipboard
        );

        if (window.__copyPostOriginalWrite) {
          clipboardPrototype.write = window.__copyPostOriginalWrite;
        }

        delete window.__copyPostOriginalWrite;
        delete document.documentElement.dataset.copyPostClipboardWriteStarted;
      JAVASCRIPT
    end
  end

  context "when using html mode" do
    before do
      theme_component.update_setting(:copy_type, "html")
      theme_component.save!
    end

    it "should copy the post with html" do
      topic_page.visit_topic(topic)
      copy_post_button.click_copy_post_button(post.post_number)
      cdp.clipboard_has_text?(post.cooked)
    end
  end

  context "when user is not member of the allowed groups" do
    before do
      theme_component.update_setting(
        :copy_button_allowed_groups,
        Group::AUTO_GROUPS[:trust_level_4].to_s,
      )
      theme_component.save!
    end

    it "should not show the copy post button" do
      topic_page.visit_topic(topic)
      expect(copy_post_button).to have_no_copy_post_button(post.post_number)
    end
  end

  context "when user is a member of the allowed groups" do
    before do
      theme_component.update_setting(
        :copy_button_allowed_groups,
        Group::AUTO_GROUPS[:trust_level_1].to_s,
      )
      theme_component.save!
    end

    it "should show the copy post button" do
      topic_page.visit_topic(topic)
      expect(copy_post_button).to have_copy_post_button(post.post_number)
    end
  end

  context "when allowed groups is set to logged_in_users group" do
    before do
      theme_component.update_setting(
        :copy_button_allowed_groups,
        Group::AUTO_GROUPS[:logged_in_users].to_s,
      )
      theme_component.save!
    end

    it "should show the copy post button" do
      topic_page.visit_topic(topic)
      expect(copy_post_button).to have_copy_post_button(post.post_number)
    end
  end
end
