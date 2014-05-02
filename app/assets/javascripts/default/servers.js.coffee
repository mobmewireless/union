servers_initialization = ->
  servers_datatable = $('#servers_datatable')

  servers_datatable.dataTable({
    bProcessing: true,
    bServerSide: true,
    bSort: false,
    sAjaxSource: servers_datatable.data('source'),
    fnInitComplete: ->
      this.fnAdjustColumnSizing(true)
  })

  servers_datatable_filter_input = $('#servers_datatable_filter input')

  servers_datatable_filter_input.unbind();
  servers_datatable_filter_input.bind 'keyup', (e) ->
    if e.keyCode == 13
      servers_datatable.fnFilter this.value

$ -> servers_initialization()
$(document).on('page:load', servers_initialization)
