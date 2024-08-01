table 6150835 "NPR RS EI Tax Exemption Reason"
{
    Access = Internal;
    Caption = 'RS EI Tax Exemption Reason';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS EI Tax Ex. Reasons";
    LookupPageId = "NPR RS EI Tax Ex. Reasons";

    fields
    {
        field(1; "Tax Category"; Code[10])
        {
            Caption = 'Tax Category';
            DataClassification = CustomerContent;
        }
        field(2; "Tax Exemption Reason Code"; Code[20])
        {
            Caption = 'Tax Exemption Reason Code';
            DataClassification = CustomerContent;
        }
        field(3; "Tax Exemption Reason Text"; Text[400])
        {
            Caption = 'Tax Exemption Reason Text';
            DataClassification = CustomerContent;
        }
        field(4; "Configuration Date"; Date)
        {
            Caption = 'Configuration Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Tax Category", "Tax Exemption Reason Code") { }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Tax Category", "Tax Exemption Reason Code", "Tax Exemption Reason Text") { }
    }
}