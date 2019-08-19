function changeToListViewActionSubmit() {
      // Option 'All Employees' selected
      if (document.getElementById('empl_list').value == "0") {
            $("#new").attr("action", "./pagelet-holiday-calendar-list-all.cxp");
            $("#new").submit();

      }
      // Option 'Individual Employee'
      else {
            $("#new").attr("action", "./pagelet-holiday-calendar-list-individual.cxp");
            $("#new").submit();
      }

}

function changeToGraphViewActionSubmit() {
      // Option 'All Employees' selected
      if (document.getElementById('empl_list').value == "0") {
            $("#new").attr("action", "./pagelet-holiday-calendar-timeline-all.cxp");
            $("#new").submit();
      }
      // Option 'Individual Employee'
      else {
            $("#new").attr("action", "./pagelet-holiday-calendar-timeline-individual.cxp");
            $("#new").submit();
      }

}