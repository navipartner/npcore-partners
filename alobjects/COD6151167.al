codeunit 6151167 "NpGp POS Sales Init Mgt."
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.51/MHA /20190711  CASE 361618 Added Explicit DataLogMgt.OnDatabaseInsert() in InsertPosSalesEntry() to catch log of Autoincrement integer
    // NPR5.54/MMV /20200220 CASE 391871 Moved GUID creation from table subscribers to table trigger to have everything centralized.


    trigger OnRun()
    begin
    end;

    var
        Text000: Label '[PS] ~ POS Store Code\[PU] ~ POS Unit No.\[S] ~ Sales Ticket No.\[N] ~ Random Number\[N*3] ~ 3 Random Numbers\[AN] ~ Random Char\[AN*3] ~ 3 Random Chars';
        Text001: Label '[PS] ~ POS Store Code\[PU] ~ POS Unit No.\[S] ~ Sales Ticket No.\[N] ~ Random Number\[N*3] ~ 3 Random Numbers\[AN] ~ Random Char\[AN*3] ~ 3 Random Chars\[NL] ~ Natural Line No.\[L] ~ Line No.';

    local procedure "--- Global Pos Entry"()
    begin
    end;

    procedure InsertPosSalesEntries(var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary;var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSInfoPOSEntry: Record "NpGp POS Info POS Entry" temporary)
    var
        TempNpGpPOSSalesEntry2: Record "NpGp POS Sales Entry" temporary;
    begin
        TempNpGpPOSSalesEntry2.Copy(TempNpGpPOSSalesEntry,true);
        Clear(TempNpGpPOSSalesEntry2);
        if not TempNpGpPOSSalesEntry2.FindSet then
          exit;

        repeat
          InsertPosSalesEntry(TempNpGpPOSSalesEntry2,TempNpGpPOSSalesLine,TempNpGpPOSInfoPOSEntry);
        until TempNpGpPOSSalesEntry2.Next = 0;
    end;

    local procedure InsertPosSalesEntry(var TempNpGpPOSSalesEntry: Record "NpGp POS Sales Entry" temporary;var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSInfoPOSEntry: Record "NpGp POS Info POS Entry" temporary)
    var
        NpGpPOSSalesEntry: Record "NpGp POS Sales Entry";
        TempNpGpPOSSalesLine2: Record "NpGp POS Sales Line" temporary;
        TempNpGpPOSInfoPOSEntry2: Record "NpGp POS Info POS Entry" temporary;
        DataLogMgt: Codeunit "Data Log Management";
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

        NpGpPOSSalesEntry.SetCurrentKey("POS Store Code","POS Unit No.","Document No.");
        NpGpPOSSalesEntry.SetRange("POS Store Code",TempNpGpPOSSalesEntry."POS Store Code");
        NpGpPOSSalesEntry.SetRange("POS Unit No.",TempNpGpPOSSalesEntry."POS Unit No.");
        NpGpPOSSalesEntry.SetRange("Document No.",TempNpGpPOSSalesEntry."Document No.");
        if NpGpPOSSalesEntry.FindFirst then
          exit;

        NpGpPOSSalesEntry.Init;
        NpGpPOSSalesEntry := TempNpGpPOSSalesEntry;
        NpGpPOSSalesEntry."Entry No." := 0;
        //-NPR5.51 [361618]
        DataLogMgt.DisableDataLog(true);
        //+NPR5.51 [361618]
        NpGpPOSSalesEntry.Insert(true);
        //-NPR5.51 [361618]
        DataLogMgt.DisableDataLog(false);
        RecRef.GetTable(NpGpPOSSalesEntry);
        DataLogMgt.OnDatabaseInsert(RecRef);
        //+NPR5.51 [361618]

        TempNpGpPOSSalesLine2.Copy(TempNpGpPOSSalesLine,true);
        Clear(TempNpGpPOSSalesLine2);
        TempNpGpPOSSalesLine2.SetRange("POS Entry No.",TempNpGpPOSSalesEntry."Entry No.");
        if TempNpGpPOSSalesLine2.FindSet then
          repeat
            InsertPosSalesLine(NpGpPOSSalesEntry,TempNpGpPOSSalesLine2);
          until TempNpGpPOSSalesLine2.Next = 0;

        TempNpGpPOSInfoPOSEntry2.Copy(TempNpGpPOSInfoPOSEntry,true);
        Clear(TempNpGpPOSInfoPOSEntry2);
        TempNpGpPOSInfoPOSEntry2.SetRange("POS Entry No.",TempNpGpPOSSalesEntry."Entry No.");
        if TempNpGpPOSInfoPOSEntry2.FindSet then
          repeat
            InsertPosInfoPosEntry(NpGpPOSSalesEntry,TempNpGpPOSInfoPOSEntry2);
          until TempNpGpPOSInfoPOSEntry2.Next = 0;
    end;

    local procedure InsertPosSalesLine(NpGpPOSSalesEntry: Record "NpGp POS Sales Entry";var TempNpGpPOSSalesLine: Record "NpGp POS Sales Line" temporary)
    var
        NpGpDetailedPOSSalesEntry: Record "NpGp Detailed POS Sales Entry";
        NpGpPOSSalesLine: Record "NpGp POS Sales Line";
    begin
        if NpGpPOSSalesLine.Get(NpGpPOSSalesEntry."Entry No.",TempNpGpPOSSalesLine."Line No.") then
          exit;

        NpGpPOSSalesLine.Init;
        NpGpPOSSalesLine := TempNpGpPOSSalesLine;
        NpGpPOSSalesLine."POS Entry No." := NpGpPOSSalesEntry."Entry No.";
        NpGpPOSSalesLine."POS Store Code" := NpGpPOSSalesEntry."POS Store Code";
        NpGpPOSSalesLine."POS Unit No." := NpGpPOSSalesEntry."POS Unit No.";
        NpGpPOSSalesLine."Document No." := NpGpPOSSalesEntry."Document No.";
        NpGpPOSSalesLine.Insert(true);

        NpGpDetailedPOSSalesEntry.Init;
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

    local procedure InsertPosInfoPosEntry(NpGpPOSSalesEntry: Record "NpGp POS Sales Entry";var TempNpGpPOSInfoPOSEntry: Record "NpGp POS Info POS Entry" temporary)
    var
        NpGpPOSInfoPOSEntry: Record "NpGp POS Info POS Entry";
    begin
        if NpGpPOSInfoPOSEntry.Get(NpGpPOSSalesEntry."Entry No.",TempNpGpPOSInfoPOSEntry."POS Info Code",TempNpGpPOSInfoPOSEntry."Entry No.") then
          exit;

        NpGpPOSInfoPOSEntry.Init;
        NpGpPOSInfoPOSEntry := TempNpGpPOSInfoPOSEntry;
        NpGpPOSInfoPOSEntry."POS Entry No." := NpGpPOSSalesEntry."Entry No.";
        NpGpPOSInfoPOSEntry.Insert(true);
    end;

    local procedure IncludeEntryType(NpGpPOSSalesEntry: Record "NpGp POS Sales Entry"): Boolean
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
        NcTaskProcessor: Record "Nc Task Processor";
        NcTaskSetup: Record "Nc Task Setup";
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
    begin
        NcTaskSetup.SetRange("Table No.",DATABASE::"POS Entry");
        NcTaskSetup.SetRange("Codeunit ID",CODEUNIT::"NpGp POS Sales Sync Mgt.");
        if NcTaskSetup.FindFirst then
          exit(NcTaskSetup."Task Processor Code");

        if not NcTaskProcessor.FindFirst then begin
          NcSyncMgt.UpdateTaskProcessor(NcTaskProcessor);
          Commit;
          NcTaskProcessor.FindFirst;
        end;

        NcTaskSetup.Init;
        NcTaskSetup."Entry No." := 0;
        NcTaskSetup."Task Processor Code" := NcTaskProcessor.Code;
        NcTaskSetup."Table No." := DATABASE::"POS Entry";
        NcTaskSetup."Codeunit ID" := CODEUNIT::"NpGp POS Sales Sync Mgt.";
        NcTaskSetup.Insert;
        exit(NcTaskSetup."Task Processor Code");
    end;

    local procedure "--- Retail Cross Reference"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151180, 'DiscoverRetailCrossReferenceSetup', '', true, true)]
    local procedure OnDiscoverRetailCrossReferenceSetup(var RetailCrossReferenceSetup: Record "Retail Cross Reference Setup")
    begin
        if not RetailCrossReferenceSetup.Get(DATABASE::"Sale POS") then begin
          RetailCrossReferenceSetup.Init;
          RetailCrossReferenceSetup.Validate("Table ID",DATABASE::"Sale POS");
          RetailCrossReferenceSetup.Insert(true);
        end;

        if not RetailCrossReferenceSetup.Get(DATABASE::"Sale Line POS") then begin
          RetailCrossReferenceSetup.Init;
          RetailCrossReferenceSetup.Validate("Table ID",DATABASE::"Sale Line POS");
          RetailCrossReferenceSetup.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6151181, 'OnAfterValidateEvent', 'Table ID', true, true)]
    local procedure OnValidateRetailCrossRefSetupTableId(var Rec: Record "Retail Cross Reference Setup";var xRec: Record "Retail Cross Reference Setup";CurrFieldNo: Integer)
    begin
        case Rec."Table ID" of
          DATABASE::"Sale POS":
            begin
              Rec."Reference No. Pattern" := '[PS][PU][AN*2][S][AN*2]';
              Rec."Pattern Guide" := CopyStr(Text000,1,MaxStrLen(Rec."Pattern Guide"));
            end;
          DATABASE::"Sale Line POS":
            begin
              Rec."Reference No. Pattern" := '[PS][PU][NL][AN*2][S][AN*2]';
              Rec."Pattern Guide" := CopyStr(Text001,1,MaxStrLen(Rec."Pattern Guide"));
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150621, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertPOSEntry(var Rec: Record "POS Entry";RunTrigger: Boolean)
    var
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        if Rec.IsTemporary then
          exit;

        RetailCrossRefMgt.UpdateTableReference(Rec."Retail ID",DATABASE::"POS Entry",Rec."Document No.");
    end;

    [EventSubscriber(ObjectType::Table, 6150622, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertPOSSalesLine(var Rec: Record "POS Sales Line";RunTrigger: Boolean)
    var
        RetailCrossReference: Record "Retail Cross Reference";
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        if Rec.IsTemporary then
          exit;

        RetailCrossRefMgt.UpdateTableReference(Rec."Retail ID",DATABASE::"POS Sales Line",Rec."Document No." + '_' + Format(Rec."Line No."));
    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSalePOS(var Rec: Record "Sale POS";RunTrigger: Boolean)
    var
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        if Rec.IsTemporary then
          exit;

        RetailCrossRefMgt.RemoveRetailReference(Rec."Retail ID",DATABASE::"Sale POS");
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSaleLinePOS(var Rec: Record "Sale Line POS";RunTrigger: Boolean)
    var
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        if Rec.IsTemporary then
          exit;

        RetailCrossRefMgt.RemoveRetailReference(Rec."Retail ID",DATABASE::"Sale Line POS");
    end;

    [EventSubscriber(ObjectType::Table, 6150621, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeletePOSEntry(var Rec: Record "POS Entry";RunTrigger: Boolean)
    var
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        if Rec.IsTemporary then
          exit;

        RetailCrossRefMgt.RemoveRetailReference(Rec."Retail ID",DATABASE::"POS Entry");
    end;

    [EventSubscriber(ObjectType::Table, 6150622, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeletePOSSalesLine(var Rec: Record "POS Sales Line";RunTrigger: Boolean)
    var
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        if Rec.IsTemporary then
          exit;

        RetailCrossRefMgt.RemoveRetailReference(Rec."Retail ID",DATABASE::"POS Sales Line");
    end;

    local procedure GenerateHeaderReferenceNo(SalePOS: Record "Sale POS") ReferenceNo: Text
    var
        RetailCrossReference: Record "Retail Cross Reference";
        RetailCrossReferenceSetup: Record "Retail Cross Reference Setup";
        POSUnit: Record "POS Unit";
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
        i: Integer;
    begin
        if not RetailCrossReferenceSetup.Get(DATABASE::"Sale POS") then
          exit('');
        if RetailCrossReferenceSetup."Reference No. Pattern" = '' then
          exit;

        if POSUnit.Get(SalePOS."Register No.") then;

        for i := 1 to 10 do begin
          ReferenceNo := RetailCrossReferenceSetup."Reference No. Pattern";
          ReferenceNo := RetailCrossRefMgt.RegExReplacePS(ReferenceNo,POSUnit."POS Store Code");
          ReferenceNo := RetailCrossRefMgt.RegExReplacePU(ReferenceNo,SalePOS."Register No.");
          ReferenceNo := RetailCrossRefMgt.RegExReplaceS(ReferenceNo,SalePOS."Sales Ticket No.");
          ReferenceNo := RetailCrossRefMgt.RegExReplaceN(ReferenceNo);
          ReferenceNo := RetailCrossRefMgt.RegExReplaceAN(ReferenceNo);
          ReferenceNo := UpperCase(CopyStr(ReferenceNo,1,MaxStrLen(RetailCrossReference."Reference No.")));

          if IsNullGuid(RetailCrossRefMgt.GetRetailID(DATABASE::"Sale POS",ReferenceNo)) then
            exit(ReferenceNo);

          if ReferenceNo = RetailCrossReferenceSetup."Reference No. Pattern" then
            exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    procedure InitReferenceNoSalePOS(SalePOS: Record "Sale POS") ReferenceNo: Text
    var
        RetailCrossReference: Record "Retail Cross Reference";
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        if IsNullGuid(SalePOS."Retail ID") then
          exit('');

        if RetailCrossReference.Get(SalePOS."Retail ID") then
          exit(RetailCrossReference."Reference No.");

        ReferenceNo := GenerateHeaderReferenceNo(SalePOS);
        RetailCrossRefMgt.InitRetailReference(SalePOS."Retail ID",ReferenceNo,DATABASE::"Sale POS",SalePOS."Sales Ticket No.");

        exit(ReferenceNo);
    end;

    procedure InitReferenceNoSaleLinePOS(SaleLinePOS: Record "Sale Line POS") ReferenceNo: Text
    var
        RetailCrossReference: Record "Retail Cross Reference";
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
    begin
        if IsNullGuid(SaleLinePOS."Retail ID") then
          exit('');

        if RetailCrossReference.Get(SaleLinePOS."Retail ID") then
          exit(RetailCrossReference."Reference No.");

        ReferenceNo := GenerateLineReferenceNo(SaleLinePOS);
        RetailCrossRefMgt.InitRetailReference(
          SaleLinePOS."Retail ID",ReferenceNo,DATABASE::"Sale Line POS",SaleLinePOS."Sales Ticket No." + '_' + Format(SaleLinePOS."Line No."));

        exit(ReferenceNo);
    end;

    local procedure GenerateLineReferenceNo(SaleLinePOS: Record "Sale Line POS") ReferenceNo: Text
    var
        POSUnit: Record "POS Unit";
        RetailCrossReference: Record "Retail Cross Reference";
        RetailCrossReferenceSetup: Record "Retail Cross Reference Setup";
        RetailCrossRefMgt: Codeunit "Retail Cross Ref. Mgt.";
        i: Integer;
        NaturalLineNo: Integer;
    begin
        if not RetailCrossReferenceSetup.Get(DATABASE::"Sale Line POS") then
          exit('');
        if RetailCrossReferenceSetup."Reference No. Pattern" = '' then
          exit('');

        if POSUnit.Get(SaleLinePOS."Register No.") then;

        for i := 1 to 10 do begin
          ReferenceNo := RetailCrossReferenceSetup."Reference No. Pattern";
          ReferenceNo := RetailCrossRefMgt.RegExReplacePS(ReferenceNo,POSUnit."POS Store Code");
          ReferenceNo := RetailCrossRefMgt.RegExReplacePU(ReferenceNo,POSUnit."No.");
          ReferenceNo := RetailCrossRefMgt.RegExReplaceS(ReferenceNo,SaleLinePOS."Sales Ticket No.");
          ReferenceNo := RetailCrossRefMgt.RegExReplaceN(ReferenceNo);
          ReferenceNo := RetailCrossRefMgt.RegExReplaceAN(ReferenceNo);
          ReferenceNo := RetailCrossRefMgt.RegExReplaceL(ReferenceNo,Format(SaleLinePOS."Line No."));
          NaturalLineNo := GetNaturalLineNo(SaleLinePOS);
          ReferenceNo := RetailCrossRefMgt.RegExReplaceNL(ReferenceNo,Format(NaturalLineNo));
          ReferenceNo := UpperCase(CopyStr(ReferenceNo,1,MaxStrLen(RetailCrossReference."Reference No.")));

          if IsNullGuid(RetailCrossRefMgt.GetRetailID(DATABASE::"Sale Line POS",ReferenceNo)) then
            exit(ReferenceNo);

          if ReferenceNo = RetailCrossReferenceSetup."Reference No. Pattern" then
            exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    local procedure GetNaturalLineNo(SaleLinePOS: Record "Sale Line POS") NaturalLineNo: Integer
    var
        SaleLinePOS2: Record "Sale Line POS";
    begin
        SaleLinePOS2.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetFilter("Line No.",'<%1',SaleLinePOS."Line No.");
        NaturalLineNo := SaleLinePOS2.Count + 1;
        exit(NaturalLineNo);
    end;
}

