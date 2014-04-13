import csv
import json
import string
import re
import logging


def clean_uri(uri):
    uri = re.sub("^<", "", uri)
    uri = re.sub(">$", "", uri)
    return uri


def dict_to_aoa(self, valdict):
    valarr = []
    for key, val in valdict.iteritems():
        this = []
        this.append(key)
        this.append(val)
        valarr.append(this)
    return sorted(valarr, key=first_number_column)


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


class Vis:

    def __init__(self, **kwargs):
        logging.basicConfig(level=logging.DEBUG)
        self.output_dir = kwargs['output_dir']
        self.template_dir = kwargs['template_dir']
        self.analyses_dir = kwargs['analyses_dir']
        self.datasets = kwargs['datasets']
        self.numbers_per_dataset = {'total': {}}
        for ds in self.datasets:
            self.numbers_per_dataset[ds] = {}

    def run_template(self, tpl_name, filename, **kwargs):
        out_path = self.output_dir + '/' + filename
        tpl_path = self.template_dir + '/' + tpl_name + '.html'
        tpl = string.Template(open(tpl_path, 'rb').read())
        out_str = tpl.substitute(kwargs)
        with open(out_path, 'wb') as out_file:
            out_file.write(out_str)

    def average_across_datasets_no(self, analysis):
        logging.debug("Average '%s'" % analysis)
        valdict = {}
        headers = [['string', 'dataset'], ['number', 'average']]
        for dataset in self.datasets:
            with open(self.analyses_dir + dataset + '-count-' + analysis + '.rq.tsv', 'rb') as tsvin:
                dataset_stmts = 0
                dataset_total = 0
                reader = csv.reader(tsvin, delimiter='\t')
                first_line = True
                for row_tsv in reader:
                    no_index = 0
                    if len(row_tsv) > 1: no_index = 1
                    if first_line:
                        first_line = False
                    else:
                        dataset_total += int(row_tsv[no_index])
                        dataset_stmts += 1
                        valdict[dataset] = dataset_total / float(dataset_stmts)
        valarr = dict_to_aoa(valdict)
        for vis_type in ['pie', 'bar']:
            self.run_template(vis_type,
                              'average_' + analysis + '_' + vis_type + '.html',
                              TABLE_ROWS=json.dumps(valarr),
                              TABLE_COLUMNS=json.dumps(headers),
                              TITLE=analysis)

    def distribution_no(self, analysis):
        valdict = {}
        headers = [['string', 'number'], ['number', 'frequency']]
        for dataset in self.datasets:
            valdict_per_dataset = {}
            try:
                with open(self.analyses_dir + dataset + '-count-' + analysis + '.rq.tsv', 'rb') as tsvin:
                    reader = csv.reader(tsvin, delimiter='\t')
                    first_line = True
                    for row_tsv in reader:
                        no_index = 0
                        if len(row_tsv) > 1: no_index = 1
                        if first_line: first_line = False
                        else:
                            try:
                                valdict[row_tsv[no_index]] += 1
                                valdict_per_dataset[row_tsv[no_index]] += 1
                            except KeyError:
                                valdict[row_tsv[no_index]] = 1
                                valdict_per_dataset[row_tsv[no_index]] = 1

                    valarr_per_dataset = dict_to_aoa(valdict_per_dataset)

                    for vis_type in ['pie', 'bar']:
                        self.run_template(vis_type,
                                          dataset + '_dist_' + analysis + '_' + vis_type + '.html',
                                          TABLE_ROWS=json.dumps(valarr_per_dataset),
                                          TABLE_COLUMNS=json.dumps(headers),
                                          TITLE=analysis)
            except IOError:
                pass

        valarr = dict_to_aoa(valdict)
        for vis_type in ['pie', 'bar']:
            self.run_template(vis_type,
                              'dist_' + analysis + '_' + vis_type + '.html',
                              TABLE_ROWS=json.dumps(valarr),
                              TABLE_COLUMNS=json.dumps(headers),
                              TITLE=analysis)

    def collate_no(self, analysis):
        logging.info("Collate '%s'" % analysis)
        valdict = {}
        headers = [['string','foo'],['number','bar']]
        for dataset in self.datasets:
            valdict_per_dataset = {}
            with open(self.analyses_dir + dataset + '-count-' + analysis + '.rq.tsv', 'rb') as tsvin:
                reader = csv.reader(tsvin, delimiter='\t')
                first_line = True
                for row_tsv in reader:
                    if len(row_tsv) == 1:
                        if first_line:
                            first_line = False
                            continue
                        key = dataset
                        val = int(row_tsv[0])
                        try:
                            valdict[key] += val
                            valdict_per_dataset[key] += val
                        except KeyError:
                            valdict[key] = val
                            valdict_per_dataset[key] = val
                    elif len(row_tsv) == 2:
                        if first_line:
                            first_line = False
                            continue
                        key = self.clean_uri(row_tsv[0])
                        val = int(row_tsv[1])
                        try:
                            valdict[key] += val
                            valdict_per_dataset[key] += val
                        except KeyError:
                            valdict[key] = val
                            valdict_per_dataset[key] = val
                    elif len(row_tsv) == 3:
                        if first_line:
                            first_line = False
                            continue
                        key = self.clean_uri(row_tsv[0]) + self.clean_uri(row_tsv[1])
                        val = int(row_tsv[2])
                        try:
                            valdict[key] += val
                            valdict_per_dataset[key] += val
                        except KeyError:
                            valdict[key] = val
                            valdict_per_dataset[key] = val
                for vis_type in ['pie', 'bar']:
                    self.run_template(vis_type,
                                      dataset + '_frequency' + analysis + '_' + vis_type + '.html',
                                      TABLE_ROWS=json.dumps(dict_to_aoa(valdict_per_dataset)),
                                      TABLE_COLUMNS=json.dumps(headers),
                                      TITLE=analysis)
        for vis_type in ['pie', 'bar']:
            self.run_template(vis_type,
                              'frequency' + analysis + '_' + vis_type + '.html',
                              TABLE_ROWS=json.dumps(dict_to_aoa(valdict)),
                              TABLE_COLUMNS=json.dumps(headers),
                              TITLE=analysis)

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

        def visualize_total(self, tsv_fname, key_group, key_number):
            valdict = {}
            with open(self.analyses_dir + tsv_fname + ".tsv", "rb") as tsvin:
                reader = csv.DictReader(tsvin)
                for row in reader:
                    valdict[row[key_group]] = row[key_number]
            return dict_to_aoa(valdict)


if __name__ == '__main__':
    vis = Vis(
        output_dir='out/',
        template_dir='tpl/',
        datasets='bbawdta geigeidigital mpiwgharriot mpiwgrara mpiwgrarafulltextsample onbabo onbcodices uberdingler ubffmsammlungen uibwab'.split(' '),
        analyses_dir='analysis/',
    )
    # vis.visualize_total('numbers-per-dataset', '?nr_stmt_total')
    # vis.collate_no('hostnames')
    # vis.collate_no('license')
    # # vis.collate_no('predicate-object-equal-statements')
    # vis.collate_no('triples-per-dataset')
    # vis.distribution_no('statements-per-resource')
    # vis.average_across_datasets_no('statements-per-resource')
    # vis.visualize_map('find-geonames')
