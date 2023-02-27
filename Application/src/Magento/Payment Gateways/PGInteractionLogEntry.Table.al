table 6151473 "NPR PG Interaction Log Entry"
{
    Access = Internal;
    Caption = 'Payment Gateways Interactions Log';
    DataClassification = CustomerContent;
    LookupPageId = "NPR PG Interaction Log Entries";
    DrillDownPageId = "NPR PG Interaction Log Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Payment Line System Id"; Guid)
        {
            Caption = 'Payment Line System Id';
            DataClassification = SystemMetadata;
            TableRelation = "NPR Magento Payment Line".SystemId;
        }
        field(4; "Interaction Type"; Option)
        {
            Caption = 'Interaction Type';
            DataClassification = CustomerContent;
            OptionMembers = Capture,Refund,Cancel;
            OptionCaption = 'Capture,Refund,Cancel';
        }
        field(5; "In Progress"; Boolean)
        {
            Caption = 'In Progress';
            DataClassification = SystemMetadata;
        }
        field(6; "Error Message"; Blob)
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(7; "Operation Success"; Boolean)
        {
            Caption = 'Operation Success';
            DataClassification = SystemMetadata;
        }
        field(8; "Ran With Error"; Boolean)
        {
            Caption = 'Ran With Error';
            DataClassification = SystemMetadata;
        }
        field(10; "Request Object"; Blob)
        {
            Caption = 'Request Body';
            DataClassification = SystemMetadata;
        }
        field(11; "Response Object"; Blob)
        {
            Caption = 'Response Body';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}

