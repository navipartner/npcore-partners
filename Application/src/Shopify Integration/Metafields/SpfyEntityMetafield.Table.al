#if not BC17
table 6150951 "NPR Spfy Entity Metafield"
{
    Access = Internal;
    Extensible = false;
    Caption = 'Shopify Entity Metafield';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Entity Metafields";
    LookupPageId = "NPR Spfy Entity Metafields";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table No.';
        }
        field(20; "BC Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'BC Record ID';
        }
        field(50; "Owner Type"; Enum "NPR Spfy Metafield Owner Type")
        {
            Caption = 'Owner Type';
            DataClassification = CustomerContent;
        }
        field(60; "Metafield ID"; Text[30])
        {
            Caption = 'Metafield ID';
            DataClassification = CustomerContent;
        }
        field(70; "Metafield Key"; Text[80])
        {
            Caption = 'Metafield Key';
            DataClassification = CustomerContent;
        }
        field(80; "Metafield Value"; Text[250])
        {
            Caption = 'Metafield Value';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-08-03';
            ObsoleteReason = 'Replaced with a blob field "Metafield Raw Value" to support complex metafield values.';
        }
        field(81; "Metafield Raw Value"; Blob)
        {
            Caption = 'Metafield Value';
            DataClassification = CustomerContent;
        }
        field(90; "Metafield Value Version ID"; Text[80])
        {
            Caption = 'Metafield Value Version ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Table No.", "BC Record ID", "Owner Type", "Metafield ID") { }
        key(Key3; "Owner Type", "Metafield ID", "Table No.") { }
    }

    internal procedure SetMetafieldValue(NewMetafieldValue: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Metafield Raw Value");
        if NewMetafieldValue = '' then
            exit;
        "Metafield Raw Value".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewMetafieldValue);
    end;

    procedure GetMetafieldValue(RunCalcFields: Boolean): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        if not "Metafield Raw Value".HasValue() then
            exit('');
        if RunCalcFields then
            CalcFields("Metafield Raw Value");
        "Metafield Raw Value".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;
}
#endif