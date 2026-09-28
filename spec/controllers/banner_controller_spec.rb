# frozen_string_literal: true

require 'spec_helper'

MockBanner = Data.define(:banner) { def as_json = banner.to_json }

describe BannerController do
  it 'gets data from the banner repo' do
    controller = described_class.new(banner_repo: [MockBanner.new({ text: 'hello!  welcome to our site!' })])
    response_body = controller.call({})[2]
    expect(response_body.join).to include 'hello!  welcome to our site!'
  end
end
