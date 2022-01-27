page 6150695 "NPR NPRE Serv. Flow Prof. Card"
{
    Extensible = False;
    Caption = 'Rest. Service Flow Profile Card';
    PageType = Card;
    SourceTable = "NPR NPRE Serv.Flow Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Close Waiter Pad On"; Rec."Close Waiter Pad On")
                {

                    ToolTip = 'Specifies the value of the Close Waiter Pad On field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        UpdateControls();
                    end;
                }
                field("Only if Fully Paid"; Rec."Only if Fully Paid")
                {

                    Enabled = IsCloseOnPayment;
                    ToolTip = 'Specifies whether waiter pads will be closed only after full payment';
                    ApplicationArea = NPRRetail;
                }
                field("Clear Seating On"; Rec."Clear Seating On")
                {

                    ToolTip = 'Specifies the value of the Clear Seating On field';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Status after Clearing"; Rec."Seating Status after Clearing")
                {

                    ToolTip = 'Specifies the value of the Seating Status after Clearing field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                ApplicationArea = NPRRetail;

            }
            systempart(Control6014408; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
        }
    }

    var
        IsCloseOnPayment: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;

    local procedure UpdateControls()
    begin
        IsCloseOnPayment := Rec."Close Waiter Pad On" in [Rec."Close Waiter Pad On"::Payment, Rec."Close Waiter Pad On"::"Payment if Served"];
    end;
}
