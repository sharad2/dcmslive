<%@ Page Language="C#" MasterPageFile="~/MasterPage.master" CodeFile="Default.aspx.cs"
    Inherits="_Default" Title="Home Page" ClientIDMode="Static" %>

<%@ Import Namespace="EclipseLibrary.Web.Extensions" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 5395 $
 *  $Author: skumar $
 *  $HeadURL: http://vcs.eclipse.com/svn/net35/Projects/XTremeReporter3/trunk/Website/Default.aspx$
 *  $Id: Default.aspx 5395 2013-05-31 04:56:17Z skumar $
 * Version Control Template Added.
 *
--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('#divCategories').accordion({ header: 'h3', autoHeight: false, collapsible: true, active: 0 });
            $('#divFavorites').droppable({
                accept: '#divQuicklinks .ui-button',
//                activate: function (event, ui) {
//                    // Highlight the button if it is already a favorite
//                    var $btn = $('> span[title=' + ui.draggable.parent().attr('title') + '] > .ui-button', this)
//                        .removeClass('ui-state-default').addClass('ui-state-highlight');
//                    if ($btn.length == 0) {
//                        $(this).addClass('ui-state-highlight');
//                    }
//                },
//                deactivate: function (event, ui) {
//                    var $btn = $('> span[title=' + ui.draggable.parent().attr('title') + '] > .ui-button', this)
//                        .addClass('ui-state-default').removeClass('ui-state-highlight');
//                    if ($btn.length == 0) {
//                        $(this).removeClass('ui-state-highlight');
//                    }
//                },
                drop: function (event, ui) {
//                    var $btn = $('> span[title=' + ui.draggable.parent().attr('title') + '] > .ui-button', this);
//                    if ($btn.length > 0) {
//                        // Ignore the drop
//                        return;
//                    }
                    var $self = $(this);
                    // Make an ajax call to add favorite. On success, update UI
                    $.ajax({
                        cache: false,
                        data: { report_key: ui.draggable.parent().attr('title'), action: 'add_fav' },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            $self.html(XMLHttpRequest.responseText);
                        },
                        success: function (data, textStatus) {
                            var $clone = ui.draggable.parent().clone();
                            $('span.ui-icon', $clone).attr('class', 'ui-icon ui-icon-heart');
                            $('.ui-button', $clone).draggable({ revert: 'invalid', handle: 'span.ui-icon' });
                            $self.append($clone);
                        },
                        type: 'POST',
                        url: 'AjaxHelper.aspx'
                    });
                }
            }).disableSelection().find('.ui-button').draggable({ revert: 'invalid', handle: 'span.ui-icon' });

            $('#qlInstructions').droppable({
                accept: '#divFavorites .ui-button',
                activeClass: 'ui-state-highlight',
                drop: function (event, ui) {
                    $.ajax({
                        cache: false,
                        data: { report_key: ui.draggable.parent().attr('title'), action: 'remove_fav' },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            $self.html(XMLHttpRequest.responseText);
                        },
                        success: function (data, textStatus) {
                            ui.draggable.parent().remove();
                        },
                        type: 'POST',
                        url: 'AjaxHelper.aspx'
                    });
                }
            }).disableSelection();

            $('#divQuicklinks .ui-button')
                .draggable({ revert: 'invalid', handle: 'span.ui-icon', helper: 'clone' });
        });
    </script>
    <style type="text/css">
        .ui-draggable span.ui-icon
        {
            cursor: move;
        }
        /* Make the button thinner */
        .ui-button-text-icon-primary .ui-button-text 
        {
            line-height:normal!important;
            padding-top:2px!important;
            padding-bottom:2px!important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <p>
        <asp:MultiView runat="server" ID="mvStats" ActiveViewIndex="0">
            <asp:View runat="server">
                Execution times displayed against each report are updated hourly and were last updated
                <em>
                    <%= (DateTime.Now - __statUpdateTime).Format() %></em> ago. If you need up to
                the minute statistics, you can
            </asp:View>
            <asp:View runat="server">
                The following error occured while attempting to retrieve report execution statistics:
                <br />
                <asp:Label runat="server" ID="lblError" CssClass="ui-state-error" />.
                <br />
                You can attempt to try again by clicking
            </asp:View>
        </asp:MultiView>
        <i:LinkButtonEx ID="btnUpdateNow" runat="server" Text="Update Now" OnClick="btnUpdateNow_Click" />
        .
    </p>
<%--    <p>
        <span class="ui-state-highlight ui-button ui-widget ui-corner-all ui-button-text-icon-primary" style="cursor:default"><span class="ui-button-icon-primary ui-icon ui-icon-extlink"></span><span class="ui-button-text">Legacy Reports</span></span>
        <strong style="font-size:1.2em">will be removed on 1<sup>st</sup> July 2013</strong>.
        Legacy Reports run on an old reporting server which we plan to remove. If you use any of these reports, please send an e-mail to IT so that we can move the report to our new server.
    </p>--%>
    <div class="ui-widget">
        <div class="ui-widget-header">
            Favorites
        </div>
        <div class="ui-widget-content">
            <div id="divFavorites" style="min-height: 2em">
                <asp:Repeater ID="repFavorites" runat="server">
                    <ItemTemplate>
                        <span title='<%# Eval("Key") %>'>
                            <i:ButtonEx runat="server" Icon="Heart" ToolTip='<%# Eval("Title") %>' Action='<%# Eval("LinkTarget") %>'
                                Text='<%# Eval("ReportId") %>' OnClientClick='<%# Eval("Url") %>' />
                        </span>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <p id="qlInstructions" style="text-align: center; font-size: smaller">
                <i:ButtonEx runat="server" Icon="Trash" ToolTip="Updated report" />
                Drop <em>quick link</em> <%--of updated report--%> above to add to favorite list. Drag favorite
                here to remove it.
                <i:ButtonEx runat="server" Icon="Trash" ToolTip="Updated report" />
            </p>
        </div>
    </div>
    <asp:Repeater ID="repQuickLinks" runat="server">
        <HeaderTemplate>
            <div class="ui-widget">
                <div class="ui-widget-header" style="padding: 1mm 1mm 1mm 1mm">
                    Quick Links&nbsp;
                    <%--<i:ButtonEx runat="server" Icon="Custom" CustomIconName='<%# Profile.ReportsInNewWindow ? "ui-icon-newwin" : "ui-icon-link"%>' />
                    &nbsp;Updated Report &bull;
                    <i:ButtonEx runat="server" Icon="Custom" CustomIconName="ui-icon-extlink" CssClasses="ui-state-error" />
                    &nbsp;Original Report--%>
                    <%--&bull;
                    <i:ButtonEx runat="server" Icon="Custom" CustomIconName="ui-icon-extlink" CssClasses="ui-state-highlight" />
                    &nbsp;Legacy Report--%>
                </div>
                <div class="ui-widget-content" id="divQuicklinks">
        </HeaderTemplate>
        <ItemTemplate>
            <span title='<%# Eval("Key") %>'>
                <i:ButtonEx runat="server" CssClasses='<%# Eval("IconState") %>' Icon="Custom" CustomIconName='<%# Eval("Image") %>'
                    ToolTip='<%# Eval("Title") %>' OnClientClick='<%# Eval("Url") %>' Text='<%# Eval("ReportId") %>'
                    Width="6em" Action='<%# Eval("LinkTarget") %>' />
            </span>
        </ItemTemplate>
        <FooterTemplate>
            </div></div>
        </FooterTemplate>
    </asp:Repeater>
    <div style="margin-top: 0.5in">
        <asp:Repeater ID="repCategories" runat="server" OnItemDataBound="repCategories_ItemDataBound"
            OnItemCreated="repCategories_ItemCreated">
            <HeaderTemplate>
                <div id="divCategories">
            </HeaderTemplate>
            <ItemTemplate>
                <h3>
                    <a href="#">
                        <asp:Literal runat="server" ID="litCategoryHeader" />
                    </a>
                </h3>
                <jquery:GridViewEx runat="server" ID="gvDetailLinks" AutoGenerateColumns="false"
                    CellPadding="2" ClientIDMode="Predictable">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <i:ButtonEx runat="server" CssClasses='<%# Eval("IconState") %>' Icon="Custom" CustomIconName='<%# Eval("Image") %>'
                                    ToolTip='<%# Eval("ImageTitle") %>' ClientIDMode="Static" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField SortExpression="ReportId" HeaderText="ID">
                            <ItemTemplate>
                                <asp:HyperLink runat="server" Text='<%# Eval("ReportId") %>' NavigateUrl='<%# Eval("Url") %>'
                                    Target='<%# Eval("LinkTarget") %>' ClientIDMode="Static" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <eclipse:MultiBoundField HeaderText="Av Sec" DataFields="AverageQuerySeconds" DataFormatString="{0:N2}"
                            ToolTipFields="MinQuerySeconds,MaxQuerySeconds" ToolTipFormatString="Min {0:N2} sec to Max {1:N2} sec"
                            HeaderToolTip="Average number of seconds this report requires for execution">
                            <ItemStyle HorizontalAlign="Right" />
                        </eclipse:MultiBoundField>
                        <eclipse:MultiBoundField HeaderText="Hits" DataFields="HitCount" DataFormatString="{0:N0}">
                            <ItemStyle HorizontalAlign="Right" />
                        </eclipse:MultiBoundField>
                        <asp:BoundField DataField="Title" HeaderText="Title" />
                        <asp:BoundField DataField="Description" HeaderText="Description" />
                    </Columns>
                </jquery:GridViewEx>
            </ItemTemplate>
            <FooterTemplate>
                </div>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</asp:Content>
