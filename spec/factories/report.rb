FactoryGirl.define do
  factory :report do
    report_type Report::TYPE_BURNDOWN
    data { { new: 5, wip: 3 }.with_indifferent_access }
  end
end
