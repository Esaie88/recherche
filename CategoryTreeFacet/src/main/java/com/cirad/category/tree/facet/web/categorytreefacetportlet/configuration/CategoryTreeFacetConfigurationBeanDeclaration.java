package com.cirad.category.tree.facet.web.categorytreefacetportlet.configuration;

import com.liferay.portal.kernel.settings.definition.ConfigurationBeanDeclaration;
import org.osgi.service.component.annotations.Component;

@Component
public class CategoryTreeFacetConfigurationBeanDeclaration implements ConfigurationBeanDeclaration {

    @Override
    public Class<?> getConfigurationBeanClass() {
        return  CategoryTreeFacetConfiguration.class;
    }

}
