using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace EclipseLibrary.Web.Extensions
{
    /// <summary>
    /// Dictionary which allows duplicate keys. Internal until we find a need to make it public.
    /// </summary>
    internal class MultiKeyDictionary<TKey, TValue> : IDictionary<TKey, TValue> where TKey : IEquatable<TKey> 
    {
        private readonly List<KeyValuePair<TKey, TValue>> _list;

        /// <summary>
        /// 
        /// </summary>
        public MultiKeyDictionary()
        {
            _list = new List<KeyValuePair<TKey, TValue>>();
        }

        #region IDictionary<TKey,TValue> Members

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="key"></param>
        /// <param name="value"></param>
        public void Add(TKey key, TValue value)
        {
            _list.Add(new KeyValuePair<TKey, TValue>(key, value));
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public bool ContainsKey(TKey key)
        {
            return _list.Any(p => p.Key.Equals(key));
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        public ICollection<TKey> Keys
        {
            get { throw new NotImplementedException(); }
        }

        /// <summary>
        /// Removes all values associted with the key
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public bool Remove(TKey key)
        {
            return _list.RemoveAll(p => p.Key.Equals(key)) > 0;
        }

        /// <summary>
        /// Returns the first value corresponding to the passed key
        /// </summary>
        /// <param name="key"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        public bool TryGetValue(TKey key, out TValue value)
        {
            var kvp = _list.FirstOrDefault(p => p.Key.Equals(key));
            if (key.Equals(kvp.Key))
            {
                value = kvp.Value;
                return true;
            }
            value = default(TValue);
            return false;
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        public ICollection<TValue> Values
        {
            get { throw new NotImplementedException(); }
        }

        /// <summary>
        /// Returns the first value. If not found, returns default value.
        /// Setter throws exception if value already exists.
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public TValue this[TKey key]
        {
            get
            {
                var kvp = _list.FirstOrDefault(p => p.Key.Equals(key));
                return kvp.Key.Equals(key) ? kvp.Value : default(TValue);
            }
            set
            {
                if (_list.Any(p => p.Key.Equals(key)))
                {
                    throw new ArgumentException("Key already exists. Use Add to add anyway.");
                }
                _list.Add(new KeyValuePair<TKey, TValue>(key, value));
            }
        }

        #endregion

        #region ICollection<KeyValuePair<TKey,TValue>> Members

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="item"></param>
        /// <exception cref="NotImplementedException"></exception>
        public void Add(KeyValuePair<TKey, TValue> item)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        public void Clear()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        public bool Contains(KeyValuePair<TKey, TValue> item)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="array"></param>
        /// <param name="arrayIndex"></param>
        public void CopyTo(KeyValuePair<TKey, TValue>[] array, int arrayIndex)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        public int Count
        {
            get { return _list.Count; }
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        public bool IsReadOnly
        {
            get { throw new NotImplementedException(); }
        }

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <param name="item"></param>
        /// <exception cref="NotImplementedException"></exception>
        /// <returns></returns>
        public bool Remove(KeyValuePair<TKey, TValue> item)
        {
            throw new NotImplementedException();
        }

        #endregion

        #region IEnumerable<KeyValuePair<TKey,TValue>> Members

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <returns></returns>
        public IEnumerator<KeyValuePair<TKey, TValue>> GetEnumerator()
        {
            return _list.GetEnumerator();
        }

        #endregion

        #region IEnumerable Members

        /// <summary>
        /// <inheritdoc />
        /// </summary>
        /// <exception cref="NotImplementedException"></exception>
        /// <returns></returns>
        IEnumerator IEnumerable.GetEnumerator()
        {
            throw new NotImplementedException();
        }

        #endregion
    }
}
