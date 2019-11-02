page 6151392 "CS Posting Buffer"
{
    // NPR5.51/CLVA/20190813  CASE 365967 Object created - NP Capture Service
    // NPR5.52/CLVA/20190813  CASE 365967 Added fields "Job Queue Status","Job Queue Entry ID" and "Job Type"

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
                field("Table No.";"Table No.")
                {
                }
                field(RecId;RecId)
                {
                    Caption = 'Record Id';
                }
                field("Created By";"Created By")
                {
                }
                field(Created;Created)
                {
                }
                field(Executed;Executed)
                {
                }
                field("Job Queue Status";"Job Queue Status")
                {
                }
                field("Job Type";"Job Type")
                {
                }
                field("Posting Index";"Posting Index")
                {
                }
                field("Update Posting Date";"Update Posting Date")
                {
                }
                field("Job Queue Priority for Post";"Job Queue Priority for Post")
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
                    CSPostYesNo: Codeunit "CS Post (Yes/No)";
                begin
                    //-NPR5.52 [365967]
                    //CSHelperFunctions.PostTransferOrder(Rec);
                    CSPostYesNo.Run(Rec);
                    //+NPR5.52 [365967]
                end;
            }
            action(Delete)
            {
                Caption = 'Delete';
                Image = Delete;

                trigger OnAction()
                begin
                    if "Job Queue Status" in ["Job Queue Status"::" ","Job Queue Status"::Posting,"Job Queue Status"::"Scheduled for Posting"] then
                      exit;

                    Delete(true);
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RecId := Format("Record Id");
    end;

    var
        RecId: Text;
}

