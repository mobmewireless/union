projects_initialization = ->
  projects_datatable = $('#projects_datatable')

  projects_datatable.dataTable({
    bProcessing: true,
    bServerSide: true,
    bSort: false,
    sAjaxSource: projects_datatable.data('source'),
    aoColumns: [
      {},
      {},
      { sWidth: '56px' },
      { sWidth: '56px' },
      { sWidth: '76px' }
    ],
    fnServerParams: (aoData) ->
      aoData.push { name: 'not_deployed_for', value: projects_datatable.data('filter')}
    fnInitComplete: ->
      this.fnAdjustColumnSizing(true)
  });

  projects_datatable_filter_input = $('#projects_datatable_filter input')

  projects_datatable_filter_input.unbind();
  projects_datatable_filter_input.bind 'keyup', (e) ->
    if e.keyCode == 13
      projects_datatable.fnFilter this.value

  # When the create/update button is pressed, set its state to loading and remove any errors.
  $("form#create_or_edit_project").submit ->
    $("#projects_submit").button('loading');
    $("div.control-group").removeClass("error");
    $("span.help-inline").each (idx, el) -> el.innerHTML = ""

  # When an error occurs, alert the user.
  $('#create_or_edit_project').bind 'ajax:error', ->
    $('#projects_submit').html("Failure!")
    $('#projects_submit').removeClass('btn-primary')
    $('#projects_submit').addClass('btn-danger')

    $('#projects_create_or_edit_alert').html '<div class="alert alert-error alert-block hide">' +
    '<button type="button" class="close" data-dismiss="alert">×</button>' +
    '<h4>HTTP 500 Error</h4>' +
    'The AJAX request to create the project has failed. It\'s likely that the Git URL that was supplied is incorrect. Please check access to the URL, and config file in the repository. Close this alert to acknowledge this message, and try again.'

    # Display the alert.
    $('.alert-error').slideDown();

    # Reset the button once the alert has closed.
    $('.alert-error').bind('closed', ->
      $('#projects_submit').button('reset');
      $('#projects_submit').removeClass('btn-danger');
      $('#projects_submit').addClass('btn-primary');
    )

# Do initialization stuff.
$ -> projects_initialization()
$(document).on('page:load', projects_initialization)
