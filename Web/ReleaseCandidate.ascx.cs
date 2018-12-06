using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using EclipseLibrary.Oracle;

/// <summary>
/// Most of the Release candidates feature is encapsulated in this control which is included in MasterPage.master
/// </summary>
/// <param name="days"></param>
/// <returns></returns>
/// <remarks>
/// <para>
/// You deploy a report release candidate by copying a report in the Rc directory. The web config specifies that this directory contains release candidates.
/// </para>
/// <code>
/// <![CDATA[
///<siteMap defaultProvider="Dcms">
///    <providers>
///    <clear/>
///    <add name="Dcms" type="EclipseLibrary.Web.SiteStructure.AutoSiteMapProvider" securityTrimmingEnabled="true" customAttributes="ReportId,Browsable"
///      siteMapRoot="Reports" homePageUrl="Default.aspx"/>
///    <add name="ExternalLinksProvider" description="SiteMap provider that reads in .sitemap files." type="System.Web.XmlSiteMapProvider, System.Web, Version=2.0.3600.0,
///      Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" siteMapFile="~/App_Data/ExternalLinks.sitemap"/>
///    <!--Sharad 17 Jul 2012: New entry added for Release candidate support-->
///    <add name="Rc" type="EclipseLibrary.Web.SiteStructure.AutoSiteMapProvider" securityTrimmingEnabled="false" customAttributes="ReportId,Browsable,ChangeLog" 
///      siteMapRoot="RC" homePageUrl="Dummy.aspx"/>
///    </providers>
///</siteMap>
/// ]]>
/// </code>
/// <para>
/// All reports will have a new section which will list the designated approvers of the report. It will also have a button which will allow the current user to designate/undesignate himself as 
/// an approver. 
/// </para>
/// <para>
/// Assuming that a release candidate for Report 10.17 has been deployed, the following pages will change.
/// 1. Home Page. It will list all release candidates available along with the change log and a link to the release candidates. This is <c>viewHomePage</c> of the multiview.
/// If the current user is an approver for one of the release candidates, a prominent alert style test will be displayed.
/// 
/// 2. Report 10.17 page. The report will announce the availability of the release candidate and provide a link to it. It will also list the change log.
/// This is <c>viewHasRc</c> of the multiview. If the current user is a designated approver of the report, it will announce that the report is waiting for his approval. If the user has already
/// approved or rejected the report, it will announce that his feedback has been received and action will be taken soon. It will also list the approval status of all other designated approvers.
/// 
/// 2. Report 10.17 release candidate page. It will announce that this is a release candidate report. If the current user is a designated approver, it will either thank him for the feedback
/// or request feedback from him. If the current user is not a designated approver, it will still allow him to provide feedback. This is <c>viewIsRc</c> of the multiview.
/// </para>
/// <para>
/// </para>
/// </remarks>
public partial class ReleaseCandidate : System.Web.UI.UserControl
{
    /// <summary>
    /// The numeric values of the enum are used in markup
    /// </summary>
    protected enum ApprovalStatus
    {
        NotSet = 0,
        Pending = 1,
        Approved = 2,
        Disapproved = 3
    }

    /// <summary>
    /// Approval status of a specific user
    /// </summary>
    protected class RcUserApprovalStatus
    {
        /// <summary>
        /// The forward \ has been removed from this
        /// </summary>
        public string UserId { get; set; }

        public string UserDisplayName
        {
            get
            {
                return UserId.Substring(UserId.IndexOf('\\') + 1);
            }
        }

        /// <summary>
        /// Doubles the \ so that it reaches the web service
        /// </summary>
        public string AjaxUserId
        {
            get
            {
                return UserId.Replace("\\", "\\\\");
            }
        }
        public ApprovalStatus Status { get; set; }

        /// <summary>
        /// The date on which the status was last modified by this user
        /// </summary>
        public DateTime? StatusDate { get; set; }

        public string DbStatus
        {
            set
            {
                switch (value)
                {
                    case "Y":
                        this.Status = ApprovalStatus.Approved;
                        break;

                    case "N":
                        this.Status = ApprovalStatus.Disapproved;
                        break;

                    default:
                        this.Status = ApprovalStatus.Pending;
                        break;
                }
            }
        }

        public bool HasApproved
        {
            get
            {
                return this.Status == ApprovalStatus.Approved;
            }
        }

