Sequel.migration do
  change do
    execute <<~SQL
      ALTER TABLE library_staff_records 
      ALTER COLUMN email DROP NOT NULL;
    SQL
  end
end
    