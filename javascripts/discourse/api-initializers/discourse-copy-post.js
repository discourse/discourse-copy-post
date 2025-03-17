import { apiInitializer } from "discourse/lib/api";
import { AUTO_GROUPS } from "discourse/lib/constants";
import CopyPostButton from "../components/copy-post-button";

export default apiInitializer("2.0.0", (api) => {
  const currentUser = api.getCurrentUser();
  const currentUserGroupIds = currentUser?.groups.map((group) => group.id);
  const allowedGroups = settings.copy_button_allowed_groups;
  const allowedGroupIds = allowedGroups.split("|").map(Number);
  const userNotAllowed = !allowedGroupIds.some(
    (groupId) =>
      currentUserGroupIds?.includes(groupId) ||
      groupId === AUTO_GROUPS.everyone.id
  );

  if (userNotAllowed) {
    return;
  }

  api.registerValueTransformer("post-menu-buttons", ({ value: dag }) => {
    dag.add("copy-post", CopyPostButton);
  });
});
