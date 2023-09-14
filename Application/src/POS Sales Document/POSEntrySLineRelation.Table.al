table 6060070 "NPR POS Entry S.Line Relation"
{
    Access = Internal;
    Caption = 'POS Entry Sales line Relation';
    DataClassification = CustomerContent;
    LookupPageId = "NPR POS Entry S.Lines Relation";
    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(3; "POS Entry Buff.Sales Line No."; Integer)
        {
            Caption = 'POS Entry Buff.Sales Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry Sales Line"."Line No." where("POS Entry No." = field("POS Entry No."));
        }
        field(4; "POS Entry Reference Type"; Option)
        {
            Caption = 'POS Entry Reference Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Header,Sales Line';
            OptionMembers = HEADER,SALESLINE;
        }
        field(5; "POS Entry Reference Line No."; Integer)
        {
            Caption = 'POS Entry Reference Line No.';
            TableRelation = "NPR POS Entry Sales Doc. Link"."POS Entry Reference Line No." where("POS Entry No." = field("POS Entry No."));
            DataClassification = CustomerContent;
        }
        field(6; "Sale Document No."; Code[20])
        {
            Caption = 'Sale Document No.';
            DataClassification = CustomerContent;
        }
        field(7; "Sale Document Type"; Enum "NPR POS Sales Document Type")
        {
            Caption = 'Sale Document Type';
            DataClassification = CustomerContent;
        }
        field(8; "Sale Line No."; Integer)
        {
            Caption = 'Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(9; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(12; "Qty. to Ship"; Decimal)
        {
            Caption = 'Qty. to Ship';
            DataClassification = CustomerContent;
        }
        field(13; "Qty. to Invoice"; Decimal)
        {
            Caption = 'Qty. to Invoice';
            DataClassification = CustomerContent;
        }
        field(14; "Return Qty. to Receive"; Decimal)
        {
            Caption = 'Return Qty. to Receive';
            DataClassification = CustomerContent;
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "POS Entry No.", "Line No.")
        {
            Clustered = true;
        }
        key(SK1; "Sale Document No.", "Sale Document Type", "Sale Line No.")
        {

        }
        key(SK2; "POS Entry No.", "POS Entry Reference Line No.")
        {

        }
    }
}
