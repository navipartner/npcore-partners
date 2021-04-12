codeunit 6150631 "NPR POS Post via Task Queue"
{

    TableNo = "Job Queue Entry";

    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";

    trigger OnRun()
    var
        POSPostEntries: Codeunit "NPR POS Post Entries";
        PostingDateOption: Integer;
        POSEntry: Record "NPR POS Entry";
        POSEntryNoFilter: Text;
        POSPeriodRegisterNoFilter: Text;
        ErrorDuringPosting: Boolean;
    begin
        CheckForParameters(Rec);

        POSPostEntries.SetPostCompressed(JQParamStrMgt.GetBoolean(ParamCompressed()));
        if JQParamStrMgt.GetBoolean(ParamItemPosting()) then begin
            POSPostEntries.SetPostItemEntries(true);
            POSEntry.SetFilter("Post Item Entry Status", '<2');
        end;
        if JQParamStrMgt.GetBoolean(ParamPosPosting()) then begin
            POSPostEntries.SetPostPOSEntries(true);
            POSEntry.SetFilter("Post Entry Status", '<2');
        end;

        POSPostEntries.SetPostPOSEntries(JQParamStrMgt.GetBoolean(ParamPosPosting()));
        POSPostEntries.SetStopOnError(JQParamStrMgt.GetBoolean(ParamStopOnError()));
        PostingDateOption := JQParamStrMgt.GetInteger(ParamDateOption());
        case PostingDateOption of
            0:
                ; //No Date Set
            1:
                POSPostEntries.SetPostingDate(true, false, Today);        //1: Set Posting Date to Today
            2:
                POSPostEntries.SetPostingDate(true, false, WorkDate());     //2: Set Posting Date to Workdate
            3:
                POSPostEntries.SetPostingDate(true, true, Today);         //3: Set Posting Date and Document Date to Today
            4:
                POSPostEntries.SetPostingDate(true, true, WorkDate());      //4: Set Posting Date and Document Date to Workdate
            5:
                POSPostEntries.SetPostingDate(true, false, Today - 1);    //5: Set Posting Date to Yesterday
            6:
                POSPostEntries.SetPostingDate(true, false, WorkDate() - 1); //6: Set Posting Date to Day before Workdate
            7:
                POSPostEntries.SetPostingDate(true, true, Today - 1);     //7: Set Posting Date and Document Date to Yesterday
            8:
                POSPostEntries.SetPostingDate(true, true, WorkDate() - 1);   //8: Set Posting Date and Document Date to Day before Workdate
        end;

        POSEntryNoFilter := JQParamStrMgt.GetText(ParamPosEntryNofilter());

        POSPeriodRegisterNoFilter := JQParamStrMgt.GetText(ParamPeriodRegNoFilter());

        if POSEntryNoFilter <> '' then
            POSEntry.SetFilter("Entry No.", POSEntryNoFilter);
        if POSPeriodRegisterNoFilter <> '' then
            POSEntry.SetFilter("POS Period Register No.", POSPeriodRegisterNoFilter);

        if POSEntry.IsEmpty() then
            exit;

        repeat
            if (POSEntry.FindLast()) then
                POSEntry.SetFilter("POS Period Register No.", '=%1', POSEntry."POS Period Register No.");

            POSPostEntries.Run(POSEntry);
            ErrorDuringPosting := not POSEntry.IsEmpty();

            POSEntry.SetFilter("POS Period Register No.", '0..');
            if (POSPeriodRegisterNoFilter <> '') then
                POSEntry.SetFilter("POS Period Register No.", POSPeriodRegisterNoFilter);

            Commit();

        until (ErrorDuringPosting or POSEntry.IsEmpty());
    end;

    procedure ParamItemPosting(): Text
    begin
        exit('ITEMPOSTING');
    end;

    procedure ParamPosPosting(): Text
    begin
        exit('POSPOSTING');
    end;

    procedure ParamCompressed(): Text
    begin
        exit('COMPRESSED');
    end;

    procedure ParamDateOption(): Text
    begin
        exit('DATEOPTION');
    end;

    procedure ParamStopOnError(): Text
    begin
        exit('STOPONERROR');
    end;

    procedure ParamPosEntryNofilter(): Text
    begin
        exit('POSENTRYNOFILTER');
    end;

    procedure ParamPeriodRegNoFilter(): Text
    begin
        exit('PERIODREGNOFILTER');
    end;

    local procedure CheckForParameters(var JobQueueEntry: Record "Job Queue Entry")
    var
        NoParamsErr: Label 'No Parameters found.';
        AddParamsQst: Label 'No Parameters found. Do you wish to have empty Parameters added?';
        EmptyParamsErr: Label 'Empty Parameters added. Please fill in the parameters before run this task again';
        ChangeMeTok: Label '=?';
    begin
        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");

        if JQParamStrMgt.HasParams() then
            exit;

        if not JQParamStrMgt.ParamStringContains(ChangeMeTok) then
            exit;

        if GuiAllowed() then
            if not Confirm(AddParamsQst) then
                Error(NoParamsErr);

        JobQueueEntry."Parameter String" := '';
        JobQueueEntry."Parameter String" += ParamCompressed() + ChangeMeTok + ',';
        JobQueueEntry."Parameter String" += ParamItemPosting() + ChangeMeTok + ',';
        JobQueueEntry."Parameter String" += ParamPosPosting() + ChangeMeTok + ',';
        JobQueueEntry."Parameter String" += ParamDateOption() + ChangeMeTok + ',';
        JobQueueEntry."Parameter String" += ParamStopOnError() + ChangeMeTok + ',';
        JobQueueEntry."Parameter String" += ParamPosEntryNofilter() + ChangeMeTok + ',';
        JobQueueEntry."Parameter String" += ParamPeriodRegNoFilter() + ChangeMeTok;
        JobQueueEntry.Modify();
        Commit();
        Error(EmptyParamsErr);
    end;
}