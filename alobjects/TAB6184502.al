table 6184502 "CleanCash Audit Roll"
{
    // NPR4.21/JHL/20160302 CASE 222417 Table created to handle CleanCash Audit Roll
    // NPR5.29/JHL/20161028 CASE 256695 Inserted the field "CleanCash Register No."
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name

    Caption = 'CleanCash Audit Roll';

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
        }
        field(2;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(3;"Sale Date";Date)
        {
            Caption = 'Sale Date';
        }
        field(4;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Sale,Return';
            OptionMembers = Sale,Return;
        }
        field(5;"Receipt Type";Code[30])
        {
            Caption = 'Receipt Type';
        }
        field(6;"Receipt Total";Decimal)
        {
            Caption = 'Receipt Total';
        }
        field(7;"Receipt Total Neg";Decimal)
        {
            Caption = 'Receipt Total Neg';
        }
        field(8;"Receipt Time";Text[100])
        {
            Caption = 'Receipt Time';
        }
        field(9;VatRate1;Decimal)
        {
            Caption = 'Vat Rate 1';
        }
        field(10;VatAmount1;Decimal)
        {
            Caption = 'Vat Amount 1';
        }
        field(11;VatRate2;Decimal)
        {
            Caption = 'Vat Rate 2';
        }
        field(12;VatAmount2;Decimal)
        {
            Caption = 'Vat Amount 2';
        }
        field(13;VatRate3;Decimal)
        {
            Caption = 'Vat Rate 3';
        }
        field(14;VatAmount3;Decimal)
        {
            Caption = 'Vat Amount 3';
        }
        field(15;VatRate4;Decimal)
        {
            Caption = 'Vat Rate 4';
        }
        field(16;VatAmount4;Decimal)
        {
            Caption = 'Vat Amount 4';
        }
        field(17;"Sales Ticket Type";Option)
        {
            Caption = 'Sales Ticket Type';
            OptionCaption = 'Sale,Mix,Return';
            OptionMembers = Sale,Mix,Return;
        }
        field(18;"Closing Time";Time)
        {
            Caption = 'Closing Time';
        }
        field(29;"CleanCash Register No.";Text[16])
        {
            Caption = 'CleanCash Cash Register No.';
        }
        field(30;"CleanCash Reciept No.";Code[10])
        {
            Caption = 'CleanCash Reciept No.';
        }
        field(31;"CleanCash Serial No.";Text[30])
        {
            Caption = 'CleanCash Serial No.';
        }
        field(32;"CleanCash Control Code";Text[100])
        {
            Caption = 'CleanCash Control Code';
        }
        field(33;"CleanCash Copy Serial No.";Text[30])
        {
            Caption = 'CleanCash Copy Serial No.';
        }
        field(34;"CleanCash Copy Control Code";Text[100])
        {
            Caption = 'CleanCash Copy Control Code';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Date",Type)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        CleanCashSetup: Record "CleanCash Setup";
    begin
    end;
}

