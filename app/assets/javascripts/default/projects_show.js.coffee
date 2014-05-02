projects_show_initialization = ->
  $('#project_deployments_datatable').dataTable {
    aoColumnDefs: [
      { bSearchable: false, aTargets: [ 1, 6 ] },
      { bSortable: false, aTargets: [ 1, 6 ] }
    ],
    aaSorting: []
  }

  $('#project_cards_datatable').dataTable {
    aoColumnDefs: [
      { bSearchable: false, aTargets: [ 3, 4 ] },
      { bSortable: false, aTargets: [ 1, 3, 4 ] },
    ],
    aaSorting: []
  }

# Do initialization stuff.
$ -> projects_show_initialization()
$(document).on('page:load', projects_show_initialization)
