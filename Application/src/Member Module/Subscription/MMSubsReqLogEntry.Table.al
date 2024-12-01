table 6150981 "NPR MM Subs Req Log Entry"
{
    Access = Internal;
    Caption = 'Subscriptions Request Log Entry';
    DataClassification = CustomerContent;
    LookupPageId = "NPR MM Sub Req Log Entries";
    DrillDownPageId = "NPR MM Sub Req Log Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Request Entry No."; BigInteger)
        {
            Caption = 'Request Entry No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Request Id"; Guid)
        {
            Caption = 'Request System Id';
            DataClassification = SystemMetadata;
        }
        field(4; Status; Enum "NPR MM Subscr. Request Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(6; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(7; "Processing Status"; Enum "NPR MM Sub Req Log Proc Status")
        {
            Caption = 'Processing Status';
            DataClassification = SystemMetadata;
        }
        field(8; Manual; Boolean)
        {
            Caption = 'Manual';
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

