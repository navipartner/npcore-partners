table 6150638 "NPR POS Paym. Bin Denomin."
{
    Access = Internal;
    Caption = 'POS Payment Bin Denomination';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Denomination Type"; Enum "NPR Denomination Type")
        {
            Caption = 'Denomination Type';
            DataClassification = CustomerContent;
        }
        field(10; Denomination; Decimal)
        {
            Caption = 'Denomination';
            DataClassification = CustomerContent;
        }
        field(15; "Denomination Variant ID"; Code[20])
        {
            Caption = 'Denomination Variant ID';
            DataClassification = CustomerContent;
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(30; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(200; "Payment Type No."; Code[10])
        {
            Caption = 'Payment Type No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(220; "Payment Method No."; Code[10])
        {
            Caption = 'Payment Method No.';
            DataClassification = CustomerContent;
        }
        field(245; "Bin Checkpoint Entry No."; Integer)
        {
            Caption = 'Bin Checkpoint Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin Checkp.";
        }
        field(250; "Workshift Checkpoint Entry No."; Integer)
        {
            Caption = 'Workshift Checkpoint Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Workshift Checkpoint";
        }
        field(260; "Attached-to ID"; Enum "NPR Denomination Target")
        {
            Caption = 'Attached-to ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Bin Checkpoint Entry No.")
        {
        }
        key(Key3; "Workshift Checkpoint Entry No.")
        {
        }
    }
}
