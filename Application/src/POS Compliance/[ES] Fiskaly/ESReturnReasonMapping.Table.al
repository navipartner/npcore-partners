table 6150900 "NPR ES Return Reason Mapping"
{
    Access = Internal;
    Caption = 'ES Return Reason Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR ES Return Reason Mapping";
    LookupPageId = "NPR ES Return Reason Mapping";

    fields
    {
        field(1; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Return Reason";
        }
        field(20; "ES Return Reason"; Enum "NPR ES Return Reason")
        {
            Caption = 'ES Return Reason';
            DataClassification = CustomerContent;
            InitValue = " ";
        }
    }

    keys
    {
        key(Key1; "Return Reason Code")
        {
            Clustered = true;
        }
    }

    internal procedure CheckIsESReturnReasonPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - ES Return Reason field caption, %2 - Return Reason Code field caption, %3 - Return Reason Code field value';
    begin
        if "ES Return Reason" = "ES Return Reason"::" " then
            Error(NotPopulatedErr, FieldCaption("ES Return Reason"), FieldCaption("Return Reason Code"), "Return Reason Code");
    end;
}