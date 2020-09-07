page 6151012 "NPR NpRv Voucher Type Card"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20190123  CASE 341711 Added fields 75 "E-mail Template Code", 80 "SMS Template Code", 105 "Send Method via POS"
    // NPR5.49/MHA /20190228  CASE 342811 Added field 60 "Partner Code"
    // NPR5.50/MHA /20190426  CASE 353079 Added field 62 "Allow Top-up"
    // NPR5.53/THRO/20191216  CASE 382232 Added "Minimum Amount Issue"
    // NPR5.55/MHA /20200525  CASE 400120 Added field 1010 "Voucher Qty. (Closed)"

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
                    field("Code"; Code)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014424)
                {
                    ShowCaption = false;
                    field("Voucher Qty. (Open)"; "Voucher Qty. (Open)")
                    {
                        ApplicationArea = All;
                    }
                    field("Voucher Qty. (Closed)"; "Voucher Qty. (Closed)")
                    {
                        ApplicationArea = All;
                    }
                    field("Arch. Voucher Qty."; "Arch. Voucher Qty.")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Send Voucher")
            {
                Caption = 'Send Voucher';
                group(Control6014425)
                {
                    ShowCaption = false;
                    field("Send Voucher Module"; "Send Voucher Module")
                    {
                        ApplicationArea = All;
                    }
                    field("Account No."; "Account No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Partner Code"; "Partner Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Allow Top-up"; "Allow Top-up")
                    {
                        ApplicationArea = All;
                    }
                    field("Minimum Amount Issue"; "Minimum Amount Issue")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("No. Series"; "No. Series")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Arch. No. Series"; "Arch. No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("Reference No. Type"; "Reference No. Type")
                    {
                        ApplicationArea = All;
                    }
                    group(Control6014407)
                    {
                        ShowCaption = false;
                        Visible = ("Reference No. Type" = 0);
                        field("Reference No. Pattern"; "Reference No. Pattern")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers || [AN] ~ Random Char || [AN*3] ~ 3 Random Chars';
                        }
                    }
                    group(Control6014405)
                    {
                        ShowCaption = false;
                        Visible = ("Reference No. Type" = 1);
                        field(EAN13ReferenceNoPattern; "Reference No. Pattern")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers';
                        }
                    }
                    field("Print Template Code"; "Print Template Code")
                    {
                        ApplicationArea = All;
                    }
                    field("E-mail Template Code"; "E-mail Template Code")
                    {
                        ApplicationArea = All;
                    }
                    field("SMS Template Code"; "SMS Template Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Send Method via POS"; "Send Method via POS")
                    {
                        ApplicationArea = All;
                    }
                    field("Voucher Message"; "Voucher Message")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                    }
                }
            }
            group("Validate Voucher")
            {
                Caption = 'Validate Voucher';
                group(Control6014427)
                {
                    ShowCaption = false;
                    field("Validate Voucher Module"; "Validate Voucher Module")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014428)
                {
                    ShowCaption = false;
                    field("Valid Period"; "Valid Period")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module"; "Apply Payment Module")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasIssueVoucherSetup;
                    ApplicationArea=All;

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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasValidateVoucherSetup;
                    ApplicationArea=All;

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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasApplyPaymentSetup;
                    ApplicationArea=All;

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
                ApplicationArea=All;
            }
            action("Partner Card")
            {
                Caption = 'Partner Card';
                Image = UserSetup;
                RunObject = Page "NPR NpRv Partner Card";
                RunPageLink = Code = FIELD("Partner Code");
                Visible = "Partner Code" <> '';
                ApplicationArea=All;
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ApplicationArea=All;
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

