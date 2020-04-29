page 6014540 "Insurrance Combination"
{
    Caption = 'Insurance - Combination';
    PageType = List;
    SourceTable = "Insurance Combination";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Company;Company)
                {
                }
                field(Type;Type)
                {
                }
                field("Amount From";"Amount From")
                {
                }
                field("To Amount";"To Amount")
                {
                }
                field("Insurance Amount";"Insurance Amount")
                {
                }
                field("Profit %";"Profit %")
                {
                }
                field("Amount as Percentage";"Amount as Percentage")
                {
                }
                field("Ticket tekst";"Ticket tekst")
                {
                }
            }
        }
    }

    actions
    {
    }
}

