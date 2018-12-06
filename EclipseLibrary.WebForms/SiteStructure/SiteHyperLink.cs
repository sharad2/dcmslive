using System;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Web.UI;
using System.ComponentModel;
using EclipseLibrary.Web.JQuery;
using EclipseLibrary.Web.JQuery.Input;
using System.Web.Security;

namespace EclipseLibrary.Web.SiteStructure
{
    /// <summary>
    /// It serves the usage of <see cref="System.Web.UI.WebControls.HyperLink"/> with the enhancement to 
    /// provide the ability to specify the <see cref="SiteMapKey"/> instead of <c>NavigateUrl</c>.
    /// This avoids the need to hardwire URL paths in the program.
    /// </summary>
    /// <remarks>
    /// <para>
    /// If <see cref="SiteMapKey"/> is not specified, then this control behaves identically to the standard
    /// <c>Hyperlink</c> control. You get additional benefits of the <see cref="SecurityCheck"/> and 
    /// <see cref="AppliedFiltersControlID"/> properties.
    /// </para>
    /// <para>
    /// When links are specified using the standard <c>HyperLink</c> control, they tend to break if the pages 
    /// within the project are reorganized into different directoris.
    /// By contrast, links specified using <c>SiteHyperLink</c> do not break
    /// because you are referencing the URL using the <see cref="SiteMapKey"/> instead of having to 
    /// specify the absolute or relative path in <c>NavigateUrl</c>. The latter should just
    /// contain the query string portion of your URL.
    /// </para>
    /// <para>
    /// <c>SiteHyperLink</c> requires that the site map provider for your project should be
    /// <see cref="AutoSiteMapProvider"/>. The sitemap provider is queried for the sitemap node
    /// whose key is the value specified in <see cref="SiteMapKey"/>. If this node is found,
    /// then the URL of the node is prepended to the <c>NavigateUrl</c> along with a ? character
    /// if necessary.
    /// </para>
    /// <para>
    /// The link is displayed with an error style under the following conditions.
    /// </para>
    /// <list type="number">
    /// <item>
    /// <description>There is no enabled <see cref="AutoSiteMapProvider"/>.</description>
    /// </item>
    /// <item>
    /// <description>The sitemap does not have a node with the key specified in <see cref="SiteMapKey"/>.</description>
    /// </item>
    /// <item>
    /// <description>The containing page is not part of the sitemap.</description>
    /// </item>
    /// </list>
    /// <para>
    /// In each of the above cases, the <c>SiteMapKey</c> is treated as the URL.
    /// </para>
    /// <para>
    /// In many cases, specifying <see cref="AppliedFiltersControlID"/> can automatically build your query string.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// This is a link to the page R130_102.aspx, regardless of where in the project this page is located.
    /// For this example to work correctly, the sitemap provider must be aware of a node whose key is
    /// <c>R130_102.aspx</c>.
    /// </para>
    ///    <code lang="xml">
    ///    <![CDATA[
    ///        <eclipse:SiteHyperLink runat="server" SiteMapKey="R130_102.aspx" NavigateUrl="area=SHL&vwh_id=15"
    ///            Text="SHL Inventory" />
    ///    ]]>
    ///    </code>
    /// </example>
    public class SiteHyperLink : HyperLink
    {
        /// <summary>
        /// The Sitemap node key to navigate when the value is clicked. 
        /// </summary>
        /// <remarks>
        /// <para>
        /// If this property is not specified, then <see cref="SiteHyperLink"/> behaves identically to the
        /// standard <c>Hyperlink</c> control.
        /// </para>
        /// <para>
        /// This property gets prepended with the query string specified in the <c>NavigateUrl</c> </para>
        /// <para>
        /// The value specified is interpreted as the sitemap node key.
        /// For example, if <c>SiteMapKey</c> is <c>R110_03.aspx</c>, then <c>R110_03.aspx</c> will become 
        /// the sitemap node url to navigate.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// To see the example of <c>SiteMapKey</c> refer to <see cref="SiteHyperLink"/>
        /// </para>
        /// </example>
        public string SiteMapKey { get; set; }

        /// <summary>
        /// Whether the link should be visible only if the user has rights to the URL
        /// </summary>
        /// <remarks>
        /// If true, we check during rendering whether the resulting <see cref="HyperLink.NavigateUrl"/> is accessible to the
        /// current user. If it is not, we render nothing.
        /// </remarks>
        public bool SecurityCheck { get; set; }

