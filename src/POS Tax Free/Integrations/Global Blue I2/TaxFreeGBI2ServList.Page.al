page 6014577 "NPR Tax Free GB I2 Serv. List"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB I2 Service List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free GB I2 Service";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Service ID"; "Service ID")
                {
                    ApplicationArea = All;
                }
                field("Minimum Purchase Amount"; "Minimum Purchase Amount")
                {
                    ApplicationArea = All;
                }
                field("Maximum Purchase Amount"; "Maximum Purchase Amount")
                {
                    ApplicationArea = All;
                }
                field("Void Limit In Days"; "Void Limit In Days")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

