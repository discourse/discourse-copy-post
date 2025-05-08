# frozen_string_literal: true

require_relative "page_objects/components/copy_post_button"

RSpec.describe "Copy post spec - anonymous", system: true do
  fab!(:category)
  fab!(:topic) { Fabricate(:topic, category: category) }
  fab!(:post) { Fabricate(:post_with_long_raw_content, topic: topic) }
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }

  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:copy_post_button) { PageObjects::Components::CopyPostButton.new }
  let!(:theme_component) { upload_theme_component }

  context "when allowed groups is set to everyone group and user is logged out" do
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
