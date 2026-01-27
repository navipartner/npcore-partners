page 6248191 "NPR Tenant Media Scan"
{
    Caption = 'Tenant Media Scan';
    ApplicationArea = NPRRetail;
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR Tenant Media Analysis";
    SourceTableTemporary = true;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(TotalTables; TotalTables)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Total Tables with Media/Media Set fields';
                ToolTip = 'Specifies count for Tables with Media fields';
            }

            field(TableRecordsCount; TotalTablesWithMedia)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Total Tables with Media/Media Set Fields with Values';
                ToolTip = 'Specifies count for Tables with Media/Media Set values';
            }
            field(SkippedTables; SkippedTables)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Tables Skipped';
                ToolTip = 'Specifies count for Tables that were skipped due to errors opening the table.';
            }
            repeater(Group)
            {
                field("Table ID"; Rec."Object ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ID of the table.';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the object.';
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Object Caption of the table.';
                }
                field("Media Fields Value Count"; Rec."Media Fields Value Count")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Media fields record value count.';
                }
                field("Media Fields Size"; Rec."Media Fields Size")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Media fields size in bytes';
                    trigger OnDrillDown()
                    var
                        TenantMediaDet: Page "NPR Tenant Media Det List";
                    begin
                        TenantMediaDet.GetTableMediaSizes(Rec."Object ID");
                        TenantMediaDet.LookupMode(true);
                        if TenantMediaDet.RunModal() <> ACTION::LookupOK then
                            exit;
                    end;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ScanMedia)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Scan Media Fields';
                Image = Info;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Scan all tables for Media and MediaSet fields and count linked media.';
                trigger OnAction()
                begin
                    SkippedTables := 0;
                    TotalTables := 0;
                    TotalTablesWithMedia := 0;
                    ScanAllMediaFields();
                end;
            }
        }
    }
    var
        SkippedTables: Integer;
        TotalTables: Integer;
        TotalTablesWithMedia: Integer;

    local procedure ScanAllMediaFields()
    var
        AllObjWithCaptionScan: Record AllObjWithCaption;
        Field: Record Field;
        TenantMedia: Record "Tenant Media";
        TenantMediaSet: Record "Tenant Media Set";
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)  
        TableMetaData: Record "Table Metadata";
#endif
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TableRecordsSize: BigInteger;
        ContinueScan: Boolean;
        RecRefOpened: Boolean;
        MyDialog: Dialog;
        MediaGuid: Guid;
        MediaSetGuid: Guid;
        FieldType: Integer;
        MediaFieldIndex: Integer;
        SystemTableRangeStart: Integer;
        TableID: Integer;
        TableIndex: Integer;
        TableRecCount: Integer;
        ScanCompleteMsg: Label 'Scan complete. %1 tables with media values. TotalTables scanned : %2', Comment = 'Shown after media scan completes. %1 is the count of tables with media, %2 is the total tables scanned.';
        ScanningTablesMsg: Label 'Scanning tables #1';
        MediaFieldNoList: List of [Integer];
        MediaFieldTypeList: List of [Integer];
    begin
        Rec.DeleteAll();
        SystemTableRangeStart := 2000000000;
        if GuiAllowed then
            MyDialog.Open(ScanningTablesMsg, TableIndex);

        AllObjWithCaptionScan.Reset();
        AllObjWithCaptionScan.SetRange("Object Type", AllObjWithCaptionScan."Object Type"::Table);
        if AllObjWithCaptionScan.FindSet() then
            repeat
                ContinueScan := false;
                RecRefOpened := false;
                Clear(MediaFieldNoList);
                Clear(MediaFieldTypeList);
                TableRecCount := 0;
                TableRecordsSize := 0;
                TableID := AllObjWithCaptionScan."Object ID";

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
                if TableMetaData.Get(AllObjWithCaptionScan."Object ID") then
                    if (TableMetaData.Access <> TableMetaData.Access::Internal) and (TableID < SystemTableRangeStart) then
                        ContinueScan := true;
#else
                if TableID < SystemTableRangeStart then
                    ContinueScan := true;
#endif
                if ContinueScan then begin
                    Field.Reset();
                    Field.SetRange(TableNo, TableID);
                    Field.SetFilter(Type, '%1|%2', Field.Type::Media, Field.Type::MediaSet);
                    Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
                    if not Field.IsEmpty() then begin
                        if Field.FindSet() then
                            repeat
                                MediaFieldNoList.Add(Field."No.");
                                MediaFieldTypeList.Add(Field.Type);
                            until Field.Next() = 0;

                        if not TryOpenRecRefInternal(RecRef, TableID) then begin
                            ContinueScan := false;
                            SkippedTables += 1;
                        end
                        else
                            RecRefOpened := true;
                    end;

                    if RecRefOpened then
                        if MediaFieldNoList.Count > 0 then begin
                            TotalTables += 1;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)  
                            RecRef.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
                            if RecRef.FindSet(false) then
                                repeat
                                    for MediaFieldIndex := 1 to MediaFieldNoList.Count do begin
                                        FieldRef := RecRef.Field(MediaFieldNoList.Get(MediaFieldIndex));
                                        FieldType := MediaFieldTypeList.Get(MediaFieldIndex);

                                        TenantMediaSet.Reset();
                                        TenantMedia.Reset();
                                        if FieldType = Field.Type::Media then begin
                                            MediaGuid := FieldRef.Value;
                                            if not IsNullGuid(MediaGuid) then
                                                if TenantMedia.Get(MediaGuid) then begin
                                                    TableRecCount += 1;
                                                    TableRecordsSize += TenantMedia.Content.Length;
                                                end;
                                        end else
                                            if FieldType = Field.Type::MediaSet then begin
                                                MediaSetGuid := FieldRef.Value;
                                                if not IsNullGuid(MediaSetGuid) then begin
                                                    TenantMediaSet.SetRange(ID, MediaSetGuid);
                                                    if TenantMediaSet.FindSet() then
                                                        repeat
                                                            MediaGuid := TenantMediaSet."Media ID".MediaId();
                                                            if TenantMedia.Get(MediaGuid) then begin
                                                                TableRecCount += 1;
                                                                TableRecordsSize += TenantMedia.Content.Length;
                                                            end;
                                                        until TenantMediaSet.Next() = 0;
                                                end;
                                            end;
                                    end;
                                until RecRef.Next() = 0;
                        end;
                    if RecRefOpened then
                        RecRef.Close();

                    if TableRecCount > 0 then begin
                        Rec.Init();
                        Rec."Object ID" := TableID;
                        Rec."Object Name" := CopyStr(AllObjWithCaptionScan."Object Name", 1, MaxStrLen(Rec."Object Name"));
                        Rec."Object Caption" := CopyStr(AllObjWithCaptionScan."Object Caption", 1, MaxStrLen(Rec."Object Caption"));
                        Rec."Media Fields Value Count" := TableRecCount;
                        Rec."Media Fields Size" := TableRecordsSize;
                        TotalTablesWithMedia += 1;
                        Rec.Insert();
                    end;
                end;

                TableIndex += 1;
                if GuiAllowed then
                    MyDialog.Update();
            until AllObjWithCaptionScan.Next() = 0;

        if GuiAllowed then
            MyDialog.Close();

        CurrPage.Update(false);

        if GuiAllowed then
            Message(ScanCompleteMsg, Rec.Count(), TotalTables);
    end;

    [TryFunction]
    local procedure TryOpenRecRefInternal(var RecRef: RecordRef; TableID: Integer)
    begin
        RecRef.Open(TableID);
    end;
}

