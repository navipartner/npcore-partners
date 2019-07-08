page 6014409 "Credit card transaction ticket"
{
    Caption = 'Credit Card Transaction Receipt';
    Editable = false;
    PageType = List;
    SourceTable = "Credit Card Transaction";
    SourceTableView = WHERE(Type=FILTER(0|3));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction Time";"Transaction Time")
                {
                }
                field(Text;Text)
                {
                    Width = 250;
                }
            }
        }
    }

    actions
    {
    }
}

