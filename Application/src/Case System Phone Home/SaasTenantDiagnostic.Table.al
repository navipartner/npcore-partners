table 6059814 "NPR Saas Tenant Diagnostic"
{
    Caption = 'Saas Tenant Diagnostic';
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;

    fields
    {
        field(2; "Azure AD Tenant ID"; Text[50])
        {
            Caption = 'Azure AD Tenant ID';
            DataClassification = CustomerContent;
        }
        field(10; "POS Stores"; Integer)
        {
            Caption = 'POS Stores';
            DataClassification = CustomerContent;
        }
        field(11; "POS Stores Sent on Last Upd."; Integer)
        {
            Caption = 'POS Stores Sent on Last Update';
            DataClassification = CustomerContent;
        }
        field(15; "POS Stores Last Updated"; DateTime)
        {
            Caption = 'POS Stores Last Updated';
            DataClassification = CustomerContent;
        }
        field(20; "POS Stores Last Sent"; DateTime)
        {
            Caption = 'POS Stores Last Sent';
            DataClassification = CustomerContent;
        }
        field(25; "POS Units"; Integer)
        {
            Caption = 'POS Units';
            DataClassification = CustomerContent;
        }
        field(26; "POS Units Sent on Last Upd."; Integer)
        {
            Caption = 'POS Units Sent on Last Update';
            DataClassification = CustomerContent;
        }
        field(30; "POS Units Last Updated"; DateTime)
        {
            Caption = 'POS Units Last Updated';
            DataClassification = CustomerContent;
        }
        field(35; "POS Units Last Sent"; DateTime)
        {
            Caption = 'POS Units Last Sent';
            DataClassification = CustomerContent;
        }
        field(55; "Last DT AzTenant ID Sent to CS"; DateTime)
        {
            Caption = 'Last DateTime Azure AD Tenant ID Sent to Case System';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Azure AD Tenant ID")
        {
            Clustered = true;
        }
    }
}
