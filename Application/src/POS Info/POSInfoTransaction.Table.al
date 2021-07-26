table 6150644 "NPR POS Info Transaction"
{
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
            DataClassification = CustomerContent;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        }
        field(6; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Info";
        }
        field(11; "POS Info"; Text[250])
        {
            Caption = 'POS Info';
            DataClassification = CustomerContent;
        }
        field(12; "POS Info Type"; Option)
        {
            Caption = 'POS Info Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            OptionCaption = 'Show Message,Request Data,Write Default Message';
            OptionMembers = "Show Message","Request Data","Write Default Message";
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
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
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
        key(Key3; "Register No.", "Sales Ticket No.", "Sales Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        if "Entry No." = 0 then begin
            POSInfoTransaction.SetCurrentKey("Entry No.");
            if POSInfoTransaction.FindLast() then
                "Entry No." := POSInfoTransaction."Entry No." + 1
            else
                "Entry No." := 1;
        end;
    end;

    procedure CopyFromPOSInfo(POSInfo: Record "NPR POS Info")
    begin
        //-NPR5.53 [388697]
        "POS Info Code" := POSInfo.Code;
        "POS Info Type" := POSInfo.Type;
        "Once per Transaction" := POSInfo."Once per Transaction";
        //+NPR5.53 [388697]
    end;

    procedure ShowMessage()
    begin
        //-NPR5.53 [388697]
        if ("POS Info Type" = "POS Info Type"::"Show Message") and ("POS Info" <> '') then
            Message("POS Info");
        //+NPR5.53 [388697]
    end;
}

