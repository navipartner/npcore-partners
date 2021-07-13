page 6060056 "NPR Item Status"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Item Status';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Item Status";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Initial; Rec.Initial)
                {

                    ToolTip = 'Specifies the value of the Initial field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Allowed"; Rec."Delete Allowed")
                {

                    ToolTip = 'Specifies the value of the Delete Allowed field';
                    ApplicationArea = NPRRetail;
                }
                field("Rename Allowed"; Rec."Rename Allowed")
                {

                    ToolTip = 'Specifies the value of the Rename Allowed field';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Insert"; Rec."Purchase Insert")
                {

                    ToolTip = 'Specifies the value of the Purchase Insert field';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Release"; Rec."Purchase Release")
                {

                    ToolTip = 'Specifies the value of the Purchase Release field';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Post"; Rec."Purchase Post")
                {

                    ToolTip = 'Specifies the value of the Purchase Post field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Insert"; Rec."Sales Insert")
                {

                    ToolTip = 'Specifies the value of the Sales Insert field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Release"; Rec."Sales Release")
                {

                    ToolTip = 'Specifies the value of the Sales Release field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Post"; Rec."Sales Post")
                {

                    ToolTip = 'Specifies the value of the Sales Post field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

