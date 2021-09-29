table 6014640 "NPR Tax Free Request"
{
    Caption = 'Tax Free Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Date End"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(3; "Time End"; Time)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(4; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
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
        field(14; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(15; "Handler ID"; Text[30])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with "Enum Handler ID Enum"';
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
        field(17; "Request Type"; Text[30])
        {
            Caption = 'Request Type';
            DataClassification = CustomerContent;
        }
        field(18; Request; BLOB)
        {
            Caption = 'Request';
            DataClassification = CustomerContent;
        }
        field(19; Response; BLOB)
        {
            Caption = 'Response';
            DataClassification = CustomerContent;
        }
        field(20; "Error Code"; Text[30])
        {
            Caption = 'Error Code';
            DataClassification = CustomerContent;
        }
        field(21; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(22; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
        }
        field(23; "External Voucher No."; Text[250])
        {
            Caption = 'External Voucher No.';
            DataClassification = CustomerContent;
        }
        field(24; "External Voucher Barcode"; Text[250])
        {
            Caption = 'External Voucher Barcode';
            DataClassification = CustomerContent;
        }
        field(25; Print; BLOB)
        {
            Caption = 'Print';
            DataClassification = CustomerContent;
        }
        field(26; "Print Type"; Option)
        {
            Caption = 'Print Type';
            OptionCaption = 'Thermal,PDF';
            OptionMembers = Thermal,PDF;
            DataClassification = CustomerContent;
        }
        field(27; "Total Amount Incl. VAT"; Decimal)
        {
            Caption = 'Total Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(28; "Refund Amount"; Decimal)
        {
            Caption = 'Refund Amount';
            DataClassification = CustomerContent;
        }
        field(29; "Date Start"; Date)
        {
            Caption = 'Date Start';
            DataClassification = CustomerContent;
        }
        field(30; "Time Start"; Time)
        {
            Caption = 'Time Start';
            DataClassification = CustomerContent;
        }
        field(31; "Timeout (ms)"; Integer)
        {
            Caption = 'Timeout (ms)';
            DataClassification = CustomerContent;
        }
        field(32; "Service ID"; Integer)
        {
            Caption = 'Service ID';
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
    }
}

