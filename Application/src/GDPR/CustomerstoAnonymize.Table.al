table 6151071 "NPR Customers to Anonymize"
{
    Access = Internal;
    // NPR5.53/ZESO/20200115 CASE 358656 New Object Created
    // NPR5.55/ZESO/20200513 CASE 388813 Increased length of Customer Name to 100 as Length of Customer Name is 100 in BC.

    Caption = 'Customers to Anonymize';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Customers to Anon. List";
    LookupPageID = "NPR Customers to Anon. List";

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
            DataClassification = CustomerContent;
        }
        field(2; "Customer No"; Code[20])
        {
            Caption = 'Customer No';
            DataClassification = CustomerContent;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No")
        {
        }
    }

    fieldgroups
    {
    }
}

