//get text for any reason id
function getReasonText (reasons, reasonId) {
    var reason = reasons.find(function (item) {
        return item.Id == reasonId;
    });
    return reason.Name;
}

//highlight the matched characters in blue
function monkeyPatchAutocomplete() {
    $.ui.autocomplete.prototype._renderItem = function (ul, item) {
        var searchTerms = this.term.split(' ');
        var searchCity;
        var searchTerm;
        if (searchTerms.length > 1) {
            searchCity = searchTerms[searchTerms.length - 1].trim();
            searchTerm = this.term.replace(searchCity, "").trim();
            searchTerm = searchTerm.replace(/ /g, "[#!@@$%^*'(){}:;?_+=|/<>&,. -]+");

            item.label = item.label.replace(new RegExp("(" + searchTerm + ")", "gi"), "<strong style='color:#66CCFF'>$1</strong>");
            item.label = item.label.replace(new RegExp("(" + searchCity + ")(?=[^>]*(<|$))", "gi"), "<strong style='color:#66CCFF'>$1</strong>");
        }
        else {
            item.label = item.label.replace(new RegExp("(" + this.term + ")", "gi"), "<strong style='color:#66CCFF'>$1</strong>");
        }

        return $("<li></li>")
            .data("item.autocomplete", item)
            .append("<a>" + item.label + "</a>")
            .appendTo(ul);
    };
}