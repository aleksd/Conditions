using System;

namespace CuttingEdge.Conditions
{
    /// <summary>
    /// A custom exception indicating an invalid enum value.
    /// </summary>
    /// 
    /// <remarks>
    /// <para>
    /// The reason for the custom exception is that
    /// the use of <c>System.ComponentModel.InvalidEnumArgumentException</c> is not recommended.
    /// It's marked <c>Obsolete</c> in Silverlight and not supported in Portable Libraries.
    /// </para>
    /// <para>
    /// The <see cref="ArgumentException"/> should be used instead, which this class derives from.
    /// </para>
    /// <para>
    /// See also http://stackoverflow.com/questions/7558782/why-is-invalidenumargumentexception-obsolete-in-silverlight-4
    /// </para>
    /// </remarks>
    public class InvalidEnumArgumentException : ArgumentException
    {
        public InvalidEnumArgumentException(string message) : base(message)
        {
        }
    }
}