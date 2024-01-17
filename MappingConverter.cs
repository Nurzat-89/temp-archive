using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Windows;
using System.Windows.Data;
using System.Windows.Markup;

#pragma warning disable IDE1006 // Naming Styles

namespace Schenck.Mas.WPFToolkit.Converter
{
    /// <summary>
    ///     Helper class to define a mapping
    /// </summary>
    public class Mapping : DependencyObject
    {
        /// <summary>
        ///     Gets or sets the from value.
        /// </summary>
        public string From
        {
            get => (string) GetValue(FromProperty);
            set => SetValue(FromProperty, value);
        }

        /// <summary>
        ///     Gets or sets the to value.
        /// </summary>
        public object To
        {
            get => GetValue(ToProperty);
            set => SetValue(ToProperty, value);
        }

        /// <summary>The From dependency property</summary>
        public static readonly DependencyProperty FromProperty = DependencyProperty.Register(nameof(From), typeof(string), typeof(Mapping), new UIPropertyMetadata(null));

        /// <summary>The To dependency property</summary>
        public static readonly DependencyProperty ToProperty = DependencyProperty.Register(nameof(To), typeof(object), typeof(Mapping), new UIPropertyMetadata(null));
    }

    /// <summary>
    ///     Generic converter that can be configured in XAML
    /// </summary>
    [ContentProperty(nameof(MappingConverter.Mappings))]
    public class MappingConverter : DependencyObject, IValueConverter
    {
        /// <inheritdoc />
        public MappingConverter()
        {
            Mappings = new List<Mapping>();
        }

        /// <summary>
        ///     Gets or sets the fallback value, if the mapping fails.
        /// </summary>
        public object DefaultValue
        {
            get => GetValue(DefaultValueProperty);
            set => SetValue(DefaultValueProperty, value);
        }

        /// <summary>
        ///     Gets the mapping list.
        /// </summary>
        // ReSharper disable once CollectionNeverUpdated.Global
        public List<Mapping> Mappings { get; }

        /// <inheritdoc />
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            Mapping foundMapping = Mappings?.FirstOrDefault(mapping => mapping.From == value?.ToString());
            if (foundMapping != null)
            {
                return foundMapping.To;
            }
            return DefaultValue;
        }

        /// <inheritdoc />
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }

        /// <summary>The DefaultValue dependency property</summary>
        public static readonly DependencyProperty DefaultValueProperty =
            DependencyProperty.Register(nameof(DefaultValue), typeof(object), typeof(MappingConverter), new UIPropertyMetadata(null));
    }
}
