<%@ Control Language="C#" ClassName="ButtonBar2" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="EclipseLibrary.WebForms.Oracle" %>
<%@ Import Namespace="EclipseLibrary.Web.JQuery" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.IO" %>
<%--Sharad 20 Jul 2012: This version is identical to version 4461--%>
<%--*
 *  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 *  E-mail: support@eclsys.com
 *
 *  $Revision: 39423 $
 *  $Author: ssinghal $
 *  $HeadURL: http://vcs.eclipse.com/svn/net35/Projects/XTremeReporter3/trunk/Website/ButtonBar.ascx$
 *  $Id: ButtonBar2.ascx 39423 2011-01-13 08:22:01Z ssinghal $
 * Version Control Template Added.
 *
--%>
<script runat="server">

    /// <summary>
    /// AppliedFilters displays values of controls in this container. If the container is a tab,
    /// it is collapsed when a query is executed.
    /// The query of the data source is cancelled when the page is initially requested (i.e. no postback)
    /// if there is no query string.
    /// Display as simple table checkbox becomes visible if the default sort expression contains $.
    /// </summary>
    [Browsable(true)]
    [DefaultValue("tabs")]
    public string FilterContainerId { get; set; }

    /// <summary>
    /// Detects the data source of the grid view.
    /// Then hooks up to data source events for cancelling query and making applied filters visible.
    /// When export to excel is clicked, exports grid data to excel
    /// </summary>
    /// <remarks>
    /// Default button is set to btnGo
    /// </remarks>
    [Browsable(true)]
    [DefaultValue("gv")]
    public string GridViewId { get; set; }

    public AppliedFilters Filters
    {
        get
        {
            return this.af;
        }
    }

    protected override void OnLoad(EventArgs e)
    {
        this.Page.Form.DefaultButton = btnGo.UniqueID;
        if (string.IsNullOrEmpty(this.FilterContainerId))
        {
            this.FilterContainerId = "tabs";
        }
        af.Container = this.NamingContainer.FindControl(this.FilterContainerId);
        string str = this.Request.AppRelativeCurrentExecutionFilePath;
        str = Path.GetFileNameWithoutExtension(str);
        btnDoc.OnClientClick = this.Request.AppRelativeCurrentExecutionFilePath.Replace(str + ".aspx", str + ".htm");

        if (string.IsNullOrEmpty(this.GridViewId))
        {
            this.GridViewId = "gv";
        }
        GridViewEx gv = (GridViewEx)this.NamingContainer.FindControl(this.GridViewId);
        gv.PageIndexChanged += new EventHandler(gv_PageIndexChanged);
        gv.DataBound += new EventHandler(gv_DataBound);
        OracleDataSource ds = (OracleDataSource)this.NamingContainer.FindControl(gv.DataSourceID);
        ds.Selecting += new SqlDataSourceSelectingEventHandler(ds_Selecting);
        ds.PostSelected += new EventHandler<PostSelectedEventArgs>(ds_PostSelected);
        base.OnLoad(e);
    }


    private static int _pageIndex;
    void gv_PageIndexChanged(object sender, EventArgs e)
    {
        GridViewEx gv = (GridViewEx)sender;
        _pageIndex = gv.PageIndex;
    }

    /// <summary>
    /// Collapse the tabs when a query has been executed
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void ds_PostSelected(object sender, PostSelectedEventArgs e)
    {
        if (e.Result != null)
        {
            Tabs tabs = af.Container as Tabs;
            if (tabs != null)
            {
                tabs.Selected = -1;
            }
            if (af.Container != null)
            {
                af.Visible = true;
            }
        }
    }

    private DateTime _queryBeginTime;

    void ds_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {
        if (!this.IsPostBack && this.Page.Request.QueryString.Count == 0)
        {
            e.Cancel = true;
        }
        else if (!btnGo.IsPageValid())
        {
            e.Cancel = true;
        }
        else
        {
            _queryBeginTime = DateTime.Now;
        }
        return;
    }

    void gv_DataBound(object sender, EventArgs e)
    {
        if (_queryBeginTime != DateTime.MinValue)
        {
            ParameterCollection coll = new ParameterCollection();
            if (SiteMap.CurrentNode != null)
            {
                coll.Add("report_id", TypeCode.String, SiteMap.CurrentNode.Key);
            }
            TimeSpan span = DateTime.Now - _queryBeginTime;
            Label lblThisExecutionPublic = (Label)this.Page.Master.FindControl("lblThisExecutionPublic");
            lblThisExecutionPublic.Text = string.Format("{0:N2} sec", span.TotalSeconds);
            coll.Add("query_seconds", TypeCode.Double, span.TotalSeconds.ToString());
            coll.Add("user_name", TypeCode.String, this.Page.User.Identity.Name);
            GridViewEx gv = (GridViewEx)sender;
            OracleDataSource ds = (OracleDataSource)this.NamingContainer.FindControl(gv.DataSourceID);
            System.Threading.Tasks.Task.Factory.StartNew(state => DoExecuteNonQuery(state), new
            {
                ConnectionString = ds.ConnectionString,
                ProviderName = ds.ProviderName,
                Parameters = coll
            });
        }
    }

    private static void DoExecuteNonQuery(dynamic state)
    {
        const string QUERY_INSERT_REPORTHITS = @"
INSERT INTO xreporter_report_hits
  (application_name,
   report_id,
   hit_index,
   hit_date,
   query_seconds,
   user_name)
VALUES
  ('DcmsLive',
   :report_id,
   (SELECT nvl(max(hit_index), 0) + 1 AS hit_index
      FROM XREPORTER_report_hits
     WHERE report_id = :report_id and application_name = 'DcmsLive'),
   SYSDATE,
   :query_seconds,
   :user_name)
";
        OracleDataSource db = null;
        try
        {
            db = new OracleDataSource();
            db.ConnectionString = state.ConnectionString;
            db.ProviderName = state.ProviderName;
            db.SysContext.ModuleName = "InsertReportHits";
            db.InsertSql = QUERY_INSERT_REPORTHITS;
            foreach (Parameter param in (ParameterCollection)state.Parameters)
            {
                db.InsertParameters.Add(param);
            }
            db.Insert();
        }
        catch (Exception ex)
        {
            // Log the exception
            System.Diagnostics.Trace.TraceError(ex.ToString());
        }
        finally
        {
            if (db != null)
            {
                db.Dispose();
            }
        }
    }



    void btnExportToExcel_Click(object sender, EventArgs e)
    {
        GridViewEx gv = (GridViewEx)this.NamingContainer.FindControl(this.GridViewId);
        foreach (DataControlField col in gv.Columns)
        {
            if (col is SequenceField)
            {
                // Hide the sequence field
                col.Visible = false;
            }
            IconField iconfield = col as IconField;
            if (iconfield != null)
            {
                // Special handling so that the value shows up in Excel
                iconfield.DisplayValue = true;
            }
            // Get rid of multi row headers
            if (!(col is EclipseLibrary.Web.UI.Matrix.MatrixField))
            {
                col.HeaderText = col.HeaderText.Replace("|", " - ");
            }
        }
        gv.AllowSorting = false;
        gv.AllowPaging = false;
        gv.DisplayMasterRow = false;

        //string attachment = "attachment; filename=" + SiteMap.CurrentNode["ReportId"] + ".csv";

        this.Response.ClearContent();
        //string attachment = "attachment; filename=" + SiteMap.CurrentNode["ReportId"] + ".html";
        string attachment;
        if (SiteMap.CurrentNode != null)
        {
            attachment = string.Format("attachment; filename={0}.xls", SiteMap.CurrentNode["ReportId"]);
        }
        else
        {
            string[] strReport = this.Page.Request.FilePath.Split('/');
            string reportId = strReport.LastOrDefault().Replace("R", "").Replace('_', '.').Replace(".aspx", "");
            if (string.IsNullOrEmpty(reportId))
            {
                attachment = string.Format("attachment; filename={0}.xls", "SampleReport");
            }
            else
            {
                attachment = string.Format("attachment; filename={0}.xls", reportId);
            }
        }
        this.Response.AddHeader("content-disposition", attachment);
        this.Response.ContentType = "application/ms-excel";
        Response.BufferOutput = true;

        gv.DataBind();
        using (HtmlTextWriter writer = new ExcelHtmlTextWriter(Response.Output))
        {
            gv.RenderControl(writer);
        }
        this.Response.End();
    }

    protected void btnExportToPDF_Click(object sender, EventArgs e)
    {
        PageBase pb = (PageBase)this.Page;
        pb.EnablePdfExport();
        foreach (Control control in this.Controls)
        {
            if (control is ButtonEx)
            {
                control.Visible = false;
            }
            else if (control is HyperLink)
            {
                control.Visible = false;
            }
        }

        GridViewEx gv = (GridViewEx)this.NamingContainer.FindControl(this.GridViewId);
        gv.AllowSorting = false;
        gv.ShowExpandCollapseButtons = false;

        if (gv.AllowPaging)
        {
            gv.PageIndex = _pageIndex;
        }
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        PageBase pb = (PageBase)this.Page;
        if (pb.IsPdfEnabled)
        {
            this.NamingContainer.FindControl(this.FilterContainerId).Visible = false;
        }
    }
