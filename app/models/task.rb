class Task < ActiveRecord::Base
  attr_accessible :subject, :description, :priority, :project, :status, :type, :status_cd, :project_id, :assignee, :assignee_id, :creater, :creater_id, :checker, :checker_id

  belongs_to :project
  belongs_to :assignee, class_name: 'User', foreign_key: "assignee_id"
  belongs_to :checker, class_name: 'User', foreign_key: "checker_id"
  belongs_to :creater, class_name: 'User', foreign_key: "creater_id"

  STATUS = [:todo, :toreview, :done]
  TYPE = [:feature, :bug, :research]
  PRIORITY = [:regular, :high]

  as_enum :status, STATUS
  as_enum :type, TYPE
  as_enum :priority, PRIORITY

  after_save { project.check_status }

  scope :active, where('status_cd IN (?)', [statuses(:todo), statuses(:toreview)])
  STATUS.each do |status|
    scope status, where(status_cd: statuses(status))
  end

  validates_presence_of :subject, :priority_cd, :project_id, :status_cd, :type_cd

  def doing?
    todo? && assignee.present?
  end
end
