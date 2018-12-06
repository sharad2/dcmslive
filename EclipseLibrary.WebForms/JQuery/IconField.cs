using System;
using System.ComponentModel;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// List of images found at http://jqueryui.com/themeroller/#themeGallery
    /// DataField="poppants" DataFieldValues="TRUE,FALSE" IconNames="ui-icon-check,ui-icon-cross"
    /// You may not want to show an icon for certain values. In this case give an empty icon name.
    /// DataField="poppants" DataFieldValues="TRUE,FALSE" IconNames="ui-icon-check,"
    /// If you like to apply state to your icon name use property IconStates and give class comma seperated. An example is given below.
    /// IconStates="ui-state-error,ui-state-default"
    /// 
    /// TODO: To display an icon for a null value, you will say DataFieldValues="TRUE," IconNames="ui-icon-check,ui-icon-cross"
    /// Now when value is null, icon will be cross
    /// </summary>
    /// <remarks>
    /// If a value for which an icon has not been specified is encountered, no icon is displayed.
    /// </remarks>
    /// <example>
    /// <para>
    /// Sample Markup
    /// </para>
    /// <code>
    /// <![CDATA[
    ///<jquery:IconField DataField="status" HeaderText="Completed?" DataFieldValues="Yes"
    ///    IconNames="ui-icon-check" HeaderToolTip="Is return completed on the given date" />
    /// ]]>
    /// </code>
    /// </example>
    public class IconField : DataControlField, IHasHeaderToolTip
    {
        /// <summary>
        /// 
        /// </summary>
        public IconField()
        {
            this.ItemStyle.Width = Unit.Pixel(16);
            this.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
            this.DisplayValue = true;
        }

        /// <summary>
        /// The field whose value decides which icon to display
        /// </summary>
        [Browsable(true)]
        [Themeable(false)]
        public string DataField { get; set; }

        /// <summary>
        /// Comma seperated list of jquey icon names, corresponding to each value in <see cref="DataFieldValues"/>
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Comma seperated list of jquey icon names")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] IconNames
        {
            get;
            set;
        }

        /// <summary>
        /// Controls the color of the icon. Possible values any ui-state-* class, such as ui-state-error.
        /// Comma separted list, one per icon. Can be blank for any icon
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [DefaultValue("")]
        [Description("Comma seperated list of jquey ui-state-* class, one per icon")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        public string[] IconStates
        {
            get;
            set;
        }

        /// <summary>
        /// Comma seperated list of values, corresponding to each icon specified in <see cref="IconNames"/>
        /// </summary>
        [Browsable(true)]
        [Category("Data")]
        [Description("Comma seperated list of data field values")]
        [TypeConverterAttribute(typeof(StringArrayConverter))]
        [Themeable(false)]
        public string[] DataFieldValues
        {
            get;
            set;
        }

        /// <summary>
        /// Whether the value should also be displayed alongside the icon. This is useful when exporting to Excel
        /// </summary>
        /// <remarks>
        /// The value displayed is enclosed in a span having class=iconfield-displayvalue. Normally
        /// icons cannot be printed, so you would want to show only the icon on the screen and only the displayed
        /// value while printing. This is easily accomplished by specifying display:none for the class
        /// iconfield-displayvalue in your screen style sheet.
        /// </remarks>
        [Browsable(true)]
        [Themeable(true)]
        public bool DisplayValue { get; set; }

        public override void InitializeCell(DataControlFieldCell cell, DataControlCellType cellType, DataControlRowState rowState, int rowIndex)
        {
            switch (cellType)
            {
                case DataControlCellType.DataCell:
                    cell.DataBinding += new EventHandler(cell_DataBinding);
                    break;

                case DataControlCellType.Footer:
                    break;
                case DataControlCellType.Header:
                    break;
                default:
                    break;
            }
            base.InitializeCell(cell, cellType, rowState, rowIndex);
        }

        /// <summary>
        /// Decide which icon to show
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cell_DataBinding(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            GridViewRow row = (GridViewRow)cell.NamingContainer;
            string value = DataBinder.Eval(row.DataItem, this.DataField, "{0}");
            bool bFound = false;
            for (int i = 0; i < DataFieldValues.Length; ++i)
            {
                if (DataFieldValues[i] == value)
                {
                    bFound = true;
                    if ((this.IconStates) != null)
                    {
                        if (!string.IsNullOrEmpty(this.IconNames[i]))
                        {
                            cell.Text = string.Format("<div class='{2}'><span title='{0}' class='ui-icon {1}'></span></div>", value, this.IconNames[i], this.IconStates[i]);
                        }
                        break;
                    }
                    else
                    {
                        cell.Text = string.Format("<span title='{0}' class='ui-icon {1}'></span>", value, this.IconNames[i]);
                        break;
                    }
                }
            }
            if (!bFound)
            {
                // We encountered an unexpected value. Simply display space
                cell.Text = "&nbsp;";
            }
            if (this.DisplayValue)
            {
                cell.Text += string.Format("<span class='iconfield-displayvalue'>{0}</span>", value);
            }
        }

        protected override DataControlField CreateField()
        {
            return new IconField();
        }

        public override void ValidateSupportsCallback()
        {
            //base.ValidateSupportsCallback();
        }

        protected override void OnFieldChanged()
        {
            //base.OnFieldChanged();
        }

        #region IHasHeaderToolTip Members

        public string HeaderToolTip
        {
            get;
            set;
        }

        #endregion
    }
}
