interface "NPR Font Definition"
{
    #IF NOT BC17 
    Access = Internal;      
    #ENDIF
    procedure Code(): Text;
    procedure Name(): Text;
    procedure FontFace(): Text;
    procedure Prefix(): Text;
    procedure GetCssStream(var CssStream: OutStream);
    procedure GetWoffStream(var WoffStream: OutStream);
    procedure Initialize(Code: Text; Name: Text; FontFace: Text; Prefix: Text; CssStream: InStream; WoffStream: InStream);
    procedure Initialize(JsonStream: InStream);
    procedure GetJson(): JsonObject;
}
