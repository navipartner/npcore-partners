page 6059783 "NPR POS Payment Bins Select"
{
    Caption = 'POS Payment Bins';
    PageType = List;
    SourceTable = "NPR POS Payment Bin";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

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
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Attached to POS Unit No."; Rec."Attached to POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the Attached to POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Eject Method"; Rec."Eject Method")
                {

                    ToolTip = 'Specifies the value of the Eject Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Bin Type"; Rec."Bin Type")
                {

                    ToolTip = 'Specifies the value of the Bin Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}