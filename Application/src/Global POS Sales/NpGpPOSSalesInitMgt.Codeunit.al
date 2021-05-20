codeunit 6151167 "NPR NpGp POS Sales Init Mgt."
{
    var
        POSSalePatternGuideLbl: Label '[PS] ~ POS Store Code\[PU] ~ POS Unit No.\[S] ~ Sales Ticket No.\[N] ~ Random Number\[N*3] ~ 3 Random Numbers\[AN] ~ Random Char\[AN*3] ~ 3 Random Chars';
        POSSaleLinePatternGuideLbl: Label '[PS] ~ POS Store Code\[PU] ~ POS Unit No.\[S] ~ Sales Ticket No.\[N] ~ Random Number\[N*3] ~ 3 Random Numbers\[AN] ~ Random Char\[AN*3] ~ 3 Random Chars\[NL] ~ Natural Line No.\[L] ~ Line No.';

    procedure InsertPosSalesEntries(var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary)
    var
        TempNpGpPOSSalesEntry2: Record "NPR NpGp POS Sales Entry" temporary;
    begin
        TempNpGpPOSSalesEntry2.Copy(TempNpGpPOSSalesEntry, true);
        Clear(TempNpGpPOSSalesEntry2);
        if not TempNpGpPOSSalesEntry2.FindSet() then
            exit;

        repeat
            InsertPosSalesEntry(TempNpGpPOSSalesEntry2, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry);
        until TempNpGpPOSSalesEntry2.Next() = 0;
    end;

    local procedure InsertPosSalesEntry(var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary)
    var
        NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry";
        TempNpGpPOSSalesLine2: Record "NPR NpGp POS Sales Line" temporary;
        TempNpGpPOSInfoPOSEntry2: Record "NPR NpGp POS Info POS Entry" temporary;
        DataLogMgt: Codeunit "NPR Data Log Management";
        RecRef: RecordRef;
    begin
        if TempNpGpPOSSalesEntry."POS Store Code" = '' then
            exit;
        if TempNpGpPOSSalesEntry."POS Unit No." = '' then
            exit;
        if TempNpGpPOSSalesEntry."Document No." = '' then
            exit;

        if not IncludeEntryType(TempNpGpPOSSalesEntry) then
            exit;

        NpGpPOSSalesEntry.SetCurrentKey("POS Store Code", "POS Unit No.", "Document No.");
        NpGpPOSSalesEntry.SetRange("POS Store Code", TempNpGpPOSSalesEntry."POS Store Code");
        NpGpPOSSalesEntry.SetRange("POS Unit No.", TempNpGpPOSSalesEntry."POS Unit No.");
        NpGpPOSSalesEntry.SetRange("Document No.", TempNpGpPOSSalesEntry."Document No.");
        if NpGpPOSSalesEntry.FindFirst() then
            exit;

        NpGpPOSSalesEntry.Init();
        NpGpPOSSalesEntry := TempNpGpPOSSalesEntry;
        NpGpPOSSalesEntry."Entry No." := 0;
        DataLogMgt.DisableDataLog(true);
        NpGpPOSSalesEntry.Insert(true);
        DataLogMgt.DisableDataLog(false);
        RecRef.GetTable(NpGpPOSSalesEntry);
        DataLogMgt.OnDatabaseInsert(RecRef);

        TempNpGpPOSSalesLine2.Copy(TempNpGpPOSSalesLine, true);
        Clear(TempNpGpPOSSalesLine2);
        TempNpGpPOSSalesLine2.SetRange("POS Entry No.", TempNpGpPOSSalesEntry."Entry No.");
        if TempNpGpPOSSalesLine2.FindSet() then
            repeat
                InsertPosSalesLine(NpGpPOSSalesEntry, TempNpGpPOSSalesLine2);
            until TempNpGpPOSSalesLine2.Next() = 0;

        TempNpGpPOSInfoPOSEntry2.Copy(TempNpGpPOSInfoPOSEntry, true);
        Clear(TempNpGpPOSInfoPOSEntry2);
        TempNpGpPOSInfoPOSEntry2.SetRange("POS Entry No.", TempNpGpPOSSalesEntry."Entry No.");
        if TempNpGpPOSInfoPOSEntry2.FindSet() then
            repeat
                InsertPosInfoPosEntry(NpGpPOSSalesEntry, TempNpGpPOSInfoPOSEntry2);
            until TempNpGpPOSInfoPOSEntry2.Next() = 0;
    end;

    local procedure InsertPosSalesLine(NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary)
    var
        NpGpDetailedPOSSalesEntry: Record "NPR NpGp Det. POS Sales Entry";
        NpGpPOSSalesLine: Record "NPR NpGp POS Sales Line";
    begin
        if NpGpPOSSalesLine.Get(NpGpPOSSalesEntry."Entry No.", TempNpGpPOSSalesLine."Line No.") then
            exit;

        NpGpPOSSalesLine.Init();
        NpGpPOSSalesLine := TempNpGpPOSSalesLine;
        NpGpPOSSalesLine."POS Entry No." := NpGpPOSSalesEntry."Entry No.";
        NpGpPOSSalesLine."POS Store Code" := NpGpPOSSalesEntry."POS Store Code";
        NpGpPOSSalesLine."POS Unit No." := NpGpPOSSalesEntry."POS Unit No.";
        NpGpPOSSalesLine."Document No." := NpGpPOSSalesEntry."Document No.";
        NpGpPOSSalesLine.Insert(true);

        NpGpDetailedPOSSalesEntry.Init();
        NpGpDetailedPOSSalesEntry."Entry No." := 0;
        NpGpDetailedPOSSalesEntry."POS Entry No." := NpGpPOSSalesLine."POS Entry No.";
        NpGpDetailedPOSSalesEntry."POS Sales Line No." := NpGpPOSSalesLine."Line No.";
        NpGpDetailedPOSSalesEntry."POS Store Code" := NpGpPOSSalesEntry."POS Store Code";
        NpGpDetailedPOSSalesEntry."POS Unit No." := NpGpPOSSalesEntry."POS Unit No.";
        NpGpDetailedPOSSalesEntry."Document No." := NpGpPOSSalesEntry."Document No.";
        NpGpDetailedPOSSalesEntry."Entry Time" := CurrentDateTime;
        NpGpDetailedPOSSalesEntry."Entry Type" := NpGpDetailedPOSSalesEntry."Entry Type"::Initial;
        NpGpDetailedPOSSalesEntry.Quantity := NpGpPOSSalesLine."Quantity (Base)";
        NpGpDetailedPOSSalesEntry.Positive := NpGpDetailedPOSSalesEntry.Quantity > 0;
        NpGpDetailedPOSSalesEntry."Remaining Quantity" := NpGpDetailedPOSSalesEntry.Quantity;
        NpGpDetailedPOSSalesEntry.Open := NpGpDetailedPOSSalesEntry.Quantity <> 0;
        NpGpDetailedPOSSalesEntry.Insert(true);
    end;

    local procedure InsertPosInfoPosEntry(NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry"; var TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary)
    var
        NpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry";
    begin
        if NpGpPOSInfoPOSEntry.Get(NpGpPOSSalesEntry."Entry No.", TempNpGpPOSInfoPOSEntry."POS Info Code", TempNpGpPOSInfoPOSEntry."Entry No.") then
            exit;

        NpGpPOSInfoPOSEntry.Init();
        NpGpPOSInfoPOSEntry := TempNpGpPOSInfoPOSEntry;
        NpGpPOSInfoPOSEntry."POS Entry No." := NpGpPOSSalesEntry."Entry No.";
        NpGpPOSInfoPOSEntry.Insert(true);
    end;

    local procedure IncludeEntryType(NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry"): Boolean
    begin
        case NpGpPOSSalesEntry."Entry Type" of
            NpGpPOSSalesEntry."Entry Type"::Comment:
                exit(false);
            NpGpPOSSalesEntry."Entry Type"::"Direct Sale":
                exit(true);
            NpGpPOSSalesEntry."Entry Type"::Other:
                exit(false);
            NpGpPOSSalesEntry."Entry Type"::"Credit Sale":
                exit(true);
            NpGpPOSSalesEntry."Entry Type"::Balancing:
                exit(false);
            NpGpPOSSalesEntry."Entry Type"::"Cancelled Sale":
                exit(false);
        end;
    end;

    local procedure "-- Sync Setup"()
    begin
    end;

    procedure InitSyncSetup() TaskProcessorCode: Text
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        NcTaskSetup: Record "NPR Nc Task Setup";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        NcTaskSetup.SetRange("Table No.", DATABASE::"NPR POS Entry");
        NcTaskSetup.SetRange("Codeunit ID", CODEUNIT::"NPR NpGp POS Sales Sync Mgt.");
        if NcTaskSetup.FindFirst() then
            exit(NcTaskSetup."Task Processor Code");

        if not NcTaskProcessor.FindFirst() then begin
            NcSyncMgt.UpdateTaskProcessor(NcTaskProcessor);
            Commit();
            NcTaskProcessor.FindFirst();
        end;

        NcTaskSetup.Init();
        NcTaskSetup."Entry No." := 0;
        NcTaskSetup."Task Processor Code" := NcTaskProcessor.Code;
        NcTaskSetup."Table No." := DATABASE::"NPR POS Entry";
        NcTaskSetup."Codeunit ID" := CODEUNIT::"NPR NpGp POS Sales Sync Mgt.";
        NcTaskSetup.Insert();
        exit(NcTaskSetup."Task Processor Code");
    end;

    #region POS Cross Reference

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Cross Ref. Setup", 'OnDiscoverSetup', '', true, true)]
    local procedure OnDiscoverPOSCrossReferenceSetup(var Setup: Record "NPR POS Cross Ref. Setup")
    var
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        Setup.InitSetup(POSSale.TableName());
        Setup.InitSetup(POSSaleLine.TableName());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Cross Ref. Setup", 'OnAfterValidateEvent', 'Table Name', true, true)]
    local procedure OnValidateSetupTableName(var Rec: Record "NPR POS Cross Ref. Setup"; var xRec: Record "NPR POS Cross Ref. Setup")
    var
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        case Rec."Table Name" of
            POSSale.TableName():
                begin
                    Rec."Reference No. Pattern" := '[PS][PU][AN*2][S][AN*2]';
                    Rec."Pattern Guide" := CopyStr(POSSalePatternGuideLbl, 1, MaxStrLen(Rec."Pattern Guide"));
                end;
            POSSaleLine.TableName():
                begin
                    Rec."Reference No. Pattern" := '[PS][PU][NL][AN*2][S][AN*2]';
                    Rec."Pattern Guide" := CopyStr(POSSaleLinePatternGuideLbl, 1, MaxStrLen(Rec."Pattern Guide"));
                end;
            else begin
                    OnAfterValidateSetupTableName(Rec, xRec);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateSetupTableName(var Rec: Record "NPR POS Cross Ref. Setup"; var xRec: Record "NPR POS Cross Ref. Setup")
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Entry", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertPOSEntry(var Rec: Record "NPR POS Entry"; RunTrigger: Boolean)
    var
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        POSCrossRefMgt.UpdateReference(Rec.SystemId, Rec.TableName(), Rec."Document No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Entry Sales Line", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertPOSSalesLine(var Rec: Record "NPR POS Entry Sales Line"; RunTrigger: Boolean)
    var
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        POSCrossRefMgt.UpdateReference(Rec.SystemId, Rec.TableName(), Rec."Document No." + '_' + Format(Rec."Line No."));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSalePOS(var Rec: Record "NPR POS Sale"; RunTrigger: Boolean)
    var
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        POSCrossRefMgt.RemoveReference(Rec.SystemId, Rec.TableName());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSaleLinePOS(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        POSCrossRefMgt.RemoveReference(Rec.SystemId, Rec.TableName());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Entry", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeletePOSEntry(var Rec: Record "NPR POS Entry"; RunTrigger: Boolean)
    var
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        POSCrossRefMgt.RemoveReference(Rec.SystemId, Rec.TableName());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Entry Sales Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeletePOSSalesLine(var Rec: Record "NPR POS Entry Sales Line"; RunTrigger: Boolean)
    var
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        POSCrossRefMgt.RemoveReference(Rec.SystemId, Rec.TableName());
    end;

    procedure InitReferenceNoSaleLinePOS(SaleLinePOS: Record "NPR POS Sale Line") ReferenceNo: Text
    var
        POSCrossReference: Record "NPR POS Cross Reference";
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        if IsNullGuid(SaleLinePOS.SystemId) then
            exit('');

        if POSCrossReference.Get(SaleLinePOS.SystemId) then
            exit(POSCrossReference."Reference No.");

        ReferenceNo := GenerateLineReferenceNo(SaleLinePOS);
        POSCrossRefMgt.InitReference(
          SaleLinePOS.SystemId, ReferenceNo, POSSaleLine.TableName(), SaleLinePOS."Sales Ticket No." + '_' + Format(SaleLinePOS."Line No."));

        exit(ReferenceNo);
    end;

    local procedure GenerateLineReferenceNo(POSSaleLine: Record "NPR POS Sale Line") ReferenceNo: Text
    var
        POSUnit: Record "NPR POS Unit";
        POSCrossReference: Record "NPR POS Cross Reference";
        POSCrossRefSetup: Record "NPR POS Cross Ref. Setup";
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
        i: Integer;
        NaturalLineNo: Integer;
        NpRegEx: Codeunit "NPR RegEx";
    begin
        if not POSCrossRefSetup.Get(POSSaleLine.TableName()) then
            exit('');
        if POSCrossRefSetup."Reference No. Pattern" = '' then
            exit('');

        if POSUnit.Get(POSSaleLine."Register No.") then;

        for i := 1 to 10 do begin
            ReferenceNo := POSCrossRefSetup."Reference No. Pattern";
            ReferenceNo := NpRegEx.RegExReplacePS(ReferenceNo, POSUnit."POS Store Code");
            ReferenceNo := NpRegEx.RegExReplacePU(ReferenceNo, POSUnit."No.");
            ReferenceNo := NpRegEx.RegExReplaceS(ReferenceNo, POSSaleLine."Sales Ticket No.");
            ReferenceNo := NpRegEx.RegExReplaceN(ReferenceNo);
            ReferenceNo := NpRegEx.RegExReplaceAN(ReferenceNo);
            ReferenceNo := NpRegEx.RegExReplaceL(ReferenceNo, Format(POSSaleLine."Line No."));
            NaturalLineNo := GetNaturalLineNo(POSSaleLine);
            ReferenceNo := NpRegEx.RegExReplaceNL(ReferenceNo, Format(NaturalLineNo));
            ReferenceNo := UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(POSCrossReference."Reference No.")));

            if IsNullGuid(POSCrossRefMgt.GetSysID(POSSaleLine.TableName(), ReferenceNo)) then
                exit(ReferenceNo);

            if ReferenceNo = POSCrossRefSetup."Reference No. Pattern" then
                exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    local procedure GetNaturalLineNo(SaleLinePOS: Record "NPR POS Sale Line") NaturalLineNo: Integer
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
    begin
        SaleLinePOS2.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetFilter("Line No.", '<%1', SaleLinePOS."Line No.");
        NaturalLineNo := SaleLinePOS2.Count() + 1;
        exit(NaturalLineNo);
    end;

    #endregion
}

