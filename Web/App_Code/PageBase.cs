using System.Globalization;
using System.Threading;
using System.Web.UI;
using System.IO;
using ExpertPdf.HtmlToPdf;
using System.Web;
using System.Linq;
using System;
using System.Collections.Generic;

/// <summary>
/// Sets the date format in the culture
/// 7 Apr 2009: Not saving page state at all to minimize page size.
/// </summary>
/// 

 //*  Programming: Eclipse Systems (P) Ltd., NOIDA, INDIA
 //*  E-mail: support@eclsys.com
 //*
 //*  $Revision: 39653 $
 //*  $Author: rverma $
//*  $HeadURL: http://vcs.eclipse.com/svn/net35/Projects/XTremeReporter3/trunk/Website/App_Code/PageBase.cs$
 //*  $Id: PageBase.cs 39653 2011-01-24 09:10:40Z rverma $
 //* Version Control Template Added.


public class PageBase:Page
{
    #region Culture
    private static CultureInfo m0_reportingCulture;
    protected override void InitializeCulture()
    {
        if (m0_reportingCulture == null)
        {
            m0_reportingCulture = new CultureInfo("en-US");
            m0_reportingCulture.DateTimeFormat.ShortDatePattern = "M'/'d'/'yyyy";
            //m0_reportingCulture.NumberFormat.CurrencySymbol = string.Empty;
            // Negative numbers within parenthesis
            m0_reportingCulture.NumberFormat.CurrencyNegativePattern = 14;
        }

        Thread.CurrentThread.CurrentCulture = m0_reportingCulture;
        Thread.CurrentThread.CurrentUICulture = m0_reportingCulture;

        base.InitializeCulture();
    }
    #endregion

    public override void VerifyRenderingInServerForm(Control control)
    {
        //base.VerifyRenderingInServerForm(control);
    }

    /// <summary>
    /// Do not save any control state or view state
    /// </summary>
    /// <param name="state"></param>
    protected override void SavePageStateToPersistenceMedium(object state)
    {
        //base.SavePageStateToPersistenceMedium(state);
    }

    #region PDF

    private StringWriter _swPdf;
    public void EnablePdfExport()
    {
        // Set response properties
        _swPdf = new StringWriter();
    }

    public bool IsPdfEnabled 
    {
        get
        {
            if (_swPdf == null)
            {
                return false;
            }
            return true;
        }
    }

    protected override HtmlTextWriter CreateHtmlTextWriter(TextWriter tw)
    {
        if (_swPdf == null)
        {
            return base.CreateHtmlTextWriter(tw);
        }
        HtmlTextWriter writer = new HtmlTextWriter(_swPdf);
        return writer;
    }

