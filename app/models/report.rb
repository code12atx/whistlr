class Report < ActiveRecord::Base
  include Validations::UserCreated

  strip_attributes

  has_many :participant_joins, class_name: "Report::Participant::Join", inverse_of: :report
  has_many :participants, class_name: "Report::Participant", through: :participant_joins
  has_many :officials, class_name: "Official::Master", through: :participants, source: :reportable, source_type: "Official"
  has_many :organizations, class_name: "Organization::Master", through: :participants, source: :reportable, source_type: "Organization"
  has_many :policies, class_name: "Policy::Master", through: :participants, source: :reportable, source_type: "Policy"
  has_many :products, class_name: "Product::Master", through: :participants, source: :reportable, source_type: "Product"
  has_many :evidence_joins, class_name: "Report::Evidence::Join", inverse_of: :report
  has_many :evidence, class_name: "Report::Evidence", through: :evidence_joins
  has_many :responses, class_name: "Report::Response"

  validates :summary, presence: true, length: {maximum: 140}
  validates :description, length: {maximum: 2500}

  accepts_nested_attributes_for :participant_joins
  accepts_nested_attributes_for :evidence_joins

  #after_save :adjust_reportable_stats

  def name
    summary
  end

  def create_response(params)
    value = params[:value]
    response = Report::Response.where(user: params[:user],
     report_id: self.id).first_or_initialize(value: value)
    Report::Response.create_update_or_destroy_response(response, value)
  end

private

  def adjust_reportable_stats
    participants.each do |participant|
      approved_reports_count = participant.reportable.approved_reports.count
      reportable_controversy = approved_reports_count > 0 ? participant.reportable.approved_reports.sum(:controversy)/approved_reports_count : 0
      participant.reportable.update_columns(
        controversy: reportable_controversy,
        favor: participant.reportable.collective_opinion,
        report_count: participant.reportable.approved_reports.count)
    end
  end

end
