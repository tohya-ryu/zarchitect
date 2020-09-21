var IceBlog = {}

IceBlog.displayPostIMG = function(id) {
    figure = document.getElementById("post-image-figure-"+id);
    figure.style.display = "inline";
}

IceBlog.openPostIMG = function(id) {
    modal_background = document.getElementById("modal-bg");
    modal_content = document.getElementById("modal-content");
    thumb = document.getElementById("post-image-"+id);
    modal_background.style.display = "block";
    modal_content.innerHTML = 
        "<img class='in-modal' src='"+thumb.dataset.url+"'"+
        "onclick='event.cancelBubble=true;'>";
}

IceBlog.closeModal = function() {
    modal_content = document.getElementById("modal-content");
    modal_background = document.getElementById("modal-bg");
    modal_content.innerHTML = "";
    modal_background.style.display = "none";
}

IceBlog.openComForm = function(model, id, quote_id) {
    document.getElementById("comment-form-"+model+"-"+id).style.display =
        "inline-block";
    if (quote_id) {
        textarea = document.getElementById("comment-text-area-"+model+"-"+id);
        if (textarea.value == "") {
            textarea.value = ">"+quote_id;
        } else {
            textarea.value += "\n>"+quote_id;
        }
            
            
    }
}

IceBlog.hideComForm = function(model, id) {
    document.getElementById("comment-form-"+model+"-"+id).style.display =
        "none";
}

IceBlog.hideComments = function(model, id) {
    document.getElementById("post-comments-"+model+"-"+id).style.display =
        "none";
    document.getElementById("comment-form-"+model+"-"+id).style.display =
        "none";
}


IceBlog.loadComments = function(model, id) {
    container = IceBlog.getCommentsContainer(model, id);
    opener = document.getElementById("comments-opener-"+model+
        "-"+id);

    //opener.setAttribute("class", "disabled-link small-text");

    IceBlog.newGetRequest("/cms/"+model+"/"+id, function() {
        switch (xmlhttp.readyState) {
        case 0:
            // request not initialized
            container.innerHTML = "loading...";
            break;
        case 1:
            // server connection established
            container.innerHTML = "loading...";
            break;
        case 2:
            // request received
            container.innerHTML = "loading...";
            break;
        case 3:
            // processing request
            container.innerHTML = "....";
            break;
        case 4:
            // response ready
            //opener.setAttribute("onClick", "IceBlog.addComments('"+model+
            //"',"+id+")");
            container.style.display = "block";
            container.innerHTML = xmlhttp.responseText;
            break;
        } 
    });
}

IceBlog.addComments = function(model, id) {
    container = IceBlog.getCommentsContainer(model, id);
    container.style.display = "block";
}

IceBlog.getCommentsContainer = function(model, id) {
    container = document.getElementById("post-comments-"+model+
        "-"+id);
    return container
}

IceBlog.inputCount = function(model, id) {
    field = document.getElementById("comment-text-area-"+model+
        "-"+id);
    document.getElementById("comment-input-count-"+model+
        "-"+id).innerHTML = field.value.length+"/500";
}


IceBlog.newGetRequest = function(url, cfunc) {
    xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = cfunc;
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
}

IceBlog.showElement = function(id, option) {
    document.getElementById(id).style.display = option;
}

IceBlog.hideElement = function(id, option) {
    document.getElementById(id).style.display = option;
}

IceBlog.showSpoiler = function(id) {
    document.getElementById("spoiler-"+id).style.display = "block";
    document.getElementById("spoiler-show-"+id).style.display = "none";
    document.getElementById("spoiler-hide-"+id).style.display = "inline";
}
IceBlog.hideSpoiler = function(id) {
    document.getElementById("spoiler-"+id).style.display = "none";
    document.getElementById("spoiler-hide-"+id).style.display = "none";
    document.getElementById("spoiler-show-"+id).style.display = "inline";
}

/*
if (window.addEventListener) {
    window.addEventListener("load", IceBlog.main)
} else {
    window.attachEvent("load", IceBlog.main)
}
*/
