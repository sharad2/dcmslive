using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using EclipseLibrary.Oracle.Web.UI;
using System.Diagnostics;

namespace DcmsDatabase.BusinessLogic.BoxCreation
{
    internal class Box
    {
        private readonly BoxCase _boxCase;
        public Box(BoxCase boxCase)
        {
            _boxCase = boxCase;
        }

        #region properties
        /// <summary>
        /// The Private property to Store the UCC128_id.
        /// </summary>
        private string UccCode { get; set; }

        /// <summary>
        /// Property to store the case of this box.
        /// </summary>
        internal BoxCase Case
        {
            get
            {
                return _boxCase;
            }
        }

        /// <summary>
        /// Private List of SKUs which will have the list of SKUs in this box.
        /// </summary>
        private List<Sku> _skuList = new List<Sku>();

        /// <summary>
        /// Public property to give the all skus in that box along with Sku information
        /// </summary>
        public IEnumerable<Sku> AllSku
        {
            get
            {
                return _skuList;
            }
        }

        /// <summary>
        /// Public Property that returns the Fill Ratio of the Box according to its volume and volume of the pieces in box.
        /// If there are no SKUs return 0.
        /// </summary>
        public decimal FillRatio
        {
            get
            {
                if (_skuList.Count == 0)
                {
                    return 0;
                }
                else
                {
                    return this.VolumeUsed / this.Case.Volume;
                }
            }
        }

        /// <summary>
        /// Return total pieces in the box
        /// If box is empty return 0
        /// </summary>
        public int TotalPieces
        {
            get
            {
                if (this._skuList.Count == 0)
                {
                    return 0;
                }
                else
                {
                    return this._skuList.Sum(p => p.OrderedPieces);
                }
            }
        }

        /// <summary>
        /// Return Total weight of the box
        /// </summary>
        public decimal TotalWeight
        {
            get
            {
                return this.Case.CaseWeight + Convert.ToDecimal(this._skuList.Sum(p => p.Weight * p.OrderedPieces));
            }
        }

        /// <summary>
        /// Return the Box information by overriding the ToString function
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return string.Format("Case {0}; {1} SKUs; {2} Pieces; {3}/{4} ({5:p1}) volume",
                this.Case, this._skuList.Count,
                this.TotalPieces, this.VolumeUsed, this.Case.Volume, this.FillRatio
                );
        }

        /// <summary>
        /// Return Volume used of the case.
        /// If there is not any SKU in the box, return 0.
        /// </summary>
        public decimal VolumeUsed
        {
            get
            {
                if (this._skuList.Count == 0)
                {
                    return 0;
                }
                else
                {
                    return _skuList.Sum(p => p.Volume * p.OrderedPieces);
                }
            }
        }
        #endregion

        #region public functions
        /// <summary>
        /// Tries to accept as many pieces as will fit. Returns how many pieces were used.
        /// We are using this used pieces and check whether pieces left and assumung box 
        /// is full and create the box.
        /// </summary>
        /// <param name="sku"></param>
        /// <remarks>
        /// If an SKU is too big to fit, it will be accepted in an empty box.
        /// </remarks>
        public int AcceptSku(Sku sku, int maxPieces, int minPieces, decimal maxWeight)
        {
#if DEBUG
            if (sku.AvailablePieces == 0)
            {
                throw new ArgumentException("Internal Error: No available pieces", "sku");
            }
#endif
            decimal availableVolume = Case.Volume - _skuList.Sum(p => p.Volume * p.OrderedPieces);

            // Max pieces we can accept
            int nPieces = (int)Math.Floor(availableVolume / sku.Volume);

            if (nPieces == 0 && this.TotalPieces == 0)
            {
                // We are empty and yet unable to accept any piece. This means SKU is too big for us.
                // We should accept 1 piece of this SKU.
                nPieces = 1;
            }
            else
            {
                // Cannot accept more than are available
                nPieces = Math.Min(nPieces, sku.AvailablePieces);

                // Cannot accept more than sku max pieces
                if (sku.MaxPiecesPerBox > 0)
                {
                    nPieces = Math.Min(nPieces, sku.MaxPiecesPerBox);
                }
                //Cannot accept more than max pieces per box defined for pickslip
                if (maxPieces > 0)
                {
                    if (maxPieces < this.TotalPieces)
                    {
                        throw new InvalidOperationException("Internal error. Our algorithm should not allow maxPieces to get violated");
                    }
                    nPieces = Math.Min(nPieces, maxPieces - this.TotalPieces);
                }

                //cannot accept more pieces to honor the box max weight
                if (maxWeight > 0)
                {
                    //Checking How many pieces can be put in this box without exceeding the max weight limit.
                    int maxPiecesByWeight = (int)Math.Floor((maxWeight - TotalWeight) / sku.Weight);
                    nPieces = Math.Min(nPieces, maxPiecesByWeight);
                }

                // If we do not have at least sku min pieces, don't take any

                if (sku.MinPiecesPerBox > 0 && nPieces < sku.MinPiecesPerBox)
                {
                    //Now if min pieces per box is too large we will not be able to put any pieces in box because there may be two scenerios
                    //1. If ordered pieces are less than the min pieces defined
                    //2. If ordered pieces are not in the ratio of min max pieces defined.
                    //In this case we will put all the pieces which can be put in a box so that we can create the boxes.
                    //Here our goal is not stopping the user to create boxes.
                    //TODO: We need to inform user about the constraint is not properly handled.
                    Trace.TraceWarning("Min Max pieces constraint could not be honored");

                }
                if (minPieces > 0 && nPieces < minPieces)
                {
                    Trace.TraceWarning("Min Max pieces constraint could not be honored");
                }

            }
            if (nPieces > 0)
            {
                Sku newSku = new Sku(sku, nPieces);
                _skuList.Add(newSku);
            }

            return nPieces;
        }

        #endregion

        #region Database Functions
        /// <summary>
        /// Insert entries in box (one per pickslip) and boxdet
        /// </summary>
        /// <param name="ds"></param>
        /// <param name="vwhId"></param>
        /// <param name="seq"></param>
        /// <param name="pickslipPrefix"></param>
        public void InsertInDb(OracleDataSource ds, string vwhId, int seq, string pickslipPrefix)
        {
            //TODO: MIN_PIECES_PER_BOX_5

            const string QUERY_BOX = @"
INSERT INTO <proxy />box
  (pickslip_id,
   ucc128_id,
   case_id,
   sequence_in_ps,
   min_pieces_per_box,
   vwh_id)
VALUES
  (:PICKSLIP_ID,
   NVL(:ucc128_id, <proxy />GET_UCC128_ID),
   :CASE_ID,
   :sequence_in_ps,
   NULL,
   :vwh_id)
RETURNING ucc128_id INTO :ucc128_id
";
            const string QUERY_BOXDET = @"
INSERT INTO <proxy />BOXDET boxdet
  (boxdet.ucc128_id,
   boxdet.pickslip_id,
   boxdet.upc_code,
   boxdet.barcode,
   boxdet.expected_pieces)
VALUES
  (:ucc128_id, :PICKSLIP_ID, :upc_code, :barcode, :expected_pieces)

";
            ds.InsertParameters.Clear();
            ds.InsertParameters.Add("CASE_ID", DbType.String, this.Case.CaseId);
            ds.InsertParameters.Add("sequence_in_ps", DbType.Int32, seq.ToString());
            ds.InsertParameters.Add("vwh_id", DbType.String, vwhId);
            ds.InsertParameters.Add("pickslip_prefix", DbType.String, pickslipPrefix);
            ds.InsertParameters.Add("ucc128_id", DbType.String, string.Empty);

            // Value updated in loop
            ds.InsertParameters.Add("PICKSLIP_ID", DbType.Int32, string.Empty);

            // Additional BoxDet parameters
            ds.InsertParameters.Add("upc_code", DbType.String, string.Empty);
            ds.InsertParameters.Add("barcode", DbType.String, string.Empty);
            ds.InsertParameters.Add("expected_pieces", DbType.Int32, string.Empty);

            var pickslipGroup = from sku in this.AllSku
                                group sku by sku.PickslipId into g
                                select g;
            foreach (var pickslip in pickslipGroup)
            {
                ds.InsertSql = QUERY_BOX;
                ds.InsertParameters["PICKSLIP_ID"].DefaultValue = pickslip.Key.ToString();
                ds.InsertParameters["ucc128_id"].Direction = ParameterDirection.InputOutput;
                ds.InsertParameters["ucc128_id"].Size = 255;
                int i = ds.Insert();
                if (i != 1)
                {
                    throw new InvalidOperationException("Row not inserted");
                }
                ds.InsertParameters["ucc128_id"].DefaultValue = ds.OutValues["ucc128_id"].ToString();
                ds.InsertSql = QUERY_BOXDET;
                ds.InsertParameters["ucc128_id"].Direction = ParameterDirection.Input;
                foreach (var sku in pickslip)
                {
                    ds.InsertParameters["upc_code"].DefaultValue = sku.UpcCode;
                    ds.InsertParameters["barcode"].DefaultValue = sku.PickslipBarCode;
                    ds.InsertParameters["expected_pieces"].DefaultValue = sku.OrderedPieces.ToString();
                    i = ds.Insert();
                    if (i != 1)
                    {
                        throw new InvalidOperationException("Row not inserted");
                    }
                }
            }
            return;
        }

        #endregion

    }
}
