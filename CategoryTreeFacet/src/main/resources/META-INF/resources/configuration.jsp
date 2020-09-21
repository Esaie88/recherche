<%@ page import="com.liferay.portal.kernel.util.*" %>
<%@ page import="com.cirad.category.tree.facet.web.categorytreefacetportlet.constants.CategoryTreeFacetPortletKeys" %>
<%@ page import="com.liferay.portal.kernel.log.LogFactoryUtil" %>
<%@ page import="com.liferay.portal.kernel.log.Log" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.cirad.category.tree.facet.web.categorytreefacetportlet.display.context.CategoryTreeFacetDisplayContext" %>
<%@ include file="/init.jsp" %>

<%
    CategoryTreeFacetDisplayContext categoryTreeFacetDisplayContext = null;

    xmlTitleLocalized = (xmlTitleLocalized == null) ? "" : xmlTitleLocalized;

    try {
        categoryTreeFacetDisplayContext = new CategoryTreeFacetDisplayContext(request);
    } catch (ConfigurationException e) {
        _logConfig.error(e);
    }

    List<AssetVocabulary> assetVocabularies = new ArrayList<>();

    if (categoryTreeFacetDisplayContext != null) {
        assetVocabularies = categoryTreeFacetDisplayContext.getAssetVocabularies();
    }

%>

<liferay-portlet:actionURL portletConfiguration="<%= true %>" var="configurationActionURL"/>

<liferay-portlet:renderURL portletConfiguration="<%= true %>" var="configurationRenderURL"/>

<liferay-frontend:edit-form action="<%= configurationActionURL %>"
                            method="post"
                            name="fm">

    <aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>"/>
    <aui:input name="redirect" type="hidden" value="<%= configurationRenderURL %>"/>

    <liferay-frontend:edit-form-body>
        <liferay-frontend:fieldset-group>
            <aui:field-wrapper cssClass="lfr-textarea-container" label="custom-title-name">
                <liferay-ui:input-localized name="preferences--customTitleName" xml="<%= xmlTitleLocalized %>"/>
            </aui:field-wrapper>

            <aui:input label="category-parameter-name" name="preferences--parameterName"
                       value="<%= parameterName %>"><aui:validator name="required"/></aui:input>

            <c:if test="<%= assetVocabularies != null %>">

                <div class="dropdown dropdown-custom">
                    <button type="button" data-toggle="dropdown" class="btn btn-default dropdown-toggle">
                        <liferay-ui:message key="select-root-category"/>
                        <span class="caret"></span>
                    </button>
                    <div class="dropdown-menu dropdown-menu-custom">

                        <%
                            long curVocabularyOrCategoryId;
                            String namespace = renderResponse.getNamespace();

                            if (!assetVocabularyOrCategoryId.isEmpty()) {
                                curVocabularyOrCategoryId = Long.parseLong(assetVocabularyOrCategoryId);
                            } else {
                                curVocabularyOrCategoryId = 0;
                            }

                            int i = 0;

                            for (AssetVocabulary assetVocabulary : assetVocabularies) {
                        %>
                        <c:if test="<%= i == 1 %>">
                            <div class="dropdown-divider"></div>
                        </c:if>

                        <li class="form-check">
                            <c:choose>
                                <c:when test="<%= assetVocabulary.getVocabularyId() == curVocabularyOrCategoryId %>">
                                    <input class="form-check-input" id="vocabulary_<%= i %>" type="radio"
                                           value="<%= assetVocabulary.getVocabularyId() %>_isVocabulary"
                                           name="<portlet:namespace/>preferences--assetVocabularyOrCategoryId"
                                           checked/>
                                </c:when>
                                <c:otherwise>
                                    <input class="form-check-input" id="vocabulary_<%= i %>" type="radio"
                                           value="<%= assetVocabulary.getVocabularyId() %>_isVocabulary"
                                           name="<portlet:namespace/>preferences--assetVocabularyOrCategoryId"/>
                                </c:otherwise>
                            </c:choose>
                            <label class="form-check-label"
                                   for="vocabulary_<%= i %>"><%= assetVocabulary.getTitle(locale) %>
                            </label>
                        </li>


                        <%
                            List<AssetCategory> categories = assetVocabulary.getCategories();
                            String categoriesNavigation = CategoryTreeFacetPortletKeys.BLANK;

                            if (!categories.isEmpty()) {
                                StringBundler sb = new StringBundler();
                                try {
                                    categoriesNavigation = _buildCategoriesNavigation(categories, curVocabularyOrCategoryId, themeDisplay, sb, namespace);
                                } catch (Exception e) {
                                    _logConfig.error(e);
                                }
                            }
                        %>

                        <%= categoriesNavigation %>

                        <%
                                i++;
                            }
                        %>
                    </div>
                </div>
            </c:if>

            <aui:input label="display-frequencies" name="preferences--displayAssetCount" type="checkbox"
                       checked="<%= Boolean.valueOf(displayAssetCount) %>"/>

        </liferay-frontend:fieldset-group>
    </liferay-frontend:edit-form-body>

    <liferay-frontend:edit-form-footer>
        <aui:button type="submit"/>

        <aui:button type="cancel"/>
    </liferay-frontend:edit-form-footer>
</liferay-frontend:edit-form>


<%!
    private String _buildCategoriesNavigation(List<AssetCategory> categories, long curVocabularyOrCategoryId, ThemeDisplay themeDisplay, StringBundler sb, String namespace) throws Exception {

        int j = 0;

        if (sb.length() == 0) {
            sb = new StringBundler();
        }

        for (AssetCategory category : categories) {

            if (!categories.contains(category.getParentCategory())) {

                List<AssetCategory> categoriesChildren = AssetCategoryServiceUtil.getChildCategories(category.getCategoryId(), QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);

                if (!categoriesChildren.isEmpty()) {
                    boolean testChecked = category.getCategoryId() == curVocabularyOrCategoryId;

                    j++;

                    sb.append("<ul>");
                    sb.append("<li class=\"form-check\">");

                    sb.append("<input class=\"form-check-input\" value=\"" + category.getCategoryId() + "\" data-term-id=\"" + category.getCategoryId() + "\" id=\"term_child_" + j + "\" name=\"" + namespace + "preferences--assetVocabularyOrCategoryId\" type=\"radio\"");

                    if (testChecked) {
                        sb.append(" checked");
                    }

                    sb.append("/> ");
                    sb.append("<label class=\"form-check-label\" for=\"term_child_" + j + "\">" + HtmlUtil.escape(category.getTitle(themeDisplay.getLocale())) + "</label>");


                    _buildCategoriesNavigation(categoriesChildren, curVocabularyOrCategoryId, themeDisplay, sb, namespace);

                    sb.append("</li>");
                    sb.append("</ul>");
                }

            }
        }

        return sb.toString();
    }
%>

<%!
    private static Log _logConfig = LogFactoryUtil.getLog("CategoryTreeFacet.configuration_jsp");
%>