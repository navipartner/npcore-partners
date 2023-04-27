table 6059813 "NPR PG Payment Request"
{
    Caption = 'Payment Gateway Request';
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(3; "Transaction ID"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Request Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Payment Gateway Code"; Code[10])
        {
            DataClassification = SystemMetadata;
            TableRelation = "NPR Magento Payment Gateway".Code;
        }
        field(10; "Request Body"; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Request Description"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(16; "Last Operation Id"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(20; "Document Table No."; Integer)
        {
            DataClassification = SystemMetadata;
        }

        // This field may be a null-guid if the request
        // is relating to a cancel request; otherwise it will
        // be filled out.
        field(21; "Document System Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(22; "Payment Line System Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
    }

    /// <summary>
    /// Add the supplied JsonObject as the body on the request
    /// </summary>
    /// <param name="JObject">JsonObject containing the body</param>
    procedure AddBody(JObject: JsonObject)
    var
        OStr: OutStream;
    begin
        Rec."Request Body".CreateOutStream(OStr);
        JObject.WriteTo(OStr);
    end;

    /// <summary>
    /// Add the supplied text as the body on the request
    /// </summary>
    /// <param name="BodyText">String containing the body</param>
    procedure AddBody(BodyText: Text)
    var
        OStr: OutStream;
    begin
        Rec."Request Body".CreateOutStream(OStr);
        OStr.WriteText(BodyText);
    end;

    /// <summary>
    /// Add the supplied XmlDocument as the body on the request
    /// </summary>
    /// <param name="XmlDoc">XmlDocumnet containing the body</param>
    procedure AddBody(XmlDoc: XmlDocument)
    var
        OStr: OutStream;
    begin
        Rec."Request Body".CreateOutStream(OStr);
        XmlDoc.WriteTo(OStr);
    end;

    internal procedure ToJson(): Text
    var
        JObject: JsonObject;
        IStr: InStream;
        BodyTxt: Text;
        Buffer: Text;
        Out: Text;
    begin
        JObject.Add('transaction_id', Rec."Transaction ID");
        JObject.Add('request_amount', Rec."Request Amount");
        JObject.Add('payment_gateway_code', Rec."Payment Gateway Code");

        Rec."Request Body".CreateInStream(IStr);
        while (not IStr.EOS()) do begin
            IStr.ReadText(Buffer);
            BodyTxt += Buffer;
        end;
        JObject.Add('request_body', BodyTxt);

        JObject.Add('request_description', Rec."Request Description");
        JObject.Add('last_operation_id', Rec."Last Operation Id");
        JObject.Add('document_table_no', Rec."Document Table No.");
        JObject.Add('document_system_id', Rec."Document System Id");

        JObject.WriteTo(Out);
        exit(Out);
    end;
}