package com.cirad.category.tree.facet.web.categoryfacetportletfilter;

import com.cirad.category.tree.facet.web.categorytreefacetportlet.constants.CategoryTreeFacetPortletKeys;
import com.liferay.portal.kernel.theme.PortletDisplay;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.WebKeys;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.osgi.service.component.annotations.Component;

import javax.portlet.PortletException;
import javax.portlet.PortletSession;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.filter.*;
import java.io.IOException;



@Component(
        immediate = true,
        property = {
                "javax.portlet.name=" + CategoryTreeFacetPortletKeys.CATEGORY_FACET
        },
        service = PortletFilter.class
)
public class CategoryPortletFilter implements RenderFilter {

    @Override
    public void init(FilterConfig config) throws PortletException {

    }

    @Override
    public void destroy() {

    }

    @Override
    public void doFilter(RenderRequest request, RenderResponse response, FilterChain chain)
            throws IOException, PortletException {

        RenderResponseWrapper renderResponseWrapper = new BufferedRenderResponseWrapper(response);

        chain.doFilter(request, renderResponseWrapper);

        String text = renderResponseWrapper.toString();

        String formatText = CategoryTreeFacetPortletKeys.BODYBEGIN + text.replace("\n", "").replace("\t", "") + CategoryTreeFacetPortletKeys.BODYEND;

        Document doc = Jsoup.parse(formatText);
        Elements categoryResult = doc.getElementsByTag("input");
        String curParameterName = CategoryTreeFacetPortletKeys.BLANK;

        for (Element res : categoryResult) {
            if (res.hasClass("facet-parameter-name")) {
                curParameterName = res.attr("value");
            }
        }

        ThemeDisplay themeDisplay = (ThemeDisplay) request.getAttribute(WebKeys.THEME_DISPLAY);
        PortletDisplay portletDisplay = themeDisplay.getPortletDisplay();
        String curIdCategoryPortlet = portletDisplay.getId();

        PortletSession portletSession = request.getPortletSession();
        portletSession.setAttribute("text_" + curParameterName, text, PortletSession.APPLICATION_SCOPE);
        portletSession.setAttribute("curIdCategoryPortlet_" + curParameterName, curIdCategoryPortlet, PortletSession.APPLICATION_SCOPE);

        response.getWriter().write(text);

    }

}