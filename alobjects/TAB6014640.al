table 6014640 "Tax Free Request"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Request';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"Date End";Date)
        {
            Caption = 'Date';
        }
        field(3;"Time End";Time)
        {
            Caption = 'Time';
        }
        field(4;"User ID";Code[50])
        {
            Caption = 'User ID';
        }
        field(6;"Salesperson Code";Code[20])
        {
            Caption = 'Salesperson Code';
        }
        field(7;"Sales Header Type";Option)
        {
            Caption = 'Sales Header Type';
            Description = 'DEPRECATED';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(8;"Sales Header No.";Code[20])
        {
            Caption = 'Sales Header No.';
            Description = 'DEPRECATED';
        }
        field(9;"Sales Receipt No.";Code[20])
        {
            Caption = 'POS Reciept No.';
            Description = 'DEPRECATED';
        }
        field(14;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
        }
        field(15;"Handler ID";Text[30])
        {
            Caption = 'Handler ID';
        }
        field(16;Mode;Option)
        {
            Caption = 'Mode';
            OptionCaption = 'PROD,TEST';
            OptionMembers = PROD,TEST;
        }
        field(17;"Request Type";Text[30])
        {
            Caption = 'Request Type';
        }
        field(18;Request;BLOB)
        {
            Caption = 'Request';
        }
        field(19;Response;BLOB)
        {
            Caption = 'Response';
        }
        field(20;"Error Code";Text[30])
        {
            Caption = 'Error Code';
        }
        field(21;"Error Message";Text[250])
        {
            Caption = 'Error Message';
        }
        field(22;Success;Boolean)
        {
            Caption = 'Success';
        }
        field(23;"External Voucher No.";Text[250])
        {
            Caption = 'External Voucher No.';
        }
        field(24;"External Voucher Barcode";Text[250])
        {
            Caption = 'External Voucher Barcode';
        }
        field(25;Print;BLOB)
        {
            Caption = 'Print';
        }
        field(26;"Print Type";Option)
        {
            Caption = 'Print Type';
            OptionCaption = 'Thermal,PDF';
            OptionMembers = Thermal,PDF;
        }
        field(27;"Total Amount Incl. VAT";Decimal)
        {
            Caption = 'Total Amount Incl. VAT';
        }
        field(28;"Refund Amount";Decimal)
        {
            Caption = 'Refund Amount';
        }
        field(29;"Date Start";Date)
        {
            Caption = 'Date Start';
        }
        field(30;"Time Start";Time)
        {
            Caption = 'Time Start';
        }
        field(31;"Timeout (ms)";Integer)
        {
            Caption = 'Timeout (ms)';
        }
        field(32;"Service ID";Integer)
        {
            Caption = 'Service ID';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure IsThisHandler(HandlerID: Text): Boolean
    begin
        exit("Handler ID" = HandlerID);
    end;
}

