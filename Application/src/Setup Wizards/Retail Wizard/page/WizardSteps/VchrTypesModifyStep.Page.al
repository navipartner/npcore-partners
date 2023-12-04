page 6150794 "NPR Vchr. Types Modify Step"
{
    Caption = 'Retail Voucher Types';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR NpRv Voucher Type";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code value associated with the Voucher Type';
                }
                field("Voucher Category"; Rec."Voucher Category")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the category of vouchers of this type. Voucher categories are used for reporting purposes.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the Voucher Type';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Account No. field';
                }
                field("Reference No. Type"; Rec."Reference No. Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reference No. Type field';
                }
                field("Reference No. Pattern"; Rec."Reference No. Pattern")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers || [AN] ~ Random Char || [AN*3] ~ 3 Random Chars';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code of the No. Series field for the Voucher Type';
                }
                field("Arch. No. Series"; Rec."Arch. No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Archivation No. Series field';
                }
                field("Print Template Code"; Rec."Print Template Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Print Template Code field';
                }
            }
        }
    }

    internal procedure CopyTemp(var TempNpRvVoucherType: Record "NPR NpRv Voucher Type" temporary)
    begin
        if TempNpRvVoucherType.IsEmpty() then
            exit;

        TempNpRvVoucherType.FindSet();
        repeat
            Rec := TempNpRvVoucherType;
            if Rec.Insert() then;
        until TempNpRvVoucherType.Next() = 0;
    end;

    internal procedure CreateRetailVoucherTypesData()
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if Rec.IsEmpty() then
            exit;

        Rec.FindSet();
        repeat
            NpRvVoucherType := Rec;
            if not NpRvVoucherType.Insert() then
                NpRvVoucherType.Modify();
        until Rec.Next() = 0;
    end;

    internal procedure MandatoryFieldsPopulated(): Boolean
    begin
        if Rec.IsEmpty() then
            exit;

        Rec.FindSet();
        repeat
            if Rec.Code = '' then
                exit(false);

            if Rec."No. Series" = '' then
                exit(false);

            if Rec."Arch. No. Series" = '' then
                exit(false);

            if Rec."Account No." = '' then
                exit(false);

            if Rec."Print Template Code" = '' then
                exit(false);

            if Rec."Voucher Category" = Rec."Voucher Category"::" " then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;
}