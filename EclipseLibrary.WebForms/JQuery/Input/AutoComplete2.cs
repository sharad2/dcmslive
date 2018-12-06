
namespace EclipseLibrary.Web.JQuery.Input
{

    /// <summary>
    /// Represents a menu item displayed in an <see cref="AutoComplete"/> list
    /// </summary>
    /// <remarks>
    /// <para>
    /// The <see cref="Text"/> property is copied to the text box once the user makes a selection from the menu.
    /// The <see cref="Value"/> property is not diplayed but is stored in a hidden field. It is accessible after postback
    /// via the <see cref="AutoComplete.Value"/> property. <see cref="Detail"/> is shown in the menu but is not copied
    /// to the text box if selected.
    /// </para>
    /// <para>
    /// <see cref="Relevance"/> property is only used if the <see cref="AutoCompleteItem"/> array is part of
    /// <see cref="AutoCompleteData"/>.
    /// </para>
    /// </remarks>
    public class AutoCompleteItem
    {
        /// <summary>
        /// The text to be displayed in the autocomplete list
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// The id of the item chosen from the list
        /// </summary>
        public string Value { get; set; }

        /// <summary>
        /// The returned list should be sorted ascending by relevance
        /// </summary>
        /// <remarks>
        /// <para>
        /// Comparative relevance of the item. The lower the number, the better. See <see cref="AutoCompleteData"/> for an overview
        /// of the concept of Relevance.
        /// </para>
        /// </remarks>
        public int Relevance { get; set; }

        /// <summary>
        /// Displayed in the menu but does not become part of <see cref="AutoComplete.Text"/>
        /// </summary>
        public string Detail { get; set; }
    }

    public class AutoCompleteData
    {
        /// <summary>
        /// Each item whith relevance equal to this, or lower, value will be displayed in bold by the UI
        /// </summary>
        public int RelevanceGood { get; set; }

        /// <summary>
        /// The first item with relevance equal to this, or a lower, value will be automatically selected by the UI
        /// </summary>
        public int RelevancePerfect { get; set; }

        /// <summary>
        /// Array of <see cref="AutoCompleteItem"/> which will be displayed by the UI
        /// </summary>
        public AutoCompleteItem[] Items { get; set; }
    }

    //internal class AutoCompleteTypeResolver : JavaScriptTypeResolver
    //{
    //    public override Type ResolveType(string id)
    //    {
    //        if (id == typeof(AutoCompleteItem).ToString())
    //        {
    //            return typeof(AutoCompleteItem);
    //        }
    //        else if (id == typeof(AutoCompleteData).ToString())
    //        {
    //            return typeof(AutoCompleteData);
    //        }
    //        else
    //        {
    //            throw new ArgumentOutOfRangeException("id", id, "Unexpected");
    //        }
    //    }

    //    public override string ResolveTypeId(Type type)
    //    {
    //        throw new NotImplementedException();
    //    }
    //}
}
