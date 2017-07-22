
$(function() {
  window.addEventListener('message', function(event) {
      if (event.data.type == "createComponent") {
        // " + event.data.balise + " id='" + event.data.id + "' class='" + event.data.class + "' style='" + element.data.css + "'>" + event.data.content + "</" + event.data.balise + "
        var el = $(event.data.html);

        $(event.data.parent).append(el)
        el.attr("id", event.data.id)
        $("#" + event.data.id).on("click", function(){
          $.post('http://interface/click', JSON.stringify({id: event.data.id}));
        });
        $("#" + event.data.id).on("change", function(){

          $.post('http://interface/change', JSON.stringify({
            id: event.data.id,
            content: $("#" + event.data.id).text(),
            value: $("#" + event.data.id).val()
          }));
        });

        $("#" + event.data.id).change();
      } else if (event.data.type == "deleteComponent") {
        $("#" + event.data.id).remove();
      } else if (event.data.type == "SetComponentAttribute"){
        $("#" + event.data.id).attr(event.data.attributeName, event.data.attributeValue)
      }
  });
});
