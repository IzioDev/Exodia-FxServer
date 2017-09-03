$(document).ready(function(){

    var actualDatas = null
    var selector = null

    function OpenMain(){
        $('#logo').show()
        $('#panel').show();
        $('#vehicules').hide();
        $('#citoyens').hide();
    }

    function CloseAll(){
        $('#panel').hide();
        $('#vehicules').hide();
        $('#citoyens').hide();
        $('#logo').hide()
    }

    function CheckCitizenForm(){
        var isValidated = false
        if ( ($("#lastname").val().length > 0 ) && ($("#firstname").val().length > 0 ) && ($("#matricule").val().length > 0 ) && ($("#age").val().length > 0 ) && ($("#adress").val().length > 0) && ($("#phoneNumber").val().length > 0 ) && ($("#permis").val().length > 0 ) && ($("#criminalRecord").val().length > 0 ) ){
            return true
        } else {
            return false
        }
    }

    function CheckCarForm(){
        var isValidated = false
        console.log($("#carModel").val().length)
        console.log($("#carColor").val().length)
        console.log($("#carDate").val().length)
        console.log($("#carPlates").val().length)
        console.log($("#carOwner").val().length)
        console.log($("#carAdress").val().length)
        console.log($("#carOthers").val().length)
        if ( ($("#carModel").val().length > 0 ) &&  ($("#carColor").val().length > 0 ) && ($("#carDate").val().length > 0) && ($("#carPlates").val().length > 0 ) && ($("#carOwner").val().length > 0 ) && ($("#carAdress").val().length > 0 ) && ($("#carOthers").val().length > 0 ) ){
            return true
        } else {
            return false
        }
    }

    function TreatResult(type, datas){
        if (type == "citizen"){
            if (datas == null){
                if (!($('#validationMessage').length)) {
                    $('.resultValidated').append("<div class='alert alert-danger' id='validationPoped'><center><p id='validationMessage'>Pas de résultat trouvé pour le nom rentré.</p></center></div>")
                } else {
                    $( "#validationMessage" ).text( "Pas de résultat trouvé pour le nom rentré." );
                }
            } else {
                SetTheTextFirstResultText(type, datas)
                $('#citoyenResultats').modal('show');
            }
        } else if (type == "vehicle") {
            if (datas == null){
                if (!($('#validationMessage').length)) {
                    $('.resultValidated').append("<div class='alert alert-danger' id='validationPoped'><center><p id='validationMessage'>Pas de résultat trouvé pour le nom rentré.</p></center></div>")
                } else {
                    $( "#validationMessage" ).text( "Pas de résultat trouvé pour le nom rentré." );
                }
            } else {
                SetTheTextFirstResultText(type, datas)
                $('#resultatsVehicule').modal('show');
            }
        }
    }

    function SetTheTextFirstResultText(type, datas){
        console.log(datas.infos)
        if (type == "citizen"){
            $( "#citizenFirstName" ).text( datas.infos.firstname );
            $( "#citizenLastName" ).text( datas.infos.lastname );
            $( "#citizenAge" ).text( datas.infos.age );
            $( "#citizenPermis" ).text( datas.infos.permis );
            $( "#citizenAdress" ).text( datas.infos.adress );
            $( "#citizenMatricule" ).text( datas.infos.matricule );
            $( "#creationDate" ).text( datas.infos.time );
            $( "#citizenNumberRecords" ).text( datas.note.length );
            $( "#citizenCriminalRecord" ).text( datas.infos.criminalRecord );
            $( "#citizenPhoneNumber" ).text( datas.infos.phoneNumber );
        } else if (type == "vehicle"){
            $( "#resultCarManufacturer" ).text( datas.infos.carManufacturer );
            $( "#resultCarModel" ).text( datas.infos.carModel );
            $( "#resultCarColor" ).text( datas.infos.carColor );
            $( "#resultCarTime" ).text( datas.infos.carDate );
            $( "#resultCarPlate" ).text( datas.infos.carPlate );
            $( "#resultCarOwner" ).text( datas.infos.carOwner );
            $( "#resultCarAdress" ).text( datas.infos.carAdress );
            $( "#resultCarOther" ).text( datas.note.carOthers );
        }
    }

    function SetTheSecondResultText(datas, type){
        if (type == "citizen"){
             $( "#numberResult" ).text("1 / " + datas.note.length)
             $('#actualNote').text(datas.note[0].text)
             $('#actualCreator').text(datas.note[0].creator)
             $('#previousNote').show();
             $('#nextNote').show();
        } else if (type == "vehicle"){

        }
    }

    function UpdateNoteText(selector, allDatas){
        $( "#numberResult" ).text(selector.toString() + " / " + allDatas.datas.note.length.toString())
        $('#actualNote').text(allDatas.datas.note[selector-1].text)
        $('#actualCreator').text(allDatas.datas.note[selector-1].creator)
    }

    /*creator = user.get('identifier'),
    access = user.get('job'),
    infos = data,
    new = true,
    id = #Records + 1,
    note = {}*/

    document.onkeydown = function (data) {
        if (data.which == 27 ) {
            $.post('http://icops/close', JSON.stringify({}));
        }
    };

    $('#previousNote').click(function(){
        if (selector != null){
            selector = selector - 1
            if (selector == 1){
                $('#previousNote').hide();
            } else if(selector + 1 == actualDatas.datas.note.length){
                $('#nextNote').show();
            }
            UpdateNoteText(selector, actualDatas)
        }
    });

    $('#nextNote').click(function(){
        if (selector != null){
            selector = selector + 1
            if (selector == actualDatas.datas.note.length){
                $('#nextNote').hide();
            } else if (selector == 2){
               $('#previousNote').show(); 
            }
            UpdateNoteText(selector, actualDatas)
        }
    });

    $('#getRecords').click(function(){
        console.log(actualDatas)
        if (actualDatas.datas.note.length > 0) {
            SetTheSecondResultText(actualDatas.datas, actualDatas.type);
            if (actualDatas.datas.note.length < 2){
                $('#nextNote').hide();
            }
            $('#previousNote').hide();
            $('#citizenRecords').modal('show');
            selector = 1
        } else {
            alert("Le citoyen n'a pas de note enregistré.")
        }
    });
    
    $('#accessModalNote').click(function(){
        $('#addCitizenNote').modal('show');
    });

    $('#sendCitizenNote').click(function(){
        if ($("#citizenNote").val().length > 0) {
            $.post('http://icops/addCitizenNote', JSON.stringify({
                data: $("#citizenNote").val(),
                id: actualDatas.datas.id
            }));
            $('#addCitizenNote').modal('hide');
        }
    });

    $("#resetSelector").click(function(){
        selector = null
    });

    $('#boutonCitoyens').click(function() {
        $('#logo').show()
        $('#citoyens').show();
        $('#panel').hide();
        $('#vehicules').hide();
    });  
    $('#boutonVehicules').click(function() {
        $('#logo').show()
        $('#vehicules').show();
        $('#panel').hide();
        $('#citoyens').hide();
    });
    $('.logo').click(function() {
        OpenMain();
    });

    $('#sendCitizenMatricule').click(function() {
        if ($('#citizenMatricule').val().length >0 ){
            $.post('http://icops/askForCitizenSearch', JSON.stringify({
                matricule : $('#citizenMatricule').val(),
                type : "citizen"
            }));
        } else {
            if (!($('#validationPoped').length)) {
                $('.resultValidated').append("<div class='alert alert-danger' id='validationPoped'><center><p id='validationMessage'>Merci de bien vouloir rentrer un nom</p></center></div>")
            }
        }
    });

    $('#sendCarPlate').click(function() {
        if ($('#carPlate').val().length >0 ){
            $.post('http://icops/askForCarSearch', JSON.stringify({
                matricule : $('#carPlate').val(),
                type : "vehicle"
            }));
        } else {
            /*if (!($('#validationPoped').length)) {
                $('.resultValidated').append("<div class='alert alert-danger' id='validationPoped'><center><p id='validationMessage'>Merci de bien vouloir rentrer un nom</p></center></div>")
            }*/
        }
    });
    
    $("#sendAddCitoyen").click(function(e){
        event.preventDefault(e);
        var isVerified = CheckCitizenForm();
        if (isVerified == true) {
            $.post('http://icops/addCitoyen', JSON.stringify({
                lastname : $("#lastname").val(),
                firstname : $("#firstname").val(),
                matricule : $("#matricule").val(),
                age : $("#age").val(),
                adress : $("#adress").val(),
                phoneNumber : $("#phoneNumber").val(),
                permis : $("#permis").val(),
                criminalRecord : $("#criminalRecord").val()
            }));
        } else {
            alert("Merci de rentrer une valeur dans tous les champs.")
        }
    });
    $("#sendAddCar").click(function(e){
        event.preventDefault(e);
        var isVerified = CheckCarForm();
        if (isVerified == true) {
            $.post('http://icops/addCar', JSON.stringify({
                carManufacturer : $("#carManufacturer").val(),
                carModel : $("#carModel").val(),
                carColor : $("#carColor").val(),
                carDate : $("#carDate").val(),
                carPlate : $("#carPlate").val(),
                carOwner : $("#carOwner").val(),
                carAdress : $("#carAdress").val(),
                carOthers : $("#carOthers").val()
            }));
        } else {
            alert("Merci de rentrer une valeur dans tous les champs.")
        }
    });

    window.addEventListener('message', function(event){
        var item = event.data;
        if (item.action == "open") {
            OpenMain();
        }
        else if (item.action == "close"){
            CloseAll();
        }
        else if (item.action == "returnResult"){
            /*console.log(item)
            console.log(item.datas)*/
            if ( item.datas != null && item.datas.note && item.datas.note.length) {
                item.datas.note.sort(function(a, b) {
                    return a.time - b.time;
                });
            }

            actualDatas = item
            TreatResult(item.type, item.datas)
        }
    });
});