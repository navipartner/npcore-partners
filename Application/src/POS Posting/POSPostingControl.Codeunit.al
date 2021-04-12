codeunit 6150637 "NPR POS Posting Control"
{
    var
        DimConsistencyErr: Label 'There was an attempt to post a transaction with inconsistent dimensions. The following values were used:\%1=%2, %3=%4, %5=%6.\RecordID: %7.\This indicates a programming bug, no a user error. Please contact system vendor.\\Error call stack:\%8\Ref. case ID 375258';
        GLSetup: Record "General Ledger Setup";
        GLSetupGot: Boolean;
        DimConsistencyErrHdr: Label 'Dimension consistency check error', Comment = '{Max.Length 140}';

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSEntry', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSEntry(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    begin
        CheckGlobalDimAndDimSetConsistency(POSEntry.RecordId(), POSEntry."Shortcut Dimension 1 Code", POSEntry."Shortcut Dimension 2 Code", POSEntry."Dimension Set ID", 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSPaymentLine', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSPmtLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; POSPaymentLine: Record "NPR POS Entry Payment Line")
    begin
        CheckGlobalDimAndDimSetConsistency(POSPaymentLine.RecordId(), POSPaymentLine."Shortcut Dimension 1 Code", POSPaymentLine."Shortcut Dimension 2 Code", POSPaymentLine."Dimension Set ID", 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', false, false)]
    local procedure CheckDimOnAfterInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
        CheckGlobalDimAndDimSetConsistency(POSSalesLine.RecordId(), POSSalesLine."Shortcut Dimension 1 Code", POSSalesLine."Shortcut Dimension 2 Code", POSSalesLine."Dimension Set ID", 1);
    end;

    local procedure GetGLSetup()
    begin
        if GLSetupGot then
            exit;
        GLSetup.Get();
        GLSetupGot := true;
    end;

    procedure MakeNote(RecID: RecordID; HeaderTxt: Text; MessageTxt: Text; FromUserID: Text[50]; SentToUserID: Text[50])
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.Init();
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
        RecordLink.Insert();
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

