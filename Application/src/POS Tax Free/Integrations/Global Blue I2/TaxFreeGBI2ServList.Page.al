page 6014577 "NPR Tax Free GB I2 Serv. List"
{

    Caption = 'Tax Free GB I2 Service List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free GB I2 Service";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Service ID"; Rec."Service ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service ID field';
                }
                field("Minimum Purchase Amount"; Rec."Minimum Purchase Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Purchase Amount field';
                }
                field("Maximum Purchase Amount"; Rec."Maximum Purchase Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximum Purchase Amount field';
                }
                field("Void Limit In Days"; Rec."Void Limit In Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Void Limit In Days field';
                }
            }
        }
    }
}

