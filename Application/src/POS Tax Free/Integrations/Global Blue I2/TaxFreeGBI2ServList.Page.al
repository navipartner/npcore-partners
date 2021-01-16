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
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Service ID"; "Service ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service ID field';
                }
                field("Minimum Purchase Amount"; "Minimum Purchase Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Purchase Amount field';
                }
                field("Maximum Purchase Amount"; "Maximum Purchase Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum Purchase Amount field';
                }
                field("Void Limit In Days"; "Void Limit In Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Void Limit In Days field';
                }
            }
        }
    }

    actions
    {
    }
}

