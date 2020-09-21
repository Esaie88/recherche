package com.cirad.category.tree.facet.web.categorytreefacetportlet.portlet;

import com.cirad.category.tree.facet.web.categorytreefacetportlet.configuration.CategoryTreeFacetConfiguration;
import com.cirad.category.tree.facet.web.categorytreefacetportlet.model.HtmlNodeCategoryModel;
import com.cirad.category.tree.facet.web.categorytreefacetportlet.constants.CategoryTreeFacetPortletKeys;
import com.liferay.portal.configuration.metatype.bnd.util.ConfigurableUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.module.configuration.ConfigurationException;
import com.liferay.portal.kernel.module.configuration.ConfigurationProviderUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.theme.PortletDisplay;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Modified;

import javax.portlet.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;


@Component(
        configurationPid = "com.cirad.category.tree.facet.web.portlet.configuration.CategoriesFacetSWMPortletInstanceConfiguration",
        immediate = true,
        property = {
                "com.liferay.portlet.display-category=category.search",
                "com.liferay.portlet.header-portlet-css=/css/main.css",
                "com.liferay.portlet.footer-portlet-javascript=/js/main.js",
                "com.liferay.portlet.instanceable=true",
                "javax.portlet.init-param.template-path=/",
                "javax.portlet.init-param.view-template=/view.jsp",
                "javax.portlet.name=" + CategoryTreeFacetPortletKeys.CIRAD_CATEGORY_TREE_FACET,
                "javax.portlet.resource-bundle=content.Language",
                "javax.portlet.security-role-ref=power-user,user",
                "com.liferay.portlet.private-request-attributes=false",
                "com.liferay.portlet.private-session-attributes=false",
                "com.liferay.portlet.render-weight=0"
        },
        service = Portlet.class
)

public class CategoryTreeFacetPortlet extends MVCPortlet {

    @Override
    public void doView(RenderRequest renderRequest,
                       RenderResponse renderResponse) throws IOException, PortletException {

        ThemeDisplay themeDisplay = (ThemeDisplay) renderRequest.getAttribute("LIFERAY_SHARED_THEME_DISPLAY");
        PortletDisplay portletDisplay = themeDisplay.getPortletDisplay();

        // remove refresh button
        portletDisplay.setShowRefreshIcon(false);

        CategoryTreeFacetConfiguration categoryTreeFacetConfiguration = null;

        try {
            categoryTreeFacetConfiguration = ConfigurationProviderUtil.getPortletInstanceConfiguration(CategoryTreeFacetConfiguration.class, themeDisplay.getLayout(), CategoryTreeFacetPortletKeys.CIRAD_CATEGORY_TREE_FACET);
        } catch (ConfigurationException e) {
            _log.error(e);
        }

        PortletPreferences portletPreferences = portletDisplay.getPortletSetup();

        String parameterName = CategoryTreeFacetPortletKeys.BLANK;

        if (categoryTreeFacetConfiguration != null) {
            parameterName = portletPreferences.getValue(
                    "parameterName", categoryTreeFacetConfiguration.parameterName());
        }

        PortletSession portletSession = renderRequest.getPortletSession();
        String text = (String) portletSession.getAttribute("text_" + parameterName, PortletSession.APPLICATION_SCOPE);

        if (text != null) {
            renderRequest.setAttribute(
                    CategoryTreeFacetConfiguration.class.getName(), _categoryTreeFacetConfiguration);

            String formatText = CategoryTreeFacetPortletKeys.BODYBEGIN + text.replace("\n", "").replace("\t", "") + CategoryTreeFacetPortletKeys.BODYEND;

            Document doc = Jsoup.parse(formatText);

            Elements categoryResult = doc.getElementsByTag("label");
            ArrayList<HtmlNodeCategoryModel> nodes = new ArrayList<>();

            for (Element res : categoryResult) {
                nodes.add(new HtmlNodeCategoryModel(res.child(1).text(), Integer.parseInt(res.child(2).text().replace("(", "").replace(")", "")), res.child(0).hasAttr("checked")));
            }

            String curIdCategoryPortlet = (String) portletSession.getAttribute("curIdCategoryPortlet_" + parameterName, PortletSession.APPLICATION_SCOPE);

            String hideCategoryPortlet = CategoryTreeFacetPortletKeys.BLANK;

            if (curIdCategoryPortlet != null && !curIdCategoryPortlet.isEmpty()) {
                hideCategoryPortlet = "<style type=\"text/css\">#p_p_id_" + curIdCategoryPortlet + "_{display:none}</style>";
            }

            renderRequest.setAttribute("categoryNodes", nodes);
            renderRequest.setAttribute("hideCategoryPortlet", hideCategoryPortlet);
        } else {
            String isEmptyResultList = "true";
            renderRequest.setAttribute("isEmptyResultList", isEmptyResultList);
        }

        portletSession.removeAttribute("text_" + parameterName, PortletSession.APPLICATION_SCOPE);
        portletSession.removeAttribute("curIdCategoryPortlet_" + parameterName, PortletSession.APPLICATION_SCOPE);

        super.doView(renderRequest, renderResponse);
    }


    @Activate
    @Modified
    protected void activate(Map<String, Object> properties) {
        _categoryTreeFacetConfiguration = ConfigurableUtil.createConfigurable(
                CategoryTreeFacetConfiguration.class, properties);
    }


    private volatile CategoryTreeFacetConfiguration _categoryTreeFacetConfiguration;

    private static Log _log = LogFactoryUtil.getLog(CategoryTreeFacetPortlet.class);

}