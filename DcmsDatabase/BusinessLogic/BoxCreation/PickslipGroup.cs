using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Oracle.Web.UI;
using System.Diagnostics;

namespace DcmsDatabase.BusinessLogic.BoxCreation
{
    internal class PickslipGroup
    {

        #region private properties
        /// <summary>
        /// Below both constraints value will be set per pickslip when pickslip contain single label
        /// Otherwise we will not honor these two constraints and not set the value.
        /// </summary>
        /// <remarks>
        /// We only setting the values of these constraints when SKU level min max pieces are not defined.
        /// We are checking these while accepting any SKU for the box and accept SKUs according to these values.
        /// </remarks>
        private int _minPiecesPerBox;
        private int _maxPiecesPerBox;

        /// <summary>
        /// This private property is being used while creating boxes and we are setting the vwh_id in box table.
        /// </summary>
        private string VwhId { get; set; }


        /// <summary>
        /// This private property is being used while creating the boxes and we are getting the UCC128_ID on the 
        /// basis of this pickslip_prefix.
        /// </summary>
        private string PickslipPrefix { get; set; }


        /// <summary>
        /// The max sequence which has been used for existing boxes if any
        /// </summary>
        private int SequenceInPs { get; set; }


        /// <summary>
        /// This List contain the SKUs of this pickslip group along with all SKU properties.
        /// </summary>
        private HashSet<Sku> _skuList;

        /// <summary>
        /// This List contain the Boxes of this pickslip group along with all Box properties.
        /// </summary>
        private List<Box> _boxes;

        #endregion

        #region public properties

        /// <summary>
        /// This public property will return all Skus of the pickslip along with all sku information.
        /// </summary>
        public IEnumerable<Sku> AllSku
        {
            get
            {
                return _skuList;
            }
        }

        /// <summary>
        /// This public property will return the boxes of the pickslip group, if there are no boxes it will 
        /// return the empty box list.
        /// </summary>
        public ICollection<Box> Boxes
        {
            get
            {
                if (_boxes == null)
                {
                    _boxes = new List<Box>();
                }
                return _boxes;
            }
        }

        /// <summary>
        /// This public Property will return total ordered pieces of this pickslip group for all SKUs.
        /// </summary>
        public int TotalOrderedPieces
        {
            get
            {
                if (_skuList.Count == 0)
                {
                    return 0;
                }
                else
                {
                    return _skuList.Sum(p => p.OrderedPieces);
                }
            }
        }

        /// <summary>
        /// Calculate the total labels available in pickslip to honor the constraints defined in custlblsplh table.
        /// This will return the number of distinct Labels present in this pickslip.
        /// </summary>
        public int TotalLabels
        {
            get
            {
                if (_skuList.Count == 0)
                {
                    return 0;
                }
                else
                {
                    var q1 = (from ps in this._skuList
                              select ps.SkuLabel).Distinct();
                    return q1.Count();
                }
            }
        }
        #endregion

        #region public functions

        /// <summary>
        /// Returns and forgets all created boxes. Also resets all consumed pieces.
        /// Never returns an empty list. Instead returns null.
        /// </summary>
        /// <returns></returns>
        public List<Box> RelinquishBoxList()
        {
            var temp = _boxes;
            _boxes = null;
            foreach (Sku sku in _skuList)
            {
                sku.ConsumedPieces = 0;
            }
            if (temp == null || temp.Count == 0)
            {
                return null;
            }
            else
            {
                return temp;
            }
        }

        /// <summary>
        /// This function takes the list of boxes and set as list of boxes for this pickslip. 
        /// </summary>
        /// <param name="boxes"></param>
        public void SetBoxList(List<Box> boxes)
        {
            _boxes = boxes;
        }


