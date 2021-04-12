page 6151590 "NPR NpDc Coupon Type Card"
{
    Caption = 'Coupon Type Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    field("Discount Type"; Rec."Discount Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Discount Type field';
                    }
                    group(Control6014439)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 0);
                        field("Discount Amount"; Rec."Discount Amount")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount Amount field';
                        }
                    }
                    group(Control6014440)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 1);
                        field("Discount %"; Rec."Discount %")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount % field';
                        }
                        field("Max. Discount Amount"; Rec."Max. Discount Amount")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Max. Discount Amount per Sale';
                        }
                    }
                    field(Enabled; Rec.Enabled)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enabled field';
                    }
                }
                group(Control6014443)
                {
                    ShowCaption = false;
                    field("Coupon Qty. (Open)"; Rec."Coupon Qty. (Open)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Coupon Qty. (Open) field';
                    }
                    field("Arch. Coupon Qty."; Rec."Arch. Coupon Qty.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Arch. Coupon Qty. field';
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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Coupon Module field';

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
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = '[S] ~ Coupon No. [AN] ~ Random Char [AN*3] ~ 3 Random Chars';
                    }
                    field("Customer No."; Rec."Customer No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                    }
                    field("Print on Issue"; Rec."Print on Issue")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print on Issue field';
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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Validate Coupon Module field';

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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Starting Date field';
                    }
                    field("Ending Date"; Rec."Ending Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ending Date field';
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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Apply Discount Module field';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Application Sequence No."; Rec."Application Sequence No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Application Sequence No. field';
                    }
                }
                group(Control6014433)
                {
                    ShowCaption = false;
                    field("Max Use per Sale"; Rec."Max Use per Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Max Use per Sale field';
                    }
                    field("Multi-Use Coupon"; Rec."Multi-Use Coupon")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Multi-Use Coupon field';
                    }
                    field("Multi-Use Qty."; Rec."Multi-Use Qty.")
                    {
                        ApplicationArea = All;
                        Caption = 'Multi-Use Qty.';
                        ToolTip = 'Specifies the value of the Multi-Use Qty. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Issue Coupons action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup Issue Coupon action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup Validate Coupon action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup Apply Discount action';

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
                ToolTip = 'Executes the Coupons action';
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
                ToolTip = 'Executes the Co&mments action';
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

