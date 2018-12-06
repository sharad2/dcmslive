using System;
using System.IO;
using System.Text;
using System.Web.UI;
using EclipseLibrary.Web.UI;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Compares markup of two controls by comparing their rendered output
    /// </summary>
    ///
    internal class ControlMarkupComparer : IDisposable
    {
        private readonly StringBuilder _sb;
        private readonly StringWriter _sw;
        private readonly MiniHtmlTextWriter _hw;

        public ControlMarkupComparer()
        {
            _sb = new StringBuilder();
            _sw = new StringWriter(_sb);
            _hw = new MiniHtmlTextWriter(_sw);
        }

        public bool MarkupSame(Control x, Control y)
        {
            _sb.Length = 0;
            x.RenderControl(_hw);
            string str1 = _sb.ToString();
            _sb.Length = 0;
            y.RenderControl(_hw);
            string str2 = _sb.ToString();
            return str1 == str2;
        }

        #region IDisposable Members

        public void Dispose()
        {
            _hw.Dispose();
            _sw.Dispose();
        }

        #endregion
    }
}
