interface "NPR Font Definition"
{
    procedure Initialize(Code: Text; Name: Text; FontFace: Text; Prefix: Text; CssStream: InStream; WoffStream: InStream);

    procedure GetJson(): JsonObject;
}
