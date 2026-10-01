import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import discourseLater from "discourse/lib/later";
import { clipboardCopy, clipboardCopyAsync } from "discourse/lib/utilities";

export default class CopyPostButton extends Component {
  static hidden() {
    return false;
  }

  @tracked icon = "far-copy";

  @action
  async copyPost() {
    const copyType = settings.copy_type;

    try {
      if (copyType === "html") {
        await clipboardCopy(this.args.post.cooked);
      } else {
        await clipboardCopyAsync(async () => {
          const { raw } = await ajax(`/posts/${this.args.post.id}.json`);
          return new Blob([raw], { type: "text/plain" });
        });
      }

      this.icon = "check";
    } catch (error) {
      popupAjaxError(error);
    } finally {
      discourseLater(() => {
        this.icon = "far-copy";
      }, 2000);
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