    protected override void Render(HtmlTextWriter writer)
    {
        base.Render(writer);

        if (_swPdf != null)
        {
            string htmlToConvert = _swPdf.GetStringBuilder().ToString();
            PdfConverter pdfConverter = new PdfConverter();
            pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
            pdfConverter.PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Landscape;
            pdfConverter.PdfDocumentOptions.LeftMargin = 36;        //36/72 = 0.5 in
            pdfConverter.PdfDocumentOptions.RightMargin = 36;        //36/72 = 0.5 in

            string[] strReport = this.Page.Request.FilePath.Split('/');
            string reportId = strReport.LastOrDefault().Replace("R", "").Replace('_', '.').Replace(".aspx", "");
            if (string.IsNullOrEmpty(reportId))
            {
                reportId = "SampleReport";
            }

            //TODO: Show 130.16: SKUs in a PO. How to manage font. Investigate top and bottom margins
            string strHeader;// = string.Format("{0}:{1}", SiteMap.CurrentNode["ReportId"], SiteMap.CurrentNode.Title);
            if (SiteMap.CurrentNode != null)
            {
                strHeader = string.Format("{0}:{1}", SiteMap.CurrentNode["ReportId"], SiteMap.CurrentNode.Title);
            }
            else
            {
                strHeader = string.Format("{0}:{1}", reportId, this.Page.Title);
            }
            pdfConverter.PdfHeaderOptions.HeaderText = strHeader;
            //pdfConverter.PdfHeaderOptions.HeaderSubtitleText = string.Format("Report generated on {0:D}", DateTime.Now);
            pdfConverter.PdfDocumentOptions.ShowHeader = true;
            pdfConverter.PdfDocumentOptions.ShowFooter = true;
            pdfConverter.PdfFooterOptions.FooterText = string.Format("Report generated on {0:D}", DateTime.Now);
            pdfConverter.PdfFooterOptions.ShowPageNumber = true;

            //TODO: Set more properties and in generic fashion
            pdfConverter.PdfDocumentInfo.CreatedDate = DateTime.Now;
            pdfConverter.PdfDocumentInfo.AuthorName = HttpContext.Current.User.Identity.Name;
            pdfConverter.ScriptsEnabled = true;
            pdfConverter.PdfDocumentOptions.LiveUrlsEnabled = false;

            if (SiteMap.CurrentNode != null)
            {
                pdfConverter.PdfDocumentInfo.Title = SiteMap.CurrentNode.Title;
                pdfConverter.PdfDocumentInfo.Keywords = SiteMap.CurrentNode.Description; //SiteMap.CurrentNode["Description"];
                pdfConverter.PdfDocumentInfo.Subject = string.Format("{0}: {1}", SiteMap.CurrentNode["ReportId"], SiteMap.CurrentNode.Title);
            }
            else
            {
                pdfConverter.PdfDocumentInfo.Title = this.Page.Title;
                pdfConverter.PdfDocumentInfo.Keywords = "Sample Report";
                pdfConverter.PdfDocumentInfo.Subject = string.Format("{0}: {1}", reportId, this.Page.Title);
            }
            
            //pdfConverter.ColorSpace = ColorSpace.Gray;
            byte[] pdfBytes = null;
            pdfBytes = pdfConverter.GetPdfBytesFromHtmlString(htmlToConvert, this.Request.Url.AbsoluteUri);
            if (SiteMap.CurrentNode != null)
            {
                strHeader = string.Format("attachment; filename={0}.pdf; size=", SiteMap.CurrentNode["reportId"]);    
            }
            else
            {
                strHeader = string.Format("attachment; filename={0}.pdf; size=", reportId);
            }
            Response.AddHeader("Content-Disposition", strHeader + pdfBytes.Length.ToString());
            Response.BinaryWrite(pdfBytes);
        }
    }
    #endregion

}

/// <summary>
/// This is the type used in web.config for string array profile properties, such as RecentReports and FavoriteReports.
/// </summary>
/// <remarks>
/// It behaves as a fixed size list. Oldest items are discarded when a new item is added.
/// Does not allow duplicates.
/// </remarks>
public class StringSet: IEnumerable<string>
{
    private readonly List<string> _list;
    public StringSet()
    {
        _list = new List<string>();
    }

    /// <summary>
    /// Oldest entry will be discarded if the list has already reached maxSize. The key is not added if it already exists
    /// and false is returned.
    /// </summary>
    /// <param name="reportKey"></param>
    /// <param name="maxSize"></param>
    public bool Add(string reportKey, int maxSize )
    {
        bool b = _list.Contains(reportKey);
        if (b)
        {
            return false;
        }

        if (_list.Count >= maxSize)
        {
            // Remove the oldest item
            _list.RemoveAt(0);
        }
        _list.Add(reportKey);
        return true;
    }

    /// <summary>
    /// This exists for the Xml serializer
    /// </summary>
    /// <param name="obj"></param>
    public void Add(object obj)
    {
        if (obj != null)
        {
            _list.Add(obj.ToString());
        }
    }

    public void Remove(string reportKey)
    {
        _list.Remove(reportKey);
    }

    public IEnumerator<string> GetEnumerator()
    {
        return _list.GetEnumerator();
    }

    System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
    {
        return _list.GetEnumerator();
    }
}
