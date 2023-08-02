page 6151592 "NPR NpDc Coupon Card"
{
    Extensible = False;
    Caption = 'Coupon Card';
    ContextSensitiveHelpPage = 'docs/retail/coupons/reference/coupon_types/';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = None;

    SourceTable = "NPR NpDc Coupon";


    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014436)
                {
                    ShowCaption = false;
                    field("No."; Rec."No.")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the unique number of the coupon.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Coupon Type"; Rec."Coupon Type")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the coupon type.';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the name of the coupon.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Discount Type"; Rec."Discount Type")
                    {

                        ToolTip = 'Specifies the discount type of the coupon.';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6014432)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 0);
                        field("Discount Amount"; Rec."Discount Amount")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the discount amount of the coupon.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014430)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 1);
                        field("Discount %"; Rec."Discount %")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the discount percent of the coupon.';
                            ApplicationArea = NPRRetail;
                        }
                        field("Max. Discount Amount"; Rec."Max. Discount Amount")
                        {

                            ToolTip = 'Specifies the max. discount amount per sale.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(Control6014437)
                {
                    ShowCaption = false;
                    field(Open; Rec.Open)
                    {
                        ToolTip = 'Specifies if the coupon is open.';
                        ApplicationArea = NPRRetail;
                    }
                    field("POS Store Group"; Rec."POS Store Group")
                    {
                        ToolTip = 'Specifies the group of POS stores where coupon can be used.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Remaining Quantity"; Rec."Remaining Quantity")
                    {

                        ToolTip = 'Specifies the remaining quantity of the coupon.';
                        ApplicationArea = NPRRetail;
                    }
                    field("In-use Quantity"; Rec."In-use Quantity")
                    {

                        ToolTip = 'Specifies the value of the In-use Quantity field';
                        ApplicationArea = NPRRetail;
                    }
                    field("In-use Quantity (External)"; Rec."In-use Quantity (External)")
                    {

                        ToolTip = 'Specifies the value of the In-use Quantity (External) field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Issue Coupon")
            {
                Caption = 'Issue Coupon';
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Issue Coupon Module"; Rec."Issue Coupon Module")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the issue coupon module of the coupon.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014410)
                {
                    ShowCaption = false;
                    field("Reference No."; Rec."Reference No.")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the reference no. of the coupon.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer No."; Rec."Customer No.")
                    {

                        ToolTip = 'Specifies the customer no. of the coupon.';
                        ApplicationArea = NPRRetail;
                    }
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
                        ToolTip = 'Specifies the value of the print template code of the coupon';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Validate")
            {
                Caption = 'Validate';
                group(Control6014416)
                {
                    ShowCaption = false;
                    field("Validate Coupon Module"; Rec."Validate Coupon Module")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Validate Coupon Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014418)
                {
                    ShowCaption = false;
                    field("Starting Date"; Rec."Starting Date")
                    {

                        ToolTip = 'Specifies the value of the Starting Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending Date"; Rec."Ending Date")
                    {

                        ToolTip = 'Specifies the value of the Ending Date field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Apply Discount")
            {
                Caption = 'Apply Discount';
                group(Control6014414)
                {
                    ShowCaption = false;
                    field("Apply Discount Module"; Rec."Apply Discount Module")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Apply Discount Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Max Use per Sale"; Rec."Max Use per Sale")
                    {

                        ToolTip = 'Specifies the value of the Max Use per Sale field';
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
            group(PrintGroup)
            {
                Caption = '&Print';
                Image = Print;
                action(Print)
                {
                    Caption = 'Print';
                    Image = Print;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Print action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                    begin
                        NpDcCouponMgt.PrintCoupon(Rec);
                    end;
                }
            }
            action("Reset Coupons In-use")
            {
                Caption = 'Reset Coupons In-use';
                Image = RefreshVoucher;

                ToolTip = 'Executes the Reset Coupons In-use action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                begin
                    if not Confirm(DeleteCouponsQst, false) then
                        exit;

                    NpDcCouponMgt.ResetInUseQty(Rec);
                end;
            }
            group(ArchiveGroup)
            {
                Caption = '&Archive';
                Image = Post;
                action("Archive Coupon")
                {
                    Caption = 'Archive Coupon';
                    Image = Post;

                    ToolTip = 'Executes the Archive Coupon action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Coupon: Record "NPR NpDc Coupon";
                        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                    begin
                        if not Confirm(ArchiveCouponQst, false, Coupon.Count) then
                            exit;

                        NpDcCouponMgt.ArchiveCoupons(Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Coupon Entries")
            {
                Caption = 'Coupon Entries';
                Image = Entries;
                RunObject = Page "NPR NpDc Coupon Entries";
                RunPageLink = "Coupon No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';

                ToolTip = 'Executes the Coupon Entries action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        DeleteCouponsQst: Label 'Are you sure you want to delete Coupons In-use?';
        ArchiveCouponQst: Label 'Archive Coupon Manually?';
        PrintUsingTemplate: Boolean;

    local procedure UpdateControls()
    begin
        PrintUsingTemplate := Rec."Print Object Type" = Rec."Print Object Type"::Template;
    end;
}

