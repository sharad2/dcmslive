using System.ComponentModel;
using System.Web.UI;
using EclipseLibrary.Web.JQuery.Scripts;
using System.Collections.Generic;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Provides properties which can control the row selection behavior of <see cref="GridViewEx"/>
    /// </summary>
    /// <remarks>
    /// <para>This class encapsulates the jQuery <c>selectable</c> widget.
    /// You set its properties via the <see cref="GridViewEx.Selectable"/> property of <c>GridViewEx</c>.
    /// It has properties corresponding
    /// to most of the options and events exposed by the <c>selectable</c> widget. Although multiple row selection
    /// is the default, single row selection is possible by setting an appropriate value for the <see cref="Cancel"/>
    /// property. If you do not want all rows to be selectable, you could modify the value of the <see cref="Filter"/>
    /// property.
    /// </para>
    /// <para>
    /// In all client events, <c>this</c> refers to the associated <see cref="GridViewEx"/>.
    /// Handle the <see cref="OnSelectableStop"/> event to do something after the user has made some selections.
    /// </para>
    /// </remarks>
    /// <example>
    /// Here is the markup which can enable row level selection within a grid view.
    /// <code>
    /// <![CDATA[
    ///<jquery:GridViewEx ID="gvPickSlip" runat="server">
    ///    <Selectable />
    ///     ...
    ///</jquery:GridViewEx>
    /// ]]>
    /// </code>
    /// </example>
    [TypeConverter(typeof(ExpandableObjectConverter))]
    [ParseChildren(true)]
    [PersistChildren(false)]
    public class GridViewExSelectable
    {
        public GridViewExSelectable()
        {
            this.IsSelectable = true;
            // All tr excluding master rows and master headers
            //this.Filter = " > tbody > tr:not(.ui-state-disabled, .gvex-masterrow, .gvex-subtotal-row, :has(th), [disabled])";
            // :has(th) causes problems on windows 7 and IE9. No row remains selectable
            this.Filter = " > tbody > tr:not(.ui-state-disabled, .gvex-masterrow, .gvex-subtotal-row, [disabled])";

        }

        /// <summary>
        /// Elements matching this selector will not cause selection to start. Specifying * will
        /// enforce that only a single row can be selected at any time.
        /// </summary>
        /// <remarks>
        /// <para>
        /// This property corresponds to the <c>cancel</c> option of the jQuery widget. By default,
        /// multiple row selection cannot begin if the user begins dragging on any input control or a
        /// hyperlink.
        /// </para>
        /// <para>
        /// A value of * would normally mean that rows cannot be selected by clicking. However,
        /// extra code exists in <c>gridViewEx</c> widget which implements single row selection.
        /// The row that you click on will get selected and all other rows will get unselected.
        /// </para>
        /// <para>
        /// If you want to prevent selctions using a mouse click altogether,
        /// set <c>Cancel="table *"</c>.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [Themeable(true)]
        [DefaultValue(":input,option,a[href]")]
        public string Cancel { get; set; }

        /// <summary>
        /// This event is triggered at the end of the select operation.
        /// </summary>
        /// <remarks>
        /// <para>
        /// This is a good time to count how many rows have been selected and possibly display this count
        /// in some status label as shown in this example. <c>this</c> refers to the associated <see cref="GridViewEx"/>.
        /// </para>
        /// <code>
        /// <![CDATA[
        ///<jquery:GridViewEx ID="gvPickSlip" runat="server">
        ///    <Selectable OnSelectableStop="function(event) {
        ///     // Shows how many rows are currently selected
        ///     alert($(this).gridViewEx('selectedRows').length);
        ///    }" />
        ///     ...
        ///</jquery:GridViewEx>
        /// ]]>
        /// </code>
        /// </remarks>
        [Browsable(true)]
        public string OnSelectableStop { get; set; }

        /// <summary>
        /// This event is triggered during the select operation, on each element added to the selection.
        /// </summary>
        /// <remarks>
        /// <para>
        /// While the user is selcting rows by dragging, this event could be raised multiple times.
        /// By contrast, the <see cref="OnSelectableSelected"/> event is raised only after the user has
        /// finished dragging. Thus the event handler for this event is useful for highlighting something
        /// which might help the user to understand what will happen if the row is actually selected.
        /// </para>
        /// <para>
        /// This example code checks a check box in the row whenever the row is selected. In fact, this is
        /// how a <see cref="SelectCheckBoxField"/> gets checked, no matter how you select the row.
        /// <c>ui.selecting</c> refers to the row which is getting selected. If you are unchecking the checkbox
        /// in this event, it is redundant to uncheck it in <see cref="OnSelectableSelected"/> as well.
        /// <code>
        /// <![CDATA[
        /// function(event, ui) {
        ///   $('.mycb', ui.selecting).attr('checked', true);
        /// }
        /// ]]>
        /// </code>
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public string OnSelectableSelecting { get; set; }

        /// <summary>
        /// This event is triggered at the end of the select operation, on each element added to the selection.
        /// </summary>
        /// <remarks>
        /// <para>
        /// The function is passed the selected row which can be used to obtain the selected key
        /// as shown in the example. If the user reselects a row, this event will be raised but
        /// the <see cref="OnSelectableUnselected"/> will not be raised.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// This example code checks a check box in the row whenever the row is selected. In fact, this is
        /// how a <see cref="SelectCheckBoxField"/> gets checked, no matter how you select the row.
        /// <c>ui.selected</c> refers to the row which is has been selected. As a bonus, it alerts the
        /// data the first data key of the selected row.
        /// </para>
        /// <code>
        /// <![CDATA[
        /// function(event, ui) {
        ///   $('.mycb', ui.selected).attr('checked', true);
        ///   var x = $(this).gridViewEx('keys', $(ui.selected));
        ///   alert(x[0][0]);
        /// }
        /// ]]>
        /// </code>
        /// </example>
        [Browsable(true)]
        public string OnSelectableSelected { get; set; }
        
        /// <summary>
        /// This event is triggered at the end of the select operation, on each element removed from the selection.
        /// </summary>
        /// <remarks>
        /// <para>
        /// This example code unchecks a check box in the row whenever the row is unselected. In fact, this is
        /// how a <see cref="SelectCheckBoxField"/> gets checked, no matter how you unselect the row.
        /// <c>ui.unselected</c> refers to the row which is has been selected.
        /// <code>
        /// <![CDATA[
        /// function(event, ui) {
        ///   $('.mycb', ui.unselected).removeAttr('checked');
        /// }
        /// ]]>
        /// </code>
        /// </para>
        /// </remarks>        
        [Browsable(true)]
        public string OnSelectableUnselected { get; set; }


        /// <summary>
        /// Controls which rows are candidates for selection
        /// </summary>
        /// <remarks>
        /// <para>
        /// The default selector excludes disabled rows as well as master detail header and subtotal rows.
        /// This should be treated as an advanced property and should not be changed under normal cicumstances.
        /// If you want to exclude additional rows from selection, simply assign the <c>ui-state-disabled</c>
        /// class to them. See <see cref="GridViewEx.Selectable"/> property for a code example.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        [DefaultValue(" > tbody > tr:not(.ui-state-disabled, .gvex-masterrow.gvex-subtotal-row, :has(th), [disabled])")]
        public string Filter { get; set; }

        /// <summary>
        /// Default is true. <see cref="SelectCheckBoxField"/> ensures that it is set to true
        /// </summary>
        /// <remarks>
        /// This is provided as a convenience so that you can disable the selectable functionality without
        /// having to remove your markup. The default value is <c>true</c>.
        /// </remarks>
        [Browsable(false)]
        [DefaultValue(true)]
        internal bool IsSelectable { get; set; }

        /// <summary>
        /// Generates the options which need to be passed to the jQuery <c>selectable</c> widget.
        /// </summary>
        /// <param name="owner"></param>
        /// <param name="gridOptions"></param>
        internal void MakeSelectable(GridViewEx owner, JQueryOptions gridOptions)
        {
            if (!this.IsSelectable)
            {
                return;
            }
            JQueryOptions selectableOptions = new JQueryOptions();
            if (owner.EnableViewState)
            {
                gridOptions.Add("enableClientState", true);
            }
            //options.Add("autoRefresh", false);
            selectableOptions.Add("filter", this.Filter);
            selectableOptions.Add("tolerance", "touch");
            // Multiple selection will not start until the mouse is dragged beyond these many pixels
            //options.Add("distance", 8);
            if (string.IsNullOrEmpty(this.Cancel))
            {
                // If any of the header rows is clicked, do not modify selection
                selectableOptions.Add("cancel", ":input,option,a[href], tr.gvex-masterrow *, tr.gvex-subtotal-row *, thead *, tfoot *");
            }
            else
            {
                selectableOptions.Add("cancel", this.Cancel);
            }

            if (!string.IsNullOrEmpty(this.OnSelectableStop))
            {
                //options.AddRaw("stop", this.OnSelectableStop);
                owner.ClientEvents.Add("selectablestop", this.OnSelectableStop);
            }
            if (!string.IsNullOrEmpty(this.OnSelectableSelecting))
            {
                owner.ClientEvents.Add("selectableselecting", this.OnSelectableSelecting);
            }
            if (!string.IsNullOrEmpty(this.OnSelectableUnselected))
            {
                owner.ClientEvents.Add("selectableunselected", this.OnSelectableUnselected);
            }
            if (!string.IsNullOrEmpty(this.OnSelectableSelected))
            {
                owner.ClientEvents.Add("selectableselected", this.OnSelectableSelected);
            }
            gridOptions.Add("selectable", selectableOptions);
        }
    }
}
