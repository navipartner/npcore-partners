page 6151608 "NPR NpDc Ext. Coupon Reserv."
{
    Caption = 'External Coupon Reservations';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpDc Ext. Coupon Reserv.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("Inserted at"; Rec."Inserted at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inserted at field';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Coupon Type"; Rec."Coupon Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Type field';
                }
                field("Coupon No."; Rec."Coupon No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
            }
        }
    }
}

