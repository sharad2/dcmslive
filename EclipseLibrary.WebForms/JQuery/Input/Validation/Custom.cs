using System;
using System.ComponentModel;
using System.Web.UI;

namespace EclipseLibrary.Web.JQuery.Input
{

    /// <summary>
    /// Allows for custom validation. You specify a client rule name and a server validate event handler to
    /// accomplish the valdiation.
    /// </summary>
    /// <include file='Custom.xml' path='Custom/doc[@name="class"]/*'/>
    public class Custom : ValidatorBase, IStateManager
    {
        /// <summary>
        /// 
        /// </summary>
        public Custom()
            : base(ValidatorType.Value)
        {

        }

        /// <summary>
        /// Name of the custom rule you have created. If this is blank, client side validation is not invoked.
        /// </summary>
        /// <include file='Custom.xml' path='Custom/doc[@name="Rule"]/*'/>
        [Browsable(true)]
        public string Rule { get; set; }

        private object _params;

        /// <summary>
        /// Parameters to pass to the client validation function. Default true.
        /// </summary>
        /// <include file='Custom.xml' path='Custom/doc[@name="Params"]/*'/>
        [Browsable(false)]
        public object Params
        {
            get
            {
                return _params ?? true;
            }
            set
            {
                if (_isTrackingViewState && _params != value)
                {
                    _isDirty = true;
                }
                _params = value;
            }
        }

        /// <summary>
        /// Use this property to set value from markup
        /// </summary>
        /// <remarks>
        /// <para>
        /// You can set string values from markup using this property. Values of other types
        /// must be set through code.
        /// </para>
        /// </remarks>
        [Browsable(true)]
        public string StringParams
        {
            get
            {
                return string.Format("{0}", this.Params);
            }
            set
            {
                this.Params = value;
            }
        }

        /// <summary>
        /// This is not used by the validation framework. It is provides so that you can search for a specific custom validator
        /// when multiple validators are being used.
        /// </summary>
        public string ID { get; set; }


        #region IStateManager Members

        private bool _isTrackingViewState;
        private bool _isDirty;

        bool IStateManager.IsTrackingViewState
        {
            get { throw new NotImplementedException(); }
        }

        void IStateManager.LoadViewState(object state)
        {
            if (state != null)
            {
                this.Params = (string)state;
            }
        }

        object IStateManager.SaveViewState()
        {
            return _isDirty ? this.Params : null;
        }

        void IStateManager.TrackViewState()
        {
            _isTrackingViewState = true;
        }

        #endregion

        internal override void RegisterClientRules(InputControlBase ctlInputControl)
        {
            if (!string.IsNullOrEmpty(this.Rule))
            {
                DoRegisterValidator(ctlInputControl, this.Rule, this.Params, null);
            }
        }
    }
}
