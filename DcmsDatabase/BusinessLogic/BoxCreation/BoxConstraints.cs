using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using EclipseLibrary.Oracle.Web.UI;
using System.Diagnostics;

namespace DcmsDatabase.BusinessLogic.BoxCreation
{
    /// <summary>
    /// Controls what type of SKUs can be mixed within a single box
    /// </summary>
    ///<remarks>
    ///Enum to define the possible values of SkuPerBox constraint
    ///</remarks>
    enum SkuPerBox
    {
        NoConstraint,
        SingleSku,
        SingleStyleColor
    }


    /// <summary>
    /// This class exposes constraints
    /// which impact box creation for a particular customer.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Instantiate this class by passing a data source and the customer whose constraints
    /// must be honored. To create boxes, call CreateBoxesForPickslipGroup and pass it the pickslip
    /// id. It is an error if the picslip does not belong to the customer passed for constraints.
    /// </para>
    /// <para>
    /// It provides a public function CreateBoxesForPickslipGroup which can be used for 
    /// creating boxes for any pickslip.
    /// This class also provides the public static function DeleteBoxesForPickslipGroup used for 
    /// deleting the unprocessed boxes.
    /// </para>
    /// </remarks>
    public class CustomerConstraints
    {
        #region Public Functions

        ///<summary>
        /// Pass a pickslip to create its boxes.
        /// </summary>
        /// <remarks>
        /// Algorithm:
        ///  1. Retrieve all candidate box cases.
        ///  2. Attempt to create boxes using the largest case first.
        ///  3. Stop as soon as the number of boxes created are more than the previous solution and
        ///  accept the previous solution as the best solution.
        ///  
        /// TODO: 
        /// Handling for SLN (box creation on the basis of defined inner and outer pack   /// <summary>
        /// </remarks>
        public void CreateBoxesForPickslipGroup(int pickslipId)
        {
            PickslipGroup pickslipGroup = new PickslipGroup();
            bool b = PreBoxCreation(pickslipGroup, pickslipId);

            if (!b)
            {
                return;
            }

            // Try each case first, starting with the biggest. Stop when number of cases needed increases.
            foreach (BoxCase boxCase in this.BoxCases.OrderByDescending(p => p.Volume))
            {
                if (!this.CreateBoxesUsingBoxCase(pickslipGroup, boxCase))
                {
                    // If this case is not accepted, we do not try any more
                    break;
                }
            }

            //TODO: For each box, see whether it is possible to use a smaller SKU case
            // If we get here, we must have some boxes
            this.PostBoxCreation(pickslipGroup);
        }
        #endregion

        #region Properties
        /// <summary>
        /// Data Source which will be used for box creation
        /// </summary>
        private readonly OracleDataSource _ds;

        /// <summary>
        /// True if PickslipGroup is obliged to honor the SKU min/max constraints.
        /// Null if constraints have not been retieved yet
        /// </summary>
        private bool? _bMinMaxPiecesRequired;

        /// <summary>
        /// Customer Id for which we have the constraints.
        /// </summary>
        private readonly string _customerId;
        /// <summary>
        /// Constructor of this class BoxConstraint and setting the customer_id and datatsource to its private members.
        /// </summary>
        /// <param name="ds">This datasource will be used for whoel box creation process</param>
        /// <param name="customerId">We will know for which customer these constraints are.</param>
        public CustomerConstraints(OracleDataSource ds, string customerId)
        {
            _ds = ds;
            _customerId = customerId;
        }


        /// <summary>
        /// Datasource property used for database connection throgh out the box creation
        /// </summary>
        public OracleDataSource DataSource
        {
            get
            {
                return _ds;
            }
        }

        /// <summary>
        /// Return the customer Id for which we have the constraints.
        /// </summary>
        public string CustomerId
        {
            get
            {
                return _customerId;
            }
        }

        /// <summary>
        /// Dictates whether a box should contain a single SKU or a single Style-Color.
        /// </summary>
        internal SkuPerBox SkuMixing { get; set; }

        /// <summary>
        /// The box must have at least this weight.
        /// </summary>
        /// <remarks>
        /// TODO: need to be honored.
        /// </remarks>
        internal decimal BoxMinWeight { get; set; }

        /// <summary>
        /// The maximum permissible weight of the box.
        /// </summary>
        /// <remarks>
        /// While adding pieces, we keep in mind that whatever number we add should not cause the box
        /// to exceed this weight.
        /// Now we are checking the number of pieces and adding only required pieces so that weight
        /// will be less than max weight.
        /// </remarks>
        internal decimal BoxMaxWeight { get; set; }

