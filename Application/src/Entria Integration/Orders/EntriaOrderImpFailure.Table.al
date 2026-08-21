#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6248186 "NPR Entria Order Imp. Failure"
{
    Caption = 'Entria Order Import Failure';
    Access = Internal;
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Entria Order Imp. Failures";
    LookupPageId = "NPR Entria Order Imp. Failures";

    fields
    {
        field(1; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Entria Store".Code;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(3; "Order Id"; Text[100])
        {
            Caption = 'Order Id';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(4; "Order Updated At"; DateTime)
        {
            Caption = 'Order Updated At';
            DataClassification = CustomerContent;
        }
        field(5; "Last Error"; Text[2048])
        {
            Caption = 'Last Error';
            DataClassification = CustomerContent;
        }
        field(6; "Retry Count"; Integer)
        {
            Caption = 'Retry Count';
            DataClassification = CustomerContent;
        }
        field(7; "Next Retry At"; DateTime)
        {
            Caption = 'Next Retry At';
            DataClassification = CustomerContent;
        }
        field(8; Suppressed; Boolean)
        {
            Caption = 'Suppressed';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2027-08-19';
            ObsoleteReason = 'Replaced by the Status field, where Skipped carries the same meaning.';
        }
        field(9; "Display No."; Integer)
        {
            Caption = 'Display No.';
            DataClassification = CustomerContent;
            BlankZero = true;
        }
        field(10; Status; Enum "NPR Entria Order Imp. Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Store Code", "Order Id")
        {
            Clustered = true;
        }
        key(SK1; Status, "Next Retry At")
        {
        }
    }
}
#endif
