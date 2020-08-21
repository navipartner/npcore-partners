page 6151593 "NpDc Coupons"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Renamed Action "Manual Post Coupons" to "Archive Coupons" and added Action "Show Expired Coupons"

    Caption = 'Coupons';
    CardPageID = "NpDc Coupon Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NpDc Coupon";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Coupon Type"; "Coupon Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
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
                        Coupon: Record "NpDc Coupon";
                        NpDcCouponMgt: Codeunit "NpDc Coupon Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Coupon);
                        if not Coupon.FindSet then
                            exit;

                        repeat
                            NpDcCouponMgt.PrintCoupon(Coupon);
                        until Coupon.Next = 0;
                    end;
                }
            }
            group(ArchiveGroup)
            {
                Caption = '&Archive';
                Image = Post;
                action("Archive Coupons")
                {
                    Caption = 'Archive Coupons';
                    Image = Post;

                    trigger OnAction()
                    var
                        Coupon: Record "NpDc Coupon";
                        NpDcCouponMgt: Codeunit "NpDc Coupon Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Coupon);
                        if not Confirm(Text000, false, Coupon.Count) then
                            exit;

                        NpDcCouponMgt.ArchiveCoupons(Coupon);
                    end;
                }
                action("Show Expired Coupons")
                {
                    Caption = 'Show Expired Coupons';
                    Image = "Filter";

                    trigger OnAction()
                    begin
                        //-NPR5.37 [293232]
                        SetFilter("Ending Date", '>%1&<%2', 0DT, CurrentDateTime);
                        //+NPR5.37 [293232]
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
                RunObject = Page "NpDc Coupon Entries";
                RunPageLink = "Coupon No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }

    var
        Text000: Label 'Archive %1 selected Coupons Manually?';
}

