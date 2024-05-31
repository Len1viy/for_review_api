class RenameUserIdToTeacherIdInCourses < ActiveRecord::Migration[7.1]
  def change
    rename_column :courses, :user_id, :teacher_id
  end
end
