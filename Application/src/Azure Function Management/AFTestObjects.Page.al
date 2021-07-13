page 6151571 "NPR AF Test Objects"
{
    Caption = 'AF Test Objects';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR AF Test Objects";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; Rec."Object Type")
                {

                    ToolTip = 'Specifies the value of the Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Object ID"; Rec."Object ID")
                {

                    ToolTip = 'Specifies the value of the Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Name"; Rec."Object Name")
                {

                    ToolTip = 'Specifies the value of the Object Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Run Test")
            {
                Caption = 'Run Test';
                Image = TaskList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Run Test action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    case Rec."Object Type" of
                        Rec."Object Type"::Page:
                            PAGE.Run(Rec."Object ID");
                    end;
                end;
            }
        }
    }
}

