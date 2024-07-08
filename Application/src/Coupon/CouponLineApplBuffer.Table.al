table 6150839 "NPR Coupon Line Appl Buffer"
{
    DataClassification = SystemMetadata;
    Access = Internal;
    TableType = Temporary;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Sale Line Record ID"; RecordID)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Sale Line System ID"; Guid)
        {
            DataClassification = CustomerContent;
        }
        field(4; Priority; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(5; "Amount Excluding VAT"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Amount Including VAT"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(9; "VAT %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Register No."; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(12; "Sales Ticket No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Price Includes VAT"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Amount Including VAT")
        {
        }
        key(Key3; "Amount Including VAT", "Line No.")
        {
        }
    }

    internal procedure CopyInformationFromSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        Rec."Amount Excluding VAT" := SaleLinePOS.Amount;
        Rec."Amount Including VAT" := SaleLinePOS."Amount Including VAT";
        Rec.Quantity := SaleLinePOS.Quantity;
        Rec."VAT %" := SaleLinePOS."VAT %";
        Rec."No." := SaleLinePOS."No.";
        Rec."Line No." := SaleLinePOS."Line No.";
        Rec."Register No." := SaleLinePOS."Register No.";
        Rec.Date := SaleLinePOS.Date;
        Rec."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        Rec."Price Includes VAT" := SaleLinePOS."Price Includes VAT";
    end;
}