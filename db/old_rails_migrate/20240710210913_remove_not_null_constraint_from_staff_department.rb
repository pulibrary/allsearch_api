class RemoveNotNullConstraintFromStaffDepartment < ActiveRecord::Migration[7.1]
  def up
    change_column_null :library_staff_records, :department, true
  end

  def down
    change_column_null :library_staff_records, :department, false
  end
end
