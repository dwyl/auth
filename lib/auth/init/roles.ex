defmodule Auth.InitRoles do

  def create_default_roles do
    roles =  [
      %{
        name: "superadmin", 
        desc: "With great power comes great responsibility", 
        person_id: 1,
        # id: 1,
        permissions: "grant_admin_role"
      },
      %{
        name: "admin", 
        desc: "Can perform all system administration tasks", 
        person_id: 1,
        # id: 2,
        permissions: "manage_people, grant_non_admin_role"
      },
      %{
        name: "moderator", 
        desc: "Can view and neutrally moderate any content. Can ban rule-breakers. Cannot delete.", 
        person_id: 1,
        # id: 3,
        permissions: "edit_any_content, lock_content, unpublish_content, ban_rule_breaking_people, view_deleted"
      },
      %{
        name: "creator", 
        desc: "Can create any content. Can edit and delete their own content.", 
        person_id: 1,
        # id: 4,
        permissions: "create_content, upload_images, edit_own_content, delete_own_content, invite_people"
      },
      %{
        name: "commenter", 
        desc: "Can comment on content where commenting is available.", 
        person_id: 1,
        # id: 5,
        permissions: "comment, flag_comments, flag_content"
      },
      %{
        name: "subscriber", 
        desc: "Subscribes for updates e.g. newsletter or content from a specific person. Cannot comment until verified.", 
        person_id: 1,
        # id: 6,
        permissions: "subscribe, give_feedback"
      },
      %{
        name: "banned", 
        desc: "Can still login to see their content but cannot perform any other action.", 
        person_id: 1,
        # id: 7,
        permissions: "view_content, view_profile, delete_own_content, delete_own_profile"
      },
      %{
        name: "app_admin", 
        desc: "Can manage their own App(s).", 
        person_id: 1,
        # id: 8,
        permissions: "manage_own_apps, create_content, upload_images, edit_own_content, delete_own_content, invite_people"
      }
    ]
    Enum.each(roles, fn role ->
      Auth.Role.upsert_role(role)
    end)
  end
end