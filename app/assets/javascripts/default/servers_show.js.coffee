servers_show_initialization = ->
  $('#server_deployments_datatable').dataTable {
    aoColumnDefs: [
      { bSearchable: false, aTargets: [ 1, 6 ] },
      { bSortable: false, aTargets: [ 1, 6 ] }
    ],
    aaSorting: []
  }

  $('#server_cards_datatable').dataTable {
    aoColumnDefs: [
      { bSearchable: false, aTargets: [ 3, 4 ] },
      { bSortable: false, aTargets: [ 1, 3, 4 ] },
    ],
    aaSorting: []
  }

$ -> servers_show_initialization()
$(document).on('page:load', servers_show_initialization())
