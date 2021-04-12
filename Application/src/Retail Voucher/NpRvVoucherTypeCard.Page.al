page 6151012 "NPR NpRv Voucher Type Card"
{
    UsageCategory = None;
    Caption = 'Retail Voucher Type Card';
    PromotedActionCategories = 'New,Process,Reports,Manage,Setup';
    SourceTable = "NPR NpRv Voucher Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6014420)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                }
                group(Control6014424)
                {
                    ShowCaption = false;
                    field("Voucher Qty. (Open)"; Rec."Voucher Qty. (Open)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Voucher Qty. (Open) field';
                    }
                    field("Voucher Qty. (Closed)"; Rec."Voucher Qty. (Closed)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Voucher Qty. (Closed) field';
                    }
                    field("Arch. Voucher Qty."; Rec."Arch. Voucher Qty.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Archived Voucher Qty. field';
                    }
                }
            }
            group("Send Voucher")
            {
                Caption = 'Send Voucher';
                group(Control6014425)
                {
                    ShowCaption = false;
                    field("Send Voucher Module"; Rec."Send Voucher Module")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send Voucher Module field';
                    }
                    field("Account No."; Rec."Account No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Account No. field';
                    }
                    field("Partner Code"; Rec."Partner Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Partner Code field';
                    }
                    field("Allow Top-up"; Rec."Allow Top-up")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Allow Top-up field';
                    }
                    field("Minimum Amount Issue"; Rec."Minimum Amount Issue")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Minimum Amount Issue field';
                    }
                }
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("No. Series"; Rec."No. Series")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the No. Series field';
                    }
                    field("Arch. No. Series"; Rec."Arch. No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Archivation No. Series field';
                    }
                    field("Reference No. Type"; Rec."Reference No. Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reference No. Type field';
                    }
                    group(Control6014407)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Reference No. Type" = 0);
                        field("Reference No. Pattern"; Rec."Reference No. Pattern")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers || [AN] ~ Random Char || [AN*3] ~ 3 Random Chars';
                        }
                    }
                    group(Control6014405)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Reference No. Type" = 1);
                        field(EAN13ReferenceNoPattern; Rec."Reference No. Pattern")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers';
                        }
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                    }
                    field("E-mail Template Code"; Rec."E-mail Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail Template Code field';
                    }
                    field("SMS Template Code"; Rec."SMS Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the SMS Template Code field';
                    }
                    field("Send Method via POS"; Rec."Send Method via POS")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send Method via POS field';
                    }
                    field("Voucher Message"; Rec."Voucher Message")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'Specifies the value of the Voucher Message field';
                    }
                }
            }
            group("Validate Voucher")
            {
                Caption = 'Validate Voucher';
                group(Control6014427)
                {
                    ShowCaption = false;
                    field("Validate Voucher Module"; Rec."Validate Voucher Module")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Validate Voucher Module field';
                    }
                }
                group(Control6014428)
                {
                    ShowCaption = false;
                    field("Valid Period"; Rec."Valid Period")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Valid Period field';
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module"; Rec."Apply Payment Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Apply Payment Module field';
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Payment Type field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Setup)
            {
                action("Setup Send Voucher")
                {
                    Caption = 'Setup Send Voucher';
                    Image = VoucherGroup;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasIssueVoucherSetup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup Send Voucher action';

                    trigger OnAction()
                    var
                        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
                    begin
                        NpRvModuleMgt.OnSetupSendVoucher(Rec);
                    end;
                }
                action("Setup Validate Voucher")
                {
                    Caption = 'Setup Validate Voucher';
                    Image = RefreshVoucher;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasValidateVoucherSetup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup Validate Voucher action';

                    trigger OnAction()
                    var
                        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
                    begin
                        NpRvModuleMgt.OnSetupValidateVoucher(Rec);
                    end;
                }
                action("Setup Apply Payment")
                {
                    Caption = 'Setup Apply Payment';
                    Image = Voucher;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasApplyPaymentSetup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup Apply Payment action';

                    trigger OnAction()
                    var
                        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
                    begin
                        NpRvModuleMgt.OnSetupApplyPayment(Rec);
                    end;
                }
            }
            separator(Separator6014431)
            {
            }
            action(Vouchers)
            {
                Caption = 'Vouchers';
                Image = Voucher;
                RunObject = Page "NPR NpRv Vouchers";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Vouchers action';
            }
            action("Partner Card")
            {
                Caption = 'Partner Card';
                Image = UserSetup;
                RunObject = Page "NPR NpRv Partner Card";
                RunPageLink = Code = FIELD("Partner Code");
                Visible = Rec."Partner Code" <> '';
                ApplicationArea = All;
                ToolTip = 'Executes the Partner Card action';
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Partner Relations action';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetHasSetup();
    end;

    var
        HasApplyPaymentSetup: Boolean;
        HasIssueVoucherSetup: Boolean;
        HasValidateVoucherSetup: Boolean;

    local procedure SetHasSetup()
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
    begin
        HasIssueVoucherSetup := false;
        NpRvModuleMgt.OnHasSendVoucherSetup(Rec, HasIssueVoucherSetup);

        HasValidateVoucherSetup := false;
        NpRvModuleMgt.OnHasValidateVoucherSetup(Rec, HasValidateVoucherSetup);

        HasApplyPaymentSetup := false;
        NpRvModuleMgt.OnHasApplyPaymentSetup(Rec, HasApplyPaymentSetup);

        CurrPage.Update(false);
    end;
}

