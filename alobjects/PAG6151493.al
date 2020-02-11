page 6151493 "Raptor Actions"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    Caption = 'Raptor Actions';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Raptor Action";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Raptor Module Code";"Raptor Module Code")
                {
                }
                field("Raptor Module API Req. String";"Raptor Module API Req. String")
                {
                    Visible = false;
                }
                field("Data Type Description";"Data Type Description")
                {
                }
                field("Number of Entries to Return";"Number of Entries to Return")
                {
                }
                field(Comment;Comment)
                {
                }
                field("Show Date-Time Created";"Show Date-Time Created")
                {
                }
                field("Show Priority";"Show Priority")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407;Notes)
            {
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(AddDefaultActions)
            {
                Caption = 'Add Default Actions';
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RaptorManagement: Codeunit "Raptor Management";
                begin
                    RaptorManagement.InitializeDefaultActions(true,false);
                end;
            }
        }
    }
}

