<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@ taglib uri="http://liferay.com/tld/util" prefix="liferay-util" %>
<%@ taglib uri="http://liferay.com/tld/frontend" prefix="liferay-frontend" %>
<%@ taglib uri="http://liferay.com/tld/clay" prefix="clay" %>
<%@ page import="com.cirad.category.tree.facet.web.categorytreefacetportlet.configuration.CategoryTreeFacetConfiguration" %>
<%@ page import="com.cirad.category.tree.facet.web.categorytreefacetportlet.constants.CategoryTreeFacetPortletKeys" %>
<%@ page import="com.cirad.category.tree.facet.web.categorytreefacetportlet.model.HtmlNodeCategoryModel" %>

<%@ page import="com.liferay.asset.kernel.model.AssetCategory" %>
<%@ page import="com.liferay.asset.kernel.model.AssetVocabulary" %>
<%@ page import="com.liferay.asset.kernel.service.AssetCategoryServiceUtil" %>
<%@ page import="com.liferay.portal.kernel.dao.orm.QueryUtil" %>
<%@ page import="com.liferay.portal.kernel.log.Log" %>
<%@ page import="com.liferay.portal.kernel.log.LogFactoryUtil" %>
<%@ page import="com.liferay.portal.kernel.module.configuration.ConfigurationException" %>
<%@ page import="com.liferay.portal.kernel.theme.ThemeDisplay" %>
<%@ page import="com.liferay.portal.kernel.util.HtmlUtil" %>
<%@ page import="com.liferay.portal.kernel.util.LocalizationUtil" %>
<%@ page import="com.liferay.portal.kernel.util.StringBundler" %>
<%@ page import="com.liferay.portal.kernel.util.Validator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>

<liferay-theme:defineObjects/>

<portlet:defineObjects/>

<%
    CategoryTreeFacetConfiguration categoryTreeFacetConfiguration = null;
    try {
        categoryTreeFacetConfiguration = portletDisplay.getPortletInstanceConfiguration(CategoryTreeFacetConfiguration.class);
    } catch (ConfigurationException e) {
        _logInit.error(e);
    }

    String assetVocabularyOrCategoryId = CategoryTreeFacetPortletKeys.BLANK;
    String displayAssetCount = CategoryTreeFacetPortletKeys.BLANK;
    String parameterName = CategoryTreeFacetPortletKeys.BLANK;
    String customTitleNameLocalized = CategoryTreeFacetPortletKeys.BLANK;

    //Localized Inputs
    String xmlTitleLocalized = LocalizationUtil.getLocalizationXmlFromPreferences(portletPreferences, renderRequest, "preferences--customTitleName");
    Map<Locale, String> mapLocalized = LocalizationUtil.getLocalizationMap(xmlTitleLocalized);

    boolean isVocabulary = false;

    if (Validator.isNotNull(categoryTreeFacetConfiguration)) {
        assetVocabularyOrCategoryId =
                portletPreferences.getValue(
                        "assetVocabularyOrCategoryId", categoryTreeFacetConfiguration.assetVocabularyId());

        if (assetVocabularyOrCategoryId.contains("_isVocabulary")) {
            assetVocabularyOrCategoryId = assetVocabularyOrCategoryId.substring(0, assetVocabularyOrCategoryId.indexOf("_isVocabulary"));
            isVocabulary = true;
        }

        displayAssetCount = portletPreferences.getValue(
                "displayAssetCount", categoryTreeFacetConfiguration.displayAssetCount());

        parameterName = portletPreferences.getValue(
                "parameterName", categoryTreeFacetConfiguration.parameterName());

    } else {
        assetVocabularyOrCategoryId = portletPreferences.getValue("assetVocabularyOrCategoryId", "0");
        displayAssetCount = portletPreferences.getValue(
                "displayAssetCount", CategoryTreeFacetPortletKeys.BLANK);
        parameterName = portletPreferences.getValue(
                "parameterName", "category");
    }
%>

<%!
    private static Log _logInit = LogFactoryUtil.getLog("CategoryTreeFacet.init_jsp");
%>
