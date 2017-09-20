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

$(document).on('click', '#gene_list_c tr', function() {
    get_gene_annotation($(this).data('gene-id'), $(this).data('polypeptide-id'));
});

function get_gene_annotation(gene_id, polypeptide_id) {
    $.ajax({
        url: './cgi/get_gene_annotation_and_evidence.cgi',
        type: 'POST',
        data: {'gene_id': gene_id, 'polypeptide_id': polypeptide_id},
        dataType: 'json',
        success: function(data, textStatus, jqXHR) {
            var template = $.templates("#evidence_tmpl");
            var htmlOutput = template.render(data['annotation']);
            $("#evidence_c").html(htmlOutput);

            var hmm_template = $.templates("#hmm_list_tmpl");
            var html_output_hmm = hmm_template.render(data['hmm']);
            $("#hmm_list_c").html(html_output_hmm);
        },
        error: function(jqXHR, textStatus, errorThrown) {
            display_error_bar(jqXHR.status + ' ' + errorThrown.name);
        }
    });
}

function search_product(search_str) {
    $('#product_search_string').html(search_str);

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

