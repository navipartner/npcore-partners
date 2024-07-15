table 6150885 "NPR PG Posting Log Entry"
{
    Access = Internal;
    Caption = 'Payment Gateways Posting Log ';
    DataClassification = CustomerContent;
    LookupPageId = "NPR PG Posting Log Entries";
    DrillDownPageId = "NPR PG Posting Log Entries";

    fields
    {
        field(10; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Payment Line System Id"; Guid)
        {
            Caption = 'Payment Line System Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Line".SystemId;
        }

        field(30; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
        }

        field(40; "Error Description"; Text[250])
        {
            Caption = 'Error Description';
            DataClassification = CustomerContent;
        }
        field(50; "Posting Timestamp"; DateTime)
        {
            Caption = 'Posting Timestamp';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }


}