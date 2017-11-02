var annotation_dir;


window.onload=function() {
    annotation_dir = getUrlParameter('annotation_dir');

    // include the header
    $('#header').load('/include/header.html', function() {
        var input_label = annotation_dir.split('/').pop();
        input_label = input_label.replace(/_/g, ' ');
        $('#input_label').html( input_label );
    });

    get_fasta_stats();
    get_annotation_stats();

    google.charts.load('current', {packages: ['corechart']});
    google.charts.setOnLoadCallback(draw_go_slim_function_chart);
    google.charts.setOnLoadCallback(draw_go_slim_process_chart);
    google.charts.setOnLoadCallback(draw_go_slim_component_chart);

    $('button#product_search_btn').click( function( event ) {
        event.preventDefault();
        if (annotation_dir) {
            window.location = encodeURI('/browser.html?annotation_dir=' + annotation_dir +
                                                 '&product_search_string=' + $('#product_search_string').val());
        }
    });

};  // end window onload

function draw_go_slim_component_chart() {
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'GO term');
    data.addColumn('number', 'count');

    $.getJSON("data/obo_slim_counts.json", function (jsondata) {
        function_data = jsondata['cellular_component']

        $.each( function_data, function( key, value ) {
            data.addRow([key, value]);
        });

        // Set chart options
        var options = {'title':'Cellular component',
                       'width':400,
                       'height':300,
                       'chartArea': {'width': '65%', 'height': '85%'},
                       legend:{position:'none'}
                      };
        
        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.BarChart(document.getElementById('go_chart_component'));
        chart.draw(data, options);
    });
}

function draw_go_slim_function_chart() {
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'GO term');
    data.addColumn('number', 'count');

    $.getJSON("data/obo_slim_counts.json", function (jsondata) {
        function_data = jsondata['molecular_function']

        $.each( function_data, function( key, value ) {
            data.addRow([key, value]);
        });

        // Set chart options
        var options = {'title':'Molecular function',
                       'width':400,
                       'height':300,
                       'chartArea': {'width': '65%', 'height': '85%'},
                       legend:{position:'none'}
                      };
        
        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.BarChart(document.getElementById('go_chart_function'));
        chart.draw(data, options);
    });
}

function draw_go_slim_process_chart() {
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'GO term');
    data.addColumn('number', 'count');

    $.getJSON("data/obo_slim_counts.json", function (jsondata) {
        function_data = jsondata['biological_process']

        $.each( function_data, function( key, value ) {
            data.addRow([key, value]);
        });

        // Set chart options
        var options = {'title':'Biological process',
                       'width':400,
                       'height':300,
                       'chartArea': {'width': '65%', 'height': '85%'},
                       legend:{position:'none'}
                      };
        
        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.BarChart(document.getElementById('go_chart_process'));
        chart.draw(data, options);
    });
}

function get_annotation_stats() {
    $.ajax({
        url : './cgi/get_annotation_stats.cgi',
        type: "POST",
        data : { 'annotation_dir': getUrlParameter('annotation_dir')},
        dataType:"json",
        success: function(data, textStatus, jqXHR) {
            $('#stats_dbxrefs_assigned').text(data['stats_dbxrefs_assigned'])
            $('#stats_ec_numbers_assigned').text(data['stats_ec_numbers_assigned'])
            $('#stats_gene_count').text(data['stats_gene_count'])
            $('#stats_gene_mean_length').text(data['stats_gene_mean_length'])
            $('#stats_gene_symbols_assigned').text(data['stats_gene_symbols_assigned'])
            $('#stats_go_terms_assigned').text(data['stats_go_terms_assigned'])
            $('#stats_hypo_gene_count').text(data['stats_hypo_gene_count'])
            $('#stats_mean_go_terms_per_gene').text(data['stats_mean_go_terms_per_gene'])
            $('#stats_rRNA_count').text(data['stats_rRNA_count'])
            $('#stats_specific_annot_count').text(data['stats_specific_annot_count'])
            $('#stats_tRNA_count').text(data['stats_tRNA_count'])
        },
        error: function (jqXHR, textStatus, errorThrown) {
		    console.log('textStatus= ', textStatus);
		    console.log('errorThrown= ', errorThrown);
        }
    });
}

function get_fasta_stats() {
    $.ajax({
        url : './cgi/get_fasta_stats.cgi',
        type: "POST",
        data : { 'fasta_file': getUrlParameter('fasta_file'), 
                 'annotation_dir': getUrlParameter('annotation_dir')},
        dataType:"json",
        success: function(data, textStatus, jqXHR) {
            $('#stats_assembly_count').text(data['stats_assembly_count'])
            console.log("Assembly sum length is " + data['stats_assembly_sum_length']);
            $('#stats_assembly_sum_length').text(data['stats_assembly_sum_length'] + " bp")
            $('#stats_assembly_longest_length').text(data['stats_assembly_longest_length'] + " bp")
            $('#stats_assembly_shortest_length').text(data['stats_assembly_shortest_length'] + " bp")
            $('#stats_assembly_gc').text(data['stats_assembly_gc'])
            $('#stats_gene_count').text(data['stats_gene_count'])
        },
        error: function (jqXHR, textStatus, errorThrown) {
		    console.log('textStatus= ', textStatus);
		    console.log('errorThrown= ', errorThrown);
        }
    });
}


