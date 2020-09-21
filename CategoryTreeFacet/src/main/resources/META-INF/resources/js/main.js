function toggleTreeElementCirad(event) {

    var cur = $(event.currentTarget);
    var parentNode = cur[0].parentElement;

    parentNode.parentElement.querySelector(".nested").classList.toggle("active");
    if (cur[0].className === "caret-custom-cirad glyphicon glyphicon-menu-right") {
        cur[0].className = "caret-custom-cirad glyphicon glyphicon-menu-down";
    } else {
        cur[0].className = "caret-custom-cirad glyphicon glyphicon-menu-right";
    }

}

function changeSelectionAllCirad(event) {

    var cur = $(event.currentTarget);
    var parent = cur.parent().parent();
    var next = parent.next();

    if (next.hasClass("active")) {

        var elements = next.find('input:enabled');

        if (event.currentTarget.checked) {
            elements.prop('checked', true);
        } else {
            elements.prop('checked', false);
        }

    }

    Liferay.Search.FacetUtil.changeSelection(event);

};
