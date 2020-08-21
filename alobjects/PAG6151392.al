page 6151392 "CS Posting Buffer"
{
    // NPR5.51/CLVA/20190813  CASE 365967 Object created - NP Capture Service
    // NPR5.52/CLVA/20190813  CASE 365967 Added fields "Job Queue Status","Job Queue Entry ID" and "Job Type"
    // NPR5.54/CLVA/20200217  CASE 391080 Added action "Re-Schedule Posting" and "Job Queue Entry"

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
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field(RecId; RecId)
                {
                    ApplicationArea = All;
                    Caption = 'Record Id';
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field(Executed; Executed)
                {
                    ApplicationArea = All;
                }
                field("Job Queue Status"; "Job Queue Status")
                {
                    ApplicationArea = All;
                }
                field("Job Type"; "Job Type")
                {
                    ApplicationArea = All;
                }
                field("Posting Index"; "Posting Index")
                {
                    ApplicationArea = All;
                }
                field("Update Posting Date"; "Update Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Priority for Post"; "Job Queue Priority for Post")
                {
                    ApplicationArea = All;
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
                    if "Job Queue Status" in ["Job Queue Status"::" ", "Job Queue Status"::Posting, "Job Queue Status"::"Scheduled for Posting"] then
                        exit;

                    Delete(true);
                    CurrPage.Update;
                end;
            }
            action("Re-Schedule Posting")
            {
                Caption = 'Re-Schedule Posting';
                Image = RefreshPlanningLine;

                trigger OnAction()
                var
                    CSSetup: Record "CS Setup";
                    CSPostEnqueue: Codeunit "CS Post - Enqueue";
                    CSPost: Codeunit "CS Post";
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    if "Job Queue Status" in ["Job Queue Status"::" ", "Job Queue Status"::Posting] then
                        exit;

                    if not IsNullGuid(Rec."Job Queue Entry ID") then begin
                        if JobQueueEntry.Get(Rec."Job Queue Entry ID") then
                            JobQueueEntry.Delete(true);
                        Rec."Job Queue Status" := Rec."Job Queue Status"::" ";
                        Clear(Rec."Job Queue Entry ID");
                        Rec.Executed := false;
                        Rec.Modify(true);
                        Commit;
                    end;

                    CSSetup.Get;
                    if CSSetup."Post with Job Queue" then begin
                        CSPostEnqueue.Run(Rec);
                    end else begin
                        if CSPost.Run(Rec) then begin
                            Rec.Executed := true;
                            Rec.Modify(true);
                        end;
                    end;
                end;
            }
            action("Job Queue Entry")
            {
                Caption = 'Job Queue Entry';
                Image = Job;

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                begin
                    if JobQueueEntry.Get(Rec."Job Queue Entry ID") then
                        PAGE.RunModal(PAGE::"Job Queue Entry Card", JobQueueEntry);
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

