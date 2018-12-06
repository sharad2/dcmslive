using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Web;
using System.Web.Profile;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.WebForms.Oracle;
using EclipseLibrary.Web.JQuery.Input;
using System.Xml.Linq;
using System.Xml;
using System.IO;

/// <summary>
/// Sharad 7 Aug 2009: Report statistics data is cached for one hour.
/// </summary>
public partial class _Default : PageBase
{

    private class ReportStat
    {
        private readonly string _key;
        public ReportStat(string key)
        {
            _key = key;
        }

        /// <summary>
        /// Blank for external reports
        /// </summary>
        public string Key
        {
            get
            {
                return _key;
            }

        }

        public object HitCount { get; set; }

        public object AverageQuerySeconds { get; set; }

        public object MinQuerySeconds { get; set; }
        public object MaxQuerySeconds { get; set; }
    }


    private class CustomSiteMapNode : ReportStat, IEquatable<CustomSiteMapNode>
    {
        private int _reportNumber;
        /// <summary>
        /// Constructor for normal reports
        /// </summary>
        /// <param name="bReportsInNewWindow"></param>
        /// <param name="category"></param>
        /// <param name="reportNumber"></param>
        /// <param name="url"></param>
        /// <param name="title"></param>
        public CustomSiteMapNode(bool bReportsInNewWindow, SiteMapNode node)
            : base(node.Key)
        {
            Initialize(node);
            if (bReportsInNewWindow)
            {
                this.Image = "ui-icon-newwin";
                this.ImageTitle = "Opens in new window. If you prefer that reports should open in the same window, modify your Preferences";
                this.LinkTarget =  ButtonAction.NewWindow;
            }
            else
            {
                this.Image = "ui-icon-link";
                this.ImageTitle = "If you prefer that reports should open in a new window, modify your Preferences";              
                this.LinkTarget = ButtonAction.Navigate;
            }
            //this.IconState = ButtonState.Default;       // = "ui-state-default";
        }

        private void Initialize(SiteMapNode node)
        {
            string[] tokens = node["ReportId"].Split('.');
            this.Category = int.Parse(tokens[0]);
            _reportNumber = int.Parse(tokens[1]);
            this.Url = node.Url;
            this.Title = node.Title;
            this.Description = node.Description;
            _reportId = string.Format("{0}.{1:00}", this.Category, _reportNumber);
            // Workaround for old library
            this.IconState = new string[0];
        }

        /// <summary>
        /// Constructor for external reports
        /// </summary>
        /// <param name="category"></param>
        /// <param name="reportNumber"></param>
        /// <param name="url"></param>
        /// <param name="title"></param>
        public CustomSiteMapNode(Uri uriRoot, SiteMapNode node)
            : base(string.Empty)
        {
            Initialize(node);
            this.Image = "ui-icon-extlink";
            this.LinkTarget = ButtonAction.NewWindow;
            Uri uri = new Uri(this.Url);

            if (uriRoot.MakeRelativeUri(uri).ToString() == uri.ToString())
            {
                // This represents a very old report
                this.IconState = new string[] { "ui-state-highlight" };
                this.ImageTitle = "Available in the original DCMS Live system";
            }
            else
            {
                this.ImageTitle = "Available in the previous version of XTremeReporter";
                this.IconState = new string[] { "ui-state-error" };
            }
        }

        public int ReportNumber
        {
            get
            {
                return _reportNumber;
            }
        }
        public string Title { get; set; }

        public string Image { get; set; }

        public string ImageTitle { get; set; }

        public ButtonAction LinkTarget { get; set; }

        public string[] IconState { get; set; }

        private string _reportId;
        public string ReportId
        {
            get
            {
                return _reportId;
            }
        }

        public int Category { get; set; }
        public string Url { get; set; }
        public string Description { get; set; }

