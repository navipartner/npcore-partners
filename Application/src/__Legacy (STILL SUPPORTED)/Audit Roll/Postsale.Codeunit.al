codeunit 6014419 "NPR Post sale"
{
    // NPR5.36/TJ /20170920 CASE 286283 Renamed variables/function into english and into proper naming terminology

    TableNo = "NPR Audit Roll";

    trigger OnRun()
    var
        TempAuditRollPosting: Record "NPR Audit Roll Posting";
        PostTempAuditRoll: Codeunit "NPR Post Temp Audit Roll";
    begin
        Clear(PostTempAuditRoll);
        TempAuditRollPosting.DeleteAll;

        PostTempAuditRoll.SetPostingNo(PostTempAuditRoll.GetNewPostingNo(true));

        PostTempAuditRoll.StraksBogfCurrent(true);
        PostTempAuditRoll.StraksBogfVarePostFraAfslEksp(SalePOS, ImmediatlyPostItemEntries, Post);

        TempAuditRollPosting.TransferFromRevSilent(Rec, TempAuditRollPosting);
        PostTempAuditRoll.RemoveSuspendedPayouts(TempAuditRollPosting);
        TempAuditRollPosting.Reset;
        PostTempAuditRoll.RunPost(TempAuditRollPosting);
        TempAuditRollPosting.UpdateChangesSilent;

        TempAuditRollPosting.Reset;
        TempAuditRollPosting.DeleteAll;
        TempAuditRollPosting.TransferFromRevSilentItemLedg(Rec, TempAuditRollPosting);
        TempAuditRollPosting.Reset;
        PostTempAuditRoll.RunPostItemLedger(TempAuditRollPosting);
        TempAuditRollPosting.UpdateChangesSilent;
    end;

    var
        SalePOS: Record "NPR Sale POS";
        ImmediatlyPostItemEntries: Boolean;
        Post: Boolean;

    procedure SetParam(var SalePOS2: Record "NPR Sale POS"; PostItemEntries: Boolean; Post2: Boolean)
    begin
        SalePOS := SalePOS2;
        ImmediatlyPostItemEntries := PostItemEntries;
        Post := Post2;
    end;
}

