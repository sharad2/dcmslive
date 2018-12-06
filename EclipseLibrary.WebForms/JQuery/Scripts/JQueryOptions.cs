using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;


namespace EclipseLibrary.Web.JQuery.Scripts
{
    /// <summary>
    /// The code of this class is emitted as is to JSON
    /// </summary>
    public struct JScriptCode
    {
        public JScriptCode(string code)
        {
            _code = code;
        }

        private readonly string _code;
        public string Code {
            get
            {
                return _code;
            }
        }
    }

    /// <summary>
    /// Assists in generating the syntax required for passing options to jQuery widgets.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Use <see cref="Add(string, string, object[])"/> method or one of its overloads to add an option to the list. Then
    /// use <c>ToString()</c> to get the syntax required by jQuery. <see cref="JavaScriptSerializer"/> is used for serialing which
    /// should lead to robust javascript code. Unfortunately, we had to do manual tweaks to handle code blocks.
    /// </para>
    /// <para>
    /// Implementing IFormattable so that string.Format("{0}", options) returns a
    /// JSON string.
    /// </para>
    /// </remarks>
    /// <example>
    /// <code>
    /// JQueryOptions options = new JQueryOptions()
    /// options.Add("index", 3);
    /// options.Add("selector", "#id");
    /// string str = options.ToString();  // str = { index: 3, selector: '#id' }
    /// </code>
    /// </example>
    public class JQueryOptions:IFormattable
    {
        private readonly Dictionary<string, object> _dict;

        public JQueryOptions()
        {
            _dict = new Dictionary<string, object>();
        }

        #region Add and Set

        /// <summary>
        /// Throws exception if key exists
        /// </summary>
        /// <param name="option"></param>
        /// <param name="value"></param>
        internal void Add(string option, object value)
        {
            _dict.Add(option, value);
        }

        /// <summary>
        /// Convenience function for adding strings
        /// </summary>
        /// <param name="option"></param>
        /// <param name="formatString"></param>
        /// <param name="args"></param>
        public void Add(string option, string formatString, params object[] args)
        {
            if (string.IsNullOrEmpty(option))
            {
                throw new ArgumentNullException("option");
            }
            string str;
            if (args.Length == 0)
            {
                str = formatString;
            }
            else
            {
                str = string.Format(formatString, args);
            }
            _dict.Add(option, str);
        }

        /// <summary>
        /// Does not put any quotes around the string. Allows you to format the string exactly as you want.
        /// Result: { myfunc: OnChange }
        /// </summary>
        /// <param name="option"></param>
        /// <param name="value"></param>
        public void AddRaw(string option, string value)
        {
            _dict.Add(option, new JScriptCode(value));
        }

        internal void Set<T>(string key, T value, T valueToIgnore) where T : IEquatable<T>
        {
            if (value.Equals(valueToIgnore))
            {
                _dict.Remove(key);
            }
            else
            {
                _dict[key] = value;
            }
        }

        internal void Set(string key, object value)
        {
            _dict[key] = value;
        }

        #endregion

        #region Get

        public T Get<T>(string option)
        {
            object obj;
            bool b = _dict.TryGetValue(option, out obj);
            if (b)
            {
                // Found. Remove enclosing quotes
                return (T)obj;
            }
            else
            {
                return default(T);
            }
        }

        public T Get<T>(string option, T defaultValue)
        {
            object obj;
            bool b = _dict.TryGetValue(option, out obj);
            if (b)
            {
                return (T)obj;
            }
            else
            {
                return defaultValue;
            }
        }


        internal bool ContainsKey(string p)
        {
            return _dict.ContainsKey(p);
        }

        #endregion

        #region Serialization

        // {"param":{"0":"Sharad"},"depends":{"1":"Sharad"}}
        //private static Regex _regex = new Regex(@"(""\{\S+?\}"")", RegexOptions.Compiled);
        private static Regex _regex = new Regex(@"\{""(?<index>\d+?)"":null\}", RegexOptions.Compiled);

        /// <summary>
        /// Returns all the options in javascript format
        /// </summary>
        /// <returns>Javascript code</returns>
        /// <remarks>
        /// <para>
        /// <see cref="JavaScriptSerializer"/> does not handle raw code. So we use regular expression replacement to handle them.
        /// <see cref="AddRaw"/> actually adds a place holder like <c>{onclick}</c> as the value in the dictionary. It gets serialized as
        /// <c>"{onclick}"</c>. Then we use regular expression pattern matching to replace it with the actual value which
        /// we had stored in _dictRawRext.
        /// </para>
        /// </remarks>
        public string ToJson()
        {
            JavaScriptSerializer ser = new JavaScriptSerializer();
            List<string> rawList = new List<string>();
            ser.RegisterConverters(new SerialiaztionConverter[] { new SerialiaztionConverter(rawList) });
            string json;
            StringBuilder sb = new StringBuilder();
            ser.Serialize(_dict, sb);
            MatchCollection matches = _regex.Matches(sb.ToString());
            foreach (Match m in matches.Cast<Match>().Reverse())
            {
                var i = Convert.ToInt32(m.Groups["index"].Value);
                sb.Remove(m.Index, m.Length);
                sb.Insert(m.Index, rawList[i]);
            }
            json = sb.ToString();
            return json;
        }

        private class SerialiaztionConverter : JavaScriptConverter
        {
            private readonly IList<string> _rawList;
            public SerialiaztionConverter(IList<string> rawList)
            {
                _rawList = rawList;
            }

            public override object Deserialize(IDictionary<string, object> dictionary, Type type, JavaScriptSerializer serializer)
            {
                throw new NotImplementedException();
            }

            public override IDictionary<string, object> Serialize(object obj, JavaScriptSerializer serializer)
            {
                if (obj is JQueryOptions)
                {
                    JQueryOptions options = (JQueryOptions)obj;
                    return options._dict;
                }
                else if (obj is JScriptCode)
                {
                    JScriptCode jcode = (JScriptCode)obj;
                    Dictionary<string, object> dict = new Dictionary<string, object>();
                    //var mangledKey = string.Format("{{{0}}}", _rawDict.Count);
                    var key = _rawList.Count.ToString();
                    dict.Add(key, null);
                    _rawList.Add(jcode.Code);
                    return dict;

                }
                else
                {
                    throw new NotSupportedException();
                }
            }

            public override IEnumerable<Type> SupportedTypes
            {
                get
                {
                    return new ReadOnlyCollection<Type>(new List<Type>(new Type[] { typeof(JQueryOptions), typeof(JScriptCode) }));
                }
            }
        }
        #endregion

        /// <summary>
        /// To help with debugging
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return _dict.ToString();
        }

        /// <summary>
        /// Using string.Format will return JSON string. This supports old controls
        /// </summary>
        /// <param name="format"></param>
        /// <param name="formatProvider"></param>
        /// <returns></returns>
        public string ToString(string format, IFormatProvider formatProvider)
        {
            return ToJson();
        }
    }


}
