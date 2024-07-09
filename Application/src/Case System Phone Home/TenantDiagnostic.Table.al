table 6014696 "NPR Tenant Diagnostic"
{
    Caption = 'Tenant Diagnostic';
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;

    fields
    {
        field(1; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
            DataClassification = CustomerContent;
        }
        field(2; "Azure AD Tenant ID"; Text[50])
        {
            Caption = 'Azure AD Tenant ID';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'We have new set of objects and functions for SaaS environment, so this field is going to be obsoleted.';
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
        field(50; "Last Tenant ID Sent to CS"; Text[50])
        {
            Caption = 'Last Tenant ID Sent to Case System';
            DataClassification = CustomerContent;
        }
        field(55; "Last DT Tenant ID Sent to CS"; DateTime)
        {
            Caption = 'Last DateTime Tenant ID Sent to Case System';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Tenant ID")
        {
            Clustered = true;
        }
    }
}
