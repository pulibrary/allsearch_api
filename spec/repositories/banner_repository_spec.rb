# frozen_string_literal: true

require 'rack_helper'

RSpec.describe BannerRepository do
  it 'can get a banner' do
    banner_repo = described_class.new Rails.application.config.rom
    banner = banner_repo.banners.first
    expect(banner.dismissible).to be true
  end

  describe '#modify' do
    after do
      banner_repo = described_class.new Rails.application.config.rom
      banner_repo.modify(text: '')
    end

    it 'modifies an existing banner if it exists' do
      banner_repo = described_class.new Rails.application.config.rom
      expect(banner_repo.banners.first.text).to eq ''

      banner_repo.modify(text: 'Dogs! Cats!')

      expect(banner_repo.banners.first.text).to eq 'Dogs! Cats!'
    end

    it 'updates the updated_at timestamp' do
      banner_repo = described_class.new Rails.application.config.rom

      expect do
        allow(Time).to receive(:now).and_return Time.utc(2020, 1, 1)
        banner_repo.modify(text: 'Old banner')
        expect(banner_repo.banners.first.updated_at).to eq Date.new(2020, 1, 1)

        allow(Time).to receive(:now).and_return Time.utc(2050, 1, 1)
        banner_repo.modify(text: 'New banner')
        expect(banner_repo.banners.first.updated_at).to eq Date.new(2050, 1, 1)
      end.not_to(change { banner_repo.banners.first.created_at })
    end

    it 'creates a new banner if none exists' do
      banner_repo = described_class.new Rails.application.config.rom
      banner_repo.delete
      expect(banner_repo.banners.count).to eq 0

      banner_repo.modify(text: 'Dogs! Cats!')

      expect(banner_repo.banners.first.text).to eq 'Dogs! Cats!'
    end

    it 'updates the updated_at and created_at timestamps' do
      banner_repo = described_class.new Rails.application.config.rom
      banner_repo.delete

      allow(Time).to receive(:now).and_return Time.utc(2020, 1, 1)
      banner_repo.modify(text: 'Old banner')
      expect(banner_repo.banners.first.updated_at).to eq Date.new(2020, 1, 1)
      expect(banner_repo.banners.first.created_at).to eq Date.new(2020, 1, 1)
    end
  end
end
