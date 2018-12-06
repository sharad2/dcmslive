<%@ Page Title="Manage DCMS Live Preferences" Language="C#" MasterPageFile="~/MasterPage.master" %>

<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 4535 $
 *  $Author: skumar $
 *  $HeadURL: http://server/svn/dcmslive/Projects/DcmsLive/trunk/Web/Preferences.aspx $
 *  $Id: Preferences.aspx 4535 2012-09-24 11:45:06Z skumar $
 * Version Control Template Added.
 *
--%>
<script runat="server">
    void blRoles_PreRender(object sender, EventArgs e)
    {
        BulletedList blRoles = (BulletedList)sender;
        if (Roles.Enabled)
        {
            string[] roles = Roles.GetRolesForUser();
            blRoles.DataSource = roles;
            blRoles.DataBind();
        }
    }
    
    protected void btnSave_Click(object sender, EventArgs e)
    {
        this.Profile.ReportsInNewWindow = cbNewWindow.Checked;
        this.Profile.Save();
        //this.Profile.RestartSequencePerMaster = true;
    }

    // Sharad 24 Sep 2012: No need to explicitly data bind because it should be automatic.
    // It also breaks the ReleaseCandidates.ascx control
    protected override void OnPreRender(EventArgs e)
    {
        cbNewWindow.DataBind();
        base.OnPreRender(e);
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <meta name="Version" content="$Id: Preferences.aspx 4535 2012-09-24 11:45:06Z skumar $" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="ui-widget">
        <div class="ui-widget-content">
            <asp:CheckBox ID="cbNewWindow" runat="server" Checked='<%# this.Profile.ReportsInNewWindow %>' />Open Reports in new window.
            <br />
            Check here if you wish to open each report in a seperate browser window. This only
            applies when you click a report link on the home page.
            <br />
            <br />
            <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
            
            <asp:LoginView ID="LoginView1" runat="server">
                <AnonymousTemplate>
                    <p>
                        You are not logged in so links requiring authentication will not be visible to you.
                    </p>
                </AnonymousTemplate>
                <LoggedInTemplate>
                    <p>
                        We know you as
                        <asp:LoginName ID="LoginName1" runat="server" Font-Italic="true" />
                        . Currently you belong to these Roles:
                    </p>
                    <asp:BulletedList ID="blRoles" runat="server" OnPreRender="blRoles_PreRender" />
                </LoggedInTemplate>
            </asp:LoginView>
        </div>
    </div>
</asp:Content>
