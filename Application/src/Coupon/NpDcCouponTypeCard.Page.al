page 6151590 "NPR NpDc Coupon Type Card"
{
    Extensible = False;
    Caption = 'Coupon Type Card';
    PageType = Card;
    UsageCategory = Administration;

    PromotedActionCategories = 'New,Process,Reports,Manage,Setup';
    SourceTable = "NPR NpDc Coupon Type";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014442)
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
                    field("Discount Type"; Rec."Discount Type")
                    {

                        ToolTip = 'Specifies the value of the Discount Type field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6014439)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 0);
                        field("Discount Amount"; Rec."Discount Amount")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount Amount field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014440)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 1);
                        field("Discount %"; Rec."Discount %")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount % field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Max. Discount Amount"; Rec."Max. Discount Amount")
                        {

                            ToolTip = 'Max. Discount Amount per Sale';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(Control6014443)
                {
                    ShowCaption = false;
                    field("Coupon Qty. (Open)"; Rec."Coupon Qty. (Open)")
                    {

                        ToolTip = 'Specifies the value of the Coupon Qty. (Open) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Arch. Coupon Qty."; Rec."Arch. Coupon Qty.")
                    {

                        ToolTip = 'Specifies the value of the Arch. Coupon Qty. field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Enabled; Rec.Enabled)
                    {

                        ToolTip = 'Specifies the value of the Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Issue Coupon")
            {
                Caption = 'Issue Coupon';
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("Issue Coupon Module"; Rec."Issue Coupon Module")
                    {

                        ToolTip = 'Specifies the value of the Issue Coupon Module field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                group(Control6014427)
                {
                    ShowCaption = false;
                    field("Reference No. Pattern"; Rec."Reference No. Pattern")
                    {

                        ShowMandatory = true;
                        ToolTip = '[S] ~ Coupon No. [AN] ~ Random Char [AN*3] ~ 3 Random Chars';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer No."; Rec."Customer No.")
                    {

                        Caption = 'Customer No.';
                        ToolTip = 'Specifies the value of the Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {

                        ToolTip = 'Specifies the value of the Print Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print on Issue"; Rec."Print on Issue")
                    {

                        ToolTip = 'Specifies the value of the Print on Issue field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Validate Coupon")
            {
                Caption = 'Validate Coupon';
                group(Control6014430)
                {
                    ShowCaption = false;
                    field("Validate Coupon Module"; Rec."Validate Coupon Module")
                    {

                        ToolTip = 'Specifies the value of the Validate Coupon Module field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                group(Control6014431)
                {
                    ShowCaption = false;
                    field("Starting Date"; Rec."Starting Date")
                    {

                        ToolTip = 'Specifies the value of the Starting Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Starting Date Formula"; Rec."Starting Date DateFormula")
                    {

                        ToolTip = 'Specifies the value of the Starting Date Formula  field.';
                        ApplicationArea = All;
                    }
                    field("Ending Date"; Rec."Ending Date")
                    {

                        ToolTip = 'Specifies the value of the Ending Date Formula field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending Date Formula"; Rec."Ending Date DateFormula")
                    {
                        ToolTip = 'Specifies the value of the Ending Date Formula field.';
                        ApplicationArea = All;
                    }
                }
            }
            group("Apply Discount")
            {
                Caption = 'Apply Discount';
                group(Control6014432)
                {
                    ShowCaption = false;
                    field("Apply Discount Module"; Rec."Apply Discount Module")
                    {

                        ToolTip = 'Specifies the value of the Apply Discount Module field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Application Sequence No."; Rec."Application Sequence No.")
                    {

                        ToolTip = 'Specifies the value of the Application Sequence No. field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014433)
                {
                    ShowCaption = false;
                    field("Max Use per Sale"; Rec."Max Use per Sale")
                    {

                        ToolTip = 'Specifies the value of the Max Use per Sale field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Multi-Use Coupon"; Rec."Multi-Use Coupon")
                    {

                        ToolTip = 'Specifies the value of the Multi-Use Coupon field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Multi-Use Qty."; Rec."Multi-Use Qty.")
                    {

                        Caption = 'Multi-Use Qty.';
                        ToolTip = 'Specifies the value of the Multi-Use Qty. field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Issue Coupons")
            {
                Caption = 'Issue Coupons';
                Image = PostedVoucherGroup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Issue Coupons action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                begin
                    NpDcCouponMgt.IssueCoupons(Rec);
                end;
            }
        }
        area(navigation)
        {
            group(Setup)
            {
                action("Setup Issue Coupon")
                {
                    Caption = 'Setup Issue Coupon';
                    Image = VoucherGroup;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasIssueCouponSetup;

                    ToolTip = 'Executes the Setup Issue Coupon action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
                    begin
                        NpDcCouponModuleMgt.OnSetupIssueCoupon(Rec);
                    end;
                }
                action("Setup Validate Coupon")
                {
                    Caption = 'Setup Validate Coupon';
                    Image = RefreshVoucher;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasValidateCouponSetup;

                    ToolTip = 'Executes the Setup Validate Coupon action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
                    begin
                        NpDcCouponModuleMgt.OnSetupValidateCoupon(Rec);
                    end;
                }
                action("Setup Apply Discount")
                {
                    Caption = 'Setup Apply Discount';
                    Image = Voucher;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasApplyDiscountSetup;

                    ToolTip = 'Executes the Setup Apply Discount action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
                    begin
                        NpDcCouponModuleMgt.OnSetupApplyDiscount(Rec);
                    end;
                }
            }
            separator(Separator6014422)
            {
            }
            action(Coupons)
            {
                Caption = 'Coupons';
                Image = Voucher;
                RunObject = Page "NPR NpDc Coupons";
                RunPageLink = "Coupon Type" = FIELD(Code);
                ShortCutKey = 'Ctrl+F7';

                ToolTip = 'Executes the Coupons action';
                ApplicationArea = NPRRetail;
            }
            action(Comments)
            {
                Caption = 'Co&mments';
                Image = ViewComments;
                RunObject = Page "NPR Retail Comments";
                RunPageLink = "Table ID" = CONST(6151590),
                              "No." = FIELD(Code),
                              "No. 2" = FILTER(''),
                              Option = CONST("0"),
                              "Option 2" = CONST("0"),
                              Integer = CONST(0),
                              "Integer 2" = CONST(0);

                ToolTip = 'Executes the Co&mments action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetHasSetup();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        NpDcCouponMgt.InitCouponType(Rec);
    end;

    var
        HasApplyDiscountSetup: Boolean;
        HasIssueCouponSetup: Boolean;
        HasValidateCouponSetup: Boolean;

    local procedure SetHasSetup()
    var
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
    begin
        HasIssueCouponSetup := false;
        NpDcCouponModuleMgt.OnHasIssueCouponSetup(Rec, HasIssueCouponSetup);

        HasValidateCouponSetup := false;
        NpDcCouponModuleMgt.OnHasValidateCouponSetup(Rec, HasValidateCouponSetup);

        HasApplyDiscountSetup := false;
        NpDcCouponModuleMgt.OnHasApplyDiscountSetup(Rec, HasApplyDiscountSetup);

        CurrPage.Update(false);
    end;
}

