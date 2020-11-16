codeunit 6060044 "NPR Item Wsht.-Regist. Batch"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR5.25\BR \20160718 CASE 246088 Added Parameter to CheckLines
    // NPR5.55/TJ  /20200304 CASE 388960 Added function DeleteWorksheetLine and publisher OnAfterRegisterLines

    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        ItemWkshLine.Copy(Rec);
        Code;
        Copy(ItemWkshLine);
    end;

    var
        ItemWkshLine: Record "NPR Item Worksheet Line";
        ItemWkshCheckLine: Codeunit "NPR Item Wsht.-Check Line";
        ItemWorksheet: Record "NPR Item Worksheet";
        RegisteredItemWorksheet: Record "NPR Registered Item Works.";
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        NextEntryNo: Integer;
        Window: Dialog;
        StartLineNo: Integer;
        NoOfRecords: Integer;
        Text1002: Label 'Checking lines        #2######\';
        Text1005: Label 'Register lines         #3###### @4@@@@@@@@@@@@@';

    local procedure "Code"()
    begin
        with ItemWkshLine do begin
            LockTable;

            if not Find('=><') then begin
                "Line No." := 0;
                Commit;
                exit;
            end;

            ItemWorksheetTemplate.Get("Worksheet Template Name");

            CreateWindow;

            CheckLines;

            CreateRegisteredWorksheet;

            RegisterLines;

            //DeleteLines;
            //-NPR5.55 [388960]
            OnAfterRegisterLines(ItemWkshLine);
            DeleteWorksheetLine();
            //+NPR5.55 [388960]

            Commit;
        end;
    end;

    local procedure DeleteLines()
    var
        ItemWkshLine2: Record "NPR Item Worksheet Line";
        ItemWkshtVariantLine2: Record "NPR Item Worksh. Variant Line";
        ItemWkshtVarietyValueLine2: Record "NPR Item Worksh. Variety Value";
    begin
        ItemWkshLine2.Copy(ItemWkshLine);
        if ItemWkshLine2.FindSet then
            repeat
                ItemWkshtVariantLine2.SetRange("Worksheet Name", ItemWkshLine2."Worksheet Name");
                ItemWkshtVariantLine2.SetRange("Worksheet Line No.", ItemWkshLine2."Line No.");
                ItemWkshtVariantLine2.DeleteAll;
                ItemWkshtVarietyValueLine2.SetRange("Worksheet Name", ItemWkshLine2."Worksheet Name");
                ItemWkshtVarietyValueLine2.SetRange("Worksheet Line No.", ItemWkshLine2."Line No.");
                ItemWkshtVarietyValueLine2.DeleteAll;
            until ItemWkshtVarietyValueLine2.Next = 0;
    end;

    local procedure CreateWindow()
    begin
        Window.Open(
          Text1002 +
          Text1005);
    end;

    local procedure CreateRegisteredWorksheet()
    begin
        if NextEntryNo = 0 then begin
            RegisteredItemWorksheet.LockTable;
            if RegisteredItemWorksheet.FindLast then
                NextEntryNo := RegisteredItemWorksheet."No.";
            NextEntryNo := NextEntryNo + 1;
        end;

        ItemWkshLine.FindFirst;
        ItemWkshLine.TestField("Worksheet Name");
        ItemWorksheet.Get(ItemWkshLine."Worksheet Template Name", ItemWkshLine."Worksheet Name");
        with RegisteredItemWorksheet do begin
            Init;
            "No." := NextEntryNo;
            "Worksheet Name" := ItemWorksheet.Name;
            Description := ItemWorksheet.Description;
            "Vendor No." := ItemWorksheet."Vendor No.";
            "Currency Code" := ItemWorksheet."Currency Code";
            "Prices Including VAT" := ItemWorksheet."Prices Including VAT";
            "Print Labels" := ItemWorksheet."Print Labels";
            "No. Series" := ItemWorksheet."No. Series";
            "Item Worksheet Template" := ItemWorksheet."Item Template Name";
            "Registered Date Time" := CurrentDateTime;
            "Registered by User ID" := UserId;
            "Item Group" := ItemWorksheet."Item Group";
            Insert(true);
        end;
    end;

    local procedure CheckLines()
    var
        LineCount: Integer;
    begin
        with ItemWkshLine do begin
            LineCount := 0;
            StartLineNo := "Line No.";
            repeat
                LineCount := LineCount + 1;
                Window.Update(2, LineCount);
                case ItemWorksheetTemplate."Error Handling" of
                    //-NPR5.25 [246088]
                    // ItemWorksheetTemplate."Error Handling" :: StopOnFirst :
                    //  ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,TRUE);
                    // ItemWorksheetTemplate."Error Handling" :: SkipItem :
                    //  ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,FALSE);
                    // ItemWorksheetTemplate."Error Handling" :: SkipVariant :
                    //  ItemWkshCheckLine.RunCheck(ItemWorksheetLine2,FALSE);
                    ItemWorksheetTemplate."Error Handling"::StopOnFirst:
                        ItemWkshCheckLine.RunCheck(ItemWkshLine, true, true);
                    ItemWorksheetTemplate."Error Handling"::SkipItem:
                        ItemWkshCheckLine.RunCheck(ItemWkshLine, false, true);
                    ItemWorksheetTemplate."Error Handling"::SkipVariant:
                        ItemWkshCheckLine.RunCheck(ItemWkshLine, false, true);
                //+NPR5.25 [246088]
                end;
                if Next = 0 then
                    FindFirst;
            until "Line No." = StartLineNo;
            NoOfRecords := LineCount;
        end;
    end;

    local procedure RegisterLines()
    var
        LineCount: Integer;
    begin
        with ItemWkshLine do begin
            LineCount := 0;
            FindSet;
            repeat
                LineCount := LineCount + 1;
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                CODEUNIT.Run(CODEUNIT::"NPR Item Wsht.Register Line", ItemWkshLine);
            until Next = 0;
        end;
    end;

    local procedure DeleteWorksheetLine()
    var
        ItemWkshLine2: Record "NPR Item Worksheet Line";
    begin
        //-NPR5.55 [388960]
        ItemWkshLine2.Copy(ItemWkshLine);
        if ItemWorksheetTemplate."Delete Processed Lines" then begin
            ItemWkshLine2.SetRange(Status, ItemWkshLine2.Status::Processed);
            if ItemWkshLine2.FindSet then
                repeat
                    if not (ItemWorksheetTemplate."Leave Skipped Line on Register" and (ItemWkshLine2.Action = ItemWkshLine2.Action::Skip)) then
                        ItemWkshLine2.Delete(true);
                until ItemWkshLine2.Next = 0;
        end;
        //+NPR5.55 [388960]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterLines(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;
}

