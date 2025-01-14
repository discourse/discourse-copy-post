# frozen_string_literal: true

require_relative "page_objects/components/copy_post_button"

RSpec.describe "Copy post spec", system: true do
  fab!(:topic)
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

  context "when allowed groups is set to everyone group" do
    before do
      theme_component.update_setting(
        :copy_button_allowed_groups,
        Group::AUTO_GROUPS[:everyone].to_s,
      )
      theme_component.save!
    end

    it "should show the copy post button" do
      topic_page.visit_topic(topic)
      expect(copy_post_button).to have_copy_post_button(post.post_number)
    end
  end
end
