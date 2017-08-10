// From: http://stackoverflow.com/a/21903119/1368079
// Use example:
//   if URL is: http://dummy.com/?technology=jquery&blog=jquerybyexample
//   then:      var tech = getUrlParameter('technology');
//              var blog = getUrlParameter('blog');
var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};
