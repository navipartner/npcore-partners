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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("Attached to POS Unit No."; Rec."Attached to POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attached to POS Unit No. field';
                }
                field("Eject Method"; Rec."Eject Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Eject Method field';
                }
                field("Bin Type"; Rec."Bin Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin Type field';
                }
            }
        }
    }
}