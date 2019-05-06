using System;

namespace PokeBrowser.Properties
{
    [AttributeUsage(AttributeTargets.Assembly, AllowMultiple = true)]
    public sealed class RazorPageBaseTypeAttribute : Attribute
    {
        public RazorPageBaseTypeAttribute([NotNull] string baseType)
        {
            BaseType = baseType;
        }
        public RazorPageBaseTypeAttribute([NotNull] string baseType, string pageName)
        {
            BaseType = baseType;
            PageName = pageName;
        }

        [NotNull] public string BaseType { get; private set; }
        [CanBeNull] public string PageName { get; private set; }
    }
}