package com.cirad.category.tree.facet.web.categorytreefacetportlet.model;

public class HtmlNodeCategoryModel {

    private String label;
    private int count;
    private boolean checked;


    public HtmlNodeCategoryModel(String label, int count, boolean checked) {
        this.label = label;
        this.count = count;
        this.checked = checked;
    }


    public String getLabel() {
        return label;
    }

    public int getCount() {
        return count;
    }

    public boolean isChecked() {
        return checked;
    }

}
