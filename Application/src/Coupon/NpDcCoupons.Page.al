page 6151593 "NPR NpDc Coupons"
{
    Caption = 'Coupons';
    CardPageID = "NPR NpDc Coupon Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Coupon";
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
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Coupon: Record "NPR NpDc Coupon";
                        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
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
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Coupon: Record "NPR NpDc Coupon";
                        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
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
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        SetFilter("Ending Date", '>%1&<%2', 0DT, CurrentDateTime);
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
                ApplicationArea = All;
            }
        }
    }

    var
        Text000: Label 'Archive %1 selected Coupons Manually?';
}

