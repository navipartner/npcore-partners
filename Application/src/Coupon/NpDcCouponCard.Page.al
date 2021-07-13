page 6151592 "NPR NpDc Coupon Card"
{
    Caption = 'Coupon Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpDc Coupon";
    ApplicationArea = NPRRetail;

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
                        ToolTip = 'Specifies the value of the No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Coupon Type"; Rec."Coupon Type")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Coupon Type field';
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
                    group(Control6014432)
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
                    group(Control6014430)
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
                group(Control6014437)
                {
                    ShowCaption = false;
                    field(Open; Rec.Open)
                    {

                        ToolTip = 'Specifies the value of the Open field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Remaining Quantity"; Rec."Remaining Quantity")
                    {

                        ToolTip = 'Specifies the value of the Remaining Quantity field';
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
                        ToolTip = 'Specifies the value of the Issue Coupon Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014410)
                {
                    ShowCaption = false;
                    field("Reference No."; Rec."Reference No.")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Reference No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer No."; Rec."Customer No.")
                    {

                        ToolTip = 'Specifies the value of the Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {

                        ToolTip = 'Specifies the value of the Print Template Code field';
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
                group(Control6014415)
                {
                    ShowCaption = false;
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
                    if not Confirm(Text000) then
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
                        if not Confirm(Text001, false, Coupon.Count) then
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
        Text000: Label 'Are you sure you want to delete Coupons In-use?';
        Text001: Label 'Archive Coupon Manually?';
}

