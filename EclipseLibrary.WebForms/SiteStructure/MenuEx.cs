using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using EclipseLibrary.Oracle.Helpers.XPath;
using EclipseLibrary.Web.JQuery;


namespace EclipseLibrary.Web.SiteStructure
{
    public class MenuExItem
    {
        private readonly Collection<MenuExItem> _childItems;
        public MenuExItem()
        {
            _childItems = new Collection<MenuExItem>();

        }
        public string Text { get; set; }

        public string ToolTip { get; set; }

        public ICollection<MenuExItem> ChildItems {

            get {

                return _childItems;
            }
        }

        public string NavigateUrl { get; set; }

        public string[] RolesRequired { get; set; }
    }

    /// <summary>
    /// Generates a two level menu using jQuery theme. The first level is displayed horizontally.
    /// The second level becomes visible when the first level item is hovered.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The data for the first level of the menu is obtained via data binding from <see cref="DataSourceID"/> or
    /// <see cref="DataSource"/> by evaluating the values of <see cref="DataTextField"/> for the text and
    /// <see cref="DataNavigateUrlField"/> for the URL to navigate to. The second level items are obtained
    /// by evaluating <see cref="DataChildItemsField"/>. This field should evaluate to an enumerable which has
    /// the same properties as the top level item. The default value for each property is such that you do not
    /// have to specify it if you are binding to a <see cref="SiteMapDataSource"/>. <see cref="DataToolTipField"/>
    /// is also available if you are interested in showing a tooltip for each item.
    /// </para>
    /// <para>
    /// If the user does not have access to the menu link, a lock icon is displayed against that menu item.
    /// If the Url of the item ends with #, then the item is not clickable.
    /// Menu items which point to the url of the page on which they are being displayed are rendered with style
    /// <c>ui-state-active</c> and they are not clickable either.
    /// </para>
    /// <para>
    /// You can specify <see cref="TopItemWidth"/> to control the width of each top level item. <see cref="ChildItemWidth"/>
    /// specifies the width of each child item.
    /// </para>
    /// <para>
    /// By default the child menu items are displayed. Set <see cref="DisplayChildItems"/> to false
    /// to see only top level items.
    /// </para>
    /// <para>
    /// Sharad 30 Jul 2010: <see cref="DataFilterFields"/> can be specified to filter the items returned by the datasource.
    /// </para>
    /// <para>
    /// Deepak 4 Dec 2010: TODO: Add property DataRolesField. If specified, it is evaluated to determine what roles are
    /// required and if user does not have at least one of those roles then a lock is displayed. If it evaluates to empty
    /// then it means that no specific role is required.
    /// </para>
    /// </remarks>
    /// <example>
    /// <para>
    /// This simplest configuration is suitable for use on the master page. The sitemap data source
    /// returns top level nodes which <c>MenuEx</c> displays at the first level. The next level of the menu
    /// is shown as a pull down which opens up on hover.
    /// </para>
    /// <code lang="XML">
    /// <![CDATA[
    /// <asp:SiteMapDataSource runat="server" ID="dsTopLevel" ShowStartingNode="false" StartFromCurrentNode="false"
    ///     EnableViewState="false" />
    /// <eclipse:MenuEx runat="server" DataSourceID="dsTopLevel" />
    /// ]]>
    /// </code>
    /// <para>
    /// Here is a sample <c>web.sitemap</c> file
    /// </para>
    /// <code lang="XML">
    /// <![CDATA[
    ///<?xml version="1.0" encoding="utf-8" ?>
    ///<siteMap xmlns="http://schemas.microsoft.com/AspNet/SiteMap-File-1.0" >
    ///  <siteMapNode url="~/default.aspx" title="DCMS Home"  description="DCMS Website Home Page" roles="*">
    ///    <siteMapNode url="#" title="Pick and Pack" description="Pick and Pack Guide">
    ///      <siteMapNode url="~/Apps/Interface/ImportedPickslipList.aspx" title="Imported Pickslips"
    ///         description="Pickslips which have been imported" />
    ///      <siteMapNode url="~/Apps/Bucket/PickslipList/PickslipList.aspx" title="Pickslip List"
    ///         description="Search for Pickslips and view corresponding details"/>
    ///      <siteMapNode url="~/Apps/Bucket/PickslipDetails/PickslipDetails.aspx" title="Pickslip Details"
    ///         description="Full details of a specific pickslip" />
    ///      <siteMapNode url="~/Apps/Bucket/PoList.aspx" title="PO List"
    ///         description="List of Customer Purchase Orders" />
    ///    </siteMapNode>
    ///    <siteMapNode url="~/Apps/Receiving/Receiving.aspx" title="--Receiving" 
    ///     description="Receive inventory into DCMS">
    ///      <siteMapNode url="~/Apps/Receiving/InTransitList.aspx" title="--List of Intransits" 
    ///         description="See a list of intransits which have not yet been received" />
    ///      <siteMapNode url="~/Apps/Receiving/SkuReceiving.aspx" title="--Receive SKU" 
    ///         description="Receive non cartonized (Pieces) inventory" />
    ///      <siteMapNode url="~/Apps/Receiving/PreReceiving/PreReceiving.aspx" title="--Pre Receive Cartons"  
    ///         description="Create ASN for Cartonized Receiving" />
    ///    </siteMapNode>
    ///  </siteMapNode>
    ///</siteMap>
    /// ]]>
    /// </code>
    /// </example>
    [ParseChildren(true)]
    [PersistChildren(false)]
    public class MenuEx : WidgetBase
    {
        public MenuEx()
            : base(string.Empty)
        {
            this.EnableViewState = false;
            this.DataTextField = "Title";
            this.DataNavigateUrlField = "Url";
            this.DataChildItemsField = "ChildNodes";
            this.DisplayChildItems = true;
            this.DataToolTipField = "Description";
            this.ClearFix = true;
        }

        /// <summary>
        /// Set to false if you do not wish to see a drop down for each top level item.
        /// </summary>
        [Browsable(true)]
        [DefaultValue(true)]
        [Category("Appearance")]
        public bool DisplayChildItems { get; set; }

        /// <summary>
        /// The ID of the data source to use for data binding.
        /// </summary>
        /// <remarks>
        /// You do not need to manually call <see cref="DataBind"/>. It will be called automatically.
        /// </remarks>
        [Browsable(true)]
        [IDReferenceProperty(typeof(DataSourceControl))]
        [Category("Data")]
        public string DataSourceID { get; set; }

        /// <summary>
        /// Use this if you want to call DataBind yourself.
        /// </summary>
        [Browsable(false)]
        [Category("Data")]
        public object DataSource { get; set; }

        /// <summary>
        /// The field to evaluate for obtaining the text of the menu item.
        /// </summary>
        /// <remarks>
        /// The same field is evaluated for child items as well.
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("Title")]
        [Category("Data")]
        public string DataTextField { get; set; }

        /// <summary>
        /// The field to evaluate for obtaining the URL of the menu item.
        /// </summary>
        /// <remarks>
        /// The same field is evaluated for child items as well.
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("Url")]
        [Category("Data")]
        public string DataNavigateUrlField { get; set; }

        /// <summary>
        /// The tooltip to display for each iter
        /// </summary>
        [Browsable(true)]
        [DefaultValue("Description")]
        [Category("Data")]
        public string DataToolTipField { get; set; }

        /// <summary>
        /// The field to evaluate for each top level item to get a lsit of child items.
        /// </summary>
        [Browsable(true)]
        [DefaultValue("ChildNodes")]
        [Category("Data")]
        public string DataChildItemsField { get; set; }

        /// <summary>
        /// 
        /// </summary>
        [Browsable(true)]
        [DefaultValue("")]
        [Category("Data")]
        public string DataRolesField { get; set; }

        /// <summary>
        /// If specified, then only those menu items are displayed where this field evaluates to a non null value
        /// </summary>
        /// <remarks>
        /// This provides a way to filter out some of the menu items returned by the data source. See <see cref="FilterExpression"/>
        /// for a complete example.
        /// </remarks>
        [Browsable(true)]
        [Category("Data")]
        [DefaultValue("")]
        [TypeConverter(typeof(StringArrayConverter))]
        public string[] DataFilterFields { get; set; }

        /// <summary>
        /// The XPath expression to evaluate for each menu item
        /// </summary>
        /// <remarks>
        /// <para>
        /// If <see cref="DataFilterFields"/> is specified, then <c>FilterExpression</c> is evaluated for each menu item
        /// using the <see cref="XPathEvaluator"/> class.
        /// If the expression evaluates to <c>true</c>, then the menu item is displayed in the menu, otherwise it is not.
        /// If a first level menu item is filtered away, then child items of that menu will not display regardless of the filter
        /// expression. The expression can refer to the value of the n'th filter field by using the <c>$Filtern</c> syntax.
        /// For example, <c>$Field1 &gt; $Field2</c> is a possible filter expression.
        /// </para>
        /// <para>
        /// It must be specified if <c>DataFilterFields</c> are specified
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// Suppose we want to get rid of all those menu items for which the <c>TweakMf</c> attribute has been specified.
        /// Then our markup for the menu control will look like this:
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        /// <asp:SiteMapDataSource runat="server" ID="dsTopLevel" ShowStartingNode="false" StartFromCurrentNode="false"
        ///     EnableViewState="false" />
        /// <eclipse:MenuEx runat="server" DataSourceID="dsTopLevel" 
        ///     DataFilterFields="[TweakMf]" FilterExpression="not($Filter0)" />
        /// ]]>
        /// </code>
        /// <para>
        /// Next we simply decorate the items to be hidden with the <c>TweakMf</c> attribute as shown in the web.sitemap below.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<?xml version="1.0" encoding="utf-8" ?>
        ///<siteMap xmlns="http://schemas.microsoft.com/AspNet/SiteMap-File-1.0" >
        ///  <siteMapNode url="~/default.aspx" title="DCMS Home"  description="DCMS Website Home Page" roles="*">
        ///    <siteMapNode url="#" title="Pick and Pack" description="Pick and Pack Guide">
        ///      <siteMapNode url="~/Apps/Interface/ImportedPickslipList.aspx" title="Imported Pickslips"
        ///         description="Pickslips which have been imported" />
        ///      <siteMapNode url="~/Apps/Bucket/PickslipList/PickslipList.aspx" title="Pickslip List"
        ///         description="Search for Pickslips and view corresponding details"/>
        ///      <siteMapNode url="~/Apps/Bucket/PickslipDetails/PickslipDetails.aspx" title="Pickslip Details"
        ///         description="Full details of a specific pickslip" />
        ///      <siteMapNode url="~/Apps/Bucket/PoList.aspx" title="PO List" TweakMf="true"
        ///         description="List of Customer Purchase Orders" />
        ///    </siteMapNode>
        ///    <siteMapNode url="~/Apps/Receiving/Receiving.aspx" title="--Receiving" 
        ///     description="Receive inventory into DCMS">
        ///      <siteMapNode url="~/Apps/Receiving/InTransitList.aspx" title="--List of Intransits" 
        ///         description="See a list of intransits which have not yet been received" />
        ///      <siteMapNode url="~/Apps/Receiving/SkuReceiving.aspx" title="--Receive SKU" TweakMf="true"
        ///         description="Receive non cartonized (Pieces) inventory" />
        ///      <siteMapNode url="~/Apps/Receiving/PreReceiving/PreReceiving.aspx" title="--Pre Receive Cartons"  
        ///         description="Create ASN for Cartonized Receiving" />
        ///    </siteMapNode>
        ///  </siteMapNode>
        ///</siteMap>
        /// ]]>
        /// </code>
        /// </example>
        public string FilterExpression { get; set; }

        /// <summary>
        /// Width of each top level item. Defaults to 10 em.
        /// </summary>
        /// <remarks>
        /// <para>
        /// The top level menu items should all be of the same width. 
        /// If you do not specify a width, each top level item would be of a different width.
        /// In most cases you will need to specify a value after some hit and trial. The width should be large 
        /// enough to accommodate the largest menu item. Remember to take into account the width of an icon which could show up
        /// if the URL is not accessible.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Category("Appearance")]
        public Unit TopItemWidth { get; set; }

        /// <summary>
        /// The width of each child item
        /// </summary>
        /// <remarks>
        /// <para>
        /// The width of each child item should generally be 50% more than the width of the top level item.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue("15em")]
        [Category("Appearance")]
        public Unit ChildItemWidth { get; set; }

        private Collection<MenuExItem> _items = new Collection<MenuExItem>();

        /// <summary>
        /// The items in the menu. These are commonly populated using data binding but can be specified
        /// in markup as well.
        /// </summary>
        [Browsable(true)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        public Collection<MenuExItem> Items
        {
            get
            {
                return _items;
            }
        }


        /// <summary>
        /// This is an advanced property. By default, the markup <![CDATA[<div class="ui-helper-clearfix"></div>]]>
        /// is generated after the menu to ensure that the menu line does not display any other content.
        /// </summary>
        /// <remarks>
        /// <para>
        /// If you intend to display something on the same line as the menu, set this property to false, and then generate this markup
        /// yourself.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// The following is markup from a master page. This master page allows individual pages to place content to the right of the menu.
        /// </para>
        /// <code lang="XML">
        /// <![CDATA[
        ///<eclipse:MenuEx ID="MenuEx1" runat="server" DataSourceID="dsTopLevel" ClearFix="false" />
        ///<div style="float: right">
        ///    <asp:ContentPlaceHolder runat="server" ID="contentRight">
        ///    </asp:ContentPlaceHolder>
        ///</div>
        ///<div class="ui-helper-clearfix">
        ///</div>
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool ClearFix { get; set; }

        private bool _requiresDataBinding = true;

        /// <summary>
        /// Calls <see cref="DataBind"/> if it has not been called already.
        /// </summary>
        protected void EnsureDataBound()
        {
            if (_requiresDataBinding)
            {
                DataBind();
            }
        }

        /// <summary>
        /// Set to true just before DataBind() is called from within PreRender. Then set to false.
        /// </summary>
        private bool _inPreRender;

        /// <summary>
        /// Populates <see cref="Items"/> by retrieving data from the data source.
        /// </summary>
        public override void DataBind()
        {
            if (!_inPreRender)
            {
                OnDataBinding(EventArgs.Empty);
            }
            PerformDataBinding();
            _requiresDataBinding = false;
        }

        /// <summary>
        /// Add <see cref="Items"/> from the data source. Derived classes should override this to add items
        /// from their custom data source.
        /// </summary>
        protected virtual void PerformDataBinding()
        {
            IEnumerable data = PerformSelect();
            if (data == null)
            {
                // Do nothing. This happens when no data source has been assigned to us
                return;
            }
            _items.Clear();

            if (data != null)
            {
                //DropDownItemEventArgs args = new DropDownItemEventArgs();
                foreach (object dataItem in data)
                {
                    MenuExItem item = CreateItem(dataItem);
                    // Sharad 5 Aug 2010: In security trimming scenarios, we get items with empty text. We should just ignore these.
                    if (item != null && !string.IsNullOrEmpty(item.Text))
                    {
                        if (this.DisplayChildItems)
                        {
                            IEnumerable children = (IEnumerable)DataBinder.Eval(dataItem, this.DataChildItemsField);
                            foreach (object childItem in children)
                            {
                                MenuExItem item2 = CreateItem(childItem);
                                if (item2 != null)
                                {
                                    item.ChildItems.Add(item2);
                                }
                            }
                        }
                        _items.Add(item);
                    }
                }
            }
        }

        private XPathEvaluator _evaluator;

        /// <summary>
        /// This will return null if the item text begins with --
        /// </summary>
        /// <param name="dataItem"></param>
        /// <returns></returns>
        private MenuExItem CreateItem(object dataItem)
        {
            MenuExItem item = new MenuExItem();
            item.Text = DataBinder.Eval(dataItem, this.DataTextField, "{0}");
            if (this.DataFilterFields != null && this.DataFilterFields.Length > 0)
            {
                if (_evaluator == null)
                {
                    _evaluator = new XPathEvaluator();
                }
                Dictionary<string, object> dict = this.DataFilterFields.Select((p, i) => new
                {
                    Field = string.Format("Filter{0}", i),
                    Value = DataBinder.Eval(dataItem, p)
                }).ToDictionary(p => p.Field, p => p.Value);
                _evaluator.Callback = p => dict[p];
                if (!_evaluator.Matches(this.FilterExpression))
                {
                    return null;
                }
            }
            item.NavigateUrl = DataBinder.Eval(dataItem, this.DataNavigateUrlField, "{0}");
            item.ToolTip = DataBinder.Eval(dataItem, this.DataToolTipField, "{0}");
            if (!string.IsNullOrEmpty(this.DataRolesField))
            {
                IEnumerable roles = (IEnumerable)DataBinder.Eval(dataItem, this.DataRolesField);
                string[] rolesArray = roles.Cast<string>().ToArray();
                if (rolesArray.Length > 0)
                {
                    item.RolesRequired = rolesArray;
                }

            }
            return item;
        }

        private IEnumerable PerformSelect()
        {
            IEnumerable data;
            if (!string.IsNullOrEmpty(this.DataSourceID))
            {
                IDataSource ds = (IDataSource)this.NamingContainer.FindControl(this.DataSourceID);
                data = null;
                ds.GetView(string.Empty).Select(DataSourceSelectArguments.Empty, delegate(IEnumerable data1)
                {
                    data = data1;
                });
            }
            else if (this.DataSource == null)
            {
                data = null;
            }
            else if (this.DataSource is IEnumerable)
            {
                data = (IEnumerable)this.DataSource;
            }
            else if (this.DataSource is IDataSource)
            {
                IDataSource ds = (IDataSource)this.DataSource;
                data = null;
                ds.GetView(string.Empty).Select(DataSourceSelectArguments.Empty, delegate(IEnumerable data1)
                {
                    data = data1;
                });
            }
            else
            {
                throw new NotSupportedException();
            }
            return data;
        }


        protected override void PreCreateScripts()
        {
            JQueryScriptManager.Current.RegisterScripts(ScriptTypes.Core);
            const string SCRIPT = @"
$('ul.menuex-outermost > li').hoverIntent(
{
    over: function(e) {
        $('> ul', this).show();
      },
    out: function(e) {
        $('> ul', this).hide();
      },
    sensitivity: 2
}).find('a').hover(function(e) {
    $(this).addClass('ui-state-hover');
}, function(e) {
    $(this).removeClass('ui-state-hover');
});";
            JQueryScriptManager.Current.RegisterReadyScript("MenuExScript", SCRIPT);
        }

        /// <summary>
        /// Data bind if necessary
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPreRender(EventArgs e)
        {
            if (!string.IsNullOrEmpty(this.DataSourceID))
            {
                _inPreRender = true;
                EnsureDataBound();
                _inPreRender = false;
            }

            base.OnPreRender(e);
        }

        /// <summary>
        /// Return UL
        /// </summary>
        protected override HtmlTextWriterTag TagKey
        {
            get
            {
                return HtmlTextWriterTag.Ul;
            }
        }

        /// <summary>
        /// Add CSS classes
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            cssClasses.Add("menuex-outermost");
            base.AddAttributesToRender(attributes, cssClasses);
        }

        /// <summary>
        /// Render the markup
        /// </summary>
        /// <param name="writer"></param>
        /// <remarks>
        /// <para>
        /// The markup rendered by this control looks like:
        /// </para>
        /// <code>
        /// <![CDATA[
        /// <ul class="menuex-outermost">
        ///   <li style="width:??">
        ///   <a href="url1" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon">
        ///     <span class="ui-button-icon-primary ui-icon ui-icon-locked"/>
        ///     <span class="ui-button-text">Top Item 1</span>
        ///   </a>
        ///     <ul>
        ///       <li style="width:??">
        ///         <a href="url1" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-icon">
        ///           <span class="ui-button-icon-primary ui-icon ui-icon-locked"/>
        ///           <span class="ui-button-text">Child 1 of Top 1</span>
        ///         </a>
        ///       </li>
        ///       ...
        ///     </ul>
        ///   </li>
        ///   ...
        /// </ul>
        /// <div class="ui-helper-clearfix"></div>
        /// ]]>
        /// </code>
        /// </remarks>        
        protected override void Render(HtmlTextWriter writer)
        {
            base.Render(writer);
            if (this.ClearFix)
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-helper-clearfix");
                writer.RenderBeginTag(HtmlTextWriterTag.Div);
                writer.RenderEndTag();
            }
        }

        /// <summary>
        /// Renders the items
        /// </summary>
        /// <param name="writer"></param>
        protected override void RenderContents(HtmlTextWriter writer)
        {
            foreach (MenuExItem item in _items)
            {
                if (this.TopItemWidth != Unit.Empty)
                {
                    writer.AddStyleAttribute(HtmlTextWriterStyle.Width, this.TopItemWidth.ToString());
                }
                writer.RenderBeginTag(HtmlTextWriterTag.Li);
                RenderItem(writer, item, this.TopItemWidth);
                if (this.DisplayChildItems && item.ChildItems.Count > 0)
                {
                    writer.RenderBeginTag(HtmlTextWriterTag.Ul);
                    foreach (MenuExItem childItem in item.ChildItems)
                    {
                        writer.RenderBeginTag(HtmlTextWriterTag.Li);
                        RenderItem(writer, childItem, this.ChildItemWidth);
                        writer.RenderEndTag();      // li
                    }
                    writer.RenderEndTag();      // ul
                }
                writer.RenderEndTag();      // li
            }
            base.RenderContents(writer);
        }

        private bool IsSamePageUrl(MenuExItem item)
        {
            string url = this.ResolveUrl(item.NavigateUrl);
            return url == this.Page.Request.RawUrl;
        }
        /// <summary>
        /// Renders A tag and possibly a lock icon
        /// </summary>
        /// <param name="writer"></param>
        /// <param name="item"></param>
        /// <param name="itemWidth"></param>
        private void RenderItem(HtmlTextWriter writer, MenuExItem item, Unit itemWidth)
        {
            if (!string.IsNullOrEmpty(item.ToolTip))
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Title, item.ToolTip);
            }


            string iconName = string.Empty;
            string[] y = new string[] { "ui-button", "ui-widget", "ui-corner-all" };
            List<string> cssClasses = new List<string>(y);
            if (IsSamePageUrl(item))
            {
                cssClasses.Add("ui-state-active");
            }
            else
            {
                cssClasses.Add("ui-state-default");
                if (item.NavigateUrl.EndsWith("#"))
                {
                    writer.AddStyleAttribute(HtmlTextWriterStyle.Cursor, "default");
                    iconName = "ui-icon-triangle-1-s";
                }
                else
                {
                    string url = this.ResolveUrl(item.NavigateUrl);
                    writer.AddAttribute(HtmlTextWriterAttribute.Href, url);

                    int index = item.NavigateUrl.IndexOf('?');
                    bool isAccessible;
                    // Do not pass query string as part of URL
                    if (index < 0)
                    {
                        isAccessible = UrlAuthorizationModule.CheckUrlAccessForPrincipal(item.NavigateUrl, this.Page.User, "GET");
                    }
                    else
                    {
                        isAccessible = UrlAuthorizationModule.CheckUrlAccessForPrincipal(item.NavigateUrl.Substring(0, index), this.Page.User, "GET");
                    }
                    if (!isAccessible)
                    {
                        iconName = "ui-icon-locked";
                        cssClasses.Add("ui-priority-secondary");
                    }
                }
            }

            if (string.IsNullOrEmpty(iconName))
            {
                cssClasses.Add("ui-button-text-only");
            }
            else
            {
                cssClasses.Add("ui-button-text-icon-primary");
            }

            writer.AddAttribute(HtmlTextWriterAttribute.Class, string.Join(" ", cssClasses.ToArray()));
            if (itemWidth != Unit.Empty)
            {
                writer.AddStyleAttribute(HtmlTextWriterStyle.Width, itemWidth.ToString());
            }
            writer.RenderBeginTag(HtmlTextWriterTag.A);
            if (!string.IsNullOrEmpty(iconName))
            {
                // Show lock icon
                writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-button-icon-primary ui-icon " + iconName);
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
                writer.RenderEndTag();
            }

            writer.AddAttribute(HtmlTextWriterAttribute.Class, "ui-button-text");
            writer.RenderBeginTag(HtmlTextWriterTag.Span);
            writer.Write(item.Text);
            writer.RenderEndTag();      // span
            writer.RenderEndTag();      // a
        }
    }
}
