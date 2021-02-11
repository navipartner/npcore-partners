codeunit 6150637 "NPR POS Posting Control"
{
    var
        TextCouldNotBePosted: Label 'The POS Entry could not be posted. Please contact your system administrator to adjust the posting setup.';
        DimConsistencyErr: Label 'There was an attempt to post a transaction with inconsistent dimensions. The following values were used:\%1=%2, %3=%4, %5=%6.\RecordID: %7.\This indicates a programming bug, no a user error. Please contact system vendor.\\Error call stack:\%8\Ref. case ID 375258';
        GLSetup: Record "General Ledger Setup";
        GLSetupGot: Boolean;
        DimConsistencyErrHdr: Label 'Dimension consistency check error', Comment = '{Max.Length 140}';

    procedure AutomaticPostPeriodRegister(var POSPeriodRegister: Record "NPR POS Period Register")
    var
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSUnit: Record "NPR POS Unit";
        ItemPost: Boolean;
        POSPost: Boolean;
        SessionNo: Integer;
    begin
        POSUnit.GetPostingProfile(POSPeriodRegister."POS Unit No.", POSPostingProfile);
        case POSPostingProfile."Automatic Item Posting" of
            POSPostingProfile."Automatic Item Posting"::No,
          POSPostingProfile."Automatic Item Posting"::AfterSale:
                ItemPost := false;
            POSPostingProfile."Automatic Item Posting"::AfterEndOfDay:
                ItemPost := true;
            POSPostingProfile."Automatic Item Posting"::AfterLastEndofDayStore:
                ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister, POSPeriodRegister."POS Store Code");
            POSPostingProfile."Automatic Item Posting"::AfterLastEndofDayCompany:
                ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister, '');
        end;
        case POSPostingProfile."Automatic POS Posting" of
            POSPostingProfile."Automatic POS Posting"::No,
          POSPostingProfile."Automatic POS Posting"::AfterSale:
                POSPost := false;
            POSPostingProfile."Automatic POS Posting"::AfterEndOfDay:
                POSPost := true;
            POSPostingProfile."Automatic POS Posting"::AfterLastEndofDayStore:
                POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister, POSPeriodRegister."POS Store Code");
            POSPostingProfile."Automatic POS Posting"::AfterLastEndofDayCompany:
                POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister, '');
        end;

        if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::Direct then begin
            POSEntry.SetRange(POSEntry."POS Period Register No.", POSPeriodRegister."No.");
            PostEntry(POSEntry, ItemPost, POSPost)
        end else begin
            if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::StartNewSession then begin
                if ItemPost or POSPost then begin
                    Commit;
                    if not StartSession(SessionNo, CODEUNIT::"NPR POS AutoPost PeriodRegist.", CompanyName, POSPeriodRegister) then begin
                        POSEntry.SetRange(POSEntry."POS Period Register No.", POSPeriodRegister."No.");
                        PostEntry(POSEntry, ItemPost, POSPost)
                    end;
                end;
            end;
        end;

    end;

    procedure AutomaticPostEntry(var POSEntry: Record "NPR POS Entry")
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSUnit: Record "NPR POS Unit";
        ItemPost: Boolean;
        POSPost: Boolean;
        SessionNo: Integer;
    begin
        POSUnit.GetPostingProfile(POSEntry."POS Unit No.", POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::Direct then begin
            POSEntry.SetRange("Entry No.", POSEntry."Entry No.");
            PostEntry(POSEntry, ItemPost, POSPost);
        end else begin
            if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::StartNewSession then begin
                if ItemPost or POSPost then begin
                    Commit;
                    if not StartSession(SessionNo, CODEUNIT::"NPR POS Auto Post Entry", CompanyName, POSEntry) then begin
                        POSEntry.SetRange("Entry No.", POSEntry."Entry No.");
                        PostEntry(POSEntry, ItemPost, POSPost);
                    end;
                end;
            end;
        end;
    end;

    procedure PostEntry(var POSEntry: Record "NPR POS Entry"; ItemPost: Boolean; POSPost: Boolean)
    var
        POSPostEntries: Codeunit "NPR POS Post Entries";
    begin
        if (not ItemPost) and (not POSPost) then
            exit;
        Commit;
        POSPostEntries.SetPostItemEntries(ItemPost);
        POSPostEntries.SetPostPOSEntries(POSPost);
        if not POSPostEntries.Run(POSEntry) then
            Message(TextCouldNotBePosted);
    end;

    local procedure PostEntriesInSeparateSession(var POSEntry: Record "NPR POS Entry"; ItemPost: Boolean; POSPost: Boolean)
    var
        SessionNo: Integer;
        POSPostingLog: Record "NPR POS Posting Log";
    begin
        if not StartSession(SessionNo, CODEUNIT::"NPR POS Post Entries", CompanyName, POSEntry) then
            PostEntry(POSEntry, ItemPost, POSPost);
    end;

    local procedure OtherPOSUnitsAreClosed(var POSPeriodRegister: Record "NPR POS Period Register"; POSStoreCode: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.SetFilter(Status, '<>%1', POSUnit.Status::CLOSED);
        POSUnit.SetFilter("No.", '<>%1', POSPeriodRegister."POS Unit No.");
        if POSStoreCode <> '' then
            POSUnit.SetFilter("POS Store Code", POSPeriodRegister."POS Store Code");
        exit(not POSUnit.IsEmpty);
    end;

    procedure CheckGlobalDimAndDimSetConsistency(RecID: RecordID; GlobalDim1: Code[20]; GlobalDim2: Code[20]; DimSetID: Integer; RespType: Option "Show Error","Log and Continue")
    var
        DimSetEntry: Record "Dimension Set Entry";
        LastErrorStack: Text;
    begin
        if DimUsageIsConsistent(GlobalDim1, GlobalDim2, DimSetID) then
            exit;
        GetGLSetup;
        LastErrorStack := GetLastErrorCallstack;
        case RespType of
            RespType::"Show Error":
                Error(DimConsistencyErr,
                  GLSetup.FieldCaption("Global Dimension 1 Code"), GlobalDim1,
                  GLSetup.FieldCaption("Global Dimension 2 Code"), GlobalDim2,
                  DimSetEntry.FieldCaption("Dimension Set ID"), DimSetID,
                  RecID,
                  LastErrorStack);

            RespType::"Log and Continue":
                MakeNote(
                  RecID,
                  DimConsistencyErrHdr,
                  StrSubstNo(DimConsistencyErr,
                    GLSetup.FieldCaption("Global Dimension 1 Code"), GlobalDim1,
                    GLSetup.FieldCaption("Global Dimension 2 Code"), GlobalDim2,
                    DimSetEntry.FieldCaption("Dimension Set ID"), DimSetID,
                    RecID,
                    LastErrorStack),
                    UserId, '');
        end;
    end;

    procedure DimUsageIsConsistent(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DimSetID: Integer) Ok: Boolean
    begin
        if (DimSetID = 0) and (GlobalDim1 = '') and (GlobalDim2 = '') then
            exit(true);
        GetGLSetup;
        Ok := CheckDimInDimSet(GLSetup."Global Dimension 1 Code", GlobalDim1, DimSetID);
        if Ok then
            Ok := CheckDimInDimSet(GLSetup."Global Dimension 2 Code", GlobalDim2, DimSetID);
    end;

    [TryFunction]
    local procedure CheckDimInDimSet(DimCode: Code[20]; DimValueCode: Code[20]; DimSetID: Integer)
    var
        DimSetEntry: Record "Dimension Set Entry";
    begin
        if DimCode = '' then
            exit;

        if DimValueCode <> '' then begin
            if DimSetID = 0 then
                Error('');
            DimSetEntry.Get(DimSetID, DimCode);
            DimSetEntry.TestField("Dimension Value Code", DimValueCode);
        end;

        if DimValueCode = '' then begin
            if DimSetID = 0 then
                exit;
            if DimSetEntry.Get(DimSetID, DimCode) then
                Error('');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSEntry', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSEntry(var SalePOS: Record "NPR Sale POS"; var POSEntry: Record "NPR POS Entry")
    begin
        with POSEntry do
            CheckGlobalDimAndDimSetConsistency(RecordId, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID", 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSPaymentLine', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSPmtLine(SalePOS: Record "NPR Sale POS"; SaleLinePOS: Record "NPR Sale Line POS"; POSEntry: Record "NPR POS Entry"; POSPaymentLine: Record "NPR POS Payment Line")
    begin
        with POSPaymentLine do
            CheckGlobalDimAndDimSetConsistency(RecordId, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID", 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSSalesLine', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSSalesLine(SalePOS: Record "NPR Sale POS"; SaleLinePOS: Record "NPR Sale Line POS"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Sales Line")
    begin
        with POSSalesLine do
            CheckGlobalDimAndDimSetConsistency(RecordId, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID", 1);
    end;

    local procedure GetGLSetup()
    begin
        if GLSetupGot then
            exit;
        GLSetup.Get;
        GLSetupGot := true;
    end;

    procedure MakeNote(RecID: RecordID; HeaderTxt: Text; MessageTxt: Text; FromUserID: Text[50]; SentToUserID: Text[50])
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.Init;
        RecordLink."Link ID" := 0;
        RecordLink."Record ID" := RecID;
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Company := CompanyName;
        RecordLink.Created := CurrentDateTime;
        RecordLink.Description := CopyStr(HeaderTxt, 1, MaxStrLen(RecordLink.Description));
        RecordLink."User ID" := FromUserID;
        RecordLink."To User ID" := SentToUserID;
        RecordLink.Notify := SentToUserID <> '';
        SetNoteURL(RecordLink, RecID);
        SetNoteText(RecordLink, HeaderTxt, MessageTxt);
        RecordLink.Insert;
    end;

    local procedure SetNoteURL(var RecordLink: Record "Record Link"; RecID: RecordID)
    var
        PageMgt: Codeunit "Page Management";
        PageID: Integer;
        Link: Text;
    begin
        PageID := PageMgt.GetPageID(RecID);
        Link := GetUrl(CLIENTTYPE::Default, CompanyName, OBJECTTYPE::Page, PageID);
        RecordLink.URL1 := CopyStr(Link, 1, MaxStrLen(RecordLink.URL1));
    end;

    local procedure SetNoteText(var RecordLink: Record "Record Link"; NoteHeading: Text; NewNoteText: Text)
    var
        OStr: OutStream;
        c1: Char;
        lf: Text;
        Note: Text;
    begin
        c1 := 13;
        lf[1] := c1;
        Note := CopyStr(NoteHeading, 1, 140) + lf + ConvertStr(NewNoteText, '\', lf);

        RecordLink.Note.CreateOutStream(OStr, TEXTENCODING::UTF8);
        OStr.WriteText(Note);
    end;
}

