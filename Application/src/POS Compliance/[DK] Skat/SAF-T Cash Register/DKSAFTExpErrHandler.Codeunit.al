codeunit 6184673 "NPR DK SAF-T Exp. Err. Handler"
{
    Access = Internal;
    TableNo = "NPR DK SAF-T Cash Export Line";

    trigger OnRun()
    var
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
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