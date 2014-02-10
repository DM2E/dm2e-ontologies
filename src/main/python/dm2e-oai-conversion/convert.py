from rdflib import Graph, URIRef, Namespace, Literal
from lxml import etree
from urlparse import urlparse, urlsplit
import re

ns = {
    'oai': 'http://www.openarchives.org/OAI/2.0/',
    'dc': 'http://purl.org/dc/elements/1.1/',
    'dcterms': 'http://purl.org/dc/terms/',
    'oai_dc': 'http://www.openarchives.org/OAI/2.0/oai_dc/',
    'oai_rights': 'http://www.openarchives.org/OAI/2.0/rights/',
    'edm': 'http://www.europeana.eu/schemas/edm/',
    'dm2e': 'http://onto.dm2e.eu/schemas/dm2e/1.1/',
    'bibo': 'http://purl.org/ontology/bibo/',
    'dm2e_helper_ns': 'urn:x-dm2e:',
    'fabio': 'http://purl.org/spar/fabio/',
}

class DM2E_to_DC:

    def __init__(self):
        with open("dm2e-to-dc.rq") as f:
            self.sparco = f.read()
        with open("rdfxml_to_oaipmh.xsl") as f:
            xslt_xml = etree.parse(f)
            self.xslt = etree.XSLT(xslt_xml)
        with open("xsd/OAI-PMH.xsd") as f:
            xsd_xml = etree.parse(f)
            self.oai_schema = etree.XMLSchema(xsd_xml)

    def convert(self, inputGraph=None):
        if inputGraph is None:
            inputGraph = Graph()
            inputGraph.parse('Mappings/Ts-213.rdf.xml')
        qres = inputGraph.query(self.sparco)
        g = Graph()
        for k,v in ns.iteritems():
            g.bind(k,v)
        for triple in qres:
            g.add(triple)
        xml = g.serialize(format='pretty-xml')
        with open("current_rdf.xml", 'w') as f:
            f.write(xml)
        # print xml
        result_xml = self.xslt(etree.XML(xml))
        with open("current_oai.xml", 'w') as f:
            f.write(etree.tostring(result_xml, pretty_print=True))
        self.oai_schema.assertValid(result_xml)
        # print etree.tostring(result_xml, pretty_print=True)


if __name__ == '__main__':
    conv = DM2E_to_DC()
    conv.convert()
