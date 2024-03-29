# frozen_string_literal: true

require 'spec_helper'
require 'seed_reaper/value_serializer'

describe SeedReaper::ValueSerializer do
  describe '#serialized' do
    let(:nullify) { false }
    subject { described_class.new(value).serialized(nullify: nullify) }

    context 'nil' do
      let(:value) { nil }

      it 'is "nil"' do
        is_expected.to eq "nil"
      end
    end

    context 'the integer value 24' do
      let(:value) { 24 }

      it 'is 24' do
        is_expected.to eq 24
      end
    end

    context 'the string "this thing"' do
      let(:value) { 'this thing' }

      it 'is %q{this thing}' do
        is_expected.to eq "%q{this thing}"
      end
    end

    context 'the string "this "thing""' do
      let(:value) { 'this "thing"' }

      it 'is %q{this "thing"}' do
        is_expected.to eq '%q{this "thing"}'
      end
    end

    context 'the integer value 24 with nullify: true' do
      let(:nullify) { true }
      let(:value) { 24 }

      it 'is "nil"' do
        is_expected.to eq 'nil'
      end
    end

    context 'the string value "things {more} things"' do
      let(:value) { 'things {more} things' }

      it 'is %q{things \{more\} things}' do
        is_expected.to eq '%q{things \{more\} things}'
      end
    end
  end
end
