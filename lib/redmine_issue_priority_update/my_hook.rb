module Redmine_issue_priority_update
  module Hooks
    class ControllerIssuesEditBeforeSaveHook < Redmine::Hook::ViewListener

      def get_true_parent(issue_id)
        parent = false
        issue = Issue.find(issue_id)
        if (not issue.nil?)
          if (not issue.assigned_to_id.nil?)
            issue.custom_values.each do |custom_value|
              if ((custom_value.custom_field_id == 6) && (not custom_value.value.empty?))
                parent = issue
              end
            end
          end
          if ((issue.parent_id.present?) && (parent == false))
            parent = get_true_parent(issue.parent_id)
          end
        end
        return parent    
      end  

      def controller_issues_new_before_save(context={})
        return ''
      end

      def controller_issues_new_after_save(context={})
        issue = Issue.find(context[:issue].id)
        if (not issue.nil?)
          if (not issue.parent_id.nil?)
            true_parent = get_true_parent(issue.parent_id)
            if (not true_parent.nil?)
              custom_values = get_custom_values(true_parent)
              updateIssue(issue.id, true_parent.priority_id, custom_values)
            end
          end
        end
        
        return ''
      end

      def updateIssue(issue_id, priority_id, custom_values)
        Issue.transaction do
          conn = Issue.connection
          Rails.logger.info "UPDATE issues SET priority_id=#{priority_id} WHERE id=#{issue_id}"
          conn.execute("UPDATE issues SET priority_id=#{priority_id} WHERE id=#{issue_id}")
          conn.execute("DELETE FROM custom_values WHERE customized_type='Issue' AND customized_id=#{issue_id} AND (custom_field_id=7 OR custom_field_id=6)")
          conn.execute("INSERT INTO custom_values (customized_type, customized_id, custom_field_id, value) VALUES ('Issue', '#{issue_id}', 6, '#{custom_values['value1']}')")
          custom_values['value2'].each do |custom_value|
            conn.execute("INSERT INTO custom_values (customized_type, customized_id, custom_field_id, value) VALUES ('Issue', '#{issue_id}', 7, '#{custom_value}')")
          end
        end  
      end

      def update_childs(issue_id, priority_id, custom_values)
        Issue.where('parent_id = ?', issue_id).each do |issue|
            updateIssue(issue.id, priority_id, custom_values)
            update_childs(issue.id, priority_id, custom_values)
        end    
        return ''
      end

      def get_custom_values(issue)
        result = {"value1"=>'', "value2"=>[]}
        issue.custom_values.each do |custom_value|
          if ((custom_value.custom_field_id == 6) && (not custom_value.value.empty?))
            result["value1"] = custom_value.value
          end
          if ((custom_value.custom_field_id == 7) && (not custom_value.value.empty?))
            result["value2"].append(custom_value.value)
          end
        end 
        return result
      end

      def controller_issues_edit_after_save(context={})

        Rails.logger.info "find issue"

        issue = Issue.find(context[:issue].id)
        if (not issue.nil?)
          if (not issue.assigned_to_id.nil?)
            custom_values = get_custom_values(issue)
            if (not custom_values['value1'].empty?)
              update_childs(context[:issue].id, issue.priority_id, custom_values)
            end
          end
        end
        return ''
      end

      alias_method :controller_issues_bulk_edit_before_save, :controller_issues_new_after_save

    end

    
    class Hooks < Redmine::Hook::ViewListener
      render_on :view_issues_show_description_bottom, :partial => 'hooks/issue_priority_update/view_issues_show_description_bottom'
    end


  end




end
