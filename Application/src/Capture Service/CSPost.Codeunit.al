codeunit 6151357 "NPR CS Post"
{
    TableNo = "NPR CS Posting Buffer";

    trigger OnRun()
    var
        RecRef: RecordRef;
        DocNo: Code[20];
    begin
        TestField("Table No.");
        TestField("Record Id");
        RecRef.Open("Table No.");
        RecRef.Get("Record Id");

        case "Table No." of
            83:
                PostItemJournalLine(RecRef);
            233:
                begin
                    case "Job Type" of
                        "Job Type"::"Phy. Inv. Journal", "Job Type"::"Store Counting":
                            PostItemJournal(RecRef);
                        "Job Type"::"Item Reclass.":
                            PostItemReclassJournal(RecRef, Rec);
                        "Job Type"::"Unplanned Count":
                            PostUnplannedCounting(RecRef, Rec);
                    end;
                end;
            5740:
                PostTransferOrder(RecRef);
            5766:
                PostWhseActivity(RecRef, Rec);
            6151391:
                PostStoreApprovel(RecRef);
        end;
    end;

    var
        Text023: Label '%1 = ''%2'', %3 = ''%4'', %5 = ''%6'', %7 = ''%8'': The total base quantity to take %9 must be equal to the total base quantity to place %10.';
        Text024: Label '%1 = ''%2'', %3 = ''%4'':\The total base quantity to take %5 must be equal to the total base quantity to place %6.';
        Text025: Label 'Predicted Qty. %1 is not equal to Item Journal Qty.(Calculated) total %2';

    local procedure PostTransferOrder(var RecRef: RecordRef)
    var
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        ReleaseTransferDoc: Codeunit "Release Transfer Document";
        TransferHeader: Record "Transfer Header";
        DocNo: Code[20];
    begin
        RecRef.SetTable(TransferHeader);
        TransferHeader.Find;
        DocNo := TransferHeader."No.";

        TransferPostReceipt.SetHideValidationDialog(true);
        TransferPostReceipt.Run(TransferHeader);

        if TransferHeader.Get(DocNo) then begin
            if TransferHeader.Status = TransferHeader.Status::Released then
                ReleaseTransferDoc.Reopen(TransferHeader);

            TransferHeader.Delete(true);

        end;
    end;

    local procedure PostWhseActivity(var RecRef: RecordRef; var CSPostingBuffer: Record "NPR CS Posting Buffer")
    var
        WhseActivityHeader: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        WhseActivityPost: Codeunit "Whse.-Activity-Post";
        WhseActivityPosted: Boolean;
        DocNo: Code[20];
        SourceNo: Code[20];
        IsInvtPick: Boolean;
        TransferHeader: Record "Transfer Header";
        TestTransferHeader: Record "Transfer Header";
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        ReleaseTransferDoc: Codeunit "Release Transfer Document";
        RecRef2: RecordRef;
        CSPostingBuffer2: Record "NPR CS Posting Buffer";
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
    begin
        RecRef.SetTable(WhseActivityHeader);
        WhseActivityHeader.Find;
        DocNo := WhseActivityHeader."No.";
        SourceNo := WhseActivityHeader."Source No.";
        WhseActivityPosted := false;
        IsInvtPick := false;

        if CSPostingBuffer."Update Posting Date" then begin
            WhseActivityHeader.Validate("Posting Date", Today);
            WhseActivityHeader.Modify(true);
        end;

        Clear(WhseActivityLine);
        WhseActivityLine.SetRange("No.", WhseActivityHeader."No.");
        if WhseActivityLine.FindSet then begin
            repeat
                case WhseActivityHeader.Type of
                    WhseActivityHeader.Type::Pick, WhseActivityHeader.Type::"Put-away":
                        begin
                            if CheckBalanceQtyToHandle(WhseActivityLine) then begin
                                WhseActivityRegister.ShowHideDialog(true);
                                WhseActivityRegister.Run(WhseActivityLine);
                            end;
                        end;
                    WhseActivityHeader.Type::"Invt. Pick", WhseActivityHeader.Type::"Invt. Put-away":
                        begin
                            if WhseActivityLine."Qty. to Handle" <> 0 then begin
                                WhseActivityPost.SetInvoiceSourceDoc(CSPostingBuffer."Posting Index" = 2);
                                WhseActivityPost.Run(WhseActivityLine);
                                WhseActivityPosted := true;
                                IsInvtPick := true;
                                Clear(WhseActivityPost);
                            end;
                        end;
                end;
            until WhseActivityLine.Next = 0;
        end;

        if (CSPostingBuffer."Posting Index" = 2) and WhseActivityPosted and IsInvtPick then begin
            if SourceNo <> '' then begin
                if TransferHeader.Get(SourceNo) then begin

                    if WhseActivityHeader.Get(WhseActivityHeader.Type::"Invt. Pick", DocNo) then
                        WhseActivityHeader.Delete(true);

                    if TransferHeader.Get(SourceNo) then begin
                        RecRef2.GetTable(TransferHeader);
                        CSPostingBuffer2.Init;
                        CSPostingBuffer2."Table No." := RecRef2.Number;
                        CSPostingBuffer2."Record Id" := RecRef2.RecordId;
                        CSPostingBuffer2."Job Type" := CSPostingBuffer2."Job Type"::"Transfer Order";
                        if CSPostingBuffer2.Insert(true) then
                            CSPostEnqueue.Run(CSPostingBuffer2);
                    end;
                end;
            end;
        end;
    end;

    procedure PostItemJournal(var RecRef: RecordRef)
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        CSStockTakes: Record "NPR CS Stock-Takes";
        DocumentNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        RecRef.SetTable(ItemJournalBatch);
        ItemJournalBatch.Find;

        ItemJnlTemplate.Get(ItemJournalBatch."Journal Template Name");
        ItemJnlTemplate.TestField("Force Posting Report", false);

        if (ItemJournalBatch."No. Series" <> '') then begin
            DocumentNo := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", WorkDate, false);
            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
            ItemJournalLine.ModifyAll("Document No.", DocumentNo, false);
        end;

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        if ItemJournalLine.FindSet then begin
            repeat
                ItemJnlPostBatch.Run(ItemJournalLine);
            until ItemJournalLine.Next = 0;
        end;

        Clear(CSStockTakes);
        CSStockTakes.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        CSStockTakes.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        CSStockTakes.SetRange("Journal Posted", false);
        if CSStockTakes.FindSet then begin
            repeat
                CSStockTakes.Closed := CurrentDateTime;
                CSStockTakes."Closed By" := UserId;
                CSStockTakes."Journal Posted" := true;
                CSStockTakes.Modify(true);
            until CSStockTakes.Next = 0;
        end;
    end;

    local procedure PostItemReclassJournal(var RecRef: RecordRef; var CSPostingBuffer: Record "NPR CS Posting Buffer")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        DocumentNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        RecRef.SetTable(ItemJournalBatch);
        ItemJournalBatch.Find;

        ItemJnlTemplate.Get(ItemJournalBatch."Journal Template Name");
        ItemJnlTemplate.TestField("Force Posting Report", false);

        if (ItemJournalBatch."No. Series" <> '') then begin
            DocumentNo := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", WorkDate, false);
            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
            ItemJournalLine.SetRange("External Document No.", CSPostingBuffer."Session Id");
            ItemJournalLine.ModifyAll("Document No.", DocumentNo, false);
        end;

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.SetRange("External Document No.", CSPostingBuffer."Session Id");
        if ItemJournalLine.FindSet then begin
            repeat
                ItemJnlPostBatch.Run(ItemJournalLine);
            until ItemJournalLine.Next = 0;
        end;
    end;

    procedure PostStoreApprovel(var RecRef: RecordRef)
    var
        CSStockTakes: Record "NPR CS Stock-Takes";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
        BaseItemJournalLine: Record "Item Journal Line";
        TestItemJournalLine: Record "Item Journal Line";
        LineNo: Integer;
        CSStockTakesDataQy: Query "NPR CS Stock-Takes Data";
        ItemJournalLine: Record "Item Journal Line";
        NewItemJournalLine: Record "Item Journal Line";
        ResetItemJournalLine: Record "Item Journal Line";
        CSStockTakesDataTb: Record "NPR CS Stock-Takes Data";
        PostingRecRef: RecordRef;
        CSPostingBuffer: Record "NPR CS Posting Buffer";
        CSPostEnqueue: Codeunit "NPR CS Post - Enqueue";
        CalcItemJournalLine: Record "Item Journal Line";
        QtyCalculated: Decimal;
    begin
        RecRef.SetTable(CSStockTakes);
        CSStockTakes.Find;

        if CSStockTakes."Journal Posted" then
            exit;

        ItemJournalBatch.Get(CSStockTakes."Journal Template Name", CSStockTakes."Journal Batch Name");
        ItemJournalTemplate.Get(ItemJournalBatch."Journal Template Name");

        ItemJournalTemplate.TestField("Source Code");

        QtyCalculated := 0;
        Clear(CalcItemJournalLine);
        CalcItemJournalLine.SetRange("Journal Template Name", CSStockTakes."Journal Template Name");
        CalcItemJournalLine.SetRange("Journal Batch Name", CSStockTakes."Journal Batch Name");
        CalcItemJournalLine.SetRange("Location Code", CSStockTakes.Location);
        if CalcItemJournalLine.FindSet then begin
            repeat
                QtyCalculated += CalcItemJournalLine."Qty. (Calculated)"
            until CalcItemJournalLine.Next = 0;
        end;

        if CSStockTakes."Predicted Qty." <> QtyCalculated then
            Error(Text025, CSStockTakes."Predicted Qty.", QtyCalculated);

        Clear(BaseItemJournalLine);
        BaseItemJournalLine.Init;
        BaseItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        BaseItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);
        BaseItemJournalLine."Location Code" := ItemJournalBatch.Name;
        BaseItemJournalLine."Document No." := Format(WorkDate);
        BaseItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
        BaseItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
        BaseItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

        Clear(TestItemJournalLine);
        TestItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
        TestItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
        if TestItemJournalLine.FindLast then
            LineNo := TestItemJournalLine."Line No." + 1000
        else
            LineNo := 1000;

        CSStockTakesDataQy.SetRange(Stock_Take_Id, CSStockTakes."Stock-Take Id");
        CSStockTakesDataQy.SetRange(Stock_Take_Config_Code, ItemJournalBatch."Journal Template Name");
        CSStockTakesDataQy.SetRange(Worksheet_Name, ItemJournalBatch.Name);
        CSStockTakesDataQy.SetRange(Transferred_To_Worksheet, false);
        CSStockTakesDataQy.Open;
        while CSStockTakesDataQy.Read do begin
            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
            ItemJournalLine.SetRange("Location Code", BaseItemJournalLine."Location Code");
            ItemJournalLine.SetRange("Item No.", CSStockTakesDataQy.ItemNo);
            ItemJournalLine.SetRange("Variant Code", CSStockTakesDataQy.Variant_Code);
            if not ItemJournalLine.FindSet then begin
                Clear(NewItemJournalLine);
                NewItemJournalLine.Validate("Journal Template Name", BaseItemJournalLine."Journal Template Name");
                NewItemJournalLine.Validate("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
                NewItemJournalLine."Line No." := LineNo;
                NewItemJournalLine.Insert(true);

                NewItemJournalLine.Validate("Entry Type", NewItemJournalLine."Entry Type"::"Positive Adjmt.");
                NewItemJournalLine.Validate("Item No.", CSStockTakesDataQy.ItemNo);
                NewItemJournalLine.Validate("Variant Code", CSStockTakesDataQy.Variant_Code);
                NewItemJournalLine.Validate("Location Code", BaseItemJournalLine."Location Code");
                NewItemJournalLine.Validate("Phys. Inventory", true);
                NewItemJournalLine.Validate("Qty. (Phys. Inventory)", CSStockTakesDataQy.Count_);
                NewItemJournalLine."Posting Date" := WorkDate;
                NewItemJournalLine."Document Date" := WorkDate;
                NewItemJournalLine.Validate("External Document No.", 'MOBILE');
                NewItemJournalLine.Validate("Changed by User", true);
                NewItemJournalLine."Document No." := BaseItemJournalLine."Document No.";
                NewItemJournalLine."Source Code" := BaseItemJournalLine."Source Code";
                NewItemJournalLine."Reason Code" := BaseItemJournalLine."Reason Code";
                NewItemJournalLine."Posting No. Series" := BaseItemJournalLine."Posting No. Series";
                NewItemJournalLine.Modify(true);
                LineNo += 1000;
            end else begin
                ItemJournalLine.Validate("Qty. (Phys. Inventory)", CSStockTakesDataQy.Count_);
                ItemJournalLine.Validate("Changed by User", true);
                ItemJournalLine.Modify(true);
            end;
        end;

        CSStockTakesDataQy.Close;

        Clear(ResetItemJournalLine);
        ResetItemJournalLine.SetRange("Journal Template Name", BaseItemJournalLine."Journal Template Name");
        ResetItemJournalLine.SetRange("Journal Batch Name", BaseItemJournalLine."Journal Batch Name");
        ResetItemJournalLine.SetRange("Location Code", BaseItemJournalLine."Location Code");
        ResetItemJournalLine.SetRange("Changed by User", false);
        if ResetItemJournalLine.FindSet then begin
            repeat
                ResetItemJournalLine.Validate("Qty. (Phys. Inventory)", 0);
                ResetItemJournalLine.Modify(true);
            until ResetItemJournalLine.Next = 0;
        end;

        Clear(CSStockTakesDataTb);
        CSStockTakesDataTb.SetRange("Stock-Take Id", CSStockTakes."Stock-Take Id");
        CSStockTakesDataTb.SetRange("Stock-Take Config Code", ItemJournalBatch."Journal Template Name");
        CSStockTakesDataTb.SetRange("Worksheet Name", ItemJournalBatch.Name);
        CSStockTakesDataTb.ModifyAll("Transferred To Worksheet", true);

        if CSStockTakes.Approved = 0DT then begin
            CSStockTakes.Approved := CurrentDateTime;
            CSStockTakes."Approved By" := UserId;
            CSStockTakes.Modify(true);
        end;

        if not CSStockTakes."Manuel Posting" then begin
            PostingRecRef.GetTable(ItemJournalBatch);
            CSPostingBuffer.Init;
            CSPostingBuffer."Table No." := PostingRecRef.Number;
            CSPostingBuffer."Record Id" := PostingRecRef.RecordId;
            CSPostingBuffer."Job Type" := CSPostingBuffer."Job Type"::"Store Counting";
            CSPostingBuffer."Job Queue Priority for Post" := 2000;
            if CSPostingBuffer.Insert(true) then
                CSPostEnqueue.Run(CSPostingBuffer);
        end;
    end;

    local procedure PostUnplannedCounting(var RecRef: RecordRef; var CSPostingBuffer: Record "NPR CS Posting Buffer")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        RecRef.SetTable(ItemJournalBatch);
        if not ItemJournalBatch.Find then
            exit;

        ItemJnlTemplate.Get(ItemJournalBatch."Journal Template Name");
        ItemJnlTemplate.TestField("Force Posting Report", false);

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.SetRange("External Document No.", CSPostingBuffer."Session Id");
        if ItemJournalLine.FindSet then begin
            repeat
                ItemJnlPostBatch.Run(ItemJournalLine);
            until ItemJournalLine.Next = 0;
        end;
    end;

    local procedure PostItemJournalLine(var RecRef: RecordRef)
    var
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJournalBatch: Record "Item Journal Batch";
        DocumentNo: Code[20];
        UpdateItemJournalLine: Record "Item Journal Line";
    begin
        RecRef.SetTable(ItemJournalLine);
        ItemJournalLine.Find;
        ItemJnlTemplate.Get(ItemJournalLine."Journal Template Name");
        ItemJnlTemplate.TestField("Force Posting Report", false);

        if ItemJournalBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name") then begin
            if (ItemJournalBatch."No. Series" <> '') then begin
                ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series", WorkDate, false);
                ItemJournalLine.Modify;
            end;
        end;

        ItemJnlPostBatch.Run(ItemJournalLine);
    end;

    local procedure "-- Helper functions"()
    begin
    end;

    procedure CheckBalanceQtyToHandle(var WhseActivLine2: Record "Warehouse Activity Line"): Boolean
    var
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivLine3: Record "Warehouse Activity Line";
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        QtyToPick: Decimal;
        QtyToPutAway: Decimal;
        ErrorText: Text[250];
    begin
        WhseActivLine.Copy(WhseActivLine2);
        with WhseActivLine do begin
            SetCurrentKey("Activity Type", "No.", "Item No.", "Variant Code", "Action Type");
            SetRange("Activity Type", "Activity Type");
            SetRange("No.", "No.");
            SetRange("Action Type");
            if FindSet then
                repeat
                    if not TempWhseActivLine.Get("Activity Type", "No.", "Line No.") then begin
                        WhseActivLine3.Copy(WhseActivLine);

                        WhseActivLine3.SetRange("Item No.", "Item No.");
                        WhseActivLine3.SetRange("Variant Code", "Variant Code");
                        WhseActivLine3.SetRange("Serial No.", "Serial No.");
                        WhseActivLine3.SetRange("Lot No.", "Lot No.");

                        if (WhseActivLine2."Action Type" = WhseActivLine2."Action Type"::Take) or
                           (WhseActivLine2.GetFilter("Action Type") = '')
                        then begin
                            WhseActivLine3.SetRange("Action Type", WhseActivLine3."Action Type"::Take);
                            if WhseActivLine3.FindSet then
                                repeat
                                    QtyToPick := QtyToPick + WhseActivLine3."Qty. to Handle (Base)";
                                    TempWhseActivLine := WhseActivLine3;
                                    TempWhseActivLine.Insert;
                                until WhseActivLine3.Next = 0;
                        end;

                        if (WhseActivLine2."Action Type" = WhseActivLine2."Action Type"::Place) or
                           (WhseActivLine2.GetFilter("Action Type") = '')
                        then begin
                            WhseActivLine3.SetRange("Action Type", WhseActivLine3."Action Type"::Place);
                            if WhseActivLine3.FindSet then
                                repeat
                                    QtyToPutAway := QtyToPutAway + WhseActivLine3."Qty. to Handle (Base)";
                                    TempWhseActivLine := WhseActivLine3;
                                    TempWhseActivLine.Insert;
                                until WhseActivLine3.Next = 0;
                        end;

                        if QtyToPick <> QtyToPutAway then begin
                            if (WhseActivLine3.GetFilter("Serial No.") <> '') or
                               (WhseActivLine3.GetFilter("Lot No.") <> '')
                            then
                                Error(
                                    Text023,
                                    FieldCaption("Item No."), "Item No.",
                                    FieldCaption("Variant Code"), "Variant Code",
                                    FieldCaption("Lot No."), "Lot No.",
                                    FieldCaption("Serial No."), "Serial No.",
                                    QtyToPick, QtyToPutAway)
                            else
                                Error(
                                    Text024,
                                    FieldCaption("Item No."), "Item No.", FieldCaption("Variant Code"),
                                    "Variant Code", QtyToPick, QtyToPutAway);
                            exit(false);
                        end;

                        QtyToPick := 0;
                        QtyToPutAway := 0;
                    end;
                until Next = 0;
        end;
        exit(true);
    end;
}
