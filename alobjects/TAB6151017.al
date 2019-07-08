table 6151017 "NpRv Sale Line POS Reference"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher

    Caption = 'Sale Line POS Retail Voucher Reference';
    DrillDownPageID = "NpRv POS Issue Voucher Refs.";
    LookupPageID = "NpRv POS Issue Voucher Refs.";

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = Register;
        }
        field(5;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(10;"Sale Type";Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(15;"Sale Date";Date)
        {
            Caption = 'Sale Date';
        }
        field(20;"Sale Line No.";Integer)
        {
            Caption = 'Sale Line No.';
        }
        field(25;"Voucher Line No.";Integer)
        {
            Caption = 'Voucher Line No.';
        }
        field(30;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(60;"Reference No.";Text[30])
        {
            Caption = 'Reference No.';

            trigger OnValidate()
            begin
                TestReferenceNo();
            end;
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Type","Sale Date","Sale Line No.","Voucher Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text000: Label 'Reference No. %1 is already used';

    local procedure TestReferenceNo()
    var
        Voucher: Record "NpRv Voucher";
    begin
        if "Reference No." = '' then
          exit;

        Voucher.SetRange("Reference No.","Reference No.");
        if Voucher.FindFirst then
          Error(Text000,"Reference No.");
    end;
}

