codeunit 6060044 "NPR Item Wsht.-Regist. Batch"
{
    Access = Public;
    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        ItemWkshLine.Copy(Rec);
        Code();
        Rec.Copy(ItemWkshLine);
    end;

    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWkshLine: Record "NPR Item Worksheet Line";
        ItemWkshCheckLine: Codeunit "NPR Item Wsht.-Check Line";
        Window: Dialog;
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
        if GuiAllowed then
            Window.Open(
              CheckingLinesLbl +
              RegisterLinesLbl);
    end;

    local procedure CreateRegisteredWorksheet()
    var
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWorksheetCU: Codeunit "NPR Item Worksheet";
    begin
        ItemWkshLine.FindFirst();
        ItemWkshLine.TestField("Worksheet Name");
        ItemWorksheet.Get(ItemWkshLine."Worksheet Template Name", ItemWkshLine."Worksheet Name");

        ItemWorksheetCU.InsertRegisteredWorksheet(ItemWorksheet);
    end;

    local procedure CheckLines()
    var
        LineCount: Integer;
    begin
        LineCount := 0;
        StartLineNo := ItemWkshLine."Line No.";
        repeat
            LineCount := LineCount + 1;
            if GuiAllowed then
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
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        LineCount: Integer;
    begin
        LineCount := 0;
        ItemWkshLine.FindSet();
        repeat
            LineCount := LineCount + 1;
            if GuiAllowed then begin
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
            end;
            ItemWorksheetLine := ItemWkshLine;
            Codeunit.Run(Codeunit::"NPR Item Wsht.Register Line", ItemWorksheetLine);
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
