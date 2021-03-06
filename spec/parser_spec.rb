require 'spec_helper'

describe Icalendar::Parser do
  subject { described_class.new source, false }
  let(:source) { File.read File.join(File.dirname(__FILE__), 'fixtures', fn) }

  describe '#parse' do
    context 'single_event.ics' do
      let(:fn) { 'single_event.ics' }

      it 'returns an array of calendars' do
        expect(subject.parse).to be_instance_of Array
        expect(subject.parse.count).to eq 1
        expect(subject.parse[0]).to be_instance_of Icalendar::Calendar
      end

      it 'properly splits multi-valued lines' do
        event = subject.parse.first.events.first
        expect(event.geo).to eq [37.386013,-122.0829322]
      end

      it 'saves params' do
        event = subject.parse.first.events.first
        expect(event.dtstart.ical_params).to eq('tzid' => ['US-Mountain'])
      end
    end
    context 'recurrence.ics' do
      let(:fn) { 'recurrence.ics' }
      it 'correctly parses the exdate array' do
        event = subject.parse.first.events.first
        ics = event.to_ical
        expect(ics).to match 'EXDATE;VALUE=DATE:20120323,20130323'
      end
    end
    context 'event.ics' do
      let(:fn) { 'event.ics' }

      before { subject.component = Icalendar::Event.new }

      it 'returns an array of events' do
        expect(subject.parse).to be_instance_of Array
        expect(subject.parse.count).to be 1
        expect(subject.parse[0]).to be_instance_of Icalendar::Event
      end
    end
  end

  describe '#parse with bad line' do
    let(:fn) { 'single_event_bad_line.ics' }

    it 'returns an array of calendars' do
      expect(subject.parse).to be_instance_of Array
      expect(subject.parse.count).to eq 1
      expect(subject.parse[0]).to be_instance_of Icalendar::Calendar
    end

    it 'properly splits multi-valued lines' do
      event = subject.parse.first.events.first
      expect(event.geo).to eq [37.386013,-122.0829322]
    end

    it 'saves params' do
      event = subject.parse.first.events.first
      expect(event.dtstart.ical_params).to eq('tzid' => ['US-Mountain'])
    end
  end

  describe 'missing date value parameter' do
    let(:fn) { 'single_event_bad_dtstart.ics' }

    it 'falls back to date type for dtstart' do
      event = subject.parse.first.events.first
      expect(event.dtstart).to be_kind_of Icalendar::Values::Date
    end
  end
end
