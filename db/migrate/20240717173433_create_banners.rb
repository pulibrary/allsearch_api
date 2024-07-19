class CreateBanners < ActiveRecord::Migration[7.1]
  def change
    create_table :banners do |t|
      t.text :text, default: ''
      t.boolean :display_banner, default: false
      t.integer :alert_status, default: 1
      t.boolean :dismissible, default: true
      t.boolean :autoclear, default: false

      t.timestamps
    end

    def create_banner_if_none_exists
      return Rails.logger.info('Already have a banner object, update that one') if Banner.count >= 1
    
      Banner.create!
    end
    
    create_banner_if_none_exists
  end
end
