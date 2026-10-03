table 6059923 "NPR Spfy Legacy Return Ln Buf"
{
    Access = Internal;
    Caption = 'Shopify Legacy Return Line Buffer';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(10; "Return Id"; Text[30]) { Caption = 'Return Id'; DataClassification = SystemMetadata; }
        field(20; "Line No."; Integer) { Caption = 'Line No.'; DataClassification = SystemMetadata; }
        field(30; SKU; Text[100]) { Caption = 'SKU'; DataClassification = SystemMetadata; }
        field(40; Title; Text[100]) { Caption = 'Title'; DataClassification = SystemMetadata; }
        field(50; Quantity; Decimal) { Caption = 'Quantity'; DataClassification = SystemMetadata; }
        field(60; "Order Line Item Id"; Text[30]) { Caption = 'Order Line Item Id'; DataClassification = SystemMetadata; }
        field(70; "Fulfillment Line Item Id"; Text[30]) { Caption = 'Fulfillment Line Item Id'; DataClassification = SystemMetadata; }
        field(80; "Disposition Location Id"; Text[30]) { Caption = 'Disposition Location Id'; DataClassification = SystemMetadata; }
        field(90; "Not Restocked"; Boolean) { Caption = 'Not Restocked'; DataClassification = SystemMetadata; }
        field(100; "Unit Price"; Decimal) { Caption = 'Unit Price'; DataClassification = SystemMetadata; }
        field(110; "Line Amount"; Decimal) { Caption = 'Line Amount'; DataClassification = SystemMetadata; }
        field(120; "VAT %"; Decimal) { Caption = 'VAT %'; DataClassification = SystemMetadata; }
        field(130; "Line Item Json"; Blob) { Caption = 'Line Item Json'; DataClassification = SystemMetadata; }
        field(140; "Gift Card"; Boolean) { Caption = 'Gift Card'; DataClassification = SystemMetadata; }
    }
    keys
    {
        key(PK; "Return Id", "Line No.") { Clustered = true; }
        key(FulfillmentLine; "Fulfillment Line Item Id") { }
        key(OrderLine; "Order Line Item Id") { }
    }

    internal procedure SetLineItemJson(LineItemToken: JsonToken)
    var
        OutStr: OutStream;
    begin
        Clear("Line Item Json");
        "Line Item Json".CreateOutStream(OutStr, TextEncoding::UTF8);
        LineItemToken.WriteTo(OutStr);
    end;

    internal procedure GetLineItemJson(var LineItemToken: JsonToken)
    var
        InStr: InStream;
    begin
        CalcFields("Line Item Json");
        "Line Item Json".CreateInStream(InStr, TextEncoding::UTF8);
        LineItemToken.ReadFrom(InStr);
    end;
}
