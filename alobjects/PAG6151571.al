page 6151571 "AF Test Objects"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017

    Caption = 'AF Test Objects';
    PageType = List;
    SourceTable = "AF Test Objects";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type";"Object Type")
                {
                }
                field("Object ID";"Object ID")
                {
                }
                field("Object Name";"Object Name")
                {
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    case "Object Type" of
                      "Object Type"::Page : PAGE.Run("Object ID");
                    end;
                end;
            }
        }
    }
}

