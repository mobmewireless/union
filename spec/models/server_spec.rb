require 'spec_helper'

describe Server do
  describe '.card_tags' do
    let!(:server_1) { create :server, hostname: 'SERVER_100' }
    let!(:server_2) { create :server, hostname: 'SERVER_L33T' }

    it 'returns hash mapping project names to ID-s' do
      expect(Server.card_tags).to eq({ 'SERVER_100' => { server_id: server_1.id }, 'SERVER_L33T' => { server_id: server_2.id } }.with_indifferent_access)
    end
  end

  describe '#time_to_repair' do
    let(:server) { create :server }
    let!(:card_1) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 1.hour.ago, completed_at: 10.minutes.ago }
    let!(:card_planned) { create :card, label: Card::LABEL_BUSINESS, servers: [server], created_at: 1.hour.ago, completed_at: 10.minutes.ago }
    let!(:card_2) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 1.day.ago, completed_at: 0.9.days.ago }
    let!(:card_3) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 1.1.weeks.ago, completed_at: 1.09.weeks.ago }
    let!(:card_4) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 4.weeks.ago, completed_at: 3.98.weeks.ago }

    it 'returns moving averages of time to repair' do
      mttr_moving_averages = server.time_to_repair(2.weeks.ago)
      expect(mttr_moving_averages[:point_values].length).to eq 3
      expect(mttr_moving_averages[:moving_averages].length).to eq 3
      expect(mttr_moving_averages[:point_values].keys[0]).to be_within(2).of(1.hour.ago)
      expect(mttr_moving_averages[:point_values].keys[1]).to be_within(2).of(1.day.ago)
      expect(mttr_moving_averages[:point_values].keys[2]).to be_within(2).of(1.1.weeks.ago)
      expect(mttr_moving_averages[:moving_averages].keys[0]).to be_within(2).of(1.hour.ago)
      expect(mttr_moving_averages[:moving_averages].keys[1]).to be_within(2).of(1.day.ago)
      expect(mttr_moving_averages[:moving_averages].keys[2]).to be_within(2).of(1.1.weeks.ago)
      expect(mttr_moving_averages[:point_values].values[0]).to be_within(2).of(3000)
      expect(mttr_moving_averages[:point_values].values[1]).to be_within(2).of(8640)
      expect(mttr_moving_averages[:point_values].values[2]).to be_within(2).of(6048)
      expect(mttr_moving_averages[:moving_averages].values[0]).to be_within(2).of(3000)
      expect(mttr_moving_averages[:moving_averages].values[1]).to be_within(2).of(5820)
      expect(mttr_moving_averages[:moving_averages].values[2]).to be_within(2).of(5896)
    end

    context 'when custom unit is specified' do
      it 'returns moving averages in custom unit' do
        mttr_moving_averages = server.time_to_repair(2.weeks.ago, unit: Server::TIME_UNIT_MINUTE)
        expect(mttr_moving_averages[:point_values].values[0]).to be_within(0.1).of(50)
        expect(mttr_moving_averages[:point_values].values[1]).to be_within(0.1).of(144)
        expect(mttr_moving_averages[:point_values].values[2]).to be_within(0.1).of(100.81)
        expect(mttr_moving_averages[:moving_averages].values[0]).to be_within(0.1).of(50)
        expect(mttr_moving_averages[:moving_averages].values[1]).to be_within(0.1).of(97)
        expect(mttr_moving_averages[:moving_averages].values[2]).to be_within(0.1).of(98.27)
      end
    end
  end

  describe '#time_between_failures' do
    let(:server) { create :server }
    let!(:card_1) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 1.hour.ago, completed_at: 10.minutes.ago }
    let!(:card_planned) { create :card, label: Card::LABEL_BUSINESS, servers: [server], created_at: 1.hour.ago, completed_at: 10.minutes.ago }
    let!(:card_2) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 1.day.ago, completed_at: 0.9.days.ago }
    let!(:card_3) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 1.1.weeks.ago, completed_at: 1.09.weeks.ago }
    let!(:card_4) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 4.weeks.ago, completed_at: 3.98.weeks.ago }
    let!(:card_5) { create :card, label: Card::LABEL_UNPLANNED, servers: [server], created_at: 8.weeks.ago, completed_at: 7.98.weeks.ago }

    it 'returns moving averages of time between failures' do
      mtbf_moving_averages = server.time_between_failures(6.weeks.ago)
      expect(mtbf_moving_averages[:point_values].length).to eq 3
      expect(mtbf_moving_averages[:moving_averages].length).to eq 3
      expect(mtbf_moving_averages[:point_values].keys[0]).to be_within(2).of(1.hour.ago)
      expect(mtbf_moving_averages[:point_values].keys[1]).to be_within(2).of(1.day.ago)
      expect(mtbf_moving_averages[:point_values].keys[2]).to be_within(2).of(1.1.weeks.ago)
      expect(mtbf_moving_averages[:moving_averages].keys[0]).to be_within(2).of(1.hour.ago)
      expect(mtbf_moving_averages[:moving_averages].keys[1]).to be_within(2).of(1.day.ago)
      expect(mtbf_moving_averages[:moving_averages].keys[2]).to be_within(2).of(1.1.weeks.ago)
      expect(mtbf_moving_averages[:point_values].values[0]).to be_within(2).of(74160)
      expect(mtbf_moving_averages[:point_values].values[1]).to be_within(2).of(572832)
      expect(mtbf_moving_averages[:point_values].values[2]).to be_within(2).of(1741824)
      expect(mtbf_moving_averages[:moving_averages].values[0]).to be_within(2).of(74160)
      expect(mtbf_moving_averages[:moving_averages].values[1]).to be_within(2).of(323496)
      expect(mtbf_moving_averages[:moving_averages].values[2]).to be_within(2).of(796272)
    end

    context 'when custom unit is specified' do
      it 'returns moving averages in custom unit' do
        mtbf_moving_averages = server.time_between_failures(6.weeks.ago, unit: Server::TIME_UNIT_DAY)
        expect(mtbf_moving_averages[:point_values].values[0]).to be_within(0.1).of(0.858)
        expect(mtbf_moving_averages[:point_values].values[1]).to be_within(0.1).of(6.63)
        expect(mtbf_moving_averages[:point_values].values[2]).to be_within(0.1).of(20.16)
        expect(mtbf_moving_averages[:moving_averages].values[0]).to be_within(0.1).of(0.858)
        expect(mtbf_moving_averages[:moving_averages].values[1]).to be_within(0.1).of(3.744)
        expect(mtbf_moving_averages[:moving_averages].values[2]).to be_within(0.1).of(9.216)
      end
    end
  end

  describe 'Logging validation' do
    context 'set logging as true' do
      let(:server_1) { create :server, logging: true }
      let(:server_2) { create :server, logging: true, login_user: 'deploy' }
      let(:server_3) { create :server, logging: true, login_user: 'deploy', port: 22 }

      it 'fails validation with no login_user' do
        expect { server_1 }.to raise_error(/Login user must be present/)
      end

      it 'fails validation with no port' do
        expect { server_2 }.to raise_error(/Port must be present/)
      end

      it 'passes with both login_user and port given' do
        expect(server_3.valid?).to be true
      end
    end
  end

  describe '#logs_and_cards_with_timestamp' do

    let(:server_log_1) { create :server_log }
    let(:server_log_2) { create :server_log, created_at: 4.days.ago }
    let(:server) { create :server, server_logs: [server_log_1, server_log_2] }
    let!(:card_1) { create :card, servers: [server] }
    let!(:card_2) { create :card, servers: [server], created_at: 4.days.ago }


    it 'returned hash contains timestamp to log mapping' do
      logs = server.logs_and_cards_with_timestamp(3.days.ago)
      expect(logs[:logs]).to eq({ server_log_1.timestamp => server_log_1.log.join(',') })
    end

    it 'returned hash contains timestamp to url mapping' do
      cards = server.logs_and_cards_with_timestamp(3.days.ago)
      expect(cards[:cards]).to eq({ card_1.created_at.to_i.to_s => "<a href=#{card_1.url}>Trello URL</a>" })
    end
  end
end
