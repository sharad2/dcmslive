using System;
using System.ComponentModel;
using System.Linq;
using System.Collections.Specialized;
using System.Collections.Generic;
using EclipseLibrary.Web.Extensions;

namespace EclipseLibrary.Web.JQuery
{
    /// <summary>
    /// Helper classes for Inserting
    /// </summary>
    public class GridViewInsertingEventArgs : CancelEventArgs
    {
        private readonly IOrderedDictionary _values;
        private readonly int _rowIndex;
        public GridViewInsertingEventArgs(IOrderedDictionary values, int rowIndex)
        {
            _values = values;
            _rowIndex = rowIndex;
        }

        /// <summary>
        /// Parameters for inserting
        /// </summary>
        public IOrderedDictionary Values
        {
            get
            {
                return _values;
            }
        }

        /// <summary>
        /// The index of the row which is being inserted
        /// </summary>
        public int RowIndex
        {
            get
            {
                return _rowIndex;
            }
        }
    }

    public class GridViewInsertedEventArgs : EventArgs
    {
        private readonly int _affectedRows;
        private readonly Exception _exception;
        private readonly IOrderedDictionary _values;
        public GridViewInsertedEventArgs(int affectedRows, Exception exception, IOrderedDictionary values)
        {
            _affectedRows = affectedRows;
            _exception = exception;
            _values = values;
        }

        public int AffectedRows
        {
            get
            {
                return _affectedRows;
            }
        }

        public Exception Exception
        {
            get
            {
                return _exception;
            }
        }

        public bool ExceptionHandled { get; set; }

        public bool KeepInInsertMode { get; set; }

        public IOrderedDictionary Values
        {
            get
            {
                return _values;
            }
        }
    }

    public partial class GridViewExInsert
    {
        /// <summary>
        /// Returns all grid data keys as properties
        /// </summary>
        private class InsertDataItem : ICustomTypeDescriptor
        {
            private string[] _keyNames;
            public InsertDataItem(string[] keyNames)
            {
                _keyNames = keyNames;
            }

            #region ICustomTypeDescriptor Members

            public AttributeCollection GetAttributes()
            {
                throw new NotImplementedException();
            }

            public string GetClassName()
            {
                throw new NotImplementedException();
            }

            public string GetComponentName()
            {
                throw new NotImplementedException();
            }

            public TypeConverter GetConverter()
            {
                throw new NotImplementedException();
            }

            public EventDescriptor GetDefaultEvent()
            {
                throw new NotImplementedException();
            }

            public PropertyDescriptor GetDefaultProperty()
            {
                throw new NotImplementedException();
            }

            public object GetEditor(Type editorBaseType)
            {
                throw new NotImplementedException();
            }

            public EventDescriptorCollection GetEvents(Attribute[] attributes)
            {
                throw new NotImplementedException();
            }

            public EventDescriptorCollection GetEvents()
            {
                throw new NotImplementedException();
            }

            public PropertyDescriptorCollection GetProperties(Attribute[] attributes)
            {
                throw new NotImplementedException();
            }

            public PropertyDescriptorCollection GetProperties()
            {
                //List<PropertyDescriptor> list = new List<PropertyDescriptor>();
                //foreach (string key in _keyNames)
                //{
                //    list.Add(new KeyValuePropertyDescriptor(key, null));
                //}
                var query = _keyNames.Select(p => new KeyValuePropertyDescriptor(p, null));
                return new PropertyDescriptorCollection(query.ToArray());
            }

            public object GetPropertyOwner(PropertyDescriptor pd)
            {
                throw new NotImplementedException();
            }

            #endregion
        }
    }
}
