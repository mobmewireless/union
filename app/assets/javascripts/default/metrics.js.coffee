metrics_initialization = ->
  $('#completed_cards_datatable').dataTable({
    aoColumnDefs: [
      { bSearchable: false, aTargets: [ 3, 4 ] },
      { bSortable: false, aTargets: [ 1, 3, 4 ] },
    ],
    aaSorting: []
  });

$ -> metrics_initialization()
$(document).on('page:load', metrics_initialization)
