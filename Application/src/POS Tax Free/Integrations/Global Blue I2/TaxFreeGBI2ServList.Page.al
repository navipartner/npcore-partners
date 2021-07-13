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

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Service ID"; Rec."Service ID")
                {

                    ToolTip = 'Specifies the value of the Service ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Minimum Purchase Amount"; Rec."Minimum Purchase Amount")
                {

                    ToolTip = 'Specifies the value of the Minimum Purchase Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Maximum Purchase Amount"; Rec."Maximum Purchase Amount")
                {

                    ToolTip = 'Specifies the value of the Maximum Purchase Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Void Limit In Days"; Rec."Void Limit In Days")
                {

                    ToolTip = 'Specifies the value of the Void Limit In Days field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

