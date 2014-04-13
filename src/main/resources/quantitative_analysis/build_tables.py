import csv
import re
import math
import json
import string
import logging
from operator import itemgetter


def clean_uri(uri):
    uri = re.sub("^<", "", uri)
    uri = re.sub(">$", "", uri)
    return uri


class NumberSeries:

    def __init__(self, key):
        logging.basicConfig(level=logging.DEBUG)
        self.key = clean_uri(key)
        self.values = []

    def append(self, number):
        self.values.append(float(number))

    def min(self):
        return min(self.values)

    def max(self):
        return max(self.values)

    def size(self):
        return len(self.values)

    def sum(self):
        return sum(self.values)

    def amean(self):
        return self.sum() / float(self.size())

    def gmean(self):
        logsum = 0
        for val in self.values:
            logsum += math.log(val)
        return math.exp(logsum/self.size())

    def hmean(self):
        return self.size() / sum(1. / val for val in self.values)

    def to_dict(self):
        return {
            '?key': self.key,
            '?max': self.max(),
            '?min': self.min(),
            '?amean': self.amean(),
            '?gmean': self.gmean(),
            '?hmean': self.hmean(),
            '?size': self.size()}


class TableBuilder:

    def __init__(self, **kwargs):
        logging.basicConfig(level=logging.DEBUG)
        self.output_dir = kwargs['output_dir']
        self.sparql_dir = kwargs['sparql_dir']
        self.analyses_dir = kwargs['analyses_dir']
        self.template_dir = kwargs['template_dir']

        self.prefixes = {}
        self.init_prefixes()

        self.datasets = []
        self.per_dataset_stats = {}
        self.init_per_dataset_stats()
        # self.count_per_dataset_stats()
        # self.write_per_dataset_stats()

    def init_prefixes(self):
        prefix_file = self.sparql_dir + 'prefixes.rq'
        pat = re.compile("PREFIX ([^:]+:) <([^>]+)>")
        with open(prefix_file, "rb") as rqin:
            for line in rqin:
                x = re.findall(pat, line)
                if len(x) > 0:
                    self.prefixes[x[0][0]] = x[0][1]

    def shorten_url(self, url):
        for prefix, long in self.prefixes.iteritems():
            url = url.replace(long, prefix)
        return url

    def init_per_dataset_stats(self):
        with open(self.template_dir + 'numbers-per-dataset.tsv', 'rb') as csvin:
            reader = csv.DictReader(csvin)
            for row in reader:
                self.per_dataset_stats[row['?handle']] = row
                self.datasets.append(row['?handle'])

    def count_per_dataset_stats(self):
        for dataset in self.datasets:
            stats = self.per_dataset_stats[dataset]
            # ?nr_stmt_total
            stats['?nr_stmt_total'] = self.get_second_line_as_number(dataset, 'triples-per-dataset')
            # ?nr_diff_subj
            stats['?nr_diff_subj'] = self.count_lines(dataset, 'subjects-per-dataset')
            # ?nr_diff_obj
            stats['?nr_diff_obj'] = self.count_lines(dataset, 'objects-per-dataset')
            # ?nr_diff_pred
            stats['?nr_diff_pred'] = self.count_lines(dataset, 'predicates-per-dataset')
            # ?nr_stmt_poequal
            stats['?nr_stmt_poequal'] = self.count_lines(dataset, 'predicate-object-equal-statements')
            # ?nr_diff_host
            stats['?nr_diff_host'] = self.count_lines(dataset, 'hostnames')
            # ?nr_diff_baseurl
            stats['?nr_diff_baseurl'] = self.count_lines(dataset, 'hostnames')  # TODO
            # ?nr_diff_license
            stats['?nr_diff_license'] = self.count_lines(dataset, 'license')
            # ?nr_diff_types
            stats['?nr_diff_types'] = self.count_lines(dataset, 'types')
            # ?nr_untyped_subj
            stats['?nr_untyped_subj'] = self.count_lines(dataset, 'untyped')
            # ?nr_stmt_literal
            stats['?nr_stmt_literal'] = self.get_second_line_as_number(dataset, 'literal-statements')
            # ?perc_stmt_literal
            stats['?perc_stmt_literal'] = 100 * stats['?nr_stmt_literal'] / float(stats['?nr_stmt_total'])
            # ?perc_stmt_uri
            stats['?perc_stmt_uri'] = 100 - stats['?perc_stmt_literal']
            # ?perc_stmt_poequal
            stats['?perc_stmt_poequal'] = 100 * stats['?nr_stmt_poequal'] / float(stats['?nr_stmt_total'])
            # ?perc_stmt_unique
            stats['?perc_stmt_unique'] = 100 - stats['?perc_stmt_poequal']
            # ?nr_stmt_uri
            stats['?nr_stmt_uri'] = stats['?nr_stmt_total'] - stats['?nr_stmt_literal']
            # ?perc_unique_obj
            stats['?perc_unique_obj'] = 100 * stats['?nr_diff_obj'] / float(stats['?nr_stmt_uri'])

    def get_second_line_as_number(self, dataset, analysis):
        ret = 0
        with open(self.analyses_dir + dataset + '-count-' + analysis + '.rq.tsv', 'rb') as tsvin:
            tsvin.readline()
            ret = int(tsvin.readline().strip())
        return ret

    def count_lines(self, dataset, analysis):
        with open(self.analyses_dir + dataset + '-count-' + analysis + '.rq.tsv', 'rb') as tsvin:
            total = -1
            for line in tsvin:
                total += 1
        return total

    def write_per_dataset_stats(self):
        field_sequence = []
        dataset_sequence = []
        with open(self.template_dir + 'numbers-per-dataset.tsv', 'rb') as csvin:
            firstline = True
            for line in csvin:
                seq = line.strip().split(',')
                if firstline:
                    field_sequence = seq
                    firstline = False
                else:
                    dataset_sequence.append(seq[0])
        with open(self.analyses_dir + 'numbers-per-dataset.tsv', 'wb') as csvout:
            writer = csv.DictWriter(csvout, field_sequence)
            writer.writeheader()
            for dataset in dataset_sequence:
                writer.writerow(self.per_dataset_stats[dataset])

    def calculate_average(self, analysis, key_group, key_number):
        logging.debug("Average '%s'" % analysis)
        ret_tables = {}

        total_series = {}
        for dataset in self.datasets:
            logging.debug("Average '%s' for dataset '%s'" % (analysis, dataset))
            dataset_series = {}
            with open(self.analyses_dir + dataset + '-count-' + analysis + '.rq.tsv', 'rb') as tsvin:
                reader = csv.DictReader(tsvin, delimiter='\t')
                for row in reader:
                    if not row[key_group] in dataset_series.keys(): dataset_series[row[key_group]] = NumberSeries(row[key_group])
                    if not row[key_group] in total_series.keys(): total_series[row[key_group]] = NumberSeries(row[key_group])
                    dataset_series[row[key_group]].append(row[key_number])
                    total_series[row[key_group]].append(row[key_number])
                ret_tables[dataset] = []
                for series in dataset_series.itervalues(): ret_tables[dataset].append(series.to_dict())
        ret_tables['total'] = []
        for series in total_series.itervalues(): ret_tables['total'].append(series.to_dict())
        for dataset in ret_tables.keys():
            fname = self.output_dir + 'average_' + analysis + '_by_' + key_group.replace("?", "") + "_" + dataset + ".rq.tsv"
            with open(fname, "wb") as csvout:
                writer = csv.DictWriter(csvout, "?key ?size ?min ?max ?amean ?gmean ?hmean".split(" "), delimiter="\t")
                writer.writeheader()
                for row in ret_tables[dataset]:
                    writer.writerow(row)
            print(fname)

    def extract_data_from_table(self, analysis, cols, legend=[], sort_col=0, delimiter='\t'):
        ret = []
        fname = self.analyses_dir + analysis
        with open(fname, "rb") as tsvin:
            reader = csv.DictReader(tsvin, delimiter=delimiter)
            for row in reader:
                row_arr = []
                for col in cols:
                    val = row[col]
                    try:
                        val = float(val)
                    except ValueError:
                        val = self.shorten_url(val)
                    row_arr.append(val)
                ret.append(row_arr)
        ret = sorted(ret, key=itemgetter(sort_col))
        if [] == legend:
            legend = cols
        ret.insert(0, legend)
        return ret

    def run_template(self, out_name, **kwargs):
        tpl_path = self.template_dir + 'gchart.html'
        out_path = self.output_dir + out_name + '_' + kwargs['vis'] + '.html'
        tpl = string.Template(open(tpl_path, 'rb').read())
        repl = {}
        for tplvar_key, tplvar_val in kwargs.iteritems():
            repl[tplvar_key] = json.dumps(tplvar_val)
        out_str = tpl.substitute(repl)
        with open(out_path, 'wb') as out_file:
            out_file.write(out_str)

    def visualize_global_numbers(self):
        pie_bar_number = {
            "?inst_type": "",
            "?nr_stmt_total": "Number of total statements",
            "?nr_diff_subj": "Number of different subjects",
            "?nr_diff_pred": "Number of different predicates",
            "?nr_diff_obj": "Number of different objects",
            "?nr_stmt_poequal": "Number of P-O-equal statements",
            "?nr_stmt_literal": "Number of literal statements",
            "?nr_diff_host": "Number of different hostnames",
            "?nr_diff_baseurl": "Number of different base URL",
            "?nr_diff_license": "Number of different licenses",
            "?nr_stmt_literal": "Number of literal statements",
            "?nr_diff_types": "Number of different rdf:types",
            "?nr_untyped_subj": "Number of resources w/o rdf:type",
            "?avg_stmt_per_resource": "Arith. Avg of statements per subject",
            "?perc_stmt_poequal": "Percentage of P-O-equal statements",
            "?perc_stmt_literal": "Percentage of Literal statements",
            "?perc_unique_obj": "Percentage of One-off References ot a URI [TODO]",
        }
        for csv_key, legend_key in pie_bar_number.iteritems():
            data = tb.extract_data_from_table('numbers-per-dataset.tsv', ['?handle', csv_key], legend=['Dataset', legend_key], sort_col=1, delimiter=',')
            tb.run_template('dm2e_' + csv_key.replace("?",""), vis='bar', data=data, title=legend_key)
            tb.run_template('dm2e_' + csv_key.replace("?",""), vis='pie', data=data, title=legend_key)

        stack_bar_number = {
            'Literal vs. Resource Statements': {
                "?perc_stmt_literal": "Literal Stmt",
                "?perc_stmt_uri": "Resource Stmt",
            },
            'Redundant vs. Unique Statements': {
                "?perc_stmt_unique": "Unique Stmt",
                "?perc_stmt_poequal": "P-0-Equals Stmts",
            }
        }
        for label, csv_dict in stack_bar_number.iteritems():
            csv_keys = ['?handle']
            legend_keys = ['Dataset']
            for csv_key, legend_key in csv_dict.iteritems():
                csv_keys.append(csv_key)
                legend_keys.append(legend_key)
            data = tb.extract_data_from_table('numbers-per-dataset.tsv', csv_keys, legend=legend_keys, sort_col=1, delimiter=',')
            tb.run_template('dm2e_' + label.replace("?",""), vis='stack-bar', data=data, title=label)
            tb.run_template('dm2e_' + label.replace("?",""), vis='pie', data=data, title=label)

    def visualize_average_table(self, table_name, label):
        # numcol_legend = {
        #     "?size": "Total Number",
        #     "?min": "Minimum",
        #     "?max": "Maximum",
        #     "?amean": "Arith. Mean",
        #     "?gmean": "Geom. Mean",
        #     "?hmean": "Harm. Mean",
        # }
        data_minmax = tb.extract_data_from_table(table_name, ['?key', '?min', '?max'], legend=['Value', 'Min', 'Max'], sort_col=1)
        tb.run_template(table_name + '_min_max', vis='bar', data=data_minmax, title='Min/Max for ' + label)

        data_avg = tb.extract_data_from_table(table_name, ['?key', '?amean', '?gmean', '?hmean'], ['Value', 'Abith. Mean', 'Geom. Mean', 'Harm. Mean'])
        tb.run_template(table_name + '_averages', vis='bar', data=data_avg, title='Average for ' + label)

    def visualize_averages(self):
        datasets_plus_total = ['total']
        for dataset in tb.datasets:
            datasets_plus_total.append(dataset)
        for dataset in datasets_plus_total:
            tb.visualize_average_table('average_predicate-object-equal-statements_by_predicate_' + dataset + '.rq.tsv', 'P-O-Equal Statemenets by Predicate')
            tb.visualize_average_table('average_statements-per-resource-and-type_by_dctype_' + dataset + '.rq.tsv', 'Statements per Resource by dc:type')
            tb.visualize_average_table('average_statements-per-resource-and-type_by_type_' + dataset + '.rq.tsv', 'Statements per Resource by rdf:type')
        # tb.visualize_average_table('average_ranges-per-property_by_range_' + dataset + '.rq.tsv', 'Average Number of rdfs:range per rdfs:range')

if __name__ == '__main__':
    tb = TableBuilder(
        output_dir='out/',
        template_dir='tpl/',
        sparql_dir='sparql/',
        analyses_dir='analysis/',
    )

    tb.count_per_dataset_stats()
    tb.write_per_dataset_stats()

    tb.calculate_average('statements-per-resource-and-type', '?dctype', '?no')
    tb.calculate_average('statements-per-resource-and-type', '?type', '?no')
    tb.calculate_average('predicate-object-equal-statements', '?predicate', '?no')

    tb.visualize_global_numbers()
    tb.visualize_averages()

    # vis.collate_no('license')
    # # vis.collate_no('predicate-object-equal-statements')
    # vis.collate_no('triples-per-dataset')
    # vis.distribution_no('statements-per-resource')
    # vis.average_across_datasets_no('statements-per-resource')
    # vis.visualize_map('find-geonames')
