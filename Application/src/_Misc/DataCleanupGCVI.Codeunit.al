codeunit 6060101 "NPR Data Cleanup GCVI"
{
    trigger OnRun()
    var
        SuccessLbl: Label 'SUCCESS', Locked = true;
    begin
        if GuiAllowed then
            if not Confirm(ProcessQst) then
                exit;

        DataCleanupCVI.SetCurrentKey("Cleanup Action", "Approve Delete", IsError, IsDeleted, Retries);
        DataCleanupCVI.SetRange("Cleanup Action", DataCleanupCVI."Cleanup Action"::Delete);
        DataCleanupCVI.SetRange("Approve Delete", true);
        DataCleanupCVI.SetRange(IsError, false);
        DataCleanupCVI.SetRange(IsDeleted, false);
        DataCleanupCVI.SetFilter(Retries, '<10');
        if DataCleanupCVI.FindSet() then
            repeat
                DataCleanupCVI2.Get(DataCleanupCVI."Cleanup Action", DataCleanupCVI.Type, DataCleanupCVI."No.");
                if not CODEUNIT.Run(CODEUNIT::"NPR Data Cleanup GCVI Line", DataCleanupCVI2) then begin
                    DataCleanupCVI2.Status := GetLastErrorText;
                    DataCleanupCVI2.IsError := true;
                end else begin
                    DataCleanupCVI2.Status := SuccessLbl;
                    DataCleanupCVI2.IsDeleted := true;
                    DataCleanupCVI2.IsProcessed := true;
                    DataCleanupCVI2.Success := true;
                end;
                DataCleanupCVI2.Retries := DataCleanupCVI2.Retries + 1;
                DataCleanupCVI2.Modify(true);
                Commit();
            until DataCleanupCVI.Next() = 0;

        DataCleanupCVI.SetCurrentKey("Cleanup Action", "Approve Rename", IsError, IsRenamed, Retries);
        DataCleanupCVI.SetRange("Cleanup Action", DataCleanupCVI."Cleanup Action"::Rename);
        DataCleanupCVI.SetRange("Approve Rename", true);
        DataCleanupCVI.SetRange(IsError, false);
        DataCleanupCVI.SetRange(IsRenamed, false);
        DataCleanupCVI.SetFilter(Retries, '<10');
        if DataCleanupCVI.FindSet(false, false) then
            repeat
                DataCleanupCVI2.Get(DataCleanupCVI."Cleanup Action", DataCleanupCVI.Type, DataCleanupCVI."No.");

                if not CODEUNIT.Run(CODEUNIT::"NPR Data Cleanup GCVI Line", DataCleanupCVI2) then begin
                    DataCleanupCVI2.Status := GetLastErrorText;
                    DataCleanupCVI2.IsError := true;
                end else begin
                    DataCleanupCVI2.Status := SuccessLbl;
                    DataCleanupCVI2.IsRenamed := true;
                    DataCleanupCVI2.IsProcessed := true;
                    DataCleanupCVI2.Success := true;
                end;
                DataCleanupCVI2.Retries := DataCleanupCVI2.Retries + 1;
                DataCleanupCVI2.Modify(true);
                Commit();
            until DataCleanupCVI.Next() = 0;
        Message(DoneMsg);
    end;

    var
        DataCleanupCVI: Record "NPR Data Cleanup GCVI";
        DataCleanupCVI2: Record "NPR Data Cleanup GCVI";
        ProcessQst: Label 'Do you want to process(delete/rename) entries in Data Cleanup table?';
        DoneMsg: Label 'Task completed !';
}