        public bool HasDisApproved
        {
            get
            {
                return this.Status == ApprovalStatus.Disapproved;
            }
        }

        public bool IsApprover
        {
            get
            {
                return this.Status != ApprovalStatus.NotSet;
            }
        }

        public string UserComment { get; set; }
    }

    protected class RcReport
    {
        private readonly SiteMapNode _node;

        /// <summary>
        /// This constructors takes the approver list as a parameter so that query can be avoided. Used by the Home Page view.
        /// </summary>
        /// <param name="node"></param>
        /// <param name="approvers"></param>
        public RcReport(SiteMapNode node, IEnumerable<RcUserApprovalStatus> approvers)
        {
            _node = node;
            _approvers = approvers;
            _versionNumber = node["Version"];
            _rcChangeLog = node["ChangeLog"];
        }

        private readonly string _urlOther;
        private readonly string _rcChangeLog;
        /// <summary>
        /// 
        /// </summary>
        /// <param name="node"></param>
        /// <param name="urlOther">For deployed report, this is the URL of the RC. For RC report, this is the url of the deployed report</param>
        /// <param name="rcVersion">Version of the RC report, if it exists</param>
        public RcReport(SiteMapNode node, string urlOther, string rcVersion, string rcChangeLog)
        {
            if (node == null)
            {
                throw new ArgumentNullException("node");
            }
            _node = node;
            if (string.IsNullOrEmpty(urlOther))
            {
                _isNewReport = true;
            }
            else
            {
                _urlOther = urlOther;
                _isNewReportVersion = true;
            }
            _versionNumber = rcVersion;
            _rcChangeLog = rcChangeLog;
        }

        public string UrlOther
        {
            get
            {
                return _urlOther;
            }
        }

        public string ReportId
        {
            get
            {
                return _node.Key;
            }
        }

        public string Url
        {
            get
            {
                return _node.Url;
            }
        }

        public string ReportNumber
        {
            get
            {
                return _node["ReportId"];
            }
        }

        public string Title
        {
            get
            {
                return _node.Title;
            }
        }