</script>

<script type="text/javascript">
    function btnGo_Click(e) {
        $('#dlgWait').dialog('open');
    }
    function dlgWait_Open(event, ui) {
        setInterval(function () {
            var x = Number($('#timer').text());
            x = x + 1;
            $('#timer').text(x);
        }, 1000);
        $('.ui-dialog-titlebar-close', $(this).dialog('widget')).hide();
    }


</script>
<div class="ui-widget noPrint">
    <i:ButtonEx ID="btnGo" runat="server" Text="Go" Action="Submit" CausesValidation="true"
        Icon="Refresh" IsDefault="true" OnClientClick="btnGo_Click" />
    <i:ButtonEx ID="btnReset" runat="server" Text="Reset Filters" Action="Reset" Icon="Custom"
        CustomIconName="ui-icon-arrowreturnthick-1-w" />
    <i:ButtonEx ID="btnExportToExcel" runat="server" Text="Export To Excel" Action="Submit"
        CausesValidation="true" OnClick="btnExportToExcel_Click" Icon="Custom" CustomIconName="ui-icon-transferthick-e-w" />
    <i:ButtonEx ID="btnExportToPDF" runat="server" Text="Export to PDF" Action="Submit"
        CausesValidation="true" OnClick="btnExportToPDF_Click" Icon="Custom" CustomIconName="ui-icon-transferthick-e-w" />
    <i:ButtonEx ID="btnDoc" runat="server" Text="View Report Documentation" Action="NewWindow"
        Icon="LightBulb" />
    <i:ValidationSummary runat="server" />
</div>
<eclipse:AppliedFilters ID="af" runat="server" Visible="false" DisplayEmptyValues="true" />
<jquery:Dialog ID="dlgWait" runat="server" AutoOpen="false" ClientIDMode="Static"
    Title="Please Wait..." Modal="true" Resizable="false" CloseOnEscape="false" Position="Center"
    OnClientOpen="dlgWait_Open">
    <ContentTemplate>
        <div style="text-align: center">
            Query is executing...
            <br />
            <br />
            <span id="timer" style="font-size: xx-large">0</span> seconds
        </div>
    </ContentTemplate>
</jquery:Dialog>