        #region IEquatable<CustomSiteMapNode> Members
        /// <summary>
        /// Called only when GetHashCode() returns the same value for two nodes. This is a very rare situation
        /// </summary>
        /// <param name="other"></param>
        /// <returns></returns>
        public bool Equals(CustomSiteMapNode other)
        {
            return this.Category == other.Category && this.ReportNumber == other.ReportNumber;
        }

        #endregion

        /// <summary>
        /// Called during Distinct and Union to filter out duplicates
        /// </summary>
        /// <returns></returns>
        public override int GetHashCode()
        {
            return this.ReportId.GetHashCode();
        }
    }

    protected void btnUpdateNow_Click(object sender, EventArgs e)
    {
        Cache.Remove("ReportStatData");
    }

    /// <summary>
    /// The time at which the stats were last updated
    /// </summary>
    protected static DateTime __statUpdateTime;

    private IEnumerable<ReportStat> GetReportStats()
    {
        ReportStat[] statistics;
        try
        {
            statistics = (ReportStat[])Cache["ReportStatData"];
        }
        catch (InvalidCastException)
        {
            // This happens when default.aspx page is recompiled. Just Ignore the cache
            statistics = null;
        }

        if (statistics != null)
        {
            return statistics;
        }

        using (OracleDataSource dsHits = new OracleDataSource())
        {
            dsHits.SelectSql = @"
select t.report_id as report_id,
       MIN(t.query_seconds) as min_query_seconds,
       MAX(t.query_seconds) as max_query_seconds,
       ROUND(AVG(t.query_seconds), 4) as avg_query_seconds,
       MAX(t.hit_index) as hit_count
  from xreporter_report_hits t
  where t.application_name = :application_name
 group by t.report_id
";
            dsHits.SysContext.ModuleName = "DCMS Live 2009 Home";
            dsHits.ConnectionString = ConfigurationManager.ConnectionStrings["DCMSLIVE"].ConnectionString;
            dsHits.ProviderName = ConfigurationManager.ConnectionStrings["DCMSLIVE"].ProviderName;
            Parameter appName = new Parameter("application_name", DbType.String);
            appName.DefaultValue = ProfileManager.Provider.ApplicationName;
            dsHits.SelectParameters.Add(appName);
            try
            {
                statistics =
                   (from object stat in dsHits.Select(DataSourceSelectArguments.Empty)
                    select new ReportStat(DataBinder.Eval(stat, "report_id", "{0}"))
                    {
                        MinQuerySeconds = DataBinder.Eval(stat, "min_query_seconds"),
                        MaxQuerySeconds = DataBinder.Eval(stat, "max_query_seconds"),
                        AverageQuerySeconds = DataBinder.Eval(stat, "avg_query_seconds"),
                        HitCount = DataBinder.Eval(stat, "hit_count")
                    }).ToArray();
                Cache.Insert("ReportStatData", statistics, null, DateTime.UtcNow.AddHours(1),
                    System.Web.Caching.Cache.NoSlidingExpiration);
                __statUpdateTime = DateTime.Now;

            }
            catch (DbException ex)
            {
                Trace.Warn(ex.ToString());
                // Empty array
                statistics = new ReportStat[0];
                mvStats.ActiveViewIndex = 1;
                lblError.Text = ex.Message;
            }
        }
        return statistics;
    }

    private IDictionary<int, string> _categories;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        var appDataDir = (string)AppDomain.CurrentDomain.GetData("DataDirectory");
        var fullPath = Path.Combine(appDataDir, "ReportCategories.xml");

        XElement xnode;
        using (var reader = XmlReader.Create(fullPath))
        {
            reader.MoveToContent();
            xnode = (XElement)XElement.ReadFrom(reader);
        }

