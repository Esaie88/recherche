package com.cirad.category.tree.facet.web.categorytreefacetportlet.display.context;

import com.cirad.category.tree.facet.web.categorytreefacetportlet.configuration.CategoryTreeFacetConfiguration;
import com.liferay.asset.kernel.model.AssetVocabulary;
import com.liferay.asset.kernel.service.AssetVocabularyServiceUtil;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.module.configuration.ConfigurationException;
import com.liferay.portal.kernel.theme.PortletDisplay;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;


public class CategoryTreeFacetDisplayContext {

    public CategoryTreeFacetDisplayContext(HttpServletRequest request)
            throws ConfigurationException {

        _request = request;

        ThemeDisplay themeDisplay = (ThemeDisplay) request.getAttribute(
                WebKeys.THEME_DISPLAY);

        PortletDisplay portletDisplay = themeDisplay.getPortletDisplay();

        _categoryTreeFacetConfiguration =
                portletDisplay.getPortletInstanceConfiguration(
                        CategoryTreeFacetConfiguration.class);
    }

    public List<AssetVocabulary> getAssetVocabularies() {
        if (_assetVocabularies != null) {
            return _assetVocabularies;
        }

        ThemeDisplay themeDisplay = (ThemeDisplay) _request.getAttribute(
                WebKeys.THEME_DISPLAY);

        long[] groupIds = new long[0];

        try {
            groupIds = PortalUtil.getCurrentAndAncestorSiteGroupIds(
                    themeDisplay.getScopeGroupId());
        } catch (PortalException pe) {
            groupIds = new long[]{themeDisplay.getScopeGroupId()};

            _log.error(pe, pe);
        }

        _assetVocabularies = AssetVocabularyServiceUtil.getGroupVocabularies(
                groupIds);

        return _assetVocabularies;
    }

    public long[] getAvailableAssetVocabularyIds() {
        if (_availableAssetVocabularyIds != null) {
            return _availableAssetVocabularyIds;
        }

        List<AssetVocabulary> assetVocabularies = getAssetVocabularies();

        _availableAssetVocabularyIds = new long[assetVocabularies.size()];

        for (int i = 0; i < assetVocabularies.size(); i++) {
            AssetVocabulary assetVocabulary = assetVocabularies.get(i);

            _availableAssetVocabularyIds[i] = assetVocabulary.getVocabularyId();
        }

        return _availableAssetVocabularyIds;
    }


    private static final Log _log = LogFactoryUtil.getLog(
            CategoryTreeFacetDisplayContext.class);

    private final CategoryTreeFacetConfiguration _categoryTreeFacetConfiguration;
    private List<AssetVocabulary> _assetVocabularies;
    private long[] _availableAssetVocabularyIds;
    private final HttpServletRequest _request;

}
