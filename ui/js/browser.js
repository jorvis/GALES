var annotation_dir;


window.onload=function() {
    annotation_dir = getUrlParameter('annotation_dir');

    // include the header
    $('#header').load('/include/header.html', function() {
        var input_label = annotation_dir.split('/').pop();
        input_label = input_label.replace(/_/g, ' ');
        $('#input_label').html( input_label );
    });

    product_search_string = getUrlParameter('product_search_string');

    if (product_search_string) {
        search_product(product_search_string);
    }
};

function search_product(search_str) {
    $.ajax({
        url: './cgi/search_product.cgi',
        type: 'POST',
        data: {'search_str': search_str},
        dataType: 'json',
        success: function(data, textStatus, jqXHR) {
            var template = $.templates("#gene_list_tmpl");
            var htmlOutput = template.render(data);
            $("#gene_list_c").html(htmlOutput);
        },
        error: function(jqXHR, textStatus, errorThrown) {
            display_error_bar(jqXHR.status + ' ' + errorThrown.name);
        }
    });
}
