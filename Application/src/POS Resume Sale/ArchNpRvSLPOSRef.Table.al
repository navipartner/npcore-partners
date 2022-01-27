table 6014493 "NPR Arch. NpRv SL POS Ref."
{
    Access = Internal;
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved to archive tables
    //   The table may be deleted later, when it is no longer relevant.

    Caption = 'Sale Line POS Retail Voucher Reference';
    DrillDownPageID = "NPR NpRv Sales Line Ref.";
    LookupPageID = "NPR NpRv Sales Line Ref.";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            NotBlank = true;
            TableRelation = "NPR POS Unit";
            DataClassification = CustomerContent;
        }
        field(5; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(10; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
            DataClassification = CustomerContent;
        }
        field(15; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(20; "Sale Line No."; Integer)
        {
            Caption = 'Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(25; "Voucher Line No."; Integer)
        {
            Caption = 'Voucher Line No.';
            DataClassification = CustomerContent;
        }
        field(30; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(60; "Reference No."; Text[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestReferenceNo();
            end;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Voucher Line No.", "Line No.")
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
        Voucher: Record "NPR NpRv Voucher";
    begin
        if "Reference No." = '' then
            exit;

        Voucher.SetRange("Reference No.", "Reference No.");
        if Voucher.FindFirst() then
            Error(Text000, "Reference No.");
    end;
}

