using System;
using System.Collections;
using System.Collections.Specialized;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.ComponentModel;
using System.Linq;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Can inssert rows in place using this grid
    /// </summary>
    /// <remarks>
    /// <para>
    /// GridViewExInsert provides full support for inserting rows. You can set the property 
    /// <see cref="InsertRowsCount"/> to indicate how many rows you want to display in insert mode.
    /// The insert rows are displayed at the top unless <see cref="InsertRowsAtBottom"/> property is set to true.
    /// </para>
    /// <para>
    /// Create a button for Insert and on its click handler set the GridViewExInsert property InsertRowsCount="1" and then hide the button.
    /// Again in the GridViewExInsert datasource's  inserted event, set the button to visible. So the insert mode of the GridViewExInsert will
    /// be visible only when we click the button. Again, create a method like GetPackageId which will remember the newly inserted row's datakey. In
    /// the GridViewExInsert RowDataBound event we check for the newly inserted row's datakey and highlight it by setting the DataControlRowState
    /// to Selected    
    /// </para>
    /// <code lang="xml">
    /// <![CDATA[
    ///  <i:ButtonEx ID="btnInsert" runat="server" Text="Add New Package" OnClick="btnInsert_Click"
    ///    Action="Submit" />
    /// 
    /// <phpa:PhpaLinqDataSource ID="dsPackage" runat="server"  OnInserted="dsPackage_Inserted">       
    ///     <InsertParameters>
    ///       <asp:Parameter Name="packagename" Type="String" />
    ///    <asp:Parameter Name="Description" Type="String" />
    ///    </InsertParameters>       
    ///  </phpa:PhpaLinqDataSource>
    ///  
    /// <jquery:GridViewExInsert ID="gvPackage" DataSourceID="dsPackage" runat="server" OnRowDataBound="gvPackage_RowDataBound">
    ///    <Columns>
    ///        <eclipse:SequenceField AccessibleHeaderText="sequence" />
    ///        <eclipse:MultiBoundField DataFields="packagename" HeaderText="Package Name">
    ///              <EditItemTemplate>
    ///                 <i:TextBoxEx ID="tbEditPackageName" runat="server" Text='<%#Bind("packagename") %>' FriendlyName="Package Name">
    ///                     <Validators>
    ///                          <i:Required />
    ///                         <i:Value ValueType="String" />
    ///                      </Validators>
    ///                  </i:TextBoxEx>
    ///              </EditItemTemplate>
    ///           </eclipse:MultiBoundField>      
    ///        <jquery:CommandFieldEx  />
    ///    </Columns>
    ///</jquery:GridViewExInsert>
    /// ]]>
    /// </code>
    /// <code>
    /// <![CDATA[
    ///      int _packageId = -1;
    ///      protected void dsPackage_Inserted(object sender, LinqDataSourceStatusEventArgs e)
    ///    {
    ///         if (e.Exception == null)
    ///          {
    ///              btnInsert.Visible = true;
    ///             _packageId = GetPackageId(e.Result);
    ///              Package_status.AddStatusText("Package inserted successfully");
    ///          }
    ///          else
    ///         {
    ///             Package_status.AddErrorText(e.Exception.Message);
    ///              e.ExceptionHandled = true;
    ///          }
    ///     }
    ///    protected void gvPackage_RowDataBound(object sender, GridViewRowEventArgs e)
    ///     {
    ///        switch (e.Row.RowType)
    ///        {
    ///            case DataControlRowType.DataRow:
    ///                if (_packageId != -1)
    ///                 {
    ///                    int id = GetPackageId(e.Row.DataItem);
    ///                     if (id == _packageId)
    ///                     {
    ///                        e.Row.RowState |= DataControlRowState.Selected;
    ///                   }
    ///               }
    ///                break;
    ///           default:
    ///               break;
    ///       }
    ///    }
    ///    private int GetPackageId(object dataItem)
    ///    {
    ///        Package packageresult = (Package)dataItem;
    ///         return packageresult.PackageId;
    ///    } 
    /// ]]>
    /// </code>
    /// <para>
    /// GridViewExInsert provides full support for deleting rows. You have to set ShowDeleteButton="true"
    /// in CommandFieldEx section. You can set DeleteConfirmationText and also DataFields in that section
    /// to show dynamic delete confirmation message.
    /// </para>
    /// <code>
    /// <![CDATA[
    ///   <jquery:GridViewExInsert runat="server" ID="gvFamilyMembers"  DataKeyNames="FamilyMemberId">
    ///     <Columns>
    ///            <jquery:CommandFieldEx ShowDeleteButton="true" DeleteConfirmationText="Family Member {0} will be deleted."
    ///                DataFields="FullName" />
    ///                .........
    ///      </Columns>
    /// </jquery:GridViewExInsert>
    /// ]]>
    /// </code>
    ///  </remarks>
    public partial class GridViewExInsert : GridViewEx
    {
        /// <summary>
        /// Viewstate is required for inserting and editing
        /// </summary>
        public GridViewExInsert()
        {
            this.EnableViewState = true;
        }

        /// <summary>
        /// Whether rows to insert should be displayed at the bottom of the grid
        /// </summary>
        [DefaultValue(false)]
        public bool InsertRowsAtBottom { get; set; }

        /// <summary>
        /// How many insert rows should be visible
        /// </summary>
        /// <remarks>
        /// This is saved in view state so that we can recreated the row after postback
        /// </remarks>
        public int InsertRowsCount
        {
            get
            {
                object obj = ViewState["InsertRowsCount"];
                if (obj == null)
                {
                    return 0;
                }
                else
                {
                    return (int)obj;
                }
            }
            set
            {
                int oldValue = this.InsertRowsCount;
                if (oldValue != value)
                {
                    ViewState["InsertRowsCount"] = value;
                    if (value > 0)
                    {
                        this.EditIndex = -1;        // No editing if you are inserting
                    }
                    OnDataPropertyChanged();
                }
            }
        }

        /// <summary>
        /// If we need to create insert rows, wrap data in an iterator otherwise pass the data trhough
        /// </summary>
        /// <param name="data"></param>
        /// <remarks>
        /// If we are editing, there can be no inserting.
        /// </remarks>
        protected override void PerformDataBinding(IEnumerable data)
        {
            // Forget view state when we are data binding
            this.InsertRowIndexes = null;
            //_nInsertRowsCreated = 0;
            if (this.InsertRowsCount <= 0 || this.EditIndex >= 0)
            {
                base.PerformDataBinding(data);
            }
            else
            {
                // Artificially add insert rows in data source result
                base.PerformDataBinding(GetDataWithInsertRows(data));
            }
        }

        /// <summary>
        /// Provide the number of insert rows needed
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        private IEnumerable GetDataWithInsertRows(IEnumerable data)
        {
            this.InsertRowIndexes = null;
            var insertItems = Enumerable.Repeat<InsertDataItem>(new InsertDataItem(this.DataKeyNames), this.InsertRowsCount);
            if (!this.InsertRowsAtBottom)
            {
                this.InsertRowIndexes = new Pair(0, this.InsertRowsCount - 1);
                foreach (var item in insertItems)
                {
                    yield return item;
                }
            }
            // Now return data rows
            int count = 0;
            if (data != null)
            {
                foreach (var item in data)
                {
                    ++count;
                    yield return item;
                }
            }
            if (this.InsertRowsAtBottom)
            {
                this.InsertRowIndexes = new Pair(count, count + this.InsertRowsCount - 1);
                foreach (var item in insertItems)
                {
                    yield return item;
                }
            }
        }

        /// <summary>
        /// Returns the indexes of the first and last insert rows or null
        /// </summary>
        private Pair InsertRowIndexes
        {
            get
            {
                return (Pair)ViewState["InsertRowIndexes"];
            }
            set
            {
                ViewState["InsertRowIndexes"] = value;
            }
        }
        /// <summary>
        /// Set row state of dummy rows to Insert
        /// </summary>
        /// <param name="row"></param>
        /// <param name="fields"></param>
        protected override void InitializeRow(GridViewRow row, DataControlField[] fields)
        {
            switch (row.RowType)
            {
                case DataControlRowType.DataRow:
                    Pair indexes = this.InsertRowIndexes;
                    if (indexes != null && row.RowIndex >= (int)indexes.First && row.RowIndex <= (int)indexes.Second)
                    {
                        row.RowState |= DataControlRowState.Insert;
                    }
                    break;
            }
            base.InitializeRow(row, fields);
        }

        /// <summary>
        /// Raised just before the row is inserted into the data source
        /// </summary>
        /// <remarks>
        /// <para>
        /// This is an opportunity to modify the values of parameters which will
        /// be sent to the data source.
        /// </para>
        /// </remarks>
        /// <example>
        /// <para>
        /// In this example, the value of the <c>Relationship</c> parameter is set
        /// to the value in the text box if the user has not explicitly specified it
        /// by selecting a value in a drop down list.
        /// </para>
        /// <code>
        /// <![CDATA[
        ///protected void gvFamilyMembers_RowInserting(object sender, GridViewInsertingEventArgs e)
        ///{
        ///    GridViewExInsert gv = (GridViewExInsert)sender;
        ///    GridViewRow row = gv.Rows[e.RowIndex];
        ///    string relationship = (string)e.Values["Relationship"];
        ///    if (string.IsNullOrEmpty(relationship))
        ///    {
        ///        TextBoxEx tbRelationship = (TextBoxEx)row.FindControl("tbRelationship");
        ///        e.Values["Relationship"] = tbRelationship.Text;
        ///    }
        ///}
        /// ]]>
        /// </code>
        /// </example>
        public event EventHandler<GridViewInsertingEventArgs> RowInserting;
        public event EventHandler<GridViewInsertedEventArgs> RowInserted;
        public void InsertRow(int rowIndex)
        {
            IDataSource ds = GetDataSource();
            DataSourceView view = ds.GetView(this.DataMember);
            GridViewRow row = this.Rows[rowIndex];
            OrderedDictionary values = new OrderedDictionary();
            for (int i = 0; i < this.Columns.Count; ++i)
            {
                this.Columns[i].ExtractValuesFromCell(values, (DataControlFieldCell)row.Cells[i], DataControlRowState.Insert, false);
            }
            GridViewInsertingEventArgs insertingArgs = new GridViewInsertingEventArgs(values, rowIndex);
            OnRowInserting(insertingArgs);
            if (insertingArgs.Cancel)
            {
                return;
            }
            view.Insert(values, delegate(int affectedRecords, Exception ex)
            {
                GridViewInsertedEventArgs insertedArgs = new GridViewInsertedEventArgs(affectedRecords, ex, values);
                OnRowInserted(insertedArgs);
                if (!insertedArgs.KeepInInsertMode)
                {
                    this.InsertRowsCount = 0;
                }
                return insertedArgs.ExceptionHandled;
            });
        }

        protected virtual void OnRowInserting(GridViewInsertingEventArgs e)
        {
            if (RowInserting != null)
            {
                RowInserting(this, e);
            }
        }

        protected virtual void OnRowInserted(GridViewInsertedEventArgs e)
        {
            if (RowInserted != null)
            {
                RowInserted(this, e);
            }
        }

        private const string PREFIX_CANCELEVENT = "Cancel$";
        /// <summary>
        /// If edit or insert is being cancelled, we do not show any insert rows
        /// </summary>
        /// <param name="eventArgument"></param>
        protected override void RaisePostBackEvent(string eventArgument)
        {
            if (eventArgument.StartsWith(PREFIX_CANCELEVENT))
            {
                // Remember to ignore the edit index which will be loaded from ControlState
                this.InsertRowsCount = 0;
            }
            base.RaisePostBackEvent(eventArgument);
        }
    }
}
