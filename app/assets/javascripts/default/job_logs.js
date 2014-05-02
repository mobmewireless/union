var scroll_to_bottom = function() { $(window).scrollTop(document.body.scrollHeight) };
var scroll_to_top = function() { $(window).scrollTop(0) };
var at_bottom_of_page = function() { return ($(window).scrollTop() == $(document).height() - $(window).height()) };

function refresh_logs(job_id) {
  var start = $('#start');
  var stop = $('#stop');
  var spinner = $('#jobs_spinner');

  var milliseconds = 2000;
  var id = null;

  var update = function() {
    var continue_updating = true;

    id = setInterval(function(){
      if(continue_updating) {
        continue_updating = false;

        $.ajax("/jobs/" + job_id + '/logs', {
          success: function(response) {

            var bottom = at_bottom_of_page();

            $('#logs').html(response.lines.join("<br/>"));

            if (bottom) {
              scroll_to_bottom();
            }

            if(response.complete == false) {
              continue_updating = true;
            } else {
              stop.toggle(); start.toggle(); spinner.toggle(); clearInterval(id);
            }
          }
        });
      }
    }, milliseconds);
  };

  start.click(function() { start.toggle(); stop.toggle(); spinner.toggle(); update(); });
  stop.click(function(){ stop.toggle(); start.toggle(); spinner.toggle(); clearInterval(id); });

  update();
}

$(document).ready(function() {
  var job_id = $("span#job_id").attr('data-id');

  if(typeof(job_id) != 'undefined') {
    refresh_logs(job_id);
  }
});
