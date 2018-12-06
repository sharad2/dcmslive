

<%@ Control Language="C#" CodeFile="ReleaseCandidate.ascx.cs" Inherits="ReleaseCandidate" %>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4262 $
 *  $Author: rverma $
 *  $HeadURL: svn://vcs/net4/Projects/DcmsLive/trunk/Web/ReleaseCandidate.ascx $
 *  $Id: ReleaseCandidate.ascx 4262 2012-08-17 11:12:30Z rverma $
 * Version Control Template Added.
 *
--%>
<asp:MultiView runat="server" ID="mvRc" OnLoad="mvRc_Load">
    <asp:View runat="server" ID="viewHomePage" OnPreRender="viewHomePage_PreRender">
        <div id="divMsg" runat="server" class="ui-state-highlight">
        </div>
        <jquery:Accordion ID="pnl_rptr" runat="server" Collapsible="true" SelectedIndex="-1">
            <jquery:JPanel ID="panelRc" runat="server" HeaderText="{0:N0} Release Candidates Available">
                <asp:Repeater runat="server" ID="repRc">
                    <HeaderTemplate>
                        <dl>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <dt id="hlink">
                            <asp:HyperLink ID="HyperLink3" runat="server" NavigateUrl='<%# Eval("Url") %>'><%# Eval("ReportNumber")%></asp:HyperLink>
                            <%# Eval("Title") %>. <em title='<%# Eval("CreationDate", "Posted on {0}") %>'>Posted
                                <%# Eval("DaysAgo") %>.</em>
                            <asp:ListView ID="ListView1" runat="server" DataSource='<%# Eval("ListApprovedBy") %>'>
                                <LayoutTemplate>
                                    Approved by <span id="itemPlaceHolder" runat="server"></span>.
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <span title='<%# string.Format("Approved on {0} {1}", Eval("StatusDate"), Eval("UserComment"))%>'>
                                        <%# Eval("UserDisplayName")%></span>
                                </ItemTemplate>
                                <ItemSeparatorTemplate>
                                    ,
                                </ItemSeparatorTemplate>
                            </asp:ListView>
                            <asp:ListView ID="ListView2" runat="server" DataSource='<%# Eval("ListRejectedBy") %>'>
                                <LayoutTemplate>
                                    <span class="ui-state-error"><span id="itemPlaceHolder" runat="server"></span>rejected
                                        this report. </span>
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <span title='<%# string.Format("Rejected on {0} {1}", Eval("StatusDate"), Eval("UserComment"))%>'>
                                        <%# Eval("UserDisplayName")%></span>
                                </ItemTemplate>
                                <ItemSeparatorTemplate>
                                    ,
                                </ItemSeparatorTemplate>
                            </asp:ListView>
                            <asp:ListView ID="ListView3" runat="server" DataSource='<%# Eval("ListPending") %>'>
                                <LayoutTemplate>
                                    Waiting for approval from <span id="itemPlaceHolder" runat="server"></span>
                                </LayoutTemplate>
                                <ItemTemplate>
                                    <%# Eval("UserDisplayName")%></span>
                                </ItemTemplate>
                                <ItemSeparatorTemplate>
                                    ,
                                </ItemSeparatorTemplate>
                            </asp:ListView>
                            <asp:PlaceHolder runat="server" Visible='<%# Eval("HasNoApprovers") %>'><span class="ui-state-error">
                                This report has no approvers</span> </asp:PlaceHolder>
                        </dt>
                        <dd>
                            <asp:BulletedList ID="BulletedList2" runat="server" DataSource='<%# Eval("ChangeLog") %>'
                                BulletStyle="Numbered" />
                            <asp:Literal runat="server" ID="ltrApproved" Visible='<%# Eval("IsApproved") %>'>
                                <p class="ui-state-highlight">All Approvals have been obtained. This report will be deployed soon.</p>
                            </asp:Literal>
                        </dd>
                    </ItemTemplate>
                    <FooterTemplate>
                        </dl>
                    </FooterTemplate>
                </asp:Repeater>
            </jquery:JPanel>
        </jquery:Accordion>
    </asp:View>
    <asp:View runat="server" ID="viewHasRc">
        <fieldset>
            <legend>
                <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# this.CurrentReport.UrlOther %>'
                    Target="_blank">Release Candidate</asp:HyperLink>
                Posted on
                <%# this.CurrentReport.CreationDate.ToShortDateString() %>. </legend>
            <asp:BulletedList ID="BulletedList1" runat="server" BulletStyle="Numbered" DataSource='<%# this.CurrentReport.ChangeLog %>' />
            <p>
                <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex='<%# this.CurrentReport.CurrentUserApprovalStatus.Status %>'>
                    <asp:View ID="View4" runat="server">
                    </asp:View>
                    <asp:View ID="View3" runat="server">
                        <span class="ui-state-highlight">Your approval is pending. </span>
                    </asp:View>
                    <asp:View ID="View1" runat="server">
                        <span class="ui-state-highlight">You have approved this report.
                            <%# this.CurrentReport.CurrentUserApprovalStatus.UserComment %>
                        </span>
                    </asp:View>
                    <asp:View ID="View2" runat="server">
                        <span class="ui-state-highlight">You have rejected this release candidate.
                            <%# this.CurrentReport.CurrentUserApprovalStatus.UserComment %>
                        </span>
                    </asp:View>
                </asp:MultiView>
                <%# this.CurrentReport.ListApprovedBy.Count() %>
                approvals received.
                <%# this.CurrentReport.ListRejectedBy.Count() %>
                rejections.
                <%# this.CurrentReport.ListPending.Count() %>
                approvals awaited.
            </p>
        </fieldset>
    </asp:View>
    <asp:View ID="viewIsRc" runat="server">
        <div class="ui-state-active">
            <h2 style="display: inline-block">
                This is a release candidate.</h2>
            <em>Posted on
                <%= this.CurrentReport.CreationDate %></em>.
            <br />
            <asp:ListView runat="server" ID="repRcApproved" DataSource='<%# this.CurrentReport.ListApprovedBy.Where(p=>p.UserId != HttpContext.Current.User.Identity.Name) %>'>
                <LayoutTemplate>
                    Approved by
                    <ol>
                        <li id="itemPlaceHolder" runat="server"></li>
                    </ol>
                </LayoutTemplate>
                <ItemTemplate>
                    <li><em>
                        <%# Eval("UserDisplayName")%>.</em>
                        <%# Eval("UserComment") %>
                    </li>
                </ItemTemplate>
            </asp:ListView>
            <asp:ListView runat="server" ID="repRcDisApproved" DataSource='<%# this.CurrentReport.ListRejectedBy.Where(p=>p.UserId != HttpContext.Current.User.Identity.Name) %>'>
                <LayoutTemplate>
                    Rejected by
                    <ol>
                        <li id="itemPlaceHolder" runat="server"></li>
                    </ol>
                </LayoutTemplate>
                <ItemTemplate>
                    <li><em>
                        <%# Eval("UserDisplayName")%>.</em>
                        <%# Eval("UserComment") %>
                    </li>
                </ItemTemplate>
            </asp:ListView>
            <asp:ListView runat="server" ID="repRcPending" DataSource='<%# this.CurrentReport.ListPending %>'>
                <LayoutTemplate>
                    Waiting for approvals from <span id="itemPlaceHolder" runat="server"></span>.
                </LayoutTemplate>
                <ItemTemplate>
                    <span>
                        <%# Eval("UserDisplayName")%></span>
                </ItemTemplate>
                <ItemSeparatorTemplate>
                    ,
                </ItemSeparatorTemplate>
            </asp:ListView>
            <asp:PlaceHolder ID="PlaceHolder3" runat="server" Visible='<%# this.CurrentReport.IsCurrentUserAnApprover %>'>
                <style type="text/css">
                    .feedback
                    {
                        font-size: 10pt;
                        margin-bottom: 2mm;
                    }
                </style>
                <asp:Panel runat="server" GroupingText="Your Feedback" ID="divApproveDisApprove"
                    Style="font-size: 10pt">
                    <div class="feedback">
                        <asp:RadioButton runat="server" Checked='<%# this.CurrentReport.CurrentUserApprovalStatus.HasApproved %>'
                            ID="rbApprove" ClientIDMode="Static" GroupName="feedback" data-url='<%# ResolveUrl("~/PickersAndServices/ReleaseCandidate.asmx/ApproveReport") %>' />
                        <label for="rbApprove" style="display: inline-block; width: 12em">
                            Approve</label>
                        <asp:RadioButton runat="server" Checked='<%# this.CurrentReport.CurrentUserApprovalStatus.HasDisApproved %>'
                            ID="rbDisApprove" ClientIDMode="Static" GroupName="feedback" data-url='<%# ResolveUrl("~/PickersAndServices/ReleaseCandidate.asmx/DisApproveReport") %>' />
                        <label for="rbDisApprove">
                            Disapprove</label>
                        <br />
                        Remarks (optional)
                        <br />
                        <textarea rows="5" cols="50" id="txtComments"><%# this.CurrentReport.CurrentUserApprovalStatus.UserComment %></textarea>
                        <br />
                        <input type="button" id="btnSubmit" data-reportid='<%# this.CurrentReport.ReportId %>'
                            data-version='<%# this.CurrentReport.VersionNumber %>' value="Submit" style="font-size: 8pt" />
                    </div>
                    <div class="ui-state-highlight ui-helper-hidden" id="divGotFeedback">
                        Thank you. Your feedback has been recorded.
                    </div>
                </asp:Panel>
                <script type="text/javascript">
                    $(document).ready(function () {
                        $('#btnSubmit').button();
                        $('#btnSubmit').click(function () {
                            var url;
                            if ($('#rbApprove').is(':checked')) {
                                url = $('#rbApprove').parent().attr('data-url');
                            }
                            else if ($('#rbDisApprove').is(':checked')) {
                                url = $('#rbDisApprove').parent().attr('data-url');
                            }
                            else {
                                alert('Please Select Approve/DisApprove');
                                return false;
                            }
                            $.ajax({
                                type: "POST",
                                url: url,
                                data: JSON.stringify({ reportId: $(this).attr('data-reportid'), userId: '<%# this.CurrentReport.CurrentUserApprovalStatus.AjaxUserId %>', version: $(this).attr('data-version'), approvalStatusDate: '<%# DateTime.Now %>', comments: $('#txtComments').val() }),
                                contentType: "application/json; charset=utf-8"
                            }).done(function (data, textStatus, jqXHR) {
                                $('#divGotFeedback').show();
                            }).fail(function (jqXHR, textStatus, errorThrown) {
                                alert(textStatus + ' * ' + jqXHR.responseText);
                            });

                        });

                    });
                </script>
            </asp:PlaceHolder>
            <asp:PlaceHolder runat="server" Visible='<%# this.CurrentReport.IsNewReportVersion  %>'>
                For comparison purposes, current report can be found
                <asp:HyperLink ID="HyperLink2" runat="server" NavigateUrl='<%# this.CurrentReport.UrlOther %>'
                    Target="_blank"><em>here</em></asp:HyperLink>.
                <asp:BulletedList ID="BulletedList3" runat="server" BulletStyle="Numbered" DataSource='<%# this.CurrentReport.ChangeLog %>' />
            </asp:PlaceHolder>
            <br />
            <asp:PlaceHolder runat="server" Visible='<%# this.CurrentReport.IsNewReport %>'>This
                is a New Report
                <asp:BulletedList ID="BulletedList4" runat="server" BulletStyle="Numbered" DataSource='<%# this.CurrentReport.ChangeLog %>' />
            </asp:PlaceHolder>
        </div>
    </asp:View>
