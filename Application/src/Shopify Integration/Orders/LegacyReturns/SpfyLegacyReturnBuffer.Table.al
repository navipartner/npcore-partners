table 6059917 "NPR Spfy Legacy Return Buffer"
{
    Access = Internal;
    Caption = 'Shopify Legacy Return Buffer';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(10; "Return Id"; Text[30]) { Caption = 'Return Id'; DataClassification = SystemMetadata; }
        field(20; "Return Name"; Text[50]) { Caption = 'Return Name'; DataClassification = SystemMetadata; }
        field(30; "Order Id"; Text[30]) { Caption = 'Order Id'; DataClassification = SystemMetadata; }
        field(40; "Order No."; Text[50]) { Caption = 'Order No.'; DataClassification = SystemMetadata; }
        field(50; "Order Name"; Text[50]) { Caption = 'Order Name'; DataClassification = SystemMetadata; }
        field(60; "Source Name"; Text[100]) { Caption = 'Source Name'; DataClassification = SystemMetadata; }
        field(70; "Presentment Currency Code"; Text[10]) { Caption = 'Presentment Currency Code'; DataClassification = SystemMetadata; }
        field(80; "Has Exchange Line"; Boolean) { Caption = 'Has Exchange Line'; DataClassification = SystemMetadata; }
        field(90; "Shipping Refund Amount"; Decimal) { Caption = 'Shipping Refund Amount'; DataClassification = SystemMetadata; }
        field(100; "Fee Amount"; Decimal) { Caption = 'Fee Amount'; DataClassification = SystemMetadata; }
        field(105; "Refund Beyond Lines Amount"; Decimal) { Caption = 'Refund Beyond Lines Amount'; DataClassification = SystemMetadata; }
        field(110; "Closed At"; DateTime) { Caption = 'Closed At'; DataClassification = SystemMetadata; }
        field(115; Status; Text[20]) { Caption = 'Status'; DataClassification = SystemMetadata; }
        field(120; "Order Json"; Blob) { Caption = 'Order Json'; DataClassification = SystemMetadata; }
        field(130; "Source Type"; Enum "NPR Spfy Legacy Return Source") { Caption = 'Source Type'; DataClassification = SystemMetadata; }
        field(140; "Posting DateTime"; DateTime) { Caption = 'Posting DateTime'; DataClassification = SystemMetadata; }
        field(150; "Source Created At"; DateTime) { Caption = 'Source Created At'; DataClassification = SystemMetadata; }
        field(160; "Belongs to Return"; Boolean) { Caption = 'Belongs to Return'; DataClassification = SystemMetadata; }
        field(170; "Other Refunds Incomplete"; Boolean) { Caption = 'Other Refunds Incomplete'; DataClassification = SystemMetadata; }
        field(180; "Order Cancelled"; Boolean) { Caption = 'Order Cancelled'; DataClassification = SystemMetadata; }
        field(190; "Pending Refund Txns"; Integer) { Caption = 'Pending Refund Transactions'; DataClassification = SystemMetadata; }
        field(3; "Order Fulfilled"; Boolean) { Caption = 'Order Fulfilled'; DataClassification = SystemMetadata; }
    }
    keys { key(PK; "Return Id") { Clustered = true; } }

    internal procedure SetOrderJson(OrderToken: JsonToken)
    var
        OutStr: OutStream;
    begin
        Clear("Order Json");
        "Order Json".CreateOutStream(OutStr, TextEncoding::UTF8);
        OrderToken.WriteTo(OutStr);
    end;

    internal procedure GetOrderJson(var OrderToken: JsonToken)
    var
        InStr: InStream;
    begin
        CalcFields("Order Json");
        "Order Json".CreateInStream(InStr, TextEncoding::UTF8);
        OrderToken.ReadFrom(InStr);
    end;
}
