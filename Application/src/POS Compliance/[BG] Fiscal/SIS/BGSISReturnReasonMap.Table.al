table 6060099 "NPR BG SIS Return Reason Map"
{
    Access = Internal;
    Caption = 'BG SIS Return Reason Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BG SIS Return Reason Map";
    LookupPageId = "NPR BG SIS Return Reason Map";

    fields
    {
        field(1; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Return Reason";
        }
        field(20; "BG SIS Return Reason"; Enum "NPR BG SIS Return Reason")
        {
            Caption = 'BG SIS Return Reason';
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

    internal procedure CheckIsBGSISReturnReasonPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - BG SIS Return Reason field caption, %2 - Return Reason Code field caption, %3 - Return Reason Code field value';
    begin
        if "BG SIS Return Reason" = "BG SIS Return Reason"::" " then
            Error(NotPopulatedErr, FieldCaption("BG SIS Return Reason"), FieldCaption("Return Reason Code"), "Return Reason Code");
    end;
}