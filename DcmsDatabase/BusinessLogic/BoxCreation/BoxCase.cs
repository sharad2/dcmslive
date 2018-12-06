
namespace DcmsDatabase.BusinessLogic.BoxCreation
{
    /// <summary>
    /// This class provides the Box case info and this class being used as property of box.
    /// </summary>
    internal class BoxCase
    {
        /// <summary>
        /// Define the case id of the box case
        /// </summary>
        public string CaseId { get; set; }

        /// <summary>
        /// The Volume of the case
        /// </summary>
        public decimal Volume { get; set; }

        /// <summary>
        /// The weight of empty box case.
        /// </summary>
        public decimal CaseWeight { get; set; }

        /// <summary>
        /// Returns the case_id if do boxcase.To_String.
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return this.CaseId;
        }
    }
}
