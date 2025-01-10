import { apiInitializer } from "discourse/lib/api";
import CopyPostButton from "../components/copy-post-button";

export default apiInitializer("2.0.0", (api) => {
  const currentUser = api.getCurrentUser();
  const currentUserGroupIds = currentUser.groups.map((group) => group.id);
  const allowedGroups = settings.copy_button_allowed_groups;
  const allowedGroupIds = allowedGroups.split("|").map(Number);
  const userNotAllowed = !allowedGroupIds.some((groupId) =>
    currentUserGroupIds.includes(groupId)
  );

  if (userNotAllowed) {
    return;
  }

  api.registerValueTransformer("post-menu-buttons", ({ value: dag }) => {
    dag.add("copy-post", CopyPostButton);
  });
});
