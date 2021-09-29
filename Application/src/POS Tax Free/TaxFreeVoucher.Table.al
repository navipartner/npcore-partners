table 6014477 "NPR Tax Free Voucher"
{

    Caption = 'Tax Free Voucher';
    LookupPageID = "NPR Tax Free Voucher";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            MinValue = 1;
            DataClassification = CustomerContent;
        }
        field(2; "External Voucher No."; Text[50])
        {
            Caption = 'External Voucher No.';
            DataClassification = CustomerContent;
        }
        field(3; "External Voucher Barcode"; Text[50])
        {
            Caption = 'External Voucher Barcode';
            DataClassification = CustomerContent;
        }
        field(4; "Issued Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(5; "Issued Time"; Time)
        {
            Caption = 'Created Time';
            DataClassification = CustomerContent;
        }
        field(6; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(7; "Sales Header Type"; Option)
        {
            Caption = 'Sales Header Type';
            Description = 'DEPRECATED';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(8; "Sales Header No."; Code[20])
        {
            Caption = 'Sales Header No.';
            Description = 'DEPRECATED';
            DataClassification = CustomerContent;
        }
        field(9; "Sales Receipt No."; Code[20])
        {
            Caption = 'POS Reciept No.';
            Description = 'DEPRECATED';
            DataClassification = CustomerContent;
        }
        field(10; Print; BLOB)
        {
            Caption = 'Voucher Print';
            DataClassification = CustomerContent;
        }
        field(11; "Total Amount Incl. VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;
        }
        field(12; "Refund Amount"; Decimal)
        {
            Caption = 'Refund Amount';
            DataClassification = CustomerContent;
        }
        field(13; Void; Boolean)
        {
            Caption = 'Voided';
            DataClassification = CustomerContent;
        }
        field(14; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(15; "Handler ID"; Text[30])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Enum "Handler ID Enum"';
            Caption = 'Handler ID';
            DataClassification = CustomerContent;
        }
        field(16; Mode; Option)
        {
            Caption = 'Mode';
            OptionCaption = 'PROD,TEST';
            OptionMembers = PROD,TEST;
            DataClassification = CustomerContent;
        }
        field(17; "Issued By User"; Code[50])
        {
            Caption = 'Issued By User';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "Voided By User"; Code[50])
        {
            Caption = 'Voided By User';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; "Voided Date"; Date)
        {
            Caption = 'Voided Date';
            DataClassification = CustomerContent;
        }
        field(20; "Voided Time"; Time)
        {
            Caption = 'Voided Time';
            DataClassification = CustomerContent;
        }
        field(21; "Service ID"; Integer)
        {
            Caption = 'Service ID';
            DataClassification = CustomerContent;
        }
        field(22; "Print Type"; Option)
        {
            Caption = 'Print Type';
            OptionCaption = 'Thermal,PDF';
            OptionMembers = Thermal,PDF;
            DataClassification = CustomerContent;
        }
        field(40; "Handler ID Enum"; Enum "NPR Tax Free Handler ID")
        {
            Caption = 'Handler ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "External Voucher No.")
        {
        }
        key(Key3; "External Voucher Barcode")
        {
        }
    }
}