</asp:MultiView>
<asp:PlaceHolder runat="server" ID="plhAllReports" Visible="false">
    <div style="background-color: #9A82FB; color: White; margin: 2mm 2mm 2mm 2mm; padding: 1mm 1mm 1mm 1mm">
        <script type="text/javascript">
            function AddApprover() {
                $.ajax({
                    type: "POST",
                    url: '<%# ResolveUrl("~/PickersAndServices/ReleaseCandidate.asmx/AddApprover") %>',
                    data: JSON.stringify({ reportId: '<%# this.CurrentReport.ReportId %>', userId: '<%# this.CurrentReport.CurrentUserApprovalStatus.AjaxUserId %>' }),
                    contentType: "application/json; charset=utf-8"
                }).done(function (data, textStatus, jqXHR) {
                    $('#panelRemoveApprover').show();
                    $('#panelAddApprover').hide();
                }).fail(function (jqXHR, textStatus, errorThrown) {
                    alert(textStatus + ' * ' + jqXHR.responseText);
                });
            }
            function RemoveApprover() {
                $.ajax({
                    type: "POST",
                    url: '<%# ResolveUrl("~/PickersAndServices/ReleaseCandidate.asmx/RemoveApprover") %>',
                    data: JSON.stringify({ reportId: '<%# this.CurrentReport.ReportId %>', userId: '<%# this.CurrentReport.CurrentUserApprovalStatus.AjaxUserId %>' }),
                    contentType: "application/json; charset=utf-8"
                }).done(function (data, textStatus, jqXHR) {
                    $('#panelRemoveApprover').hide();
                    $('#panelAddApprover').show();
                }).fail(function (jqXHR, textStatus, errorThrown) {
                    alert(textStatus + ' * ' + jqXHR.responseText);
                });
            }
        </script>
        <asp:Panel runat="server" ID="panelAddApprover" CssClass='<%# this.CurrentReport.CurrentUserApprovalStatus.IsApprover ? "ui-helper-hidden" : "" %>'>
            By designating yourself as an approver of this report, you will ensure that the
            report will never be updated without your explicit approval. <a href="javascript:AddApprover()"
                style="color: White; text-decoration: underline">Add Me</a>.
        </asp:Panel>
        <asp:Panel runat="server" ID="panelRemoveApprover" CssClass='<%# this.CurrentReport.CurrentUserApprovalStatus.IsApprover ? "" : "ui-helper-hidden"%>'>
            <span class="ui-icon ui-icon-check" style="display: inline-block"></span>You are
            a designated approver of this report. <a href="javascript:RemoveApprover()" style="color: White;
                text-decoration: underline">Remove me</a>.
        </asp:Panel>
        <asp:Repeater runat="server" ID="repAllApprovers" DataSource='<%# this.CurrentReport.Approvers.Where(p=>p.UserId != HttpContext.Current.User.Identity.Name) %>'>
            <HeaderTemplate>
                <div style="margin-top: 2mm">
                Other designated approvers of this report are
            </HeaderTemplate>
            <ItemTemplate>
                <%# Eval("UserDisplayName")%>
            </ItemTemplate>
            <SeparatorTemplate>
                ,
            </SeparatorTemplate>
            <FooterTemplate>
                .</div>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</asp:PlaceHolder>