        /// <summary>
        /// <para>
        /// If set, the query string parameters returned by this
        /// <see cref="AppliedFilters"/> control will be added to the url.
        /// </para>
        /// </summary>
        /// <remarks>
        /// <para>
        ///     This property can be used in case it is required to have all the filters applied be passed 
        ///     to the query string. This will be apended to the values of <c>NavigateUrl</c>.
        /// </para>
        /// <para>
        /// The referenced <see cref="AppliedFilters"/> control
        /// must be in the same naming container as the grid. If this is not the case then you can use the
        /// <see cref="FiltersControl"/> property to set it programmatically.
        /// </para>
        /// <example>
        /// <para>
        /// In the current example a link <a href="#">SHL Inventory</a> will navigate to "R130_102.aspx" page upon clicking
        /// and the applied filters will get specified as query string.
        /// </para>
        ///     <para>
        ///         Below are the applied filters.
        ///     </para>
        ///     <table>
        ///         <tr>
        ///             <td colspan="2" style="width:15em"><strong>Applied Filter</strong></td>
        ///         </tr>
        ///         <tr>
        ///             <td>Virtual Warehouse</td>
        ///             <td>15: US</td>
        ///         </tr>
        ///     </table>
        ///     <para>
        ///         Following will be the mark up to specify the applied filters as query string.
        ///         As you can see, here <c>AppliedFiltersControlID</c> has been specified as 
        ///         <c>AppliedFiltersControlID="ctlButtonBar$af"</c> where <c>ctlButtonBar</c> is 
        ///         any user control which is having <c>af</c> as <c>AppliedFilter</c> in it.
        ///     </para>
        ///     <para>
        ///     Now, with the following snippet, the resulting url will be much like this
        ///     <c>http://....../R130_102.aspx?vwh_id=15</c>.
        ///     </para>
        ///     <code lang="xml">
        ///     <![CDATA[
        ///     <eclipse:SiteHyperLink runat="server" Text="SHL Inventory" SiteMapKey="R130_102.aspx"
        ///         AppliedFiltersControlID="ctlButtonBar$af" />
        ///     ]]>
        /// </code>
        /// </example>
        /// </remarks>
        /// 
        [Browsable(true)]
        public string AppliedFiltersControlID { get; set; }

        /// <summary>
        /// The property serves the same purpose as <see cref="AppliedFiltersControlID"/>. 
        /// But if this is specified, we search for the control at the page level. This takes precedence over
        /// AppliedFiltersControlID.
        /// </summary>
        /// <remarks>
        /// </remarks>
        /// <example>
        /// 
        /// </example>
        public string AppliedFiltersControlUniqueID { get; set; }

        private AppliedFilters _filtersControl;

        /// <summary>
        /// You can also specify the control directly through code using this property
        /// </summary>
        [Browsable(false)]
        public AppliedFilters FiltersControl
        {
            get
            {
                if (_filtersControl == null)
                {
                    string str;
                    if (!string.IsNullOrEmpty(this.AppliedFiltersControlUniqueID))
                    {
                        _filtersControl = (AppliedFilters)this.Page.FindControl(AppliedFiltersControlUniqueID);
                        if (_filtersControl == null)
                        {
                            str = string.Format("AppliedFilter control {0} not found", AppliedFiltersControlUniqueID);
                            throw new Exception(str);
                        }
                    }
                    else if (!string.IsNullOrEmpty(AppliedFiltersControlID))
                    {
                        _filtersControl = (AppliedFilters)this.NamingContainer.FindControl(AppliedFiltersControlID);
                        if (_filtersControl == null)
                        {
                            str = string.Format("AppliedFilter control {0} not found", AppliedFiltersControlID);
                            throw new Exception(str);
                        }
                    }
                }
                return _filtersControl;
            }
            set
            {
                _filtersControl = value;
            }
        }


        /// <summary>
        /// Calculate the NavigateUrl in Render because no other event is absolutely guaranteed.
        /// </summary>
        /// <remarks>
        /// SiteMapKey will now become <c>NavigateUrl</c> incase <see cref="AutoSiteMapProvider"/> is 
        /// not available or the containing page is not known to <see cref="AutoSiteMapProvider"/>.
        /// </remarks>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            if (this.FiltersControl != null && !this.FiltersControl.Visible)
            {
                // Don't render anything
                return;
            }

            if (this.SecurityCheck && !string.IsNullOrWhiteSpace(this.NavigateUrl) &&
                !UrlAuthorizationModule.CheckUrlAccessForPrincipal(this.NavigateUrl, this.Page.User, "GET"))
            {
                // Security check failed. Nothing to render
                return;
            }
            if (string.IsNullOrEmpty(this.SiteMapKey))
            {
                // Do nothing. Use NavigateUrl as is
                
            }
            else
            {
                string url;
                bool broken = true;         // Assume that the link is potentially broken
                if (!SiteMap.Enabled || SiteMap.CurrentNode == null)
                {
                    url = this.SiteMapKey;
                }
                else
                {
                    SiteMapNode node = SiteMap.Provider.FindSiteMapNodeFromKey(this.SiteMapKey);
                    if (node == null)
                    {
                        url = this.SiteMapKey;
                    }
                    else
                    {
                        url = node.Url;
                        broken = false;     // Not broken
                    }
                }
                this.NavigateUrl = url + "?" + this.NavigateUrl;
                if (this.FiltersControl != null)
                {
                    this.NavigateUrl += "&" + this.FiltersControl.AsQueryString();
                }

                if (broken)
                {
                    this.Style.Add("border-bottom", "0.4mm dotted red");
                    this.ToolTip = string.Format("Link to {0} is not available", this.SiteMapKey);
                }
            }

            base.Render(writer);
        }
    }
}
