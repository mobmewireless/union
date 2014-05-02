jobs_table_initialization = ->
  $.datepicker.regional[""].dateFormat = 'yy/mm/dd'
  $.datepicker.setDefaults($.datepicker.regional[''])

  jobs_datatable = $('#jobs_datatable')

  jobs_datatable.dataTable({
    sDom: "rt<'row'<'col-sm-6 col-xs-12'i><'col-sm-6 col-xs-12'p>>",
    bProcessing: true,
    bServerSide: true,
    bSort: false,
    sAjaxSource: jobs_datatable.data('source')
  }).columnFilter(
    {
      sPlaceHolder: "head:before",
      aoColumns: [ null,
        null,
        { type: "text" },
        { type: "text" },
        { type: "text" },
        { type: "date-range" },
        { type: "select", values: ['Success', 'Failure', 'Cancelled'] }
      ]
    }
  )

  dataTableDynamicColumnNumbers = {
    'Project': 2,
    'Deployment': 3,
    'Who?': 4
  }

  myTable = $('#jobs_datatable').dataTable()

  $('input.text_filter')
    .unbind('keyup')
    .bind 'keyup', (e) ->
      if (e.keyCode != 13)
        return

      myTable.fnFilter($(this).val(), dataTableDynamicColumnNumbers[$(this)[0].getAttribute('value')])

$ jobs_table_initialization
$(document).on 'page:load', jobs_table_initialization
