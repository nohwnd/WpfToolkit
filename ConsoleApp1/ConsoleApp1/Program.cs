using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Reflection.Emit;
using System.Runtime;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            var a = new A();
            Patch(typeof(A), nameof(A.Value));
            a.Value = "hello";
        }

        public static void Patch(Type type, string property)
        {
            PropertyInfo info = type.GetProperty(property, BindingFlags.Public | BindingFlags.Instance);
            {
                var typeBuilder = new  System.Reflection.Emit.TypeBuilder();
                MethodBuilder pGet = typeBuilder.DefineMethod("get_" + info.Name, MethodAttributes.Virtual | MethodAttributes.Public | MethodAttributes.SpecialName | MethodAttributes.HideBySig, info.PropertyType, Type.EmptyTypes);
                ILGenerator pILGet = pGet.GetILGenerator();

                ////The proxy object
                //pILGet.Emit(OpCodes.Ldarg_0);
                ////The database
                //pILGet.Emit(OpCodes.Ldfld, database);
                ////The proxy object
                //pILGet.Emit(OpCodes.Ldarg_0);
                ////The ObjectId to look for
                //pILGet.Emit(OpCodes.Ldfld, f);
                //pILGet.Emit(OpCodes.Callvirt, typeof(MongoDatabase).GetMethod("Find", BindingFlags.Public | BindingFlags.Instance, null, new Type[] { typeof(ObjectId) }, null).MakeGenericMethod(info.PropertyType));
                //pILGet.Emit(OpCodes.Ret);

                MethodBuilder pSet = typeBuilder.DefineMethod("set_" + info.Name, MethodAttributes.Virtual | MethodAttributes.Public | MethodAttributes.SpecialName | MethodAttributes.HideBySig, null, new Type[] { info.PropertyType });
                ILGenerator pILSet = pSet.GetILGenerator();
                pILSet.Emit(OpCodes.Ldarg_0);
                pILSet.Emit(OpCodes.Ldarg_1);
                pILSet.Emit(OpCodes.Ldarg_0);
                pILSet.Emit(OpCodes.Ldfld, database);
                pILSet.Emit(OpCodes.Call, typeof(ProxyBuilder).GetMethod("SetValueHelper", BindingFlags.Public | BindingFlags.Static, null, new Type[] { typeof(object), typeof(MongoDatabase) }, null));
                pILSet.Emit(OpCodes.Stfld, f);
                pILSet.Emit(OpCodes.Ret);

                //Edit:  Added fix
                newProp.SetSetMethod(pSet);
                newProp.SetGetMethod(pGet);
            }
        }

    }

    public class A
    {
        public string Value { get; set; }
    }
}
