<%@ WebService Language="C#" Class="ReleaseCandidates" %>

using System;
using System.Web;
using System.Web.Services;
using System.Web.Services.Protocols;
using EclipseLibrary.WebForms.Oracle;
using System.Configuration;
using EclipseLibrary.Oracle;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class ReleaseCandidates : System.Web.Services.WebService
{

    /// <summary>
    /// Update the database to indicate that the passed user has approved the passed version of the report
    /// </summary>
    /// <param name="reportId"></param>
    /// <param name="userId"></param>
    /// <returns></returns>
    [WebMethod]
    public string ApproveReport(string reportId, string userId, string version, DateTime approvalStatusDate, string comments)
    {
        const string QUERY = @"UPDATE DCMSLIVE_USER_REPORT SET APPROVAL_STATUS=:approval_status,
                                REPORT_VERSION=:version,
                                APPROVAL_STATUS_DATE=:approval_status_date,
                                COMMENTS=:comments
                                WHERE REPORT_ID=:report_id
                                    AND USER_NAME=:user_id";

        using (var db = new OracleDatastore(HttpContext.Current.Trace))
        {
            db.CreateConnection(ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString, userId);
            var binder = new SqlBinder("ApproveReport");
            binder.Parameter("report_id", reportId);
            binder.Parameter("user_id", userId);
            binder.Parameter("approval_status", "Y");
            binder.Parameter("version", version);
            binder.Parameter("approval_status_date", approvalStatusDate);
            binder.Parameter("comments", comments);
            db.ExecuteNonQuery(QUERY, binder);
        }   
        return reportId + "*" + userId;
    }
    /// <summary>
    /// Add user as approver of report
    /// </summary>
    /// <param name="reportId"></param>
    /// <param name="userId"></param>
    /// <returns></returns>
    [WebMethod]
    public string AddApprover(string reportId, string userId)
    {
        
        const string QUERY=@"Insert into DCMSLIVE_USER_REPORT(REPORT_ID,USER_NAME,IS_APPROVER) VALUES(:report_id,:user_name,:is_approver)";
        using (var db = new OracleDatastore(HttpContext.Current.Trace))
        {
            db.CreateConnection(ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString, userId);
            var binder = new SqlBinder("AddApprover");
            binder.Parameter("report_id", reportId);
            binder.Parameter("user_name", userId);
            binder.Parameter("IS_APPROVER", "Y");
            db.ExecuteNonQuery(QUERY,binder);
        }
        return userId;
    }
    /// <summary>
    /// Remove user from approvers
    /// </summary>
    /// <param name="reportId"></param>
    /// <param name="userId"></param>
    /// <returns></returns>
    [WebMethod]
    public string RemoveApprover(string reportId, string userId)
    {

        const string QUERY = @"DELETE FROM DCMSLIVE_USER_REPORT
                                WHERE REPORT_ID=:report_id
                                AND USER_NAME=:user_id"
                                ;
        using (var db = new OracleDatastore(HttpContext.Current.Trace))
        {
            db.CreateConnection(ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString, userId);
            var binder = new SqlBinder("RemoveApprover");
            binder.Parameter("report_id", reportId);
            binder.Parameter("user_id", userId);
            db.ExecuteNonQuery(QUERY, binder);
        }        
        return userId;
    }
    /// <summary>
    /// Disapprove report
    /// </summary>
    /// <param name="reportId"></param>
    /// <param name="userId"></param>
    /// <param name="version"></param>
    /// <returns></returns>
    [WebMethod]
    public string DisApproveReport(string reportId, string userId,string version,DateTime approvalStatusDate,string comments)
    {
        const string QUERY = @"UPDATE DCMSLIVE_USER_REPORT SET APPROVAL_STATUS=:approval_status,
                                REPORT_VERSION=:version,
                                APPROVAL_STATUS_DATE=:approval_status_date,
                                COMMENTS=:comments
                                WHERE REPORT_ID=:report_id
                                    AND USER_NAME=:user_id";

        using (var db = new OracleDatastore(HttpContext.Current.Trace))
        {
            db.CreateConnection(ConfigurationManager.ConnectionStrings["dcmslive"].ConnectionString, userId);
            var binder = new SqlBinder("ApproveReport");
            binder.Parameter("report_id", reportId);
            binder.Parameter("user_id", userId);
            binder.Parameter("approval_status", "N");
            binder.Parameter("version", version);
            binder.Parameter("approval_status_date", approvalStatusDate);
            binder.Parameter("comments", comments);
            db.ExecuteNonQuery(QUERY, binder);
        }
        return reportId + "*" + userId;
    }


}