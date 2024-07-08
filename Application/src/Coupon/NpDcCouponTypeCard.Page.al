page 6151590 "NPR NpDc Coupon Type Card"
{
    Extensible = False;
    Caption = 'Coupon Type Card';
    ContextSensitiveHelpPage = 'docs/retail/coupons/reference/coupon_types/';
    PageType = Card;
    UsageCategory = None;

    PromotedActionCategories = 'New,Process,Reports,Manage,Setup';
    SourceTable = "NPR NpDc Coupon Type";
#if NOT BC17
    AboutTitle = 'Coupon Type';
    AboutText = 'This card is used to access and manage NpDc Coupon Types. These coupon types are used to create, issue, validate, and apply discounts to transactions. Customize coupon types based on your promotional needs to enhance customer experience and boost sales.';
#endif

    layout
    {
        area(content)
        {
            group(General)
            {
#if NOT BC17
                AboutTitle = 'General Information';
                AboutText = 'This section is used to view general information about the NPR NpDc Coupon Type. This includes details such as its name, description, and any relevant information that sets it apart from other coupon types.';
#endif
                group(Control6014442)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the unique code for coupon.';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the short description of a coupon.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Discount Type"; Rec."Discount Type")
                    {

                        ToolTip = 'You can choose between two methods of conveying discounts - Discount amount or Discount %.';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6014439)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 0);
                        field("Discount Amount"; Rec."Discount Amount")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the amount that will be on the coupon.';
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
                            ToolTip = 'Specifies the discount percentage that the customer gets with the coupon.';
                            ApplicationArea = NPRRetail;
                        }
                        field("Max. Discount Amount"; Rec."Max. Discount Amount")
                        {

                            ToolTip = 'Specifies the maximum amount on which the discount will be calculated.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(Control6014443)
                {
                    ShowCaption = false;
                    field("POS Store Group"; Rec."POS Store Group")
                    {
                        ToolTip = 'Specifies the group of POS Stores where the coupon can be used.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Coupon Qty. (Open)"; Rec."Coupon Qty. (Open)")
                    {
                        ToolTip = 'Specifies the number of open coupons.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Arch. Coupon Qty."; Rec."Arch. Coupon Qty.")
                    {
                        ToolTip = 'Specifies the number of archived coupons.';
                        ApplicationArea = NPRRetail;
                    }
                    field(Enabled; Rec.Enabled)
                    {
                        ToolTip = 'Enable if the coupon is in use.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Issue Coupon")
            {
                Caption = 'Issue Coupon';
#if NOT BC17
                AboutTitle = 'Issue Coupon';
                AboutText = 'This section is used to create and issue new coupons. You can generate and distribute coupons to customers based on specific criteria or promotions. Ensure your coupons are set up correctly to apply discounts accurately.';
#endif
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("Issue Coupon Module"; Rec."Issue Coupon Module")
                    {

                        ToolTip = 'Specifies whether the coupon is issued manually, automatically (during a sale) or when a member has accumulated enough points for it.';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Match POS Store Group"; Rec."Match POS Store Group")
                    {
                        ToolTip = 'Specifies the behavior of generating Coupon when Issue Coupon Module is On-Sale, if Match is selected, only from Stores that match POS Store Group coupon will be generated.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014427)
                {
                    ShowCaption = false;
                    field("Reference No. Pattern"; Rec."Reference No. Pattern")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the pattern used to create the coupon external number, which will later be scanned ([S] ~ Coupon No. [AN] ~ Random Char [AN*3] ~ 3 Random Chars).';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer No."; Rec."Customer No.")
                    {

                        Caption = 'Customer No.';
                        ToolTip = 'Specifies the number used for making the coupon tracking easier for a customer.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Object Type"; Rec."Print Object Type")
                    {
                        ToolTip = 'Specifies the template which will be printed for the coupon.';
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
                        ToolTip = 'Specifies the template which will be printed for the coupon.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print on Issue"; Rec."Print on Issue")
                    {

                        ToolTip = 'Specifies if the coupon is printed automatically after being issued.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Validate Coupon")
            {
                Caption = 'Validate Coupon';
#if NOT BC17
                AboutTitle = 'Validate Coupon';
                AboutText = 'This section allows you to validate coupons presented by customers during transactions. Verify that the coupon''s conditions are met and that it is still valid for use. Ensure smooth customer experience by confirming coupon eligibility.';
#endif
                group(Control6014430)
                {
                    ShowCaption = false;
                    field("Validate Coupon Module"; Rec."Validate Coupon Module")
                    {

                        ToolTip = 'Specifies how the coupon validation is performed.';
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

                        ToolTip = 'Specifies the date from which the coupon becomes valid.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Starting Date Formula"; Rec."Starting Date DateFormula")
                    {

                        ToolTip = 'Specifies the date until which the coupon is valid.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending Date"; Rec."Ending Date")
                    {

                        ToolTip = 'Specifies the formula which calculates the date from which the coupon becomes valid.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending Date Formula"; Rec."Ending Date DateFormula")
                    {
                        ToolTip = 'Specifies the formula which calculates the date until which the coupon is valid..';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Apply Discount")
            {
                Caption = 'Apply Discount';
#if NOT BC17
                AboutTitle = 'Apply Discount';
                AboutText = 'Use this section to apply discounts to transactions using validated coupons. Configure the system to automatically calculate and subtract discounts, providing customers with cost savings as intended.';
#endif
                group(Control6014432)
                {
                    ShowCaption = false;
                    field("Apply Discount Module"; Rec."Apply Discount Module")
                    {

                        ToolTip = 'Specifies the discount module which will be used. A coupon can be given according to settings on the coupon itself, according to settings set on the Items list, ';
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

                        ToolTip = 'Specifies the maximum number of coupon uses per sale.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Multi-Use Coupon"; Rec."Multi-Use Coupon")
                    {

                        ToolTip = 'Specifies if the coupon can be used more than once this field needs to be checked.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Multi-Use Qty."; Rec."Multi-Use Qty.")
                    {

                        Caption = 'Multi-Use Qty.';
                        ToolTip = 'Specifies the number of times a customer is allowed to use the coupon.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(GS1)
            {
                Visible = GS1Type;
                field("GS1 Account No.";
                Rec."GS1 Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the GS1 Account No. field.';
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
        PrintUsingTemplate: Boolean;
        GS1Type: Boolean;

    local procedure SetHasSetup()
    var
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
        ModuleApplyGS1: Codeunit "NPR NpDc Module Apply GS1";
    begin
        HasIssueCouponSetup := false;
        NpDcCouponModuleMgt.OnHasIssueCouponSetup(Rec, HasIssueCouponSetup);

        HasValidateCouponSetup := false;
        NpDcCouponModuleMgt.OnHasValidateCouponSetup(Rec, HasValidateCouponSetup);

        HasApplyDiscountSetup := false;
        NpDcCouponModuleMgt.OnHasApplyDiscountSetup(Rec, HasApplyDiscountSetup);
        GS1Type := Rec."Apply Discount Module" = ModuleApplyGS1.ModuleCode();
        CurrPage.Update(false);
    end;

    local procedure UpdateControls()
    begin
        PrintUsingTemplate := Rec."Print Object Type" = Rec."Print Object Type"::Template;
    end;
}

