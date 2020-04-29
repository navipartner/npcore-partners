page 6014577 "Tax Free GB I2 Service List"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB I2 Service List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Tax Free GB I2 Service";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field("Service ID";"Service ID")
                {
                }
                field("Minimum Purchase Amount";"Minimum Purchase Amount")
                {
                }
                field("Maximum Purchase Amount";"Maximum Purchase Amount")
                {
                }
                field("Void Limit In Days";"Void Limit In Days")
                {
                }
            }
        }
    }

    actions
    {
    }
}

