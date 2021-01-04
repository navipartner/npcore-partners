page 6151590 "NPR NpDc Coupon Type Card"
{
    Caption = 'Coupon Type Card';
    PageType = Card;
    UsageCategory = Administration;
    PromotedActionCategories = 'New,Process,Reports,Manage,Setup';
    SourceTable = "NPR NpDc Coupon Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014442)
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
                    field("Discount Type"; "Discount Type")
                    {
                        ApplicationArea = All;
                    }
                    group(Control6014439)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type" = 0);
                        field("Discount Amount"; "Discount Amount")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                        }
                    }
                    group(Control6014440)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type" = 1);
                        field("Discount %"; "Discount %")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                        }
                        field("Max. Discount Amount"; "Max. Discount Amount")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Max. Discount Amount per Sale';
                        }
                    }
                    field(Enabled; Enabled)
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014443)
                {
                    ShowCaption = false;
                    field("Coupon Qty. (Open)"; "Coupon Qty. (Open)")
                    {
                        ApplicationArea = All;
                    }
                    field("Arch. Coupon Qty."; "Arch. Coupon Qty.")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Issue Coupon")
            {
                Caption = 'Issue Coupon';
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("Issue Coupon Module"; "Issue Coupon Module")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                group(Control6014427)
                {
                    ShowCaption = false;
                    field("Reference No. Pattern"; "Reference No. Pattern")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = '[S] ~ Coupon No. [AN] ~ Random Char [AN*3] ~ 3 Random Chars';
                    }
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                    }
                    field("Print Template Code"; "Print Template Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Print on Issue"; "Print on Issue")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Validate Coupon")
            {
                Caption = 'Validate Coupon';
                group(Control6014430)
                {
                    ShowCaption = false;
                    field("Validate Coupon Module"; "Validate Coupon Module")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                group(Control6014431)
                {
                    ShowCaption = false;
                    field("Starting Date"; "Starting Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Ending Date"; "Ending Date")
                    {
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
                    field("Apply Discount Module"; "Apply Discount Module")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Application Sequence No."; "Application Sequence No.")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014433)
                {
                    ShowCaption = false;
                    field("Max Use per Sale"; "Max Use per Sale")
                    {
                        ApplicationArea = All;
                    }
                    field("Multi-Use Coupon"; "Multi-Use Coupon")
                    {
                        ApplicationArea = All;
                    }
                    field("Multi-Use Qty."; "Multi-Use Qty.")
                    {
                        ApplicationArea = All;
                        Caption = 'Multi-Use Qty.';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasIssueCouponSetup;
                    ApplicationArea = All;

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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasValidateCouponSetup;
                    ApplicationArea = All;

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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = HasApplyDiscountSetup;
                    ApplicationArea = All;

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
                ApplicationArea = All;
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
                ApplicationArea = All;
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

