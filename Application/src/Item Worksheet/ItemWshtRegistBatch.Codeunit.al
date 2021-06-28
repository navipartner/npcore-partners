codeunit 6060044 "NPR Item Wsht.-Regist. Batch"
{
    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        ItemWkshLine.Copy(Rec);
        Code();
        Rec.Copy(ItemWkshLine);
    end;

    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWkshLine: Record "NPR Item Worksheet Line";
        RegisteredItemWorksheet: Record "NPR Registered Item Works.";
        ItemWkshCheckLine: Codeunit "NPR Item Wsht.-Check Line";
        Window: Dialog;
        NextEntryNo: Integer;
        NoOfRecords: Integer;
        StartLineNo: Integer;
        CheckingLinesLbl: Label 'Checking lines        #2######\';
        RegisterLinesLbl: Label 'Register lines         #3###### @4@@@@@@@@@@@@@';

    local procedure "Code"()
    begin
        ItemWkshLine.LockTable();

        if not ItemWkshLine.Find('=><') then begin
            ItemWkshLine."Line No." := 0;
            Commit();
            exit;
        end;

        ItemWorksheetTemplate.Get(ItemWkshLine."Worksheet Template Name");

        CreateWindow();
        CheckLines();
        CreateRegisteredWorksheet();
        RegisterLines();
        OnAfterRegisterLines(ItemWkshLine);
        DeleteWorksheetLine();

        Commit();
    end;

    local procedure CreateWindow()
    begin
        Window.Open(
          CheckingLinesLbl +
          RegisterLinesLbl);
    end;

    local procedure CreateRegisteredWorksheet()
    begin
        if NextEntryNo = 0 then begin
            RegisteredItemWorksheet.LockTable();
            if RegisteredItemWorksheet.FindLast() then
                NextEntryNo := RegisteredItemWorksheet."No.";
            NextEntryNo := NextEntryNo + 1;
        end;

        ItemWkshLine.FindFirst();
        ItemWkshLine.TestField("Worksheet Name");
        ItemWorksheet.Get(ItemWkshLine."Worksheet Template Name", ItemWkshLine."Worksheet Name");
        RegisteredItemWorksheet.Init();
        RegisteredItemWorksheet."No." := NextEntryNo;
        RegisteredItemWorksheet."Worksheet Name" := ItemWorksheet.Name;
        RegisteredItemWorksheet.Description := ItemWorksheet.Description;
        RegisteredItemWorksheet."Vendor No." := ItemWorksheet."Vendor No.";
        RegisteredItemWorksheet."Currency Code" := ItemWorksheet."Currency Code";
        RegisteredItemWorksheet."Prices Including VAT" := ItemWorksheet."Prices Including VAT";
        RegisteredItemWorksheet."Print Labels" := ItemWorksheet."Print Labels";
        RegisteredItemWorksheet."No. Series" := ItemWorksheet."No. Series";
        RegisteredItemWorksheet."Item Worksheet Template" := ItemWorksheet."Item Template Name";
        RegisteredItemWorksheet."Registered Date Time" := CurrentDateTime;
        RegisteredItemWorksheet."Registered by User ID" := UserId;
        RegisteredItemWorksheet."Item Group" := ItemWorksheet."Item Group";
        RegisteredItemWorksheet.Insert(true);
    end;

    local procedure CheckLines()
    var
        LineCount: Integer;
    begin
        LineCount := 0;
        StartLineNo := ItemWkshLine."Line No.";
        repeat
            LineCount := LineCount + 1;
            Window.Update(2, LineCount);
            case ItemWorksheetTemplate."Error Handling" of
                ItemWorksheetTemplate."Error Handling"::StopOnFirst:
                    ItemWkshCheckLine.RunCheck(ItemWkshLine, true, true);
                ItemWorksheetTemplate."Error Handling"::SkipItem:
                    ItemWkshCheckLine.RunCheck(ItemWkshLine, false, true);
                ItemWorksheetTemplate."Error Handling"::SkipVariant:
                    ItemWkshCheckLine.RunCheck(ItemWkshLine, false, true);
            end;
            if ItemWkshLine.Next() = 0 then
                ItemWkshLine.FindFirst();
        until ItemWkshLine."Line No." = StartLineNo;
        NoOfRecords := LineCount;
    end;


    local procedure RegisterLines()
    var
        LineCount: Integer;
    begin
        LineCount := 0;
        ItemWkshLine.FindSet();
        repeat
            LineCount := LineCount + 1;
            Window.Update(3, LineCount);
            Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
            CODEUNIT.Run(CODEUNIT::"NPR Item Wsht.Register Line", ItemWkshLine);
        until ItemWkshLine.Next() = 0;
    end;

    local procedure DeleteWorksheetLine()
    var
        ItemWkshLine2: Record "NPR Item Worksheet Line";
    begin
        ItemWkshLine2.Copy(ItemWkshLine);
        if ItemWorksheetTemplate."Delete Processed Lines" then begin
            ItemWkshLine2.SetRange(Status, ItemWkshLine2.Status::Processed);
            if ItemWkshLine2.FindSet() then
                repeat
                    if not (ItemWorksheetTemplate."Leave Skipped Line on Register" and (ItemWkshLine2.Action = ItemWkshLine2.Action::Skip)) then
                        ItemWkshLine2.Delete(true);
                until ItemWkshLine2.Next() = 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterLines(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;
}

