table 6014477 "Tax Free Voucher"
{
    // NPR4.18/MMV/20160113 CASE 224257 Created table
    // NPR4.21/MMV/20160223 CASE 224257 Added missing danish captions
    // NPR5.30/MMV /20170127 CASE 261964 Added fields 14, 15, 16.
    //                                   Renamed field 10.
    //                                   Added LookupPageID.
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Voucher';
    LookupPageID = "Tax Free Voucher";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            MinValue = 1;
        }
        field(2;"External Voucher No.";Text[50])
        {
            Caption = 'External Voucher No.';
        }
        field(3;"External Voucher Barcode";Text[50])
        {
            Caption = 'External Voucher Barcode';
        }
        field(4;"Issued Date";Date)
        {
            Caption = 'Created Date';
        }
        field(5;"Issued Time";Time)
        {
            Caption = 'Created Time';
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
        field(10;Print;BLOB)
        {
            Caption = 'Voucher Print';
        }
        field(11;"Total Amount Incl. VAT";Decimal)
        {
            Caption = 'Amount Including VAT';
        }
        field(12;"Refund Amount";Decimal)
        {
            Caption = 'Refund Amount';
        }
        field(13;Void;Boolean)
        {
            Caption = 'Voided';
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
        field(17;"Issued By User";Code[50])
        {
            Caption = 'Issued By User';
        }
        field(18;"Voided By User";Code[50])
        {
            Caption = 'Voided By User';
        }
        field(19;"Voided Date";Date)
        {
            Caption = 'Voided Date';
        }
        field(20;"Voided Time";Time)
        {
            Caption = 'Voided Time';
        }
        field(21;"Service ID";Integer)
        {
            Caption = 'Service ID';
        }
        field(22;"Print Type";Option)
        {
            Caption = 'Print Type';
            OptionCaption = 'Thermal,PDF';
            OptionMembers = Thermal,PDF;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"External Voucher No.")
        {
        }
        key(Key3;"External Voucher Barcode")
        {
        }
    }

    fieldgroups
    {
    }
}

