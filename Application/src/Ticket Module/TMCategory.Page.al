page 6184629 "NPR TM Category"
{
    PageType = List;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM Category";
    Caption = 'Ticket Categories';
    Editable = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(CategoryCode; Rec.CategoryCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Category Code field.';
                }
                field(CategoryName; Rec.CategoryName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Category Name field.';
                }
            }
        }
    }
}