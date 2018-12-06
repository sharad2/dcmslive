using System;

namespace DcmsDatabase.BusinessLogic.BoxCreation
{
    internal class Sku : IEquatable<Sku>
    {
        #region Properties
        /// <summary>
        /// Store the ordered pieces of this SKU
        /// </summary>
        private int _orderedPieces;

        /// <summary>
        /// UPC COde of the SKU
        /// </summary>
        private readonly string _upcCode;

        /// <summary>
        /// The SKUs for this pickslip 
        /// </summary>
        private readonly int _pickslipId;

        /// <summary>
        /// Property that returns the pickslipId 
        /// </summary>
        public int PickslipId
        {
            get
            {
                return _pickslipId;
            }
        }

        /// <summary>
        /// Property that returns the UpcCode of the SKU
        /// </summary>
        public string UpcCode
        {
            get
            {
                return _upcCode;
            }

        }

        /// <summary>
        /// Style of the SKU
        /// </summary>
        public string Style { get; set; }

        /// <summary>
        /// Color of the SKU
        /// </summary>
        public string Color { get; set; }

        /// <summary>
        /// Identifier of the SKU
        /// </summary>
        public string Identifier { get; set; }

        /// <summary>
        /// Dimension of the SKU
        /// </summary>
        public string Dimension { get; set; }

        /// <summary>
        /// SkuSize of the SKU
        /// </summary>
        public string SkuSize { get; set; }

        /// <summary>
        /// MaxPiecesPerBox this value will be stored when Pickslip Level Min max pieces will be stored per SKU
        /// </summary>
        /// <remarks>
        /// If there is multiple SKUs are allowed than it will check the max pieces per SKU in each box. It can be possible 
        /// when SKUMixing constraint has the value as SingleStyleColor.
        /// </remarks>
        public int MaxPiecesPerBox { get; set; }
        public int MinPiecesPerBox { get; set; }

        /// <summary>
        /// Store the Label of the SKU
        /// </summary>
        public string SkuLabel { get; set; }

        /// <summary>
        /// Volume of the SKU
        /// </summary>
        public decimal Volume { get; set; }

        /// <summary>
        /// Weight of the SKU
        /// </summary>
        public decimal Weight { get; set; }

        /// <summary>
        /// Total ordered pieces of the SKU
        /// </summary>
        public int OrderedPieces
        {
            get
            {
                return _orderedPieces;
            }
        }

        /// <summary>
        /// As boxes keep getting created, Consumed pieces keep increasing.
        /// </summary>
        public int ConsumedPieces { get; set; }


        /// <summary>
        /// How many pieces are still left to put in the box. These will be Ordered Pieces - Consumed Pieces
        /// </summary>
        public int AvailablePieces
        {
            get
            {
                return this.OrderedPieces - this.ConsumedPieces;
            }
        }

        /// <summary>
        /// Barcode of the SKU, Its coming correctly on the basis of Private label flag.
        /// </summary>
        public string PickslipBarCode { get; set; }

#endregion

        #region Constructor
        /// <summary>
        /// Set the passed ordered pieces, upc_code and pickslip_id in private properties.
        /// </summary>
        /// <param name="pickslipId"></param>
        /// <param name="upcCode"></param>
        /// <param name="orderedPieces"></param>
        public Sku(int pickslipId, string upcCode, int orderedPieces)
        {
            _orderedPieces = orderedPieces;
            _upcCode = upcCode;
            _pickslipId = pickslipId;
        }

        /// <summary>
        /// Copy constructor. Copies everything except ConsumedPieces
        /// </summary>
        /// <param name="other"></param>
        public Sku(Sku other)
        {
            CopyProperties(other);
            this._upcCode = other._upcCode;
            this._orderedPieces = other._orderedPieces;
            this._pickslipId = other._pickslipId;
        }
        /// <summary>
        /// Copy the SKU along with ordered pieces
        /// </summary>
        /// <param name="other"></param>
        /// <param name="orderedPieces"></param>
        public Sku(Sku other, int orderedPieces)
        {
            CopyProperties(other);
            this._upcCode = other._upcCode;
            this._orderedPieces = orderedPieces;
            this._pickslipId = other._pickslipId;
        }
        #endregion

        #region Functions
        /// <summary>
        /// Fucntion to copy SKU properties from pass to this
        /// </summary>
        /// <param name="other"></param>
        private void CopyProperties(Sku other)
        {
            this.SkuSize = other.SkuSize;
            this.Style = other.Style;
            this.Color = other.Color;
            this.Identifier = other.Identifier;
            this.Dimension = other.Dimension;
            this.SkuSize = other.SkuSize;
            this.Volume = other.Volume;
            this.Weight = other.Weight;
            this.PickslipBarCode = other.PickslipBarCode;
            this.MaxPiecesPerBox = other.MaxPiecesPerBox;
            this.MinPiecesPerBox = other.MinPiecesPerBox;
            this.SkuLabel = other.SkuLabel;
        }

        /// <summary>
        /// Remove the ordered pieces by passing the number of pieces
        /// </summary>
        /// <param name="increment"></param>
        public void DecrementOrderedPieces(int increment)
        {
            _orderedPieces -= increment;
        }

        /// <summary>
        /// Override ToString function to display the correct SKU info.
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return string.Format("{0}/{1}/{2}/{3}/{4} - {5}/{6} pieces - {7} vol",
                this.Style, this.Color, this.Identifier, this.Dimension, this.SkuSize,
                this.AvailablePieces, this.OrderedPieces,
                this.Volume);

        }

        #region IEquatable<Sku> Members

        /// <summary>
        /// Two SKUs are equal if they are from same pickslip and have same UPC.
        /// </summary>
        /// <param name="other"></param>
        /// <returns></returns>
        public bool Equals(Sku other)
        {
            return this.UpcCode.Equals(other.UpcCode) && this.PickslipId.Equals(other.PickslipId);
        }

        #endregion

        /// <summary>
        /// Check whether SKU passed is equal with this SKU 
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public override bool Equals(object obj)
        {
            Sku other = obj as Sku;
            if (other == null)
            {
                return false;
            }
            else
            {
                return this.Equals(other);
            }
        }
        /// <summary>
        /// Internal function
        /// </summary>
        /// <returns></returns>
        public override int GetHashCode()
        {
            return this.UpcCode.GetHashCode() + this.PickslipId;
        }
        #endregion
    }
        

}
