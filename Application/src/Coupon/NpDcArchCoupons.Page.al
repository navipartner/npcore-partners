page 6151599 "NPR NpDc Arch. Coupons"
{
    Caption = 'Archived Coupons';
    CardPageID = "NPR NpDc Arch. Coupon Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Arch. Coupon";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Coupon Type"; Rec."Coupon Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Type field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Quantity field';
                }
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
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Arch. Coupon Entries")
            {
                Caption = 'Archived Coupon Entries';
                Image = Entries;
                RunObject = Page "NPR NpDc Arch.Coupon Entries";
                RunPageLink = "Arch. Coupon No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Archived Coupon Entries action';
            }
        }
    }
}

