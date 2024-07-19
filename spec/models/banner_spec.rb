# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe Banner do
  let(:banner) { described_class.first }

  it 'can be instantiated' do
    expect(banner).to be_an_instance_of(described_class)
  end

  it 'has the expected defaults' do
    expect(banner.text).to eq('')
    expect(banner.display_banner).to be(false)
    expect(banner.alert_status).to eq('info')
    expect(banner.dismissible).to be(true)
    expect(banner.autoclear).to be(false)
  end

  it 'has an as_json method' do
    expect(banner.as_json).to be_an_instance_of(Hash)
    expect(banner.as_json(except: [:id, :created_at, :updated_at]).keys)
      .to contain_exactly('text', 'display_banner', 'alert_status',
                          'dismissible', 'autoclear')
  end

  it 'can be updated' do
    banner.text = 'some other text'
    banner.save!
    expect(banner.text).to eq('some other text')
  end

  it 'only allows valid alert statuses' do
    expect do
      banner.alert_status = 'warning'
      banner.save!
    end.to change(banner, :alert_status)

    expect do
      banner.alert_status = 'potato'
      banner.save!
    end.to raise_error(ArgumentError, /not a valid alert_status/)
  end

  it 'can be updated to include html' do
    banner.text = '<h2>This is a big heading about an important thing</h2><p>It includes a <a href="https://www.example.com">link</a></p>'
    banner.save!
    expect(banner.text).to eq('<h2>This is a big heading about an important thing</h2><p>It includes a <a href="https://www.example.com">link</a></p>')
  end

  context 'when updated from the rake task' do
    context 'with four arguments' do
      let(:args) { Rake::TaskArguments.new(%w[text alert_status dismissible autoclear], ['<a href="https://www.example.com">a is a sentence</a>', 'warning', 'false', 'true']) }

      it 'can be updated using a rake task' do
        banner.rake_update(args)
        expect(banner.reload.text).to eq('<a href="https://www.example.com">a is a sentence</a>')
        expect(banner.alert_status).to eq('warning')
        expect(banner.dismissible).to be false
        expect(banner.autoclear).to be true
      end
    end

    context 'with two arguments' do
      let(:args) { Rake::TaskArguments.new(%w[text alert_status], ['<a href="https://www.example.com">a is a sentence</a>', 'warning']) }

      it 'can be updated using a rake task' do
        banner.rake_update(args)
        expect(banner.reload.text).to eq('<a href="https://www.example.com">a is a sentence</a>')
        expect(banner.alert_status).to eq('warning')
      end
    end

    context 'with one argument' do
      let(:args) { Rake::TaskArguments.new(%w[text], ['different text argument']) }

      it 'can be updated using a rake task' do
        banner.rake_update(args)
        expect(banner.reload.text).to eq('different text argument')
        expect(banner.alert_status).to eq('info')
      end
    end
  end
end