        /// <summary>
        /// Maximum number of SKUs that can be put in a box. 
        /// </summary>
        /// <remarks>
        /// <para>
        /// Maximum SKUs per Box is read from SPLH ($MAXSKUPB).
        /// </para>
        /// We are setting the value when SkuMixing has the value as SingleStyleColor
        /// While adding Sku's to the box we are checking this and create box accordingly.
        /// </remarks>
        internal int MaxSkuPerBox { get; set; }



        /// <summary>
        /// Cases which can be used for this customer
        /// </summary>
        private List<BoxCase> _boxCases;

        /// <summary>
        /// The list of box cases which can be used for this customer.
        /// </summary>
        /// <remarks>
        /// If cust.required_case_id is set, then this list will contain exactly one case.
        /// If Splh $CSEMINVOL and $CSEMAXVOL have been used to specify minimum and maximum case
        /// volumes, the list will contain only the cases which meet the volume criteria.
        /// </remarks>
        internal IEnumerable<BoxCase> BoxCases
        {
            get
            {
                return _boxCases;
            }
        }
        #endregion

        #region Retrieve from Database

        /// <summary>
        /// Called once to retrieve customer constraints. 
        /// </summary>
        /// <param name="ds"></param>
        /// <param name="customer_id"></param>
        /// <returns>Returns true if each SKU must have the min max pieces specified</returns>
        private bool RetrieveFromDataBase(string customer_id)
        {
            _ds.SelectParameters.Clear();
            //TODO: We will include the customer constraints also in future.
            _ds.SelectSql = @"select c.required_case_id as required_case_id,
                                        c.min_pieces_per_box,
                                        c.max_pieces_per_box from <proxy />cust c 
                                  where c.customer_id=:customer_id";
            _ds.SelectParameters.Add("customer_id", DbType.String, customer_id);

            var c = (from object obj in _ds.Select(DataSourceSelectArguments.Empty)
                     select obj).FirstOrDefault();

            string requiredCaseId = DataBinder.Eval(c, "required_case_id", "{0}");

            _ds.SelectSql = @"
                              with const as
                     (select s.splh_id as splh_id,
                             s.splh_value as splh_value
                        from <proxy />splh s
                       WHERE s.splh_id IN ('$SSB', '$PSMINMAX','$BOXMAXWT','$BOXMINWT','$CSEMINVOL','$CSEMAXVOL', '$MAXSKUPB' )
                         ),

                    cust_const as
                     (select c.splh_id, c.splh_value
                        from <proxy />custsplh c
                       where c.customer_id = :customer_id
                         and c.splh_id IN ('$SSB', '$PSMINMAX','$BOXMAXWT','$BOXMINWT','$CSEMINVOL','$CSEMAXVOL','$MAXSKUPB')
                         and c.splh_value is not null)

                    select co.splh_id, nvl(c.splh_value,co.splh_value) splh_value
                      from const co
                      left outer join cust_const c
                        on co.splh_id = c.splh_id
                     where nvl(c.splh_value,co.splh_value) is not null
                                     ";
            bool bMinMaxPiecesRequired = false;
            _ds.SelectParameters.Clear();
            _ds.SelectParameters.Add("customer_id", DbType.String, customer_id);
            //Getting the constraint values and set in respective properties.
            decimal? minVolume = null;
            decimal? maxVolume = null;
            foreach (var row in _ds.Select(DataSourceSelectArguments.Empty))
            {
                object obj;
                switch (DataBinder.Eval(row, "splh_id", "{0}"))
                {
                    //Setting the Single SKU per Box
                    case ("$SSB"):
                        switch (DataBinder.Eval(row, "splh_value", "{0}"))
                        {
                            case "Y":
                            case "SCDZ":
                                this.SkuMixing = SkuPerBox.SingleSku;
                                break;

                            case "SC":
                                this.SkuMixing = SkuPerBox.SingleStyleColor;
                                break;

                            default:
                                this.SkuMixing = SkuPerBox.NoConstraint;
                                break;
                        }
                        break;
                    //Setting the pickslip level min max setting
                    case ("$PSMINMAX"):
                        switch (DataBinder.Eval(row, "splh_value", "{0}"))
                        {
                            case "REQUIRED":
                                // Every SKU must have min/max defined
                                bMinMaxPiecesRequired = true;
                                this.SkuMixing = SkuPerBox.SingleSku;
                                break;
                            case "Y":
                                bMinMaxPiecesRequired = true;
                                break;
                            default:
                                break;
                        }
                        break;
                    //Setting Box Max Weight Constraint if defined.
                    case ("$BOXMAXWT"):
                        obj = DataBinder.Eval(row, "splh_value");
                        if (obj != DBNull.Value)
                        {
                            BoxMaxWeight = Convert.ToDecimal(obj);
                        }
                        break;
                    //setting the Box Min Weight Constraint if defined.
                    case ("$BOXMINWT"):
                        obj = DataBinder.Eval(row, "splh_value");
                        if (obj != DBNull.Value)
                        {
                            BoxMinWeight = Convert.ToDecimal(obj);
                        }
                        break;
                    //Setting the Case Min Volume Constraint is defined
                    case ("$CSEMINVOL"):
                        obj = DataBinder.Eval(row, "splh_value");
                        if (obj != DBNull.Value)
                        {
                            minVolume = Convert.ToDecimal(obj);
                        }
                        break;
                    //Setting the Case Max Volume Constraint if defined
                    case ("$CSEMAXVOL"):
                        obj = DataBinder.Eval(row, "splh_value");
                        if (obj != DBNull.Value)
                        {
                            maxVolume = Convert.ToDecimal(obj);
                        }
                        break;
                    //Setting the Maximum SKUs per Box.
                    case ("$MAXSKUPB"):
                        MaxSkuPerBox = Convert.ToInt32(DataBinder.Eval(row, "splh_value"));
                        break;
                    default:
                        break;
                }
            }
            //Maximum SKUs per Box(Honored only in case when single sku per box is set as single style color)
            if (SkuMixing != SkuPerBox.SingleStyleColor)
            {
                MaxSkuPerBox = 0;
            }

            //Getting the all box cases available
            RetrieveBoxCases(requiredCaseId, minVolume, maxVolume);

            return bMinMaxPiecesRequired;

        }

