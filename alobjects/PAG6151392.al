page 6151392 "CS Posting Buffer"
{
    // NPR5.51/CLVA/20190813  CASE 365967 Object created - NP Capture Service

    Caption = 'CS Posting Buffer';
    Editable = false;
    PageType = List;
    SourceTable = "CS Posting Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field("Key 1";"Key 1")
                {
                }
                field("key 2";"key 2")
                {
                }
                field(Created;Created)
                {
                }
                field(Posted;Posted)
                {
                }
                field(Aborted;Aborted)
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Post)
            {
                Caption = 'Post';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CSHelperFunctions: Codeunit "CS Helper Functions";
                begin
                    CSHelperFunctions.PostTransferOrder(Rec);
                end;
            }
        }
    }
}

