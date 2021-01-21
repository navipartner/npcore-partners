page 6151593 "NPR NpDc Coupons"
{
    Caption = 'Coupons';
    CardPageID = "NPR NpDc Coupon Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Coupon";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Coupon Type"; "Coupon Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Quantity field';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print action';

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
                    ToolTip = 'Executes the Archive Coupons action';

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
                    ToolTip = 'Executes the Show Expired Coupons action';

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
                ToolTip = 'Executes the Coupon Entries action';
            }
        }
    }

    var
        Text000: Label 'Archive %1 selected Coupons Manually?';
}

