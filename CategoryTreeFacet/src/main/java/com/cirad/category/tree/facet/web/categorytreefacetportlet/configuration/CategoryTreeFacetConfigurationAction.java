package com.cirad.category.tree.facet.web.categorytreefacetportlet.configuration;

import com.cirad.category.tree.facet.web.categorytreefacetportlet.constants.CategoryTreeFacetPortletKeys;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.ConfigurationAction;
import com.liferay.portal.kernel.portlet.DefaultConfigurationAction;
import com.liferay.portal.kernel.util.HtmlUtil;
import com.liferay.portal.kernel.util.LocalizationUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.ConfigurationPolicy;
import org.osgi.service.component.annotations.Reference;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletConfig;
import javax.portlet.PortletPreferences;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

@Component(
        configurationPid = "com.cirad.category.tree.facet.web.portlet.configuration.CategoryTreeFacetConfiguration",
        configurationPolicy = ConfigurationPolicy.OPTIONAL, immediate = true,
        property = "javax.portlet.name=" + CategoryTreeFacetPortletKeys.CIRAD_CATEGORY_TREE_FACET,
        service = ConfigurationAction.class
)
public class CategoryTreeFacetConfigurationAction extends DefaultConfigurationAction {

    @Override
    public String getJspPath(HttpServletRequest request) {
        return "/configuration.jsp";
    }

    @Override
    public void processAction(PortletConfig portletConfig, ActionRequest actionRequest, ActionResponse actionResponse)
            throws Exception {

        String assetVocabularyOrCategoryId = HtmlUtil.escape(ParamUtil.getString(actionRequest, "preferences--assetVocabularyOrCategoryId"));

        String displayAssetCount = ParamUtil.getString(actionRequest, "preferences--displayAssetCount");

        String parameterName = ParamUtil.getString(actionRequest, "preferences--parameterName");

        setPreference(actionRequest, "assetVocabularyOrCategoryId", assetVocabularyOrCategoryId);
        setPreference(actionRequest, "displayAssetCount", displayAssetCount);
        setPreference(actionRequest, "parameterName", parameterName);

        PortletPreferences preferences = actionRequest.getPreferences();
        LocalizationUtil.setLocalizedPreferencesValues(actionRequest, preferences, "preferences--customTitleName");
        preferences.store();

        super.processAction(portletConfig, actionRequest, actionResponse);
    }

    @Override
    @Reference(
            target = "(osgi.web.symbolicname=com.cirad.category.tree.facet.web)", unbind = "-"
    )
    public void setServletContext(ServletContext servletContext) {
        super.setServletContext(servletContext);
    }

    private static final Log _log = LogFactoryUtil.getLog(CategoryTreeFacetConfiguration.class);

}
