table 6151002 "NPR POS Saved Sale Entry"
{
    Caption = 'POS Saved Sale Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Saved Sales";
    LookupPageID = "NPR POS Saved Sales";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Created at"; DateTime)
        {
            Caption = 'Created at';
            DataClassification = CustomerContent;
        }
        field(10; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(15; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(25; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            OptionCaption = 'Customer,Contact';
            OptionMembers = Customer,Contact;
        }
        field(30; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = IF ("Customer Type" = CONST(Customer)) Customer."No."
            ELSE
            IF ("Customer Type" = CONST(Contact)) Contact."No.";
        }
        field(35; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "Customer Price Group";
        }
        field(40; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "Customer Discount Group";
        }
        field(45; Attention; Text[30])
        {
            Caption = 'Attention';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(50; Reference; Text[30])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(60; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Use SystemId instead';
        }
        field(200; "POS Sales Data"; BLOB)
        {
            Caption = 'POS Sales Data';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(1000; Amount; Decimal)
        {
            CalcFormula = Sum("NPR POS Saved Sale Line".Amount WHERE("Quote Entry No." = FIELD("Entry No."),
                                                             "Sale Type" = FILTER(Sale | "Debit Sale" | Deposit),
                                                             Type = FILTER(<> Comment & <> "Open/Close")));
            Caption = 'Amount';
            DecimalPlaces = 2 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005; "Amount Including VAT"; Decimal)
        {
            CalcFormula = Sum("NPR POS Saved Sale Line"."Amount Including VAT" WHERE("Quote Entry No." = FIELD("Entry No."),
                                                                             "Sale Type" = FILTER(Sale | "Debit Sale" | Deposit),
                                                                             Type = FILTER(<> Comment & <> "Open/Close")));
            Caption = 'Amount Including VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Contains EFT Approval"; Boolean)
        {
            CalcFormula = Exist("NPR POS Saved Sale Line" WHERE("Quote Entry No." = FIELD("Entry No."),
                                                        "EFT Approved" = CONST(true)));
            Caption = 'Contains EFT Approval';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POSQuoteLine: Record "NPR POS Saved Sale Line";
    begin
        POSQuoteLine.SetRange("Quote Entry No.", "Entry No.");
        POSQuoteLine.DeleteAll(not SkipLineDeleteTriggerValue);
    end;

    var
        SkipLineDeleteTriggerValue: Boolean;

    procedure SkipLineDeleteTrigger(Value: Boolean)
    begin
        SkipLineDeleteTriggerValue := Value;
    end;
}

