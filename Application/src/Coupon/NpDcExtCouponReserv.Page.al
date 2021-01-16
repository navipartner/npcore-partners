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
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("Inserted at"; "Inserted at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inserted at field';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Coupon Type"; "Coupon Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Type field';
                }
                field("Coupon No."; "Coupon No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
            }
        }
    }
}

