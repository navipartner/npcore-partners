table 6014491 "NPR Archive POS Info Trx"
{
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved to archive tables
    //   The table may be deleted later, when it is no longer relevant.

    Caption = 'POS Info Transaction';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(5; "Receipt Type"; Option)
        {
            Caption = 'Receipt Type';
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
            DataClassification = CustomerContent;
        }
        field(6; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            TableRelation = "NPR POS Info";
            DataClassification = CustomerContent;
        }
        field(11; "POS Info"; Text[250])
        {
            Caption = 'POS Info';
            DataClassification = CustomerContent;
        }
        field(12; "POS Info Type"; Option)
        {
            Caption = 'POS Info Type';
            Description = 'NPR5.53';
            OptionCaption = 'Show Message,Request Data,Write Default Message';
            OptionMembers = "Show Message","Request Data","Write Default Message";
            DataClassification = CustomerContent;
        }
        field(20; "No."; Code[30])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(22; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }
        field(23; "Net Amount"; Decimal)
        {
            Caption = 'Net Amount';
            DataClassification = CustomerContent;
        }
        field(24; "Gross Amount"; Decimal)
        {
            Caption = 'Gross Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(40; "Once per Transaction"; Boolean)
        {
            Caption = 'Once per Transaction';
            Description = 'NPR5.53';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Info Code", "Register No.", "Sales Ticket No.", "Sales Line No.", "Entry No.")
        {
        }
        key(Key2; "Entry No.")
        {
        }
    }

    trigger OnInsert()
    var
        POSInfoTransaction: Record "NPR Archive POS Info Trx";
    begin
        if "Entry No." = 0 then begin
            POSInfoTransaction.SetCurrentKey("Entry No.");
            if POSInfoTransaction.FindLast() then
                "Entry No." := POSInfoTransaction."Entry No." + 1
            else
                "Entry No." := 1;
        end;
    end;
}
