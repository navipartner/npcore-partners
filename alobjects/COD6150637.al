codeunit 6150637 "POS Posting Control"
{
    // NPR5.38/BR  /20180105  CASE 294723 Object Created
    // NPR5.38/BR  /20180119  CASE 302791 Handle Separate session posting and regular posting the same way, commitwise
    // NPR5.42/MMV /20180504  CASE 314110 Incorrect posting parameter was set.
    // NPR5.52/ALPO/20190923  CASE 365326 POS Posting related fields moved to POS Posting Profiles from NP Retail Setup
    // NPR5.53/ALPO/20191104 CASE 375258 Check posted dimension consistency
    // NPR5.53/MMV /20191106 CASE 376362 Disabled subscriber. AutomaticPostEntry is directly invoked outside the POS entry creation transaction instead.


    trigger OnRun()
    begin
    end;

    var
        TextCouldNotBePosted: Label 'The POS Entry could not be posted. Please contact your system administrator to adjust the posting setup.';
        DimConsistencyErr: Label 'There was an attempt to post a transaction with inconsistent dimensions. The following values were used:\%1=%2, %3=%4, %5=%6.\RecordID: %7.\This indicates a programming bug, no a user error. Please contact system vendor.\\Error call stack:\%8\Ref. case ID 375258';
        GLSetup: Record "General Ledger Setup";
        GLSetupGot: Boolean;
        DimConsistencyErrHdr: Label 'Dimension consistency check error', Comment = '{Max.Length 140}';

    procedure AutomaticPostPeriodRegister(var POSPeriodRegister: Record "POS Period Register")
    var
        POSEntry: Record "POS Entry";
        NPRetailSetup: Record "NP Retail Setup";
        POSPostingProfile: Record "POS Posting Profile";
        ItemPost: Boolean;
        POSPost: Boolean;
        SessionNo: Integer;
    begin
        NPRetailSetup.Get;
        //-NPR5.52 [365326]-revoked
        /*CASE NPRetailSetup."Automatic Item Posting" OF
          NPRetailSetup."Automatic Item Posting"::No,
          NPRetailSetup."Automatic Item Posting"::AfterSale                : ItemPost := FALSE;
          NPRetailSetup."Automatic Item Posting"::AfterEndOfDay            : ItemPost := TRUE;
          NPRetailSetup."Automatic Item Posting"::AfterLastEndofDayStore   : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
          NPRetailSetup."Automatic Item Posting"::AfterLastEndofDayCompany : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
        END;
        CASE NPRetailSetup."Automatic POS Posting"OF
        //-NPR5.42 [314110]
        //  NPRetailSetup."Automatic POS Posting"::No,
        //  NPRetailSetup."Automatic POS Posting"::AfterSale                : ItemPost := FALSE;
        //  NPRetailSetup."Automatic POS Posting"::AfterEndOfDay            : ItemPost := TRUE;
        //  NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayStore   : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
        //  NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayCompany : ItemPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
          NPRetailSetup."Automatic POS Posting"::No,
          NPRetailSetup."Automatic POS Posting"::AfterSale                : POSPost := FALSE;
          NPRetailSetup."Automatic POS Posting"::AfterEndOfDay            : POSPost := TRUE;
          NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayStore   : POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister,POSPeriodRegister."POS Store Code");
          NPRetailSetup."Automatic POS Posting"::AfterLastEndofDayCompany : POSPost := OtherPOSUnitsAreClosed(POSPeriodRegister,'');
        //+NPR5.42 [314110]
        END;*/
        //+NPR5.52 [365326]-revoked
        //-NPR5.52 [365326]
        NPRetailSetup.GetPostingProfile(POSPeriodRegister."POS Unit No.", POSPostingProfile);
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
        //+NPR5.52 [365326]

        //IF NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::Direct THEN BEGIN  //NPR5.52 [365326]-revoked
        if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::Direct then begin  //NPR5.52 [365326]
            POSEntry.SetRange(POSEntry."POS Period Register No.", POSPeriodRegister."No.");
            PostEntry(POSEntry, ItemPost, POSPost)
        end else begin
            //IF NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::StartNewSession THEN BEGIN  //NPR5.52 [365326]-revoked
            if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::StartNewSession then begin  //NPR5.52 [365326]
                if ItemPost or POSPost then begin
                    Commit;
                    if not StartSession(SessionNo, CODEUNIT::"POS Auto Post Period Register", CompanyName, POSPeriodRegister) then begin
                        POSEntry.SetRange(POSEntry."POS Period Register No.", POSPeriodRegister."No.");
                        PostEntry(POSEntry, ItemPost, POSPost)
                    end;
                end;
            end;
        end;

    end;

    procedure AutomaticPostEntry(var POSEntry: Record "POS Entry")
    var
        NPRetailSetup: Record "NP Retail Setup";
        POSPostingProfile: Record "POS Posting Profile";
        ItemPost: Boolean;
        POSPost: Boolean;
        SessionNo: Integer;
    begin
        NPRetailSetup.Get;
        //-NPR5.52 [365326]-revoked
        //ItemPost := (NPRetailSetup."Automatic Item Posting" = NPRetailSetup."Automatic Item Posting"::AfterSale);
        //POSPost := (NPRetailSetup."Automatic POS Posting" = NPRetailSetup."Automatic POS Posting"::AfterSale);
        //IF NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::Direct THEN BEGIN
        //+NPR5.52 [365326]-revoked
        //-NPR5.52 [365326]
        NPRetailSetup.GetPostingProfile(POSEntry."POS Unit No.", POSPostingProfile);
        ItemPost := (POSPostingProfile."Automatic Item Posting" = POSPostingProfile."Automatic Item Posting"::AfterSale);
        POSPost := (POSPostingProfile."Automatic POS Posting" = POSPostingProfile."Automatic POS Posting"::AfterSale);
        if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::Direct then begin
            //+NPR5.52 [365326]
            POSEntry.SetRange("Entry No.", POSEntry."Entry No.");
            PostEntry(POSEntry, ItemPost, POSPost);
        end else begin
            //IF NPRetailSetup."Automatic Posting Method" = NPRetailSetup."Automatic Posting Method"::StartNewSession THEN BEGIN  //NPR5.52 [365326]-revoked
            if POSPostingProfile."Automatic Posting Method" = POSPostingProfile."Automatic Posting Method"::StartNewSession then begin  //NPR5.52 [365326]
                if ItemPost or POSPost then begin
                    Commit;
                    if not StartSession(SessionNo, CODEUNIT::"POS Auto Post Entry", CompanyName, POSEntry) then begin
                        POSEntry.SetRange("Entry No.", POSEntry."Entry No.");
                        PostEntry(POSEntry, ItemPost, POSPost);
                    end;
                end;
            end;
        end;
    end;

    procedure PostEntry(var POSEntry: Record "POS Entry"; ItemPost: Boolean; POSPost: Boolean)
    var
        NPRetailSetup: Record "NP Retail Setup";
        POSPostEntries: Codeunit "POS Post Entries";
    begin
        NPRetailSetup.Get;
        if not NPRetailSetup."Advanced POS Entries Activated" then
            exit;
        if not NPRetailSetup."Advanced Posting Activated" then
            exit;
        if (not ItemPost) and (not POSPost) then
            exit;
        Commit;
        POSPostEntries.SetPostItemEntries(ItemPost);
        POSPostEntries.SetPostPOSEntries(POSPost);
        //-NPR5.38 [302791]
        //POSPostEntries.RUN(POSEntry);
        if not POSPostEntries.Run(POSEntry) then
            Message(TextCouldNotBePosted);
        //+NPR5.38 [302791]
    end;

    local procedure PostEntriesInSeparateSession(var POSEntry: Record "POS Entry"; ItemPost: Boolean; POSPost: Boolean)
    var
        SessionNo: Integer;
        POSPostingLog: Record "POS Posting Log";
    begin
        if not StartSession(SessionNo, CODEUNIT::"POS Post Entries", CompanyName, POSEntry) then
            PostEntry(POSEntry, ItemPost, POSPost);
    end;

    local procedure OtherPOSUnitsAreClosed(var POSPeriodRegister: Record "POS Period Register"; POSStoreCode: Code[10]): Boolean
    var
        POSUnit: Record "POS Unit";
    begin
        POSUnit.SetFilter(Status, '<>%1', POSUnit.Status::CLOSED);
        POSUnit.SetFilter("No.", '<>%1', POSPeriodRegister."POS Unit No.");
        if POSStoreCode <> '' then
            POSUnit.SetFilter("POS Store Code", POSPeriodRegister."POS Store Code");
        exit(not POSUnit.IsEmpty);
    end;

    local procedure "//Dim. Consistency Check"()
    begin
    end;

    procedure CheckGlobalDimAndDimSetConsistency(RecID: RecordID; GlobalDim1: Code[20]; GlobalDim2: Code[20]; DimSetID: Integer; RespType: Option "Show Error","Log and Continue")
    var
        DimSetEntry: Record "Dimension Set Entry";
        LastErrorStack: Text;
    begin
        //-NPR5.53 [375258]
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
        //+NPR5.53 [375258]
    end;

    procedure DimUsageIsConsistent(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DimSetID: Integer) Ok: Boolean
    begin
        //-NPR5.53 [375258]
        if (DimSetID = 0) and (GlobalDim1 = '') and (GlobalDim2 = '') then
            exit(true);
        GetGLSetup;
        Ok := CheckDimInDimSet(GLSetup."Global Dimension 1 Code", GlobalDim1, DimSetID);
        if Ok then
            Ok := CheckDimInDimSet(GLSetup."Global Dimension 2 Code", GlobalDim2, DimSetID);
        //+NPR5.53 [375258]
    end;

    [TryFunction]
    local procedure CheckDimInDimSet(DimCode: Code[20]; DimValueCode: Code[20]; DimSetID: Integer)
    var
        DimSetEntry: Record "Dimension Set Entry";
    begin
        //-NPR5.53 [375258]
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
        //+NPR5.53 [375258]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSEntry', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSEntry(var SalePOS: Record "Sale POS"; var POSEntry: Record "POS Entry")
    begin
        //-NPR5.53 [375258]
        with POSEntry do
            CheckGlobalDimAndDimSetConsistency(RecordId, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID", 1);
        //+NPR5.53 [375258]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSPaymentLine', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSPmtLine(SalePOS: Record "Sale POS"; SaleLinePOS: Record "Sale Line POS"; POSEntry: Record "POS Entry"; POSPaymentLine: Record "POS Payment Line")
    begin
        //-NPR5.53 [375258]
        with POSPaymentLine do
            CheckGlobalDimAndDimSetConsistency(RecordId, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID", 1);
        //+NPR5.53 [375258]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSSalesLine', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSSalesLine(SalePOS: Record "Sale POS"; SaleLinePOS: Record "Sale Line POS"; POSEntry: Record "POS Entry"; var POSSalesLine: Record "POS Sales Line")
    begin
        //-NPR5.53 [375258]
        with POSSalesLine do
            CheckGlobalDimAndDimSetConsistency(RecordId, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID", 1);
        //+NPR5.53 [375258]
    end;

    local procedure GetGLSetup()
    begin
        //-NPR5.53 [375258]
        if GLSetupGot then
            exit;
        GLSetup.Get;
        GLSetupGot := true;
        //+NPR5.53 [375258]
    end;

    procedure MakeNote(RecID: RecordID; HeaderTxt: Text; MessageTxt: Text; FromUserID: Text[50]; SentToUserID: Text[50])
    var
        RecordLink: Record "Record Link";
    begin
        //-NPR5.53 [375258]
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
        //+NPR5.53 [375258]
    end;

    local procedure SetNoteURL(var RecordLink: Record "Record Link"; RecID: RecordID)
    var
        PageMgt: Codeunit "Page Management";
        PageID: Integer;
        Link: Text;
    begin
        //-NPR5.53 [375258]
        PageID := PageMgt.GetPageID(RecID);
        Link := GetUrl(CLIENTTYPE::Default, CompanyName, OBJECTTYPE::Page, PageID);
        RecordLink.URL1 := CopyStr(Link, 1, MaxStrLen(RecordLink.URL1));
        //if StrLen(Link) > MaxStrLen(RecordLink.URL1) then
        //  RecordLink.URL2 := CopyStr(Link,StrLen(RecordLink.URL1) + 1,MaxStrLen(RecordLink.URL2));
        //+NPR5.53 [375258]
    end;

    local procedure SetNoteText(var RecordLink: Record "Record Link"; NoteHeading: Text; NewNoteText: Text)
    var
        BinWriter: DotNet npNetBinaryWriter;
        OStr: OutStream;
        c1: Char;
        lf: Text;
        Note: Text;
    begin
        //-NPR5.53 [375258]
        c1 := 13;
        lf[1] := c1;
        Note := CopyStr(NoteHeading, 1, 140) + lf + ConvertStr(NewNoteText, '\', lf);

        RecordLink.Note.CreateOutStream(OStr, TEXTENCODING::UTF8);
        BinWriter := BinWriter.BinaryWriter(OStr);
        BinWriter.Write(Note);
        //+NPR5.53 [375258]
    end;
}

