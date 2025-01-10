import Component from '@glimmer/component';
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { clipboardCopy } from "discourse/lib/utilities";
import discourseLater from "discourse-common/lib/later";

export default class CopyPostButton extends Component {
  static hidden() {
    return false;
  }

  @tracked icon = "far-copy";

  @action
  async copyPost() {
    const cookedPost = this.args.post.cooked;
    const copyType = settings.copy_type;
    const postContents = copyType === "html" ? cookedPost : await this.fetchRawPost(this.args.post.id);

    if (!postContents) {
      return;
    }

    try {
      this.icon = "check";
      await clipboardCopy(postContents);
    } catch (error) {
      popupAjaxError(error);
    } finally {
      discourseLater(() => {
        this.icon = "far-copy";
      }, 2000);
    }
  }

  async fetchRawPost(postId) {
    try {
      const { raw } = await ajax(`/posts/${postId}.json`);
      return raw;
    } catch (error) {
      popupAjaxError(error);
    }
  }

  <template>
    <DButton
      class="post-action-menu__copy-post btn-flat"
      @title={{themePrefix "title"}}
      @icon={{this.icon}}
      @action={{this.copyPost}}
      ...attributes
    />
  </template>
}