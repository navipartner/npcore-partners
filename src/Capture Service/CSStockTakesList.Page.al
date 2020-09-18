page 6151385 "NPR CS Stock-Takes List"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.52/CLVA/20190905  CASE 364063 Added field "Journal Qty. (Calculated)"
    // NPR5.54/CLVA/20200217  CASE 391080 Added field "Adjust Inventory","Unknown Entries" and action "Tag Data"
    // NPR5.54/CLVA/20200227  CASE 389224 Added action "Approved Data" and "Batch Data" and ActionGroup "Process"
    // NPR5.55/CLVA/20200710  CASE 414210 Added action group "Manual Posting"

    Caption = 'CS Stock-Takes List';
    CardPageID = "NPR CS Stock-Takes Card";
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR CS Stock-Takes";
    SourceTableView = SORTING(Created)
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Location; Location)
                {
                    ApplicationArea = All;
                }
                field("Adjust Inventory"; "Adjust Inventory")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field(Closed; Closed)
                {
                    ApplicationArea = All;
                }
                field(Approved; Approved)
                {
                    ApplicationArea = All;
                }
                field("Salesfloor Started"; "Salesfloor Started")
                {
                    ApplicationArea = All;
                }
                field("Salesfloor Duration"; "Salesfloor Duration")
                {
                    ApplicationArea = All;
                }
                field("Salesfloor Entries"; "Salesfloor Entries")
                {
                    ApplicationArea = All;
                }
                field("Stockroom Started"; "Stockroom Started")
                {
                    ApplicationArea = All;
                }
                field("Stockroom Duration"; "Stockroom Duration")
                {
                    ApplicationArea = All;
                }
                field("Stockroom Entries"; "Stockroom Entries")
                {
                    ApplicationArea = All;
                }
                field("Refill Started"; "Refill Started")
                {
                    ApplicationArea = All;
                }
                field("Refill Duration"; "Refill Duration")
                {
                    ApplicationArea = All;
                }
                field("Refill Entries"; "Refill Entries")
                {
                    ApplicationArea = All;
                }
                field("Unknown Entries"; "Unknown Entries")
                {
                    ApplicationArea = All;
                }
                field("Inventory Calculated"; "Inventory Calculated")
                {
                    ApplicationArea = All;
                }
                field("Predicted Qty."; "Predicted Qty.")
                {
                    ApplicationArea = All;
                }
                field("Journal Posted"; "Journal Posted")
                {
                    ApplicationArea = All;
                }
                field("Stock-Take Id"; "Stock-Take Id")
                {
                    ApplicationArea = All;
                }
                field(Note; Note)
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
            action("New Counting")
            {
                Caption = 'New Counting';
                Image = LedgerEntries;
                ApplicationArea = All;

                trigger OnAction()
                var
                    LocationRec: Record Location;
                begin
                    //CreateNewCounting();
                    if not LocationRec.Get(GetFilter(Location)) then
                        Error(Err_MissingLocation);

                    CSHelperFunctions.CreateNewCountingV2(LocationRec);
                    CurrPage.Update();
                end;
            }
            action("Force Close")
            {
                Caption = 'Force Close';
                Image = Cancel;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    //CancelCounting();

                    CSHelperFunctions.CancelCounting(Rec);
                    CurrPage.Update();
                end;
            }
            action("Tag Data")
            {
                Caption = 'Tag Data';
                Image = DataEntry;
                RunObject = Page "NPR CS Stock-Takes Data List";
                RunPageLink = "Stock-Take Id" = FIELD("Stock-Take Id");
                ApplicationArea = All;
            }
            group(Overview)
            {
                Caption = 'Overview';
                action(Devices)
                {
                    Caption = 'Devices';
                    Image = MiniForm;
                    RunObject = Page "NPR CS Devices";
                    RunPageLink = Location = FIELD(Location);
                    ApplicationArea = All;
                }
                action("&Item Journal")
                {
                    Caption = '&Item Journal';
                    Image = Worksheet2;
                    RunObject = Page "Phys. Inventory Journal";
                    RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                  "Journal Batch Name" = FIELD("Journal Batch Name");
                    ApplicationArea = All;
                }
                action("&Item Journal Batch")
                {
                    Caption = '&Item Journal Batch';
                    Image = InventoryJournal;
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Phys. Inventory"));
                    ApplicationArea = All;
                }
                action("Approved Data")
                {
                    Caption = 'Approved Data';
                    Image = DataEntry;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CSApprovalData: Page "NPR CS Approved Data";
                    begin
                        CSApprovalData.SetParameters("Stock-Take Id");
                        CSApprovalData.Run;
                    end;
                }
                action("Batch Data")
                {
                    Caption = 'Batch Data';
                    Image = List;
                    RunObject = Page "NPR CS StockTake Batch List";
                    RunPageLink = "Stock-Take Id" = FIELD("Stock-Take Id");
                    RunPageView = SORTING(Created)
                                  ORDER(Ascending);
                    ApplicationArea = All;
                }
            }
            group(Process)
            {
                Caption = 'Process';
                action("Re-Run Approvel")
                {
                    Caption = 'Re-Run Approvel';
                    Image = RefreshLines;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CSStockTakesData: Record "NPR CS Stock-Takes Data";
                        RecRef: RecordRef;
                        CSPost: Codeunit "NPR CS Post";
                    begin
                        if not "Adjust Inventory" then
                            exit;

                        if Approved = 0DT then
                            exit;


                        Clear(CSStockTakesData);
                        CSStockTakesData.SetRange("Stock-Take Id", Rec."Stock-Take Id");
                        CSStockTakesData.SetRange("Stock-Take Config Code", Rec."Journal Template Name");
                        CSStockTakesData.SetRange("Worksheet Name", Rec."Journal Batch Name");
                        CSStockTakesData.ModifyAll("Transferred To Worksheet", false);

                        RecRef.Open(DATABASE::"NPR CS Stock-Takes");
                        RecRef.Get(Rec.RecordId);

                        CSPost.PostStoreApprovel(RecRef);
                    end;
                }
                action("Manual Posting")
                {
                    Caption = 'Manual Posting';
                    Image = PostBatch;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RecRef: RecordRef;
                        CSPost: Codeunit "NPR CS Post";
                        ItemJournalBatch: Record "Item Journal Batch";
                    begin
                        if not "Adjust Inventory" then
                            exit;

                        if Approved = 0DT then
                            exit;

                        if "Journal Posted" then
                            exit;

                        ItemJournalBatch.Get("Journal Template Name", "Journal Batch Name");

                        RecRef.Open(DATABASE::"Item Journal Batch");
                        RecRef.Get(ItemJournalBatch.RecordId);

                        CSPost.PostItemJournal(RecRef);
                    end;
                }
                action("Schedule Posting")
                {
                    Caption = 'Schedule Posting';
                    Image = PostBatch;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CSPost: Codeunit "NPR CS Post";
                        ItemJournalBatch: Record "Item Journal Batch";
                        CSSetup: Record "NPR CS Setup";
                        PostingRecRef: RecordRef;
                        CSPostingBuffer: Record "NPR CS Posting Buffer";
                        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
                        RecRef: RecordRef;
                    begin
                        CSSetup.Get;
                        if not CSSetup."Post with Job Queue" then
                            exit;

                        if not "Adjust Inventory" then
                            exit;

                        if Approved = 0DT then
                            exit;

                        if "Journal Posted" then
                            exit;

                        ItemJournalBatch.Get("Journal Template Name", "Journal Batch Name");

                        RecRef.GetTable(ItemJournalBatch);
                        Clear(CSPostingBuffer);
                        CSPostingBuffer.SetRange("Table No.", RecRef.Number);
                        CSPostingBuffer.SetRange("Record Id", RecRef.RecordId);
                        CSPostingBuffer.SetRange(Executed, false);
                        if CSPostingBuffer.FindSet then
                            Error(Err_PostingIsScheduled, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);

                        PostingRecRef.GetTable(ItemJournalBatch);
                        Clear(CSPostingBuffer);
                        CSPostingBuffer.Init;
                        CSPostingBuffer."Table No." := PostingRecRef.Number;
                        CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
                        CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Store Counting";
                        CSPostingBuffer."Job Queue Priority for Post" := 2000;
                        if CSPostingBuffer.Insert(true) then
                            CSPostEnqueue.Run(CSPostingBuffer);
                    end;
                }
                action("Force Close w/o Posting")
                {
                    Caption = 'Force Close w/o Posting';
                    Image = CancelLine;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        CSHelperFunctions.CancelCountingWOPosting(Rec);
                        CurrPage.Update();
                    end;
                }
            }
            group(ActionGroup6014437)
            {
                Caption = 'Manual Posting';
                action("Post Approve Counting")
                {
                    Caption = 'Post Approve Counting';
                    Image = Post;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RecRef: RecordRef;
                        CSPost: Codeunit "NPR CS Post";
                    begin
                        TestField("Adjust Inventory", true);

                        if Approved = 0DT then
                            Error(Err_NotApproved);

                        RecRef.Open(DATABASE::"NPR CS Stock-Takes");
                        RecRef.Get(Rec.RecordId);

                        CSPost.PostStoreApprovel(RecRef);
                    end;
                }
                action("Post Store Counting")
                {
                    Caption = 'Post Store Counting';
                    Image = Post;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RecRef: RecordRef;
                        CSPost: Codeunit "NPR CS Post";
                        ItemJournalBatch: Record "Item Journal Batch";
                    begin
                        TestField("Journal Posted", false);

                        if Approved = 0DT then
                            Error(Err_NotApproved);

                        ItemJournalBatch.Get("Journal Template Name", "Journal Batch Name");
                        RecRef.GetTable(ItemJournalBatch);
                        RecRef.FindFirst();

                        CSPost.PostItemJournal(RecRef);
                    end;
                }
            }
        }
    }

    var
        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
        Err_MissingLocation: Label 'Location is missing on POS Store';
        Err_MissingData: Label 'There is none approved data';
        Err_PostingIsScheduled: Label 'Phy. Inventory Journal is scheduled for posting: %1 %2. Delete the entry from the Posting Buffer before Schedule Posting.';
        Err_NotApproved: Label 'Counting has not yet been approved';
}

