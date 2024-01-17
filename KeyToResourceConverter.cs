using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace Schenck.Mas.WPFToolkit.Converter
{

    /// <summary>
    ///     Converts a resource key to an object
    /// </summary>
    public class KeyToResourceConverter : IValueConverter
    {
        private static readonly Lazy<KeyToResourceConverter> Converter = new Lazy<KeyToResourceConverter>();

        /// <summary>Gets the instance.</summary>
        /// <value>The instance.</value>
        public static KeyToResourceConverter Instance
        {
            get => Converter.Value;
        }

        /// <inheritdoc />
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (!(value is string key))
            {
                return null;
            }

            if (string.IsNullOrEmpty(key))
            {
                return null;
            }

            return Application.Current.TryFindResource(key);
        }

        /// <inheritdoc />
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
#if DEBUG
#pragma warning disable CA1303 // Do not pass literals as localized parameters
            throw new NotImplementedException("Can't convert back.");
#pragma warning restore CA1303 // Do not pass literals as localized parameters
#else
            return value;
#endif
        }
    }
}