        /// <summary>
        /// Creates boxes for the pickslip group using the passed case.
        /// </summary>
        /// <param name="boxCase"></param>
        /// <returns></returns>
        /// <remarks>
        /// <para>
        /// If an SKU is too big for the case, we will put it in an empty case and log a warning.
        /// </para>
        /// </remarks>
        public void CreateBoxes(CustomerConstraints constraints, BoxCase boxCase)
        {
            //Variable created for storing the previous style and color
            //string previousStyle = string.Empty;
            //string previousColor = string.Empty;
            Sku prevSku = null;
            Box currentBox = new Box(boxCase);
            var query = from sku in this.AllSku
                        orderby sku.Style, sku.Color, sku.Identifier, sku.Dimension, sku.SkuSize
                        select sku;

            foreach (Sku sku in query)
            {
                // Decide whether we want to possibly add this SKU to the same box
                bool bCanAddtoSameBox;
                if (prevSku == null)
                {
                    bCanAddtoSameBox = true;
                }
                else
                {
                    switch (constraints.SkuMixing)
                    {
                        case SkuPerBox.NoConstraint:
                            bCanAddtoSameBox = true;
                            break;

                        case SkuPerBox.SingleSku:
                            bCanAddtoSameBox = sku.UpcCode == prevSku.UpcCode;
                            break;

                        case SkuPerBox.SingleStyleColor:
                            bCanAddtoSameBox = sku.Style == prevSku.Style && sku.Color == prevSku.Color;
                            break;

                        default:
                            throw new NotImplementedException();

                    }
                }

                //If MaximumSKUPerBox is 0 or not defined ignore this.
                if (bCanAddtoSameBox && constraints.MaxSkuPerBox > 0)
                {
                    //Only add this SKU when total SKUs in box is less than max SKUs per box.
                    bCanAddtoSameBox = currentBox.AllSku.Count() < constraints.MaxSkuPerBox;
                }

                //In Case label wise Maximum Pieces per box is defined honor this.
                if (bCanAddtoSameBox && this._maxPiecesPerBox > 1)
                {
                    bCanAddtoSameBox = currentBox.TotalPieces < this._maxPiecesPerBox;
                }

                if (!bCanAddtoSameBox)
                {
                    //add the box in boxlist only box contain some pieces other wise discard the previous created box.
                    if (currentBox.TotalPieces > 0)
                    {
                        this.Boxes.Add(currentBox);
                    }
                    else
                    {
                        throw new NotImplementedException("Will this happen?");
                    }
                    currentBox = new Box(boxCase);
                }

                prevSku = sku;

                // Use all pieces of this SKU
                while (sku.AvailablePieces > 0)
                {
                    int usedPieces = currentBox.AcceptSku(sku, this._maxPiecesPerBox, this._minPiecesPerBox, constraints.BoxMaxWeight);
                    if (usedPieces < sku.AvailablePieces)
                    {
                        #region Debug
#if DEBUG
                        // This box could not accept all. So this box is complete.
                        if (usedPieces == 0 && currentBox.TotalPieces == 0)
                        {
                            // The box was empty and yet it did not accept any piece.
                            // This is not supposed to happen and will cause infinite loop.
                            throw new InvalidOperationException();
                        }
#endif
                        #endregion
                        this.Boxes.Add(currentBox);
                        currentBox = new Box(boxCase);
                    }
                    sku.ConsumedPieces += usedPieces;
                }
            }

            if (currentBox.TotalPieces == 0)
            {
                throw new InvalidOperationException("Will this happen ?");
            }
            this.Boxes.Add(currentBox);
            return;
        }

        #endregion

        #region Database functions
        /// <summary>
        /// Retrieves pickslip and constraint info from database
        /// </summary>
        /// <param name="ds"></param>
        /// <param name="pickslipId"></param>
        public void RetrieveFromDb(CustomerConstraints constraints, int pickslipId, bool bMinMaxPiecesRequired)
        {
            RetrieveSkuList(constraints, pickslipId, bMinMaxPiecesRequired);
            // This query must ensure that at least one row is returned so that we can get pickslip info
            constraints.DataSource.SelectSql = @"
SELECT ps.pickslip_id,
       MAX(box.sequence_in_ps) AS sequence_in_ps,
       boxdet.upc_code AS upc_code,
       SUM(boxdet.expected_pieces) AS EXPECTED_PIECES,
       max(ps.vwh_id) as vwh_id,
       max(ps.pickslip_prefix) as pickslip_prefix,
       max(ps.customer_id) as customer_id
  FROM <proxy />PS PS
  left outer join <proxy />BOX box
    on ps.pickslip_id = box.pickslip_id
  left outer join <proxy />BOXDET boxdet
    on box.ucc128_id = boxdet.ucc128_id
   and box.pickslip_id = boxdet.pickslip_id
 WHERE ps.pickslip_id = :pickslip_id
 GROUP BY ps.pickslip_id, boxdet.upc_code
    
";
            constraints.DataSource.SysContext.ModuleName = "BoxCreation";
            constraints.DataSource.SelectParameters.Clear();
            constraints.DataSource.SelectParameters.Add("pickslip_id", DbType.Int32, pickslipId.ToString());
            foreach (var row in constraints.DataSource.Select(DataSourceSelectArguments.Empty))
            {
                string upcCode = DataBinder.Eval(row, "upc_code", "{0}");
                if (!string.IsNullOrEmpty(upcCode))
                {
                    // If some boxes have already been created, reduce pieces of SKU for which boxes will be created
                    Sku sku = _skuList.Single(p => p.UpcCode == upcCode);
                    object obj = DataBinder.Eval(row, "EXPECTED_PIECES");
                    if (obj != DBNull.Value)
                    {
                        sku.DecrementOrderedPieces(Convert.ToInt32(obj));
                    }
                }
                //this.RequiredCaseId = DataBinder.Eval(row, "required_case_id", "{0}");
                this.VwhId = DataBinder.Eval(row, "vwh_id", "{0}");
                object seq = DataBinder.Eval(row, "sequence_in_ps");
                if (seq == DBNull.Value)
                {
                    seq = 0;
                }
                this.SequenceInPs = Convert.ToInt32(seq);

                this.PickslipPrefix = DataBinder.Eval(row, "pickslip_prefix", "{0}");
                string customerId = DataBinder.Eval(row, "customer_id", "{0}");
                if (customerId != constraints.CustomerId)
                {
                    throw new InvalidConstraintException("Not my constraints");
                }
            }

            RetrieveLabelConstraints(constraints);

            //Checking if max pieces defined per box should not be less than min pieces defined per box
            if (this._maxPiecesPerBox < this._minPiecesPerBox)
            {
                Trace.TraceWarning("Max pieces per Box {0} defined are less than min pieces per box {1}. Treating min pieces as max pieces.",
                    this._maxPiecesPerBox, this._minPiecesPerBox);
                this._maxPiecesPerBox = this._minPiecesPerBox;
                this._minPiecesPerBox = 0;
            }
        }

