package com.cirad.category.tree.facet.web.categorytreefacetportlet.model;

import com.liferay.asset.kernel.model.AssetCategory;

import java.util.List;

public class AssetCategoryNodeModel {

    private AssetCategory assetCategory;
    private List<AssetCategoryNodeModel> childrenAssetCategoriesNodes;
    private int count;
    private boolean checked;


    public AssetCategoryNodeModel(AssetCategory assetCategory, List<AssetCategoryNodeModel> childrenAssetCategoriesNodes, int count, boolean checked) {
        this.assetCategory = assetCategory;
        this.childrenAssetCategoriesNodes = childrenAssetCategoriesNodes;
        this.count = count;
        this.checked = checked;
    }

    public AssetCategory getAssetCategory() {
        return assetCategory;
    }

    public List<AssetCategoryNodeModel> getChildrenAssetCategoriesNodes() {
        return childrenAssetCategoriesNodes;
    }

    public int getCount() {
        return count;
    }

    public boolean isChecked() {
        return checked;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public void setChecked(boolean checked) {
        this.checked = checked;
    }

}
