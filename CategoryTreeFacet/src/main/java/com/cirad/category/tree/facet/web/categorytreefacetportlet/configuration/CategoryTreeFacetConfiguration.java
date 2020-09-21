package com.cirad.category.tree.facet.web.categorytreefacetportlet.configuration;

import aQute.bnd.annotation.metatype.Meta;
import com.liferay.portal.configuration.metatype.annotations.ExtendedObjectClassDefinition;


@ExtendedObjectClassDefinition(
        category = "category.search",
        scope = ExtendedObjectClassDefinition.Scope.PORTLET_INSTANCE
)
@Meta.OCD(
        id = "com.cirad.category.tree.facet.web.portlet.configuration.CategoriesFacetSWMConfiguration",
        localization = "content/Language",
        name = "category-tree-facet-portlet-instance-configuration-name"
)
public interface CategoryTreeFacetConfiguration {

    public String customTitleName();

    public String parameterName();

    @Meta.AD(required = false)
    public String assetVocabularyId();

    @Meta.AD(deflt = "true", required = false)
    public String displayAssetCount();


}
