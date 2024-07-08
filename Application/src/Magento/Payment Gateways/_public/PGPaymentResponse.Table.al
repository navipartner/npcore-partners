table 6059836 "NPR PG Payment Response"
{
    Caption = 'Payment Gateway Response';
    Extensible = false;
    TableType = Temporary;

    fields
    {
        // Required field
        //
        // The value of this field should determine whether or not the operation
        // was a success, i.e. if the operation is a capture the capture
        // actually succeeded.
        field(10; "Response Success"; Boolean)
        {
            DataClassification = SystemMetadata;
        }

        // Required field
        field(20; "Response Body"; Blob)
        {
            DataClassification = CustomerContent;
        }

        // Optional field
        field(30; "Response Operation Id"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    /// <summary>
    /// Add the supplied JsonObject as body on the response
    /// </summary>
    /// <param name="JObject">JsonObject containing the body</param>
    procedure AddResponse(JObject: JsonObject)
    var
        OStr: OutStream;
    begin
        Rec."Response Body".CreateOutStream(OStr);
        JObject.WriteTo(OStr);
    end;

    /// <summary>
    /// Add the supplied string as body on the response
    /// </summary>
    /// <param name="ResponseText">String containing the body</param>
    procedure AddResponse(ResponseText: Text)
    var
        OStr: OutStream;
    begin
        Rec."Response Body".CreateOutStream(OStr);
        OStr.WriteText(ResponseText);
    end;

    /// <summary>
    /// Add the supplied XmlDocument as body on the response
    /// </summary>
    /// <param name="XmlDoc">XmlDocument containing the body</param>
    procedure AddResponse(XmlDoc: XmlDocument)
    var
        OStr: OutStream;
    begin
        Rec."Response Body".CreateOutStream(OStr);
        XmlDoc.WriteTo(OStr);
    end;

    internal procedure ToJson(): Text
    var
        JObject: JsonObject;
        Buffer: Text;
        ResponseTxt: Text;
        IStr: InStream;
        Out: Text;
    begin
        JObject.Add('response_success', Rec."Response Success");
        Rec."Response Body".CreateInStream(IStr);
        while (not IStr.EOS()) do begin
            IStr.ReadText(Buffer);
            ResponseTxt += Buffer;
        end;
        JObject.Add('response_body', ResponseTxt);
        JObject.Add('response_operation_id', Rec."Response Operation Id");

        JObject.WriteTo(Out);
        exit(Out);
    end;
}