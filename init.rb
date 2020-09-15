require 'redmine'
require_dependency 'redmine_issue_priority_update/my_hook'

Redmine::Plugin.register :redmine_issue_priority_update do
  name 'Redmine Issue priority update'
  author 'Sergey Lapetov'
  description 'Auto update priority sub issues'
  version '0.0.1'
  url 'http://srv-dnp.argos.loc/gitlab/argosprogrammer/redmine_issue_priority_update'
end
