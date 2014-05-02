admin_refresh_projects_button_click = ->
  r = confirm 'Are you sure about that? Refreshing all projects will engage one worker for a considerable period of time.'

  if r == true
    $("#admin_refresh_projects_button").button('loading')
  else
   return false

admin_add_projects_button_click = ->
  $("#admin_add_projects_button").button('loading')

admin_orphaned_servers_delete_click = (server_id) ->
  $("#admin_server_" + server_id + "_delete_button").button('loading')

admin_orphaned_servers_delete_success = (server_id) ->
  delete_button = $("#admin_server_" + server_id + "_delete_button")

  delete_button.attr 'value', "Done!"
  delete_button.removeClass 'btn-danger'
  delete_button.addClass 'btn-success'

  remove_orphaned_server = ->
    $("#admin_orphaned_server_" + server_id + "_row").remove()

  setTimeout remove_orphaned_server, 1500

# Add button methods to the global scope.
window.admin_refresh_projects_button_click = admin_refresh_projects_button_click
window.admin_add_projects_button_click = admin_add_projects_button_click
window.admin_orphaned_servers_delete_click = admin_orphaned_servers_delete_click
window.admin_orphaned_servers_delete_success = admin_orphaned_servers_delete_success

admin_initialization = ->
  $("#admin_refresh_boards_button").click ->
    $(this).button('loading')

  $("#admin_orphaned_servers_table").dataTable {
    aoColumnDefs: [
      { bSearchable: false, aTargets: [ 1, 2 ] },
      { bSortable: false, aTargets: [ 1, 2 ] },
    ],
    aaSorting: []
  }

$ admin_initialization
$(document).on 'page:load', admin_initialization
