<%@ page import="com.cirad.category.tree.facet.web.categorytreefacetportlet.model.AssetCategoryNodeModel" %>
<%@ page import="com.liferay.asset.kernel.service.AssetCategoryLocalServiceUtil" %>
<%@ page import="com.liferay.asset.kernel.service.AssetVocabularyLocalServiceUtil" %>
<%@ page import="com.liferay.portal.kernel.exception.PortalException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.UUID" %>
<%@ include file="/init.jsp" %>

<%
    List<HtmlNodeCategoryModel> nodes = (List<HtmlNodeCategoryModel>) renderRequest.getAttribute("categoryNodes");
    String hideCategoryPortlet = (String) renderRequest.getAttribute("hideCategoryPortlet");

    boolean isEmptyResultList = Boolean.parseBoolean((String) renderRequest.getAttribute("isEmptyResultList"));

    AssetVocabulary assetVocabulary = null;
    AssetCategory assetCategory = null;
    List<Boolean> isEmptyFormList = new ArrayList<>();

    if (!Validator.isNull(assetVocabularyOrCategoryId)) {
        if (isVocabulary) {
            try {
                assetVocabulary = AssetVocabularyLocalServiceUtil.getVocabulary(Long.parseLong(assetVocabularyOrCategoryId));
            } catch (PortalException e) {
                _logView.error(e);
            }
        } else {
            try {
                assetCategory = AssetCategoryLocalServiceUtil.getCategory(Long.parseLong(assetVocabularyOrCategoryId));
            } catch (PortalException e) {
                _logView.error(e);
            }
        }
    }
%>

<c:if test="<%= hideCategoryPortlet != null && !hideCategoryPortlet.isEmpty() %>">
    <%= hideCategoryPortlet %>
</c:if>

<%--<c:if test="<%= !isEmptyResultList %>">--%>
<c:choose>
    <c:when test="<%= Validator.isNotNull(assetVocabulary) || Validator.isNotNull(assetCategory)%>">
        <%--            <c:choose>--%>
        <%--                <c:when test="<%= Validator.isNotNull(nodes) %>">--%>
        <%
            if (assetVocabulary != null) {
                customTitleNameLocalized = mapLocalized.getOrDefault(locale, assetVocabulary.getName());
            } else {
                customTitleNameLocalized = mapLocalized.getOrDefault(locale, assetCategory.getName());
            }
        %>
        <div class="facetAssetCategoriesCustom">
            <liferay-ui:panel-container
                    extended="<%= true %>"
                    id='<%= renderResponse.getNamespace() + "facetAssetCategoriesCustomPanelContainer" %>'
                    markupView="lexicon"
                    persistState="<%= true %>"
            >
                <liferay-ui:panel
                        collapsible="<%= true %>"
                        cssClass="search-facet"
                        id='<%= renderResponse.getNamespace() + "facetAssetCategoriesCustomPanel" %>'
                        markupView="lexicon"
                        persistState="<%= true %>"
                        title="<%= customTitleNameLocalized %>"
                >

                    <aui:form method="post" name="categoryFacetCustomForm">
                        <aui:input cssClass="facet-parameter-name" name="facet-parameter-name"
                                   type="hidden"
                                   value='<%= parameterName %>'/>
                        <%
                            List<AssetCategory> categories = new ArrayList<>();

                            if (assetVocabulary != null) {
                                categories = assetVocabulary.getCategories();
                            } else {
                                try {
                                    categories = AssetCategoryServiceUtil.getChildCategories(assetCategory.getCategoryId(), QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);
                                } catch (PortalException e) {
                                    _logView.error(e);
                                }
                            }

                            // ajout des donn�es de count
                            List<AssetCategoryNodeModel> assetCategoryNodeModelList = new ArrayList<>();

                            // Si la liste est vide, soit pas de résultats, soit pas de facet Category Lfieray configurée
                            if (!isEmptyResultList) {
                                try {
                                    assetCategoryNodeModelList = _transformCategoryToCategoryNode(categories, nodes, locale);
                                } catch (PortalException e) {
                                    _logView.error(e);
                                }
                            } else {
                                try {
                                    assetCategoryNodeModelList = _transformCategoryToCategoryNodeIfNoResult(categories, locale);
                                } catch (PortalException e) {
                                    _logView.error(e);
                                }
                            }

                            // Utilisation des nouveaux objets
                            for (AssetCategoryNodeModel curAssetCategoryNodeModel : assetCategoryNodeModelList) {

                                String categoriesNavigation = CategoryTreeFacetPortletKeys.BLANK;

                                try {
                                    categoriesNavigation = _buildCategoryNavigation(categories, curAssetCategoryNodeModel, themeDisplay, displayAssetCount);
                                } catch (Exception e) {
                                    _logView.error(e);
                                }

                                if (categoriesNavigation.contains("checked")) {
                                    isEmptyFormList.add(true);
                                } else {
                                    isEmptyFormList.add(false);
                                }
                        %>

                        <%= categoriesNavigation %>

                        <%
                            }
                        %>

                        <c:if test="<%= isEmptyFormList.contains(true) %>">
                            <aui:a cssClass="text-default" href="javascript:;"
                                   onClick="Liferay.Search.FacetUtil.clearSelections(event);"><small><liferay-ui:message
                                    key="clear"/></small></aui:a>
                        </c:if>
                    </aui:form>
                </liferay-ui:panel>
            </liferay-ui:panel-container>
        </div>
    </c:when>
    <%--                <c:otherwise>--%>
    <%--                    <liferay-ui:message key="configure-category-tree-facet"/>--%>
    <%--                </c:otherwise>--%>
    <%--            </c:choose>--%>
    <%--        </c:when>--%>
    <c:otherwise>
        <liferay-ui:message key="please-configure-facet"/>
    </c:otherwise>