        public string[] ChangeLog
        {
            get
            {
                var changeLog = _rcChangeLog;
                if (string.IsNullOrWhiteSpace(changeLog))
                {
                    return new string[0];
                }
                return changeLog.Split(new[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
            }
        }

        private readonly string _versionNumber;
        public string VersionNumber
        {
            get
            {
                return _versionNumber;
            }
        }

        private readonly bool _isNewReport;
        public bool IsNewReport
        {
            get
            {
                return _isNewReport;
            }
        }


        private readonly bool _isNewReportVersion;
        public bool IsNewReportVersion
        {
             get
             {
                return _isNewReportVersion;
             }
        }

        private IEnumerable<RcUserApprovalStatus> _approvers;
        public IEnumerable<RcUserApprovalStatus> Approvers
        {
            get
            {
                if (_approvers == null)
                {
                    _approvers = GetApprovalStatus(this.ReportId, this.VersionNumber);
                }
                return _approvers;
            }
        }

        private static IList<RcUserApprovalStatus> GetApprovalStatus(string reportId, string version)
        {
            IList<RcUserApprovalStatus> approvers;
            const string QUERY = @"
Select user_name,
<if c='$version'>
case when report_version =:version then approval_status end
</if>
<else>
NULL
</else>
as approval_status,
<if c='$version'>
case when report_version =:version then comments end
</if>
<else>
NULL
</else>
as comments,
approval_status_date
from dcmslive_user_report
where report_id = :report_id and is_approver = 'Y'
";
            using (var db = new OracleDatastore(HttpContext.Current.Trace))
            {
                db.CreateConnection(ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString, "");
                var binder = SqlBinder.Create(row => new RcUserApprovalStatus
                {
                    UserId = row.GetString("user_name"),
                    DbStatus = row.GetString("approval_status"),
                    UserComment = row.GetString("comments"),
                    StatusDate = row.GetDate("approval_status_date")
                });

                binder.Parameter("report_id", reportId);
                binder.Parameter("version", version);

                approvers = db.ExecuteReader(QUERY,binder);
            }
            return approvers;
        }

        public IEnumerable<RcUserApprovalStatus> ListApprovedBy
        {
            get
            {
                return this.Approvers.Where(p => p.Status == ApprovalStatus.Approved);
            }
        }

        public IEnumerable<RcUserApprovalStatus> ListRejectedBy
        {
            get
            {
                return this.Approvers.Where(p => p.Status == ApprovalStatus.Disapproved);
            }
        }

        public IEnumerable<RcUserApprovalStatus> ListPending
        {
            get
            {
                return this.Approvers.Where(p => p.Status == ApprovalStatus.Pending);
            }
        }

        public DateTime CreationDate
        {
            get
            {
                var creationdate = _node["CreationTime"];
                return DateTime.ParseExact(creationdate, "u", null);
            }
        }

        public string DaysAgo
        {
            get
            {
                var days = (DateTime.Now - CreationDate).Days;
                switch (days)
                {
                    case 0:
                        return "today";

                    case 1:
                        return "yesterday";

                    default:
                        var weeks = (int)Math.Round((decimal)days / (decimal)7);
                        switch (weeks)
                        {
                            case 0:
                                return string.Format("{0} days ago", days);

                            case 1:
                                return "1 week ago";

                            default:
                                return string.Format("{0} weeks ago", weeks);
                        }
                }
            }
        }

        /// <summary>
        /// True if there is at least one approver, and all have approved it.
        /// </summary>
        public bool IsApproved
        {
            get
            {
                return _approvers.Any() && _approvers.All(p => p.Status == ApprovalStatus.Approved);
            }
        }

        /// <summary>
        /// Approval status object of the current user. This will be null if the current user is not an approver.
        /// </summary>
        public RcUserApprovalStatus CurrentUserApprovalStatus
        {
            get
            {
                return this.Approvers.FirstOrDefault(p => p.UserId == HttpContext.Current.User.Identity.Name) ?? new RcUserApprovalStatus
                {
                    UserId = HttpContext.Current.User.Identity.Name,
                    Status = ApprovalStatus.NotSet
                };
            }
        }

        public bool IsCurrentUserAnApprover
        {
            get
            {
                return this.Approvers.Any(p => p.UserId == HttpContext.Current.User.Identity.Name);
            }
        }

        public int CountPendingApprovals
        {
            get
            {
                return this.Approvers.Count(p => p.Status == ApprovalStatus.Pending);
            }
        }

        public bool IsApprovalPending
        {
            get
            {
                return this.Approvers.Any(p => p.Status == ApprovalStatus.Pending);
            }
        }

        /// <summary>
        /// For convenience
        /// </summary>
        public string CurrentUserId
        {
            get
            {
                return HttpContext.Current.User.Identity.Name;
            }
        }

        /// <summary>
        /// Does this report have any designated approver?
        /// </summary>
        public bool HasApprovers
        {
            get
            {
                return _approvers.Any();
            }
        }

        /// <summary>
        /// Does this this report has no approvers
        /// </summary>
        public bool HasNoApprovers
        {
            get
            {
                return !_approvers.Any();
            }
        }
    }


    #region Data Source

    /// <summary>
    /// The object representing the current report
    /// </summary>
    private RcReport _report;

    /// <summary>
    /// This property is for use in markup
    /// </summary>
    protected RcReport CurrentReport
    {
        get
        {
            return _report;
        }
    }
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        var node = SiteMap.CurrentNode;
        //bool isRc;
        string urlOther = string.Empty;
        string rcVersion = null;
        string rcChangeLog = null;
        if (node == null)
        {
            // This must be an RC report
            node = SiteMap.Providers["Rc"].CurrentNode;
            // Sharad 24 Sep 2012: Added defensive check to ensure that we are able to get a node
            if (node != null)
            {
                var deployed = SiteMap.Provider.FindSiteMapNodeFromKey(node.Key);
                if (deployed == null)
                {
                    urlOther = null;
                }
                else
                {
                    urlOther = deployed.Url;
                }
                rcVersion = node["Version"];
                rcChangeLog = node["ChangeLog"];
            }
        }
        else
        {
            // This is a deployed report
            var rc = SiteMap.Providers["Rc"].FindSiteMapNodeFromKey(node.Key);
            if (rc != null)
            {
                // This report does have an Rc
                urlOther = rc.Url;
                rcVersion = rc["Version"];
                rcChangeLog = rc["ChangeLog"];
            }
        }
        if (node != null)
        {
            _report = new RcReport(node, urlOther, rcVersion, rcChangeLog);
        }
    }
    #endregion

