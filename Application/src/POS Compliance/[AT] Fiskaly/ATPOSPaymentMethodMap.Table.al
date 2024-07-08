table 6150856 "NPR AT POS Payment Method Map"
{
    Access = Internal;
    Caption = 'AT POS Payment Method Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR AT POS Payment Method Map";
    LookupPageId = "NPR AT POS Payment Method Map";

    fields
    {
        field(1; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(20; "AT Payment Type"; Enum "NPR AT Payment Type")
        {
            Caption = 'AT Payment Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Payment Method Code")
        {
            Clustered = true;
        }
    }

    internal procedure CheckIsATPaymentTypePopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - AT Payment Type field caption, %2 - POS Payment Method Code field caption, %3 - POS Payment Method Code field value';
    begin
        if "AT Payment Type" = "AT Payment Type"::" " then
            Error(NotPopulatedErr, FieldCaption("AT Payment Type"), FieldCaption("POS Payment Method Code"), "POS Payment Method Code");
    end;
}