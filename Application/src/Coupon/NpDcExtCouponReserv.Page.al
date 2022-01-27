page 6151608 "NPR NpDc Ext. Coupon Reserv."
{
    Extensible = False;
    Caption = 'External Coupon Reservations';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpDc Ext. Coupon Reserv.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Document No."; Rec."External Document No.")
                {

                    ToolTip = 'Specifies the value of the External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Inserted at"; Rec."Inserted at")
                {

                    ToolTip = 'Specifies the value of the Inserted at field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Type"; Rec."Document Type")
                {

                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Coupon Type"; Rec."Coupon Type")
                {

                    ToolTip = 'Specifies the value of the Coupon Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Coupon No."; Rec."Coupon No.")
                {

                    ToolTip = 'Specifies the value of the Coupon No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

