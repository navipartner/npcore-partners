page 6151593 "NPR NpDc Coupons"
{
    Extensible = False;
    Caption = 'Coupons';
    ContextSensitiveHelpPage = 'docs/retail/coupons/reference/coupon_types/';
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

                    ToolTip = 'Specifies the unique number of the coupon.';
                    ApplicationArea = NPRRetail;
                }
                field("Coupon Type"; Rec."Coupon Type")
                {

                    ToolTip = 'Specifies the coupon type.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the name of the coupon.';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {

                    ToolTip = 'Specifies if the coupon is open or not.';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {

                    ToolTip = 'Specifies the remaining quantity of the coupon.';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the starting date of the coupon.';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    ToolTip = 'Specifies the ending date of the coupon.';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the reference number of the coupon.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the customer number of the coupon.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Group"; Rec."POS Store Group")
                {
                    ToolTip = 'Specifies the group of POS stores where coupon can be used.';
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

                    ToolTip = 'Prints the selected coupon.';
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

                    ToolTip = 'Archives the selected coupons.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Coupon: Record "NPR NpDc Coupon";
                        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Coupon);
                        if not Confirm(ArchiveCouponQst, false, Coupon.Count) then
                            exit;

                        NpDcCouponMgt.ArchiveCoupons(Coupon);
                    end;
                }
                action("Show Expired Coupons")
                {
                    Caption = 'Show Expired Coupons';
                    Image = "Filter";

                    ToolTip = 'Displays only the expired coupons.';
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

                ToolTip = 'Displays the coupon entries for the selected coupon.';
                ApplicationArea = NPRRetail;
            }
            action("Show Archived Coupon")
            {
                Caption = 'Show Archived Coupons';
                Image = PostedPutAway;
                RunObject = Page "NPR NpDc Arch. Coupons";

                ToolTip = 'Displays the archived coupons.';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        ArchiveCouponQst: Label 'Archive %1 selected Coupons Manually?', Comment = '%1 = number of coupons';
}

