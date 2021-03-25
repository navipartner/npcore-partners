pageextension 6014435 "NPR Extended Text" extends "Extended Text"
{
    layout
    {
        addafter(Service)
        {
            group("NPR Jobs")
            {
                Caption = 'Jobs';
                field("NPR Event"; Rec."NPR Event")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Event field';
                }
            }
        }
    }
}