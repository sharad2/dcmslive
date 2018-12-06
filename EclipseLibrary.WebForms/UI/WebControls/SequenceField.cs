using System;
using System.ComponentModel;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EclipseLibrary.Web.UI
{


    /// <summary>
    /// Displays a sequence number taking into account the page number. The first row is numbered StartSequence.
    /// In paging scenario, first row referes to the first row of the first page and not the first row of the visible page.
    /// </summary>
    [ParseChildren(true)]
    [PersistChildren(false)]
    public class SequenceField : DataControlField
    {
        //private int _curSequence;
        public SequenceField()
        {
            this.HeaderText = "#";
            this.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
            this.FooterText = "Total";
            this.FooterStyle.Font.Bold = true;
            this.UsePageIndex = true;
        }

        [DefaultValue("Totals")]
        public override string FooterText
        {
            get
            {
                return base.FooterText;
            }
            set
            {
                base.FooterText = value;
            }
        }

        /// <summary>
        /// Whether page index should be used in calculating row sequence. MasterRow sets this to false so that
        /// we see sequences within master
        /// </summary>
        [Browsable(true)]
        [DefaultValue(true)]
        public bool UsePageIndex { get; set; }

        protected override DataControlField CreateField()
        {
            SequenceField s = new SequenceField();
            return s;
        }

        public override bool Initialize(bool sortingEnabled, Control control)
        {
            GridView gv = (GridView)control;
            //_curSequence = 1 + gv.PageIndex * gv.PageSize;
            return base.Initialize(sortingEnabled, control);
        }

        public override void InitializeCell(DataControlFieldCell cell, DataControlCellType cellType, DataControlRowState rowState, int rowIndex)
        {
            switch (cellType)
            {
                case DataControlCellType.Header:
                  
                    cell.Text = this.HeaderText;
                    break;

                case DataControlCellType.DataCell:
                    cell.PreRender += new EventHandler(cell_PreRender);
                    break;
            }
            base.InitializeCell(cell, cellType, rowState, rowIndex);
        }


        void cell_PreRender(object sender, EventArgs e)
        {
            DataControlFieldCell cell = (DataControlFieldCell)sender;
            GridViewRow row = (GridViewRow)cell.NamingContainer;
            int seq = row.RowIndex + 1;
            if (this.UsePageIndex)
            {
                GridView gv = (GridView)row.NamingContainer;
                seq += gv.PageIndex * gv.PageSize;
            }
            cell.Text = string.Format("{0:N0}",  seq);
        }

        /// <summary>
        /// Do nothing to indicate that we support callbacks
        /// </summary>
        public override void ValidateSupportsCallback()
        {
            //base.ValidateSupportsCallback();
        }
    }
}
