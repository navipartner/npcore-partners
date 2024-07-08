page 6014599 "NPR CleanCash Transaction VAT"
{
    Extensible = False;
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

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Class"; Rec."VAT Class")
                {

                    ToolTip = 'Specifies VAT Class, an integer number between 1 and 4.';
                    ApplicationArea = NPRRetail;
                }
                field(Percentage; Rec.Percentage)
                {

                    ToolTip = 'Specifies the VAT percentage (25,00 for 25%).';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the net VAT amount.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