        private void RetrieveSkuList(CustomerConstraints constraints, int pickslipId, bool bMinMaxPiecesRequired)
        {
            constraints.DataSource.SelectSql = @"
SELECT psdet.pickslip_id AS pickslip_id,
       psdet.upc_code    AS upc_code,
       case
         when MAX(psdet.private_label_flag) = 'Y' then
          MAX(psdet.barcode)
         else
          psdet.upc_code
       end AS PICKSLIP_BARCODE,
       SUM(psdet.pieces_ordered) AS pieces_ordered,
       MAX(psdet.pieces_per_package),
       MIN(psdet.pieces_per_package),
       MAX(psdet.min_pieces_per_box) AS min_pieces_per_box,
       MAX(psdet.max_pieces_per_box) AS max_pieces_per_box,
       MAX(msku.style) AS SKU_STYLE,
       MAX(msku.color) AS SKU_COLOR,
       MAX(msku.dimension) AS SKU_DIMENSION,
       MAX(msku.sku_size) AS SKU_SIZE,
       round(MAX((msku.volume_per_dozen / 12)),4) AS SKU_VOLUME,
       round(MAX((msku.weight_per_dozen / 12)),4) AS SKU_WEIGHT,
       MAX(mstyle.label_id) as label_id
  FROM <proxy />PSDET psdet, <proxy />MASTER_SKU msku, <proxy />MASTER_STYLE mstyle
 WHERE msku.upc_code = psdet.upc_code
   AND mstyle.style = msku.style
   AND psdet.pickslip_id = :pickslip_id
   AND msku.inactive_flag IS NULL
 GROUP BY psdet.PICKSLIP_ID, psdet.upc_code
 ORDER BY SKU_STYLE, SKU_COLOR, SKU_DIMENSION, SKU_SIZE
";
            constraints.DataSource.SelectParameters.Clear();
            constraints.DataSource.SelectParameters.Add("pickslip_id", DbType.Int32, pickslipId.ToString());

            _skuList = new HashSet<Sku>();
            foreach (var row in constraints.DataSource.Select(DataSourceSelectArguments.Empty))
            {
                Sku sku = new Sku(Convert.ToInt32(DataBinder.Eval(row, "pickslip_id")),
                    DataBinder.Eval(row, "upc_code", "{0}"), Convert.ToInt32(DataBinder.Eval(row, "pieces_ordered")))
                {
                    Style = DataBinder.Eval(row, "SKU_STYLE", "{0}"),
                    Color = DataBinder.Eval(row, "SKU_COLOR", "{0}"),
                    Dimension = DataBinder.Eval(row, "SKU_DIMENSION", "{0}"),
                    Identifier = ".",
                    SkuSize = DataBinder.Eval(row, "SKU_SIZE", "{0}"),
                    PickslipBarCode = DataBinder.Eval(row, "PICKSLIP_BARCODE", "{0}"),
                    SkuLabel = DataBinder.Eval(row, "label_id", "{0}"),
                };
                object obj = DataBinder.Eval(row, "SKU_VOLUME");
                if (obj == DBNull.Value)
                {
                    string msg = string.Format("Pickslip {0}: SKU {1} does not have volume defined",
                        sku.PickslipId,
                        sku.UpcCode);
                    throw new InvalidOperationException(msg);
                }
                sku.Volume = Convert.ToDecimal(obj);

                //Calculate the weight of each SKU
                obj = DataBinder.Eval(row, "SKU_WEIGHT");
                if (obj != DBNull.Value)
                {
                    sku.Weight = Convert.ToDecimal(obj);
                }
                else
                {
                    // Let sku weight remain 0. This SKU will not participate in weight constraints.
                }
                // if HonorPickslipMinMaxPieces is set as required assume SkuPerBox.SingleSku is on
                if (bMinMaxPiecesRequired)
                {
                    obj = DataBinder.Eval(row, "min_pieces_per_box");
                    if (obj == DBNull.Value)
                    {
                        string str = string.Format("SKU {0} does not have min pieces defined", sku);
                        throw new InvalidConstraintException(str);
                    }
                    else
                    {
                        sku.MinPiecesPerBox = Convert.ToInt32(obj);
                    }
                    obj = DataBinder.Eval(row, "max_pieces_per_box");
                    if (obj == DBNull.Value)
                    {
                        string str = string.Format("SKU {0} does not have max pieces defined", sku);
                        throw new InvalidConstraintException(str);
                    }
                    else
                    {
                        sku.MaxPiecesPerBox = Convert.ToInt32(obj);
                    }
                }
                if (!_skuList.Add(sku))
                {
                    throw new InvalidOperationException("Query was supposed to ensure that the same sku will not be added twice");
                }
            }
        }


        /// <summary>
        /// This will set the picking_status of the pickslip group to PENDING
        /// </summary>
        /// <param name="ds"></param>
        /// <param name="pickslipId">Set the status for passed pickslip id</param>
        private void SetPickslipStatus(OracleDataSource ds, int pickslipId)
        {
            ds.UpdateSql = @"update <proxy />ps set picking_status = 'PENDING' where pickslip_id = :pickslip_id";
            ds.UpdateParameters.Clear();
            ds.UpdateParameters.Add("pickslip_id", DbType.Int32, pickslipId.ToString());
            try
            {
                ds.Update();
            }
            catch (Exception)
            {
                throw;
            }

        }
        /// <summary>
        /// Thsi function will retrieve Label Constraints if pickslip conatin single labele.
        /// </summary>
        /// <param name="constraints"></param>
        private void RetrieveLabelConstraints(CustomerConstraints constraints)
        {
            if (this.TotalLabels == 1)
            {  //We are only handling two constraints so only selecting both of them.
                constraints.DataSource.SelectSql = @"select splh_id as splh_id, splh_value as splh_value from <proxy />custlblsplh 
                                    where customer_id = :customer_id
                                    and label_id = :label_id
                                    and splh_id in('$MINPPB','$MAXPPB')
                                    and splh_value is not null";
                constraints.DataSource.SelectParameters.Clear();
                constraints.DataSource.SelectParameters.Add("customer_id", DbType.String, constraints.CustomerId);
                constraints.DataSource.SelectParameters.Add("label_id", DbType.String, this.AllSku.Max(p => p.SkuLabel));
                foreach (var row in constraints.DataSource.Select(DataSourceSelectArguments.Empty))
                {
                    switch (DataBinder.Eval(row, "splh_id", "{0}"))
                    {
                        case "$MINPPB":
                            this._minPiecesPerBox = Convert.ToInt32(DataBinder.Eval(row, "splh_value"));
                            break;
                        case "$MAXPPB":
                            this._maxPiecesPerBox = Convert.ToInt32(DataBinder.Eval(row, "splh_value"));
                            break;
                        default:
                            throw new NotImplementedException();
                    }
                }

            }
        }

        /// <summary>
        /// This function will insert the created boxes of this pickslip group in database by using the box object.
        /// It is managing the transaction so that all boxes of a pickslip will be created or none.
        /// </summary>
        /// <param name="ds"></param>
        internal void InsertBoxesInDb(OracleDataSource ds)
        {

            int seq = this.SequenceInPs;
            //selecting the distinct pickslips to set the picking status
            var q1 = (from ps in this._skuList
                      select ps.PickslipId).Distinct();

            ds.BeginTransaction();
            try
            {
                foreach (Box box in this.Boxes)
                {
                    ++seq;
                    box.InsertInDb(ds, this.VwhId, seq, this.PickslipPrefix);
                }
                //Setting the picking status for the pickslips for which we have created the box
                foreach (var ps in q1)
                {
                    this.SetPickslipStatus(ds, Convert.ToInt32(ps));
                }

                ds.CommitTransaction();
            }
            catch (Exception)
            {
                ds.RollBackTransaction();
                throw;
            }
        }
        #endregion
    }
}
