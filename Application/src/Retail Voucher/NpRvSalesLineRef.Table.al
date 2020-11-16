table 6151017 "NPR NpRv Sales Line Ref."
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.54/MHA /20200310  CASE 372135 Added field 50 "Voucher No."
    // NPR5.55/MHA /20200512  CASE 402015 Changed Primary key, Restructured fields and updated Object Name

    Caption = 'Retail Voucher Sales Line Reference';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Sales Line Ref.";
    LookupPageID = "NPR NpRv Sales Line Ref.";

    fields
    {
        field(1; Id; Guid)
        {
            Description = 'NPR5.55';
            DataClassification = CustomerContent;
        }
        field(10; "Sales Line Id"; Guid)
        {
            Caption = 'Sales Line Id';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(20; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(30; "Reference No."; Text[30])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';

            trigger OnValidate()
            begin
                TestReferenceNo();
            end;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
        key(Key2; "Sales Line Id", "Voucher No.", "Reference No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if IsNullGuid(Id) then
            Id := CreateGuid;
    end;

    var
        Text000: Label 'Reference No. %1 is already used';

    local procedure TestReferenceNo()
    var
        Voucher: Record "NPR NpRv Voucher";
    begin
        if "Reference No." = '' then
            exit;

        Voucher.SetRange("Reference No.", "Reference No.");
        if Voucher.FindFirst then
            Error(Text000, "Reference No.");
    end;
}