</c:choose>
<%--</c:if>--%>


<%!
    private String _buildCategoryNavigation(List<AssetCategory> categories, AssetCategoryNodeModel curCategoryNode, ThemeDisplay themeDisplay, String displayAssetCount) {

        StringBundler sb = new StringBundler();

        String uniqueID = UUID.randomUUID().toString();

        if (!categories.contains(curCategoryNode.getAssetCategory().getParentCategory())) {

            sb.append("<div class=\"category\">");
            sb.append("<ul class=\"tree-node-custom\">");

            sb.append("<li class=\"node-custom\">");

            if (!curCategoryNode.getChildrenAssetCategoriesNodes().isEmpty()) {
                sb.append("<span class=\"caret-custom-cirad glyphicon glyphicon-menu-down\" onClick=\"toggleTreeElementCirad(event)\"></span>");
            } else {
                sb.append("<span style='width:19.36px'></span>");
            }

            sb.append("<label class=\"facet-checkbox-label\" for=\"" + themeDisplay.getPortletDisplay().getId() + "_term_parent_" + uniqueID + "\">");
            sb.append("<input class=\"facet-term\" data-term-id=\"" + curCategoryNode.getAssetCategory().getCategoryId() + "\" id=\"" + themeDisplay.getPortletDisplay().getId() + "_term_parent_" + uniqueID + "\" name=\"" + themeDisplay.getPortletDisplay().getId() + "_term_parent_" + uniqueID + "\" onChange=\"changeSelectionAllCirad(event);\" type=\"checkbox\" ");

            if (curCategoryNode.isChecked()) {
                sb.append(" checked");
            }

            if (curCategoryNode.getCount() == 0) {
                sb.append("disabled ");
            }

            sb.append("/> ");

            sb.append("<span class=\"term-name-parent term-name facet-term-unselected\">");
            sb.append(HtmlUtil.escape(curCategoryNode.getAssetCategory().getTitle(themeDisplay.getLocale())));
            sb.append(" </span>");

            if (Boolean.parseBoolean(displayAssetCount)) {
                sb.append("<small class=\"term-count\">(" + curCategoryNode.getCount() + ")</small>");
            }

            sb.append("</label>");
            sb.append("</li>");

            if (!curCategoryNode.getChildrenAssetCategoriesNodes().isEmpty()) {
                sb.append("<ul class=\"nested active\">");
                _buildChildCategoriesNavigation(curCategoryNode.getChildrenAssetCategoriesNodes(), themeDisplay, sb, displayAssetCount);
                sb.append("</ul>");
            }

            sb.append("</ul>");
            sb.append("</div>");
        }

        return sb.toString();
    }

    private void _buildChildCategoriesNavigation(List<AssetCategoryNodeModel> childCategoriesNodes, ThemeDisplay themeDisplay, StringBundler sb, String displayAssetCount) {

        for (AssetCategoryNodeModel childCategoryNode : childCategoriesNodes) {

            String uniqueID = UUID.randomUUID().toString();

            sb.append("<li class=\"node-custom\">");

            if (!childCategoryNode.getChildrenAssetCategoriesNodes().isEmpty()) {
                sb.append("<span class=\"caret-custom-cirad glyphicon glyphicon-menu-down\" onClick=\"toggleTreeElementCirad(event)\"></span>");
            } else {
                sb.append("<span style='width:19.36px'></span>");
            }

            sb.append("<label class=\"facet-checkbox-label\" for=\"" + themeDisplay.getPortletDisplay().getId() + "_term_children_" + uniqueID + "\">");
            sb.append("<input class=\"facet-term\" data-term-id=\"" + childCategoryNode.getAssetCategory().getCategoryId() + "\" id=\"" + themeDisplay.getPortletDisplay().getId() + "_term_children_" + uniqueID + "\" name=\"" + themeDisplay.getPortletDisplay().getId() + "_term_children_" + uniqueID + "\" onChange=\"changeSelectionAllCirad(event);\" type=\"checkbox\" ");

            if (childCategoryNode.getCount() == 0) {
                sb.append("disabled ");
            }

            if (childCategoryNode.isChecked()) {
                sb.append(" checked");
            }

            sb.append("/> ");

            sb.append("<span class=\"term-name-children term-name facet-term-unselected\">");
            sb.append(HtmlUtil.escape(childCategoryNode.getAssetCategory().getTitle(themeDisplay.getLocale())));
            sb.append(" </span>");

            if (Boolean.parseBoolean(displayAssetCount)) {
                sb.append("<small class=\"term-count\">(" + childCategoryNode.getCount() + ")</small>");
            }

            sb.append("</label>");
            sb.append("</li>");

            if (!childCategoryNode.getChildrenAssetCategoriesNodes().isEmpty()) {
                sb.append("<ul class=\"nested active\">");
                _buildChildCategoriesNavigation(childCategoryNode.getChildrenAssetCategoriesNodes(), themeDisplay, sb, displayAssetCount);
                sb.append("</ul>");
            }
        }
    }

    private List<AssetCategoryNodeModel> _transformCategoryToCategoryNode(List<AssetCategory> categories, List<HtmlNodeCategoryModel> nodes, Locale locale) throws PortalException {

        List<AssetCategoryNodeModel> assetCategoryNodeModels = new ArrayList<>();

        for (AssetCategory curCategory : categories) {

            List<AssetCategory> childrenAssetCategories = _getChildrenCategories(curCategory);

            List<AssetCategoryNodeModel> childrenAssetCategoriesNodes = _transformCategoryToCategoryNode(childrenAssetCategories, nodes, locale);

            AssetCategoryNodeModel newAssetCategoryNodeModel = new AssetCategoryNodeModel(curCategory, childrenAssetCategoriesNodes, 0, false);

            for (HtmlNodeCategoryModel node : nodes) {
                if (curCategory.getTitle(locale).equals(node.getLabel())) {
                    newAssetCategoryNodeModel.setCount(node.getCount());
                    newAssetCategoryNodeModel.setChecked(node.isChecked());
                }
            }

            assetCategoryNodeModels.add(newAssetCategoryNodeModel);
        }

        for (AssetCategoryNodeModel assetCategoryNodeModel : assetCategoryNodeModels) {
            int sumCount = assetCategoryNodeModel.getCount();
            assetCategoryNodeModel.setCount(_generateSumCount(assetCategoryNodeModel, sumCount));
        }

        return assetCategoryNodeModels;
    }

    private List<AssetCategoryNodeModel> _transformCategoryToCategoryNodeIfNoResult(List<AssetCategory> categories, Locale locale) throws PortalException {

        List<AssetCategoryNodeModel> assetCategoryNodeModels = new ArrayList<>();

        for (AssetCategory curCategory : categories) {

            List<AssetCategory> childrenAssetCategories = _getChildrenCategories(curCategory);

            List<AssetCategoryNodeModel> childrenAssetCategoriesNodes = _transformCategoryToCategoryNodeIfNoResult(childrenAssetCategories, locale);

            assetCategoryNodeModels.add(new AssetCategoryNodeModel(curCategory, childrenAssetCategoriesNodes, 0, false));
        }

        for (AssetCategoryNodeModel assetCategoryNodeModel : assetCategoryNodeModels) {
            int sumCount = assetCategoryNodeModel.getCount();
            assetCategoryNodeModel.setCount(_generateSumCount(assetCategoryNodeModel, sumCount));
        }

        return assetCategoryNodeModels;
    }

    private int _generateSumCount(AssetCategoryNodeModel assetCategoryNodeModel, int sumCount) {

        List<AssetCategoryNodeModel> curChildrenAssetCategories = assetCategoryNodeModel.getChildrenAssetCategoriesNodes();

        if (!curChildrenAssetCategories.isEmpty()) {
            for (AssetCategoryNodeModel curAssetCategoryNodeModel : curChildrenAssetCategories) {
                sumCount += curAssetCategoryNodeModel.getCount();
                sumCount += _generateSumCount(curAssetCategoryNodeModel, 0);
            }
        }

        return sumCount;
    }

    private List<AssetCategory> _getChildrenCategories(AssetCategory assetCategory) throws PortalException {

        return AssetCategoryServiceUtil.getChildCategories(assetCategory.getCategoryId(), QueryUtil.ALL_POS, QueryUtil.ALL_POS, null);
    }


    private static Log _logView = LogFactoryUtil.getLog("CategoryTreeFacet.view_jsp");
%>