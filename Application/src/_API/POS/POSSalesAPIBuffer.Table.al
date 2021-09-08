table 6014596 "NPR POS Sales API Buffer"
{
    DataClassification = ToBeClassified;
    TableType = Temporary;

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

        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
        }

        field(4; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }

        field(5; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }

        field(6; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Customer Type" = CONST(Ord)) Customer."No."
            ELSE
            IF ("Customer Type" = CONST(Cash)) Contact."No.";
            ValidateTableRelation = false;
        }

        field(15; "Contact No."; Text[30])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(16; Reference; Text[35])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }

        field(106; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Ord,Cash;
        }

        field(109; "Sale type"; Option)
        {
            Caption = 'Sale type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Annullment';
            OptionMembers = Sale,Annullment;
        }

        field(120; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }

        field(128; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }

        field(1550; Password; Code[20])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
        }
        field(1560; "POS Sale System Id"; Guid)
        {
            Caption = 'POS Sale System Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.")
        {
        }

        key(Key2; "POS Sale System Id")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}