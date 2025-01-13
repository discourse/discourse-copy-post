import { click, focus, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { AUTO_GROUPS } from "discourse/lib/constants";
import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";

acceptance("Copy Post", function (needs) {
  needs.user({
    groups: [AUTO_GROUPS.trust_level_1],
  });

  needs.pretender((server, helper) => {
    server.get("/posts/398.json", () => {
      return helper.response({
        raw: "Any plans to support localization of UI elements, so that I (for example) could set up a completely German speaking forum?",
      });
    });
  });

  test("Copy post contents - markdown", async function (assert) {
    settings.copy_type = "markdown";
    const copyButtonQuery =
      "#post_1 .post-controls .post-action-menu__copy-post";

    await visit("/t/internationalization-localization/280");
    assert.ok(exists(copyButtonQuery), "copy post button is visible");
    await focus(copyButtonQuery);
    await click(copyButtonQuery);
    const cookedPost = document.querySelector("#post_1 .cooked").innerText;
    const clipboard = await navigator.clipboard.readText();
    assert.equal(
      clipboard.replace(/\s+/g, " ").trim(),
      cookedPost.replace(/\s+/g, " ").trim(),
      "post contents were correctly copied to the clipboard"
    );
  });

  test("Copy post contents - HTML", async function (assert) {
    settings.copy_type = "html";
    const copyButtonQuery =
      "#post_1 .post-controls .post-action-menu__copy-post";

    await visit("/t/internationalization-localization/280");
    assert.ok(exists(copyButtonQuery), "copy post button is visible");
    await focus(copyButtonQuery);
    await click(copyButtonQuery);
    const cookedPost = document.querySelector("#post_1 .cooked p").innerHTML;
    const clipboard = await navigator.clipboard.readText();
    assert.equal(
      clipboard,
      `<p>${cookedPost}</p>`,
      "post contents were correctly copied to the clipboard"
    );
  });
});
