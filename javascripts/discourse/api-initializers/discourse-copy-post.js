import { apiInitializer } from "discourse/lib/api";
import { AUTO_GROUPS } from "discourse/lib/constants";
import CopyPostButton from "../components/copy-post-button";

function shouldRenderCopyButton(currentUser) {
  // Using resolve_group_membership on theme settings
  if (Object.hasOwn(settings, "user_in_copy_button_allowed_groups")) {
    return settings.user_in_copy_button_allowed_groups;
  }

  // Backwards compat, remove this once the user_in_X functionality
  // for theme settings is in core.
  const allowedGroupIds = settings.copy_button_allowed_groups
    .split("|")
    .filter(Boolean)
    .map(Number);

  if (!currentUser) {
    if (!allowedGroupIds.includes(AUTO_GROUPS.anonymous_users.id)) {
      return false;
    }
  }

  const currentUserGroupIds = currentUser.groups.map((group) => group.id);
  if (
    !allowedGroupIds.some(
      (groupId) =>
        currentUserGroupIds.includes(groupId) ||
        groupId === AUTO_GROUPS.everyone.id ||
        groupId === AUTO_GROUPS.logged_in_users.id
    )
  ) {
    return false;
  }

  return true;
}

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();

  if (shouldRenderCopyButton(currentUser)) {
    api.registerValueTransformer("post-menu-buttons", ({ value: dag }) => {
      dag.add("copy-post", CopyPostButton);
    });
  }
});
