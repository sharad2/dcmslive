using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery.Input
{
    /// <summary>
    /// Encapsulates a simple check box.
    /// </summary>
    /// <remarks>
    /// <para>
    /// <see cref="CheckedValue"/> is useful in data binding scenarios. When the <see cref="InputControlBase.QueryStringValue"/> evaluates to this value,
    /// the checkbox is checked. For all other values it is unchecked.
    /// </para>
    /// <para>
    /// <see cref="WidgetBase.CssClasses"/>, if specified will be applied to a wrapper span which contains both the
    /// input check box and the label.
    /// </para>
    /// </remarks>
    /// <example>
    /// <code>
    /// <![CDATA[
    ///<i:CheckBoxEx runat="server" ID="cbOverPull" Text="Allow Overpulling." CheckedValue="O"
    ///    UnCheckedValue="U" Value='<%# Bind("pieces_constraint") %>'>
    ///</i:CheckBoxEx>
    /// ]]>
    /// </code>
    /// </example>
    public class CheckBoxEx : InputControlBase
    {
        /// <summary>
        /// Default FocusPriority set to Low.
        /// </summary>
        public CheckBoxEx()
            : base(string.Empty)
        {
            // We always need our client id so that a click on the label can check the button
            //this.ClientIdRequired = true;
            this.FocusPriority = FocusPriority.Low;
            this.CheckedValue = "Y";
            this.UnCheckedValue = string.Empty;
            this.Text = string.Empty;
// ReSharper disable DoNotCallOverridableMethodsInConstructor
            this.Value = string.Empty;
// ReSharper restore DoNotCallOverridableMethodsInConstructor
        }

        /// <summary>
        /// The <c>QueryStringValue"</c> of the control when the checkbox is checked.
        /// </summary>
        /// <value>Defaults to <see cref="Control.UniqueID"/> if not specified.</value>
        /// <remarks>
        /// If the <c>QueryStringValue"</c> matches the <c>CheckedValue</c>, the check box displays
        /// as checked. For all other values, it displays unchecked.
        /// </remarks>
        [Browsable(true)]
        public string CheckedValue { get; set; }

        /// <summary>
        /// The value to return when the checkbox is unchecked
        /// </summary>
        [Browsable(true)]
        public string UnCheckedValue { get; set; }

        /// <summary>
        /// True if the check box is checked.
        /// </summary>
        /// <remarks>
        /// The checkbox is considered to be checked if <see cref="Value"/> matches <see cref="CheckedValue"/>
        /// </remarks>
        public bool Checked
        {
            get
            {
                return this.Value == this.CheckedValue;
            }
            set
            {
                this.Value = value ? this.CheckedValue : this.UnCheckedValue;
            }
        }

        /// <summary>
        /// The text to show in the label to the right of the checkbox.
        /// </summary>
        public string Text { get; set; }

        [Browsable(true)]
        public override string Value
        {
            get;
            set;
        }

        /// <summary>
        /// <c>DisplayValue</c> is <see cref="Text"/> followed by Checked.
        /// </summary>
        public override string DisplayValue
        {
            get
            {
                return this.Checked ? "Checked" : string.Empty;
            }
        }

        /// <summary>
        /// Add a label after the check box
        /// </summary>
        /// <param name="writer"></param>
        protected override void Render(HtmlTextWriter writer)
        {
            bool bWrapperCreated = false;
            if (this.CssClasses.Length > 0)
            {
                // Create wrapper span
                writer.AddAttribute(HtmlTextWriterAttribute.Class, string.Join(" ", this.CssClasses));
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
                bWrapperCreated = true;
            }

            base.Render(writer);

            writer.AddAttribute(HtmlTextWriterAttribute.For, this.ClientID);
            if (!string.IsNullOrEmpty(this.ToolTip))
            {
                writer.AddAttribute(HtmlTextWriterAttribute.Title, this.ToolTip);
            }
            writer.RenderBeginTag(HtmlTextWriterTag.Label);
            int index = -1;
            if (!string.IsNullOrEmpty(this.AccessKey))
            {
                index = this.Text.IndexOf(this.AccessKey, StringComparison.CurrentCultureIgnoreCase);
            }
            if (index < 0)
            {
                writer.Write(this.Text);
            }
            else
            {
                writer.Write(this.Text.Substring(0, index));
                writer.AddStyleAttribute(HtmlTextWriterStyle.TextDecoration, "underline");
                writer.RenderBeginTag(HtmlTextWriterTag.Span);
                writer.Write(this.AccessKey);
                writer.RenderEndTag();      // span
                writer.Write(this.Text.Substring(index + 1));
            }
            writer.RenderEndTag();      // label

            if (bWrapperCreated)
            {
                // End wrapper span
                writer.RenderEndTag();
            }
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="attributes"></param>
        /// <param name="cssClasses"></param>
        protected override void AddAttributesToRender(IDictionary<HtmlTextWriterAttribute, string> attributes, ICollection<string> cssClasses)
        {
            // Clear the classes. We will render them ourselves on the outer span
            cssClasses.Clear();

            base.AddAttributesToRender(attributes, cssClasses);
            attributes.Add(HtmlTextWriterAttribute.Type, "checkbox");

            if (this.Checked)
            {
                attributes.Add(HtmlTextWriterAttribute.Checked, "checked");
            }
            attributes.Add(HtmlTextWriterAttribute.Value, this.CheckedValue);
        }

        internal override string GetClientCode(ClientCodeType codeType)
        {
            switch (codeType)
            {
                case ClientCodeType.InterestEvent:
                    return "click";

                case ClientCodeType.GetValue:
                    return "function(e) { return $(this).is(':checked') ? $(this).val() : ''; }";

                case ClientCodeType.InputSelector:
                    return this.ClientSelector;
                case ClientCodeType.SetValue:
                    return @"function(val) {
val ? $(this).attr('checked', 'checked') : $(this).removeAttr('checked') ;
}";

                default:
                    return base.GetClientCode(codeType);
            }
        }
    }
}
