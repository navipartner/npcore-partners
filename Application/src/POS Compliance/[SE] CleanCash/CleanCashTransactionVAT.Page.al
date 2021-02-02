page 6014599 "NPR CleanCash Transaction VAT"
{
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR CleanCash Trans. VAT";

    Caption = 'VAT Details';
    ShowFilter = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Request Entry No."; Rec."Request Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("VAT Class"; Rec."VAT Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies VAT Class, an integer number between 1 and 4.';
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT percentage (25,00 for 25%).';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the net VAT amount.';
                }
            }
        }
    }
}