table 6151066 "NPR HU L Return Reason Mapp."
{
    Access = Internal;
    Caption = 'HU Laurel Return Reason Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU L Return Reason Mapp.";
    LookupPageId = "NPR HU L Return Reason Mapp.";

    fields
    {
        field(1; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Return Reason";
        }
        field(20; "HU L Return Reason Code"; Enum "NPR HU L Return Reason Code")
        {
            Caption = 'HU L Return Reason Code';
            DataClassification = CustomerContent;
            InitValue = " ";
        }
    }

    keys
    {
        key(PK; "Return Reason Code")
        {
            Clustered = true;
        }
    }

    internal procedure CheckIsHULReturnReasonPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - HU L Return Reason Code field caption, %2 - Return Reason Code field caption, %3 - Return Reason Code field value';
    begin
        if "HU L Return Reason Code" = "HU L Return Reason Code"::" " then
            Error(NotPopulatedErr, FieldCaption("HU L Return Reason Code"), FieldCaption("Return Reason Code"), "Return Reason Code");
    end;
}