page 6151592 "NPR NpDc Coupon Card"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Renamed Action "Manual Post Coupon" to "Archive Coupon"
    // NPR5.51/MHA /20190724  CASE 343352 Added field 85 "In-use Quantity (External)"

    Caption = 'Coupon Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
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
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Coupon Type"; "Coupon Type")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                    }
                    field("Discount Type"; "Discount Type")
                    {
                        ApplicationArea = All;
                    }
                    group(Control6014432)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type" = 0);
                        field("Discount Amount"; "Discount Amount")
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                        }
                    }
                    group(Control6014430)
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
                }
                group(Control6014437)
                {
                    ShowCaption = false;
                    field(Open; Open)
                    {
                        ApplicationArea = All;
                    }
                    field("Remaining Quantity"; "Remaining Quantity")
                    {
                        ApplicationArea = All;
                    }
                    field("In-use Quantity"; "In-use Quantity")
                    {
                        ApplicationArea = All;
                    }
                    field("In-use Quantity (External)"; "In-use Quantity (External)")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Issue Coupon")
            {
                Caption = 'Issue Coupon';
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Issue Coupon Module"; "Issue Coupon Module")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
                group(Control6014410)
                {
                    ShowCaption = false;
                    field("Reference No."; "Reference No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Print Template Code"; "Print Template Code")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Validate")
            {
                Caption = 'Validate';
                group(Control6014416)
                {
                    ShowCaption = false;
                    field("Validate Coupon Module"; "Validate Coupon Module")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
                group(Control6014418)
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
                group(Control6014414)
                {
                    ShowCaption = false;
                    field("Apply Discount Module"; "Apply Discount Module")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Max Use per Sale"; "Max Use per Sale")
                    {
                        ApplicationArea = All;
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
                    PromotedCategory = Process;
                    PromotedIsBig = true;

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
            }
        }
    }

    var
        Text000: Label 'Are you sure you want to delete Coupons In-use?';
        Text001: Label 'Archive Coupon Manually?';
}

