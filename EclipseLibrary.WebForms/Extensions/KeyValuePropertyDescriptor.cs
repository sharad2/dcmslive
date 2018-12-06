using System;
using System.ComponentModel;

namespace EclipseLibrary.Web.Extensions
{
    internal class KeyValuePropertyDescriptor : PropertyDescriptor
    {
        private readonly object _value;
        public KeyValuePropertyDescriptor(string key, object value)
            : base(key, null)
        {
            _value = value;
        }
        public override bool CanResetValue(object component)
        {
            return false;
        }

        public override Type ComponentType
        {
            get { throw new NotImplementedException(); }
        }

        public override object GetValue(object component)
        {
            return _value;
        }

        public override bool IsReadOnly
        {
            get { return true; }
        }

        public override Type PropertyType
        {
            get { return typeof(object); }
        }

        public override void ResetValue(object component)
        {
            throw new NotSupportedException("We are readonly");
        }

        public override void SetValue(object component, object value)
        {
            throw new NotSupportedException("We are readonly");
        }

        public override bool ShouldSerializeValue(object component)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// For help in debugging
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return string.Format("{0}: {1}", this.Name, _value);
        }
    }
}
