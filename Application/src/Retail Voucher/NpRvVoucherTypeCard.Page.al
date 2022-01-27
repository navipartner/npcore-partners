page 6151012 "NPR NpRv Voucher Type Card"
{
    Extensible = False;
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

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014424)
                {
                    ShowCaption = false;
                    field("Voucher Qty. (Open)"; Rec."Voucher Qty. (Open)")
                    {

                        ToolTip = 'Specifies the value of the Voucher Qty. (Open) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Qty. (Closed)"; Rec."Voucher Qty. (Closed)")
                    {

                        ToolTip = 'Specifies the value of the Voucher Qty. (Closed) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Arch. Voucher Qty."; Rec."Arch. Voucher Qty.")
                    {

                        ToolTip = 'Specifies the value of the Archived Voucher Qty. field';
                        ApplicationArea = NPRRetail;
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

                        ToolTip = 'Specifies the value of the Send Voucher Module field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Account No."; Rec."Account No.")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Account No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Partner Code"; Rec."Partner Code")
                    {

                        ToolTip = 'Specifies the value of the Partner Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Allow Top-up"; Rec."Allow Top-up")
                    {

                        ToolTip = 'Specifies the value of the Allow Top-up field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Minimum Amount Issue"; Rec."Minimum Amount Issue")
                    {

                        ToolTip = 'Specifies the value of the Minimum Amount Issue field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("No. Series"; Rec."No. Series")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the No. Series field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Arch. No. Series"; Rec."Arch. No. Series")
                    {

                        ToolTip = 'Specifies the value of the Archivation No. Series field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Reference No. Type"; Rec."Reference No. Type")
                    {

                        ToolTip = 'Specifies the value of the Reference No. Type field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6014407)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Reference No. Type" = 0);
                        field("Reference No. Pattern"; Rec."Reference No. Pattern")
                        {

                            ShowMandatory = true;
                            ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers || [AN] ~ Random Char || [AN*3] ~ 3 Random Chars';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014405)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Reference No. Type" = 1);
                        field(EAN13ReferenceNoPattern; Rec."Reference No. Pattern")
                        {

                            ShowMandatory = true;
                            ToolTip = '[S] ~ Voucher No. || [N] ~ Random Number || [N*3] ~ 3 Random Numbers';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(OutputMethod)
                {
                    ShowCaption = false;
                    field("Print Object Type"; Rec."Print Object Type")
                    {
                        ToolTip = 'Specifies the print object type for the voucher type';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            UpdateControls();
                        end;
                    }
                    field("Print Object ID"; Rec."Print Object ID")
                    {
                        Enabled = not PrintUsingTemplate;
                        ToolTip = 'Specifies the print object Id for the voucher type';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {
                        Enabled = PrintUsingTemplate;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template Code"; Rec."E-mail Template Code")
                    {

                        ToolTip = 'Specifies the value of the E-mail Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("SMS Template Code"; Rec."SMS Template Code")
                    {

                        ToolTip = 'Specifies the value of the SMS Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Send Method via POS"; Rec."Send Method via POS")
                    {

                        ToolTip = 'Specifies the value of the Send Method via POS field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Message"; Rec."Voucher Message")
                    {

                        MultiLine = true;
                        ToolTip = 'Specifies the value of the Voucher Message field';
                        ApplicationArea = NPRRetail;
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

                        ToolTip = 'Specifies the value of the Validate Voucher Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014428)
                {
                    ShowCaption = false;
                    field("Valid Period"; Rec."Valid Period")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Valid Period field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module"; Rec."Apply Payment Module")
                {
                    ToolTip = 'Specifies the value of the Apply Payment Module field';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        if Rec."Apply Payment Module" <> xRec."Apply Payment Module" then
                            CurrPage.Update();
                    end;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Payment Type field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Setup Send Voucher action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Setup Validate Voucher action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Setup Apply Payment action';
                    ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Vouchers action';
                ApplicationArea = NPRRetail;
            }
            action("Partner Card")
            {
                Caption = 'Partner Card';
                Image = UserSetup;
                RunObject = Page "NPR NpRv Partner Card";
                RunPageLink = Code = FIELD("Partner Code");
                Visible = Rec."Partner Code" <> '';

                ToolTip = 'Executes the Partner Card action';
                ApplicationArea = NPRRetail;
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);

                ToolTip = 'Executes the Partner Relations action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetHasSetup();
        UpdateControls();
    end;

    var
        HasApplyPaymentSetup: Boolean;
        HasIssueVoucherSetup: Boolean;
        HasValidateVoucherSetup: Boolean;
        PrintUsingTemplate: Boolean;

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

    local procedure UpdateControls()
    begin
        PrintUsingTemplate := Rec."Print Object Type" = Rec."Print Object Type"::Template;
    end;
}