        /// <summary>
        /// Get cases which can be used for this pickslip group. 
        /// </summary>
        /// <param name="pickslip">requiredCaseId if some case id is set for customer of this pickslip group</param>
        /// <returns></returns>
        private void RetrieveBoxCases(string requiredCaseId, decimal? minVolume, decimal? maxVolume)
        {
            _ds.SelectSql = @"
SELECT scase.case_id AS case_id,
scase.empty_wt as empty_wt,
scase.max_content_volume AS max_content_volume
  FROM <proxy />SKUCASE scase 
 WHERE scase.max_content_volume IS NOT NULL
   AND scase.max_content_volume > 0.0
   AND scase.unavailability_flag is null
<if>AND scase.case_id = :required_case_id</if>
<if>AND scase.max_content_volume &gt;= :caseminvolume</if>
<if>AND scase.max_content_volume &lt;= :casemaxvolume</if>
ORDER BY scase.max_content_volume DESC
";
            _ds.SelectParameters.Clear();
            _ds.SelectParameters.Add("required_case_id", DbType.String, requiredCaseId);
            _ds.SelectParameters.Add("caseminvolume", DbType.Decimal, string.Format("{0}", minVolume));
            _ds.SelectParameters.Add("casemaxvolume", DbType.Decimal, string.Format("{0}", maxVolume));

            _boxCases = (from object row in _ds.Select(DataSourceSelectArguments.Empty)
                         select new BoxCase()
                         {
                             CaseId = DataBinder.Eval(row, "case_id", "{0}"),
                             Volume = Convert.ToDecimal(DataBinder.Eval(row, "max_content_volume")),
                             CaseWeight = Convert.ToDecimal(DataBinder.Eval(row, "empty_wt"))
                         }).ToList();
            //if no case found then we should return from here with proper message
            if (_boxCases.Count == 0)
            {
                //if min max volumes are defined, give proper diagnostic.
                if (minVolume.HasValue && maxVolume.HasValue)
                {
                    throw new InvalidConstraintException(string.Format(
                        "Cases are not found for defined min max case volume constraint between Min Case Volume {0} and Max Case Volume {1}",
                        minVolume, maxVolume));
                }
                throw new InvalidConstraintException("No cases found, please check the atleast one case should be available.");
            }
            return;
        }
        #endregion

        #region Box Creation Helpers
        /// <summary>
        /// Ensures that proper conditions exist for box creation. Returns false if boxes need not be created
        /// </summary>
        /// <returns></returns>
        private bool PreBoxCreation(PickslipGroup pickslipGroup, int pickslipId)
        {
            if (_bMinMaxPiecesRequired == null)
            {
                _bMinMaxPiecesRequired = RetrieveFromDataBase(_customerId);
            }
            //If Box minimum weight is greater than box maximum weight through the error
            if (this.BoxMinWeight > this.BoxMaxWeight)
            {
                Trace.TraceWarning("Box Minimum Weight {0} is more than Box Maximum Weight {1}. Treating min weight as max weight",
                    this.BoxMinWeight, this.BoxMaxWeight);
                this.BoxMaxWeight = this.BoxMinWeight;
                this.BoxMinWeight = 0;
            }
            pickslipGroup.RetrieveFromDb(this, pickslipId, _bMinMaxPiecesRequired.Value);

            // 1. Should have some SKUs to put in boxes.
            // This can happen if boxes have already been created.
            if (pickslipGroup.AllSku.All(p => p.OrderedPieces <= 0))
            {
                return false;
            }

            return true;
        }

