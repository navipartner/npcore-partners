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
                    ToolTip = 'Specifies the code value associated with the Voucher Type';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the Voucher Type';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code of the No. Series field for the Voucher Type';
                }
                field("Arch. No. Series"; Rec."Arch. No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Archivation No. Series field';
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
                field("Valid Period"; Rec."Valid Period")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Valid Period field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Account No. field';
                }
                field("Allow Top-up"; Rec."Allow Top-up")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Allow Top-up field.';
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Type field.';
                }
                field("Apply Payment Module"; Rec."Apply Payment Module")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Apply Payment Module field.';
                }
                field("Return Voucher Type"; Rec."Return Voucher Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Return Voucher Type field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        RetailVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if not Rec.IsEmpty() then
            Rec.DeleteAll();
        if RetailVoucherType.FindSet() then
            repeat
                if not Rec.Get(RetailVoucherType.Code) then begin
                    Rec := RetailVoucherType;
                    Rec.Insert();
                end;
            until RetailVoucherType.Next() = 0;
    end;

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
}