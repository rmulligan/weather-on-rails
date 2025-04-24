# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#page_name' do
    around do |example|
      orig = ENV['PAGE_NAME']
      example.run
      ENV['PAGE_NAME'] = orig
    end

    it 'returns default when PAGE_NAME is not set' do
      ENV.delete('PAGE_NAME')
      expect(helper.page_name).to eq('Weather Lookup')
    end

    it 'returns the value of PAGE_NAME when set' do
      ENV['PAGE_NAME'] = 'My Weather'
      expect(helper.page_name).to eq('My Weather')
    end
  end
end
