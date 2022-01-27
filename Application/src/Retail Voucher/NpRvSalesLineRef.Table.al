table 6151017 "NPR NpRv Sales Line Ref."
{
    Access = Internal;
    Caption = 'Retail Voucher Sales Line Reference';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpRv Sales Line Ref.";
    LookupPageID = "NPR NpRv Sales Line Ref.";

    fields
    {
        field(1; Id; Guid)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Sales Line Id"; Guid)
        {
            Caption = 'Sales Line Id';
            DataClassification = CustomerContent;
        }
        field(20; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
        }
        field(30; "Reference No."; Text[50])
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
        key(Key1; Id)
        {
        }
        key(Key2; "Sales Line Id", "Voucher No.", "Reference No.")
        {
        }
    }

    trigger OnInsert()
    begin
        if IsNullGuid(Id) then
            Id := CreateGuid();
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
        if Voucher.FindFirst() then
            Error(Text000, "Reference No.");
    end;
}

