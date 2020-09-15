
var f_assigned_to = false;
var f_field1      = false; //От Кого

$(document).ready(function() {

  $('#issue_parent_issue_id').keyup(function() {
      $('#issue_priority_id').closest('p').hide();
  });


  function getTreeIssues(issue_id) {
    $.ajax({
        type: "GET",
        beforeSend: function(request) {
          request.setRequestHeader("X-Redmine-API-Key", "bf506c99ba7b5e884b1c4fd758c9cef98614be97");
          //request.setRequestHeader("X-Redmine-API-Key", "296e565652d18323cabd81389dd2a9223a8f2046");
        },
        url: "/redmine/issues.json",
        //url: "/issues.json",
        data: "issue_id=" + issue_id,
        processData: false,
        success: function(data) {
          if(typeof(data.issues[0]) != "undefined" && data.issues[0] !== null) {

            if(typeof(data.issues[0].assigned_to) != "undefined" && data.issues[0].assigned_to !== null) //есть назначенный
              f_assigned_to = true;

            if(typeof(data.issues[0].custom_fields) != "undefined" && data.issues[0].custom_fields !== null) {

              $.each(data.issues[0].custom_fields, function(i, custom_field) {
                if ((custom_field.id == 29) && (custom_field.value != ""))
                  f_field1 = true;
              });
            }
            
            if(typeof(data.issues[0].parent) != "undefined" && data.issues[0].parent !== null && ((!f_assigned_to) || (!f_field1))) //есть родитель и нет назначенного
              getTreeIssues(data.issues[0].parent.id);
            else
              if (f_assigned_to && f_field1) {
                $('#issue_priority_id').attr("disabled", true); 
                $('[name="issue[custom_field_values][29]"]').attr("disabled", true);
                $('[name="issue[custom_field_values][29]"]').attr("disabled", true);
                $('#issue_custom_field_values_31').attr("disabled", true); 
              }  
          }
      }
    });
  }

  if ($('#issue_parent_issue_id').val() != '') {

    var issue_id = $('#issue_parent_issue_id').val();
    if ((issue_id != '') && (issue_id != "undefined"))
      getTreeIssues(issue_id);
    
  } 



});
