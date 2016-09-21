
window.onload=function() {
    var annotation_dir = getUrlParameter('annotation_dir');
    var input_label = annotation_dir.split('/').pop();
    input_label = input_label.replace(/_/g, ' ');
    $('#input_label').html( input_label );

    get_fasta_stats();
};  // end window onload

function get_fasta_stats() {
    $.ajax({
        url : './cgi/get_fasta_stats.cgi',
        type: "POST",
        data : { 'fasta_file': getUrlParameter('fasta_file'), 
                 'annotation_dir': getUrlParameter('annotation_dir')},
        dataType:"json",
        success: function(data, textStatus, jqXHR) {
            $('#stats_assembly_count').text(data['stats_assembly_count'])
            $('#stats_assembly_sum_length').text(data['stats_assembly_sum_length'] + " bp")
            $('#stats_assembly_longest_length').text(data['stats_assembly_longest_length'] + " bp")
            $('#stats_assembly_shortest_length').text(data['stats_assembly_shortest_length'] + " bp")
            $('#stats_assembly_gc').text(data['stats_assembly_gc'])
        },
        error: function (jqXHR, textStatus, errorThrown) {
		    console.log('textStatus= ', textStatus);
		    console.log('errorThrown= ', errorThrown);
        }
    });
}


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
