page 6151593 "NPR NpDc Coupons"
{
    Caption = 'Coupons';
    CardPageID = "NPR NpDc Coupon Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Coupon";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Coupon Type"; Rec."Coupon Type")
                {

                    ToolTip = 'Specifies the value of the Coupon Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
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
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
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
                        Coupon: Record "NPR NpDc Coupon";
                        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Coupon);
                        if not Coupon.FindSet() then
                            exit;

                        repeat
                            NpDcCouponMgt.PrintCoupon(Coupon);
                        until Coupon.Next() = 0;
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

                    ToolTip = 'Executes the Archive Coupons action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Show Expired Coupons action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.SetFilter("Ending Date", '>%1&<%2', 0DT, CurrentDateTime);
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
        Text000: Label 'Archive %1 selected Coupons Manually?';
}

