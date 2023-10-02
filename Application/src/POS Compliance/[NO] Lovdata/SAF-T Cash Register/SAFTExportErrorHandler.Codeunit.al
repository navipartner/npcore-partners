codeunit 6184523 "NPR SAF-T Export Error Handler"
{
    Access = Internal;
    TableNo = "NPR SAF-T Cash Export Line";

    trigger OnRun()
    var
        SAFTExportHeader: Record "NPR SAF-T Cash Export Header";
        SAFTExportMgt: Codeunit "NPR SAF-T Cash Export Mgt.";
    begin
        SAFTExportMgt.LogError(Rec);
        Rec.LockTable();
        Rec.Status := Rec.Status::Failed;
        Rec.Progress := 100;
        if Rec."No. Of Retries" > 0 then
            Rec."No. Of Retries" -= 1;
        Rec.Modify(true);

        SAFTExportHeader.Get(Rec.ID);
        SAFTExportMgt.UpdateExportStatus(SAFTExportHeader);
        SAFTExportMgt.StartExportLinesNotStartedYet(SAFTExportHeader);
    end;
}