        /// <summary>
        /// Apply as many checks as we can think of to ensure that the created boxes meet all
        /// requirements. This amounts to debugging the algorithm. If the test passes, insert boxes in
        /// database.
        /// </summary>
        private void PostBoxCreation(PickslipGroup pickslipGroup)
        {
            // Ensure sanity

            // 1. If we do not have any boxes, it means that some SKU was too big for the box
            if (!pickslipGroup.Boxes.Any())
            {
                throw new InvalidConstraintException("Some SKU too big for all SKU cases");
            }

            // 5. Ensure that ordered SKUs and pieces exactly match SKU and pieces we have put in boxes
            bool b = (from sku in pickslipGroup.Boxes.SelectMany(p => p.AllSku)
                      group sku by sku.UpcCode into grouping
                      orderby grouping.Key
                      select new
                      {
                          UpcCode = grouping.Key,
                          TotalPieces = grouping.Sum(p => p.OrderedPieces)
                      }).SequenceEqual(
                        from sku in pickslipGroup.AllSku
                        where sku.OrderedPieces > 0
                        group sku by sku.UpcCode into grouping
                        orderby grouping.Key
                        select new
                        {
                            UpcCode = grouping.Key,
                            TotalPieces = grouping.Sum(p => p.OrderedPieces)
                        });
            if (!b)
            {
                throw new InvalidConstraintException("Some problem");
            }

            // 3. Find most used and most unused boxes. Exception if there are no boxes
            var bestFillRatio = pickslipGroup.Boxes.Max(p => p.FillRatio);
            if (bestFillRatio > 1)
            {
                throw new InvalidConstraintException("Overfilling a box?");
            }
            var worstFillRatio = pickslipGroup.Boxes.Min(p => p.FillRatio);
            if (worstFillRatio < 0.01m)
            {
                throw new InvalidConstraintException("Very underused box?");
            }

            pickslipGroup.InsertBoxesInDb(this._ds);
        }

        /// <summary>
        /// Creates boxes of pickslip using the passed case. The newly created boxes are accepted
        /// only if the number of boxes created is less than the existing number of boxes.
        /// Returns whether the boxes were accepted.
        /// </summary>
        /// <param name="boxCase"></param>
        /// <returns></returns>
        private bool CreateBoxesUsingBoxCase(PickslipGroup pickslipGroup, BoxCase boxCase)
        {
            // Remember the current solution
            List<Box> curBoxes = pickslipGroup.RelinquishBoxList();
            // Create a new solution
            pickslipGroup.CreateBoxes(this, boxCase);
            if (curBoxes != null && pickslipGroup.Boxes.Count > curBoxes.Count)
            {
                // This solution is worse. Accept the previous solution as the final solution
                pickslipGroup.SetBoxList(curBoxes);
                return false;
            }
            else
            {
                // The solution was accepted
                return true;
            }
        }

        #endregion

        #region Box deletion
        /// <summary>
        /// The passed data source should not have an already existing transaction because
        /// we create our own transaction.
        /// </summary>
        /// <param name="pickslipId"></param>
        /// <param name="ds"></param>
        public static void DeleteBoxesForPickslipGroup(int pickslipId, OracleDataSource ds)
        {
            const string QUERY_BOX = @"
delete from <proxy />box b where b.ia_id is null and b.pickslip_id = :pickslip_id
                ";
            const string QUERY_BOXDET = @"
delete from <proxy />boxdet bd 
where bd.ucc128_id in(
    select b.ucc128_id from <proxy />box b where b.ia_id is null and b.pickslip_id = :pickslip_id
)
                ";

            ds.DeleteParameters.Clear();
            ds.DeleteParameters.Add("pickslip_id", DbType.Int32, pickslipId.ToString());
            ds.SysContext.ModuleName = "BoxCreator.DeleteBoxes";
            try
            {
                ds.BeginTransaction();
                ds.DeleteSql = QUERY_BOXDET;

                int i = ds.Delete();

                ds.DeleteSql = QUERY_BOX;
                i = ds.Delete();
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