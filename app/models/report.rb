class Report < ActiveRecord::Base
  attr_accessible :report_type, :data, :owner

  belongs_to :owner, polymorphic: true

  TYPE_BURNDOWN = 'burndown'

  serialize :data, ActiveSupport::HashWithIndifferentAccess

  class << self

    def burndown!
      Board.subscribed.each do |board|
        new_count = board.cards_with_status(Card::STATUS_NEW, exclude_discarded: true).count
        wip_count = board.cards_with_status(Card::STATUS_WIP, exclude_discarded: true).count

        create!(
          report_type: TYPE_BURNDOWN,
          data: {
            new: new_count,
            wip: wip_count
          }.with_indifferent_access,
          owner: board
        )
      end
    end

    def burndown_report(board, since_time: 30.days.ago)
      burndown_report = { new: {}, wip: {} }

      # Add reports from since_time.
      board.reports.where(report_type: TYPE_BURNDOWN).where(
        'created_at >= :since_time',
        since_time: since_time
      ).each do |report|
        burndown_report[:new][report.created_at] = report.data[:new]
        burndown_report[:wip][report.created_at] = report.data[:wip]
      end

      # Add the latest data
      burndown_report[:new][Time.now] = board.cards_with_status(Card::STATUS_NEW, exclude_discarded: true).count
      burndown_report[:wip][Time.now] = board.cards_with_status(Card::STATUS_WIP, exclude_discarded: true).count

      burndown_report
    end
  end
end
