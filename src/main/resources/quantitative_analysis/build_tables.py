import csv
import json
import re
import math
import logging


def clean_uri(uri):
    uri = re.sub("^<", "", uri)
    uri = re.sub(">$", "", uri)
    return uri


def first_number_column_index(arr):
    i = 0
    for item in arr:
        try:
            float(item)
            break
        except ValueError:
            i += 1
    return i


def first_number_column(arr):
    return arr[first_number_column(arr)]


class NumberSeries:

    def __init__(self, key):
        logging.basicConfig(level=logging.DEBUG)
        self.key = key
        self.values = []

    def append(self, number):
        self.values.append(float(number))

    def min(self):
        return min(self.values)

    def max(self):
        return max(self.values)

    def length(self):
        return len(self.values)

    def sum(self):
        return sum(self.values)

    def arithmean(self):
        return self.sum() / float(len(self.values))

    def geomean(self):
        logsum = 0
        for val in self.values:
            logsum += math.log(val)
        return logsum/self.length()

    def to_dict(self):
        return {
            'key': self.key,
            'max': self.max(),
            'arithmean': self.arithmean(),
            'geomean': self.geomean(),
            'length': self.length()}


class TableBuilder:

    def __init__(self, **kwargs):
        logging.basicConfig(level=logging.DEBUG)
        self.output_dir = kwargs['output_dir']
        self.analyses_dir = kwargs['analyses_dir']
        self.template_dir = kwargs['template_dir']
        self.datasets = []

        self.per_dataset_stats = {}
        self.init_per_dataset_stats()

    def init_per_dataset_stats(self):
        with open(self.template_dir + 'numbers-per-dataset.tsv', 'rb') as csvin:
            reader = csv.DictReader(csvin)
            for row in reader:
                self.per_dataset_stats[row['?handle']] = row
                self.datasets.append(row['?handle'])
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
        with open(self.output_dir + 'numbers-per-dataset.tsv', 'wb') as csvout:
            writer = csv.DictWriter(csvout, field_sequence)
            writer.writeheader()
            for dataset in dataset_sequence:
                writer.writerow(self.per_dataset_stats[dataset])

    def calculate_average(self, analysis, key_group, key_number):
        logging.debug("Average '%s'" % analysis)
        ret_tables = {}

        # total_series = {}
        for dataset in self.datasets:
            logging.debug("Average '%s' for dataset '%s'" % (analysis, dataset))
            dataset_series = {}
            with open(self.analyses_dir + dataset + '-count-' + analysis + '.rq.tsv', 'rb') as tsvin:
                reader = csv.DictReader(tsvin, delimiter='\t')
                for row in reader:
                    if not row[key_group] in dataset_series.keys(): dataset_series[row[key_group]] = NumberSeries(row[key_group])
                    # if not key_group in total_series.keys(): total_series[key_group] = NumberSeries(row[key_group])
                    dataset_series[row[key_group]].append(row[key_number])
                    # total_series[key_group].append(row[key_number])
                ret_tables[dataset] = []
                for series in dataset_series.itervalues(): ret_tables[dataset].append(series.to_dict())
                break
        # ret_tables['total'] = []
        # for series in total_series.itervalues(): ret_tables['total'].append(series.to_dict())
        return ret_tables

    def visualize_by_number_of_lines(self):
        print

    def visualize_map(self, analysis):
        headers = [['number', 'Lat'], ['number', 'Lon'], ['string', 'uri']]
        aoa = []
        with open(self.analyses_dir + analysis + '.rq.tsv', 'rb') as tsvin:
            reader = csv.reader(tsvin, delimiter='\t')
            first_line = True
            for row_tsv in reader:
                if len(row_tsv) < 3:
                    logging.debug(row_tsv)
                if first_line: first_line = False
                else:
                    this_row = []
                    try:
                        this_row.append(float(row_tsv[3]))
                        this_row.append(float(row_tsv[2]))
                        this_row.append(row_tsv[0])
                    except IndexError:
                        logging.debug(this_row)
                        logging.debug(row_tsv)
                    aoa.append(this_row)
        self.run_template('map',
                          'map_geonames.html',
                          TABLE_ROWS=json.dumps(aoa),
                          TABLE_COLUMNS=json.dumps(headers),
                          TITLE=analysis)


if __name__ == '__main__':
    tb = TableBuilder(
        output_dir='out/',
        template_dir='tpl/',
        analyses_dir='/data/analyses/analysis_2014-04-10_18/',
    )
    dataset_to_country = {
        'bbawdta': 'Germany',
        'geigeidigital': 'Germany',
        'mpiwgharriot': 'Germany',
        'mpiwgrara': 'Germany',
        'mpiwgrarafulltextsample': 'Germany',
        'onbabo': 'Austria',
        'onbcodices': 'Austria',
        'uberdingler': 'Germany',
        'ubffmsammlungen': 'Germany',
        'uibwab': 'Norway',
    }
    # tb.write_per_dataset_stats()
    x = tb.calculate_average('statements-per-resource-and-type', '?type', '?no')
    # print(json.dumps(x))
    print(x)
    # vis.collate_no('hostnames')
    # vis.collate_no('license')
    # # vis.collate_no('predicate-object-equal-statements')
    # vis.collate_no('triples-per-dataset')
    # vis.distribution_no('statements-per-resource')
    # vis.average_across_datasets_no('statements-per-resource')
    # vis.visualize_map('find-geonames')