        // _categories will be read in repCategories_ItemDataBound
        _categories = (from category in xnode.Descendants("category")
                       select new
                       {
                           CategoryId = (int)category.Attribute("id"),
                           Title = category.Value
                       }).ToDictionary(p => p.CategoryId, p => p.Title);
    }

    /// <summary>
    /// Data bind all the UI elements
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoadComplete(EventArgs e)
     {
        base.OnLoadComplete(e);

        IEnumerable<ReportStat> statistics = GetReportStats();

        // If duplicate reports are found with the same report id, one of them would be ignored
        // This query outer joins with the statistics query to capture report performance info which has been
        // saved in the database.
        var browsableReports =
            (from SiteMapNode node in SiteMap.RootNode.ChildNodes
             let reportId = node["ReportId"]
             join stat in statistics on node.Key equals stat.Key into g
             from stat in  g.DefaultIfEmpty()
             where node["Browsable"] != "false" && !string.IsNullOrEmpty(reportId) &&
                 reportId.Contains('.')
             select new CustomSiteMapNode(this.Profile.ReportsInNewWindow, node)
             {
                 HitCount = (stat == null ? null : stat.HitCount),
                 AverageQuerySeconds = (stat == null ? null : stat.AverageQuerySeconds),
                 MinQuerySeconds = (stat == null ? null : stat.MinQuerySeconds),
                 MaxQuerySeconds = (stat == null ? null : stat.MaxQuerySeconds)
             }).Distinct();



        //string str = this.Profile.FavoriteReports;
        //if (str != null)
        //{
            //char[] seperators = new char[] { ',' };
            //string[] favorites = str.Split(seperators, StringSplitOptions.RemoveEmptyEntries);
            repFavorites.DataSource = from node in browsableReports
                                      join favorite in this.Profile.FavoriteReports on node.Key equals favorite
                                      orderby node.Category, node.ReportId
                                      select node;
            repFavorites.DataBind();
        //}

        IEnumerable<CustomSiteMapNode> menuReports;

        try
        {
            SiteMapNode externalRootNode = SiteMap.Providers["ExternalLinksProvider"].RootNode;

            Uri uriRoot = new Uri(externalRootNode.Url);
            var externalReports = from SiteMapNode node in SiteMap.Providers["ExternalLinksProvider"].RootNode.ChildNodes
                                  let reportId = node["ReportId"]
                                  where !string.IsNullOrEmpty(reportId) && reportId.Contains('.')
                                  select new CustomSiteMapNode(uriRoot, node);

            menuReports = browsableReports.Union(externalReports);
        }
        catch (InvalidOperationException)
        {
            // Sitemap file not found. Ignore
            menuReports = browsableReports;
        }
        repQuickLinks.DataSource = menuReports
                .OrderBy(p => p.Category).ThenBy(p => p.ReportNumber).ToArray();       // _nodes;
        repQuickLinks.DataBind();

        var categorizedReports = from node in menuReports
                                 group node by node.Category into g
                                 select g;
        repCategories.DataSource = categorizedReports;
        repCategories.DataBind();
    }

    /// <summary>
    /// Update the report count for each category
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void repCategories_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        switch (e.Item.ItemType)
        {
            case ListItemType.AlternatingItem:
            case ListItemType.Item:
                GridView gvDetailLinks = (GridView)e.Item.FindControl("gvDetailLinks");
                Literal litCategoryHeader = (Literal)e.Item.FindControl("litCategoryHeader");
                var categoryId = (int)DataBinder.Eval(e.Item.DataItem, "Key");
                string title;
                if (_categories.TryGetValue(categoryId, out title))
                {
                    litCategoryHeader.Text = string.Format("{0}: {1} ({2:N0} reports)", categoryId, title, gvDetailLinks.Rows.Count);
                }
                else
                {
                    litCategoryHeader.Text = string.Format("Category {0}: {1:N0} reports", categoryId, gvDetailLinks.Rows.Count);
                }

                break;
        }
    }

    /// <summary>
    /// Set the data source of the nested grid
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void repCategories_ItemCreated(object sender, RepeaterItemEventArgs e)
    {
        switch (e.Item.ItemType)
        {
            case ListItemType.AlternatingItem:
            case ListItemType.Item:
                GridView gvDetailLinks = (GridView)e.Item.FindControl("gvDetailLinks");
                gvDetailLinks.DataSource = e.Item.DataItem;
                break;
        }
    }
}