    #region View Selection
    /// <summary>
    /// Decide which view to render
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void mvRc_Load(object sender, EventArgs e)
    {
        // Sharad 17 Jul 2012: Release candidate support
        if (SiteMap.CurrentNode == SiteMap.RootNode)
        {
            // This is the home page. Show something only if there are release candidates
            if (SiteMap.Providers["Rc"].RootNode.ChildNodes.Count > 0)
            {
                mvRc.SetActiveView(viewHomePage);
            }
        }
        else if (SiteMap.Providers["Rc"].CurrentNode != null)
        {
            // This report is the release candiate
            mvRc.SetActiveView(viewIsRc);
            viewIsRc.DataBind();
        }
        else if (SiteMap.CurrentNode != null)
        {
            // This is a report
            if (SiteMap.Providers["Rc"].FindSiteMapNodeFromKey(SiteMap.CurrentNode.Key) == null)
            {
                // This report does not have an RC
            }
            else
            {
                // This report has an RC
                mvRc.SetActiveView(viewHasRc);
                viewHasRc.DataBind();
            }
        }

        if (SiteMap.Provider.CurrentNode != null && SiteMap.CurrentNode != SiteMap.RootNode)
        {
            // Show approver list in all deployed reports. Not in release candidate reports.
            plhAllReports.Visible = true;
            plhAllReports.DataBind();
        }
    }
    #endregion

    #region Home Page
    protected void viewHomePage_PreRender(object sender, EventArgs e)
    {
        IEnumerable<RcReport> listRc;
        using (var db = new OracleDatastore(HttpContext.Current.Trace))
        {
            const string QUERY = @"
                    select t.report_id as report_id, t.user_name as user_name, t.report_version as report_version,
                    t.approval_status_date as approval_status_date,
                    <if c='$version'>
                    case when <a pre=""t.report_version IN ("" sep="","" post="")"">(:version)</a> then approval_status end
                    </if>
                    <else>
                    NULL
                    </else>
                    as approval_status,
                    t.comments as comments
                    from DCMSLIVE_USER_REPORT t
                    where <a pre=""t.report_id IN ("" sep="","" post="")"">(:report_id)</a>
";
            db.CreateConnection(ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString, HttpContext.Current.User.Identity.Name);
            var binder = SqlBinder.Create(row => new
            {
                ReportId = row.GetString("report_id"),
                RcApprover = new RcUserApprovalStatus
                {
                    DbStatus = row.GetString("approval_status"),
                    StatusDate = row.GetDate("approval_status_date"),
                    UserId = row.GetString("user_name"),
                    UserComment=row.GetString("comments")
                },
                VersionNumber = row.GetString("report_version"),
            });
            binder.ParameterXmlArray("report_id", SiteMap.Providers["Rc"].RootNode.ChildNodes.Cast<SiteMapNode>().Select(p => p.Key).ToArray());
            binder.ParameterXmlArray("version", SiteMap.Providers["Rc"].RootNode.ChildNodes.Cast<SiteMapNode>().Select(p => p["version"]).ToArray());
            var result = db.ExecuteReader(QUERY,binder);

            // LinqQuery generates an entry for each RC report. Each RC report contains a list of approval statuses
            listRc = from flatData in
                         (from SiteMapNode node in SiteMap.Providers["Rc"].RootNode.ChildNodes
                          join row in result on node.Key equals row.ReportId into outer
                          from row in outer.DefaultIfEmpty()
                          where node["Browsable"] != "false"
                          select new
                          {
                              Node = node,
                              Row = row
                          })
                     group flatData by flatData.Node into g
                     select new RcReport(g.Key, g.Where(p => p.Row != null).Select(p => p.Row.RcApprover));
        }

        repRc.DataSource = listRc;
        repRc.DataBind();


        panelRc.HeaderText = string.Format(panelRc.HeaderText, listRc.Count());

        // This is a list of rc waiting for current user's approval
        var query = (from rc in listRc
                     where rc.ListPending.Any(p => p.UserId == HttpContext.Current.User.Identity.Name)
                     select rc.ReportNumber).ToList();
        if (query.Count > 0)
        {
            string reportno = query.Count == 1 ? "Report" : "Reports";
            string reports = string.Join(",", query);
            divMsg.InnerText = string.Format("{0} {1} waiting for your approval", reportno, reports);
        }

    }
    #endregion


}