package com.cirad.category.tree.facet.web.categorytreefacetportlet.util;

import org.w3c.dom.Node;
import org.w3c.dom.traversal.NodeFilter;

public class NodeFilterImpl implements NodeFilter {

    @Override
    public short acceptNode(Node n) {
        if (n.getNodeName().contentEquals("label")) {
            return FILTER_ACCEPT;
        }
        return FILTER_SKIP;
    }

}
