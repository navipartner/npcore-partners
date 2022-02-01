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

                    ToolTip = 'Specifies whether the extended text for an Event will be available.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}