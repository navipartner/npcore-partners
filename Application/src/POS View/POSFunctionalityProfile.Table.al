table 6060098 "NPR POS Functionality Profile"
{
    Access = Internal;
    Caption = 'POS Functionality Profile';
    DataClassification = CustomerContent;
    LookupPageId = "NPR POS Functionality Profiles";
    DrillDownPageId = "NPR POS Functionality Profiles";
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR27.0';
    ObsoleteReason = 'New parameter SelectCustReq and SelectMemberReq in POS Action Login created, use this instead.';

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Require Select Member"; Boolean)
        {
            Caption = 'Require Select Member';
            DataClassification = CustomerContent;
        }
        field(40; "Require Select Customer"; Boolean)
        {
            Caption = 'Require Select Customer';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
        }
    }

}