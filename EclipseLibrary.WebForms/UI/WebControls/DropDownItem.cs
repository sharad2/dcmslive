using System.Collections.Generic;
using System.ComponentModel;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace EclipseLibrary.Web.UI
{
    public enum DropDownPersistenceType
    {
        /// <summary>
        /// Item will be lost after databinding
        /// </summary>
        Never,

        /// <summary>
        /// Item will surive after data binding only if data source returns no items
        /// </summary>
        WhenEmpty,

        /// <summary>
        /// Item will survive even afterbinding
        /// </summary>
        Always
    }

    /// <summary>
    /// Represents an item which can be used to fill a <see cref="T:EclipseLibrary.Web.JQuery.Input.DropDownListEx"/>
    /// or <see cref="T:EclipseLibrary.Web.JQuery.Input.AjaxDropDown"/> control
    /// </summary>
    [ParseChildren(true)]
    [PersistChildren(false)]
    [TypeConverter(typeof(ExpandableObjectConverter))]
    public class DropDownItem
    {
        /// <summary>
        /// 
        /// </summary>
        public DropDownItem()
        {
            this.Persistent =  DropDownPersistenceType.Never;
            this.Text = string.Empty;
            this.Value = string.Empty;
            this.OptionGroup = string.Empty;
            //this.Enabled = true;
        }


        [Browsable(true)]
        public DropDownPersistenceType Persistent
        {
            get;
            set;
        }

        [Browsable(true)]
        [PersistenceMode(PersistenceMode.Attribute)]
        public string Text { get; set; }

        [Browsable(true)]
        [PersistenceMode(PersistenceMode.Attribute)]
        public string Value { get; set; }

        [Browsable(true)]
        [PersistenceMode(PersistenceMode.Attribute)]
        public string OptionGroup { get; set; }

        /// <summary>
        /// You can style each item individually by applying a CSS class to it
        /// </summary>
        /// <remarks>
        /// <para>
        /// <c>ScriptIgnore</c> attribute ensures that <c>JavascriptSerializer</c> will not serialize this property.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [ScriptIgnore]
        public string CssClass { get; set; }

        /// <summary>
        /// Contains the values 
        /// </summary>
        /// <remarks>
        /// <para>
        /// <c>ScriptIgnore</c> attribute ensures that <c>JavascriptSerializer</c> will not serialize this property.
        /// </para>
        /// </remarks>        
        [Browsable(false)]
        [ScriptIgnore]
        public IDictionary<string, object> CustomData { get; set; }
    }
}
