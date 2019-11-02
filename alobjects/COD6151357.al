codeunit 6151357 "CS Post"
{
    // NPR5.52/CLVA  /20190903  CASE 365967 Object created - NP Capture Service
    // NPR5.52/CLVA  /20190904  CASE 367425 Customer specific customerization
    // NPR5.52/CLVA  /20190925  CASE 370277 Changed "Document No." handling
    // NPR5.52/CLVA  /20190927  CASE 370509 Added support for Item Reclass. Journal Posting

    TableNo = "CS Posting Buffer";

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
          233  : begin
                    //-NPR5.52 [370509]
                    //PostItemJournal(RecRef);
                    case "Job Type" of
                      "Job Type"::"Phy. Inv. Journal","Job Type"::"Store Counting" : PostItemJournal(RecRef);
                      "Job Type"::"Item Reclass." : PostItemReclassJournal(RecRef,Rec);
                    end;
                    //-NPR5.52 [370509]
                 end;
          5740 : PostTransferOrder(RecRef);
          5766 : PostWhseActivity(RecRef,Rec);
        end;
    end;

    var
        Text023: Label '%1 = ''%2'', %3 = ''%4'', %5 = ''%6'', %7 = ''%8'': The total base quantity to take %9 must be equal to the total base quantity to place %10.';
        Text024: Label '%1 = ''%2'', %3 = ''%4'':\The total base quantity to take %5 must be equal to the total base quantity to place %6.';

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

    local procedure PostWhseActivity(var RecRef: RecordRef;var CSPostingBuffer: Record "CS Posting Buffer")
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
        CSPostingBuffer2: Record "CS Posting Buffer";
        CSPostEnqueue: Codeunit "CS Post - Enqueue";
    begin
        RecRef.SetTable(WhseActivityHeader);
        WhseActivityHeader.Find;
        DocNo := WhseActivityHeader."No.";
        SourceNo := WhseActivityHeader."Source No.";
        WhseActivityPosted := false;
        IsInvtPick := false;

        if CSPostingBuffer."Update Posting Date" then begin
          WhseActivityHeader.Validate("Posting Date",Today);
          WhseActivityHeader.Modify(true);
        end;

        Clear(WhseActivityLine);
        WhseActivityLine.SetRange("No.",WhseActivityHeader."No.");
        if WhseActivityLine.FindSet then begin
          repeat
            case WhseActivityHeader.Type of
              WhseActivityHeader.Type::Pick,WhseActivityHeader.Type::"Put-away" : begin
                if CheckBalanceQtyToHandle(WhseActivityLine) then begin
                  WhseActivityRegister.ShowHideDialog(true);
                  WhseActivityRegister.Run(WhseActivityLine);
                end;
              end;
              WhseActivityHeader.Type::"Invt. Pick",WhseActivityHeader.Type::"Invt. Put-away" : begin
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

        //-NPR5.52 [367425]
        if (CSPostingBuffer."Posting Index" = 2) and WhseActivityPosted and IsInvtPick then begin
          if SourceNo <> '' then begin
            if TransferHeader.Get(SourceNo) then begin

              if WhseActivityHeader.Get(WhseActivityHeader.Type::"Invt. Pick",DocNo) then
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
        //+NPR5.52 [367425]
    end;

    local procedure PostItemJournal(var RecRef: RecordRef)
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
        CSStockTakes: Record "CS Stock-Takes";
        DocumentNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        RecRef.SetTable(ItemJournalBatch);
        ItemJournalBatch.Find;

        ItemJnlTemplate.Get(ItemJournalBatch."Journal Template Name");
        ItemJnlTemplate.TestField("Force Posting Report",false);

        //-NPR5.52 [370277]
        if (ItemJournalBatch."No. Series" <> '') then begin
          DocumentNo := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",WorkDate,false);
          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
          ItemJournalLine.ModifyAll("Document No.",DocumentNo,false);
        end;
        //+NPR5.52 [370277]

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
        if ItemJournalLine.FindSet then begin
          repeat
            ItemJnlPostBatch.Run(ItemJournalLine);
          until ItemJournalLine.Next = 0;
        end;

        Clear(CSStockTakes);
        CSStockTakes.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
        CSStockTakes.SetRange("Journal Batch Name",ItemJournalBatch.Name);
        CSStockTakes.SetRange("Journal Posted",false);
        if CSStockTakes.FindSet then begin
          repeat
            CSStockTakes.Closed := CurrentDateTime;
            CSStockTakes."Closed By" := UserId;
            CSStockTakes."Journal Posted" := true;
            CSStockTakes.Modify(true);
          until CSStockTakes.Next = 0;
        end;
    end;

    local procedure PostItemReclassJournal(var RecRef: RecordRef;var CSPostingBuffer: Record "CS Posting Buffer")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        RecRef.SetTable(ItemJournalBatch);
        ItemJournalBatch.Find;

        ItemJnlTemplate.Get(ItemJournalBatch."Journal Template Name");
        ItemJnlTemplate.TestField("Force Posting Report",false);

        Clear(ItemJournalLine);
        ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
        ItemJournalLine.SetRange("External Document No.",CSPostingBuffer."Session Id");
        if ItemJournalLine.FindSet then begin
          repeat
            ItemJnlPostBatch.Run(ItemJournalLine);
          until ItemJournalLine.Next = 0;
        end;
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
          SetCurrentKey("Activity Type","No.","Item No.","Variant Code","Action Type");
          SetRange("Activity Type","Activity Type");
          SetRange("No.","No.");
          SetRange("Action Type");
          if FindSet then
            repeat
              if not TempWhseActivLine.Get("Activity Type","No.","Line No.") then begin
                WhseActivLine3.Copy(WhseActivLine);

                WhseActivLine3.SetRange("Item No.","Item No.");
                WhseActivLine3.SetRange("Variant Code","Variant Code");
                WhseActivLine3.SetRange("Serial No.","Serial No.");
                WhseActivLine3.SetRange("Lot No.","Lot No.");

                if (WhseActivLine2."Action Type" = WhseActivLine2."Action Type"::Take) or
                   (WhseActivLine2.GetFilter("Action Type") = '')
                then begin
                  WhseActivLine3.SetRange("Action Type",WhseActivLine3."Action Type"::Take);
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
                  WhseActivLine3.SetRange("Action Type",WhseActivLine3."Action Type"::Place);
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
                        FieldCaption("Item No."),"Item No.",
                        FieldCaption("Variant Code"),"Variant Code",
                        FieldCaption("Lot No."),"Lot No.",
                        FieldCaption("Serial No."),"Serial No.",
                        QtyToPick,QtyToPutAway)
                  else
                    Error(
                        Text024,
                        FieldCaption("Item No."),"Item No.",FieldCaption("Variant Code"),
                        "Variant Code",QtyToPick,QtyToPutAway);
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

