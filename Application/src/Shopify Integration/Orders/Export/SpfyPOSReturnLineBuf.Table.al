table 6060026 "NPR Spfy POS Return Line Buf."
{
    Access = Internal;
    Caption = 'Shopify POS Return Line Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "POS Entry No."; Integer) { Caption = 'POS Entry No.'; DataClassification = CustomerContent; }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; DataClassification = CustomerContent; }
        field(3; "Return Case"; Enum "NPR Spfy POS Return Case") { Caption = 'Return Case'; DataClassification = CustomerContent; }
        field(4; "Target Shopify Order ID"; Text[30]) { Caption = 'Target Shopify Order ID'; DataClassification = CustomerContent; }
        field(5; "Original POS Entry No."; Integer) { Caption = 'Original POS Entry No.'; DataClassification = CustomerContent; }
        field(6; "Original Line SystemId"; Guid) { Caption = 'Original Line SystemId'; DataClassification = CustomerContent; }
        field(7; "Is Item Line"; Boolean) { Caption = 'Is Item Line'; DataClassification = CustomerContent; }
        field(8; "Item No."; Code[20]) { Caption = 'Item No.'; DataClassification = CustomerContent; }
        field(9; "Variant Code"; Code[10]) { Caption = 'Variant Code'; DataClassification = CustomerContent; }
        field(10; Quantity; Integer) { Caption = 'Quantity'; DataClassification = CustomerContent; }
        field(11; "Amount Incl. VAT"; Decimal) { Caption = 'Amount Incl. VAT'; DataClassification = CustomerContent; }
        field(12; "Unit Price"; Decimal) { Caption = 'Unit Price'; DataClassification = CustomerContent; }
        field(13; "Line Title"; Text[250]) { Caption = 'Line Title'; DataClassification = CustomerContent; }
        field(14; "Unlinked Reason"; Text[250]) { Caption = 'Unlinked Reason'; DataClassification = CustomerContent; }
        field(16; "Refund Quantity"; Integer) { Caption = 'Refund Quantity'; DataClassification = CustomerContent; }
        field(17; "Refund Amount"; Decimal) { Caption = 'Refund Amount'; DataClassification = CustomerContent; }
        field(18; "Return Reason Code"; Code[10]) { Caption = 'Return Reason Code'; DataClassification = CustomerContent; }
        field(19; "Line Item Price"; Decimal) { Caption = 'Line Item Price'; DataClassification = CustomerContent; }
        field(20; "Line Item Price 2"; Decimal) { Caption = 'Line Item Price 2'; DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "POS Entry No.", "Line No.") { Clustered = true; }
        key(Target; "Target Shopify Order ID") { }
    }
}
