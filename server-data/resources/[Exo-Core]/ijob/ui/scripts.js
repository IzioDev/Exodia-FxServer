$(document).ready(function(){
  var izio = false;
  function returnJob(job) {
    $.post('http://iJob/selectedJob', JSON.stringify({id: job}));
    $(".full-screen").hide()
    izio = true
  }

  $(document).keydown(function(e){ // é_é J'y suis arrivé !
    if (e.keyCode==27 && !izio )
    $(".full-screen").hide();
    izio = true
    $.post('http://iJob/close', JSON.stringify({}));
  });

  $("input").click(function() {
      //console.log($( this ).attr('id'));
      returnJob($( this ).attr('id'));
    });

  // Listen for NUI Events
  window.addEventListener('message', function(event){
    //console.log(event.data.action);
    var item = event.data;

    if (item.action == "open") {
      $(".full-screen").show();
      izio = false
    }
    else if (item.action == "close"){
      $(".full-screen").hide();
      izio = true
    }
  });
});