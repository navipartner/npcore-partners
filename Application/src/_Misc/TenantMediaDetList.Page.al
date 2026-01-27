page 6248209 "NPR Tenant Media Det List"
{
    Caption = 'Tenant Media Field Details';
    ApplicationArea = NPRRetail;
    DataCaptionExpression = PageCaptionText;
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR Tenant Media Field Detail";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    layout
    {
        area(content)
        {
            repeater(Fields)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the field that contains media or media set data.';
                }
                field("Field Size"; Rec."Field Size")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the size, in bytes, of the media content stored in the field.';
                }
            }
        }
    }
    procedure GetTableMediaSizes(ObjectID: Integer)
    var
        AllObjWithCaptionScan: Record AllObjWithCaption;
        Field: Record Field;
        TempTenantMediaFieldDetail: Record "NPR Tenant Media Field Detail" temporary;
        TenantMedia: Record "Tenant Media";
        TenantMediaSet: Record "Tenant Media Set";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        RecRefOpened: Boolean;
        MediaGuid: Guid;
        MediaSetGuid: Guid;
        FieldType: Integer;
        i: Integer;
        MediaFieldIndex: Integer;
        TableID: Integer;
        TableRecCount: Integer;
        PageDefaultCaption: Label 'Table ';
        FieldSizeList: List of [BigInteger];
        MediaFieldNoList: List of [Integer];
        MediaFieldTypeList: List of [Integer];
        FieldNameList: List of [Text[250]];
        MediaFieldNameList: List of [Text[250]];
    begin
        PageCaptionText := PageDefaultCaption + Format(ObjectID);
        TempTenantMediaFieldDetail.DeleteAll();
        AllObjWithCaptionScan.Reset();
        AllObjWithCaptionScan.SetFilter("Object Type", '%1', AllObjWithCaptionScan."Object Type"::Table);
        AllObjWithCaptionScan.SetRange("Object ID", ObjectID);
        if AllObjWithCaptionScan.FindFirst() then begin
            RecRefOpened := false;
            Clear(MediaFieldNoList);
            Clear(MediaFieldTypeList);
            TableRecCount := 0;
            TableID := AllObjWithCaptionScan."Object ID";
            Field.Reset();
            Field.SetRange(TableNo, TableID);
            Field.SetFilter(Type, '%1|%2', Field.Type::Media, Field.Type::MediaSet);
            Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
            if not Field.IsEmpty() then begin
                if Field.FindSet() then
                    repeat
                        MediaFieldNoList.Add(Field."No.");
                        MediaFieldTypeList.Add(Field.Type);
                        MediaFieldNameList.Add(Field.FieldName);
                    until Field.Next() = 0;

                if TryOpenRecRefInternal(RecRef, TableID) then
                    RecRefOpened := true;
            end;

            if RecRefOpened then
                if MediaFieldNoList.Count > 0 then begin
                    PageCaptionText += ' ' + Format(AllObjWithCaptionScan."Object Name");
                    TableRecCount := 0;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                    RecRef.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
                    if RecRef.FindSet(false) then
                        repeat
                            for MediaFieldIndex := 1 to MediaFieldNoList.Count do begin
                                FieldRef := RecRef.Field(MediaFieldNoList.Get(MediaFieldIndex));
                                FieldType := MediaFieldTypeList.Get(MediaFieldIndex);
                                TenantMedia.Reset();
                                TenantMediaSet.Reset();

                                if FieldType = Field.Type::Media then begin
                                    MediaGuid := FieldRef.Value;
                                    if not IsNullGuid(MediaGuid) then
                                        if TenantMedia.Get(MediaGuid) then begin
                                            FieldNameList.Add(MediaFieldNameList.Get(MediaFieldIndex));
                                            FieldSizeList.Add(TenantMedia.Content.Length);
                                            TableRecCount += 1;
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
                                                        FieldNameList.Add(MediaFieldNameList.Get(MediaFieldIndex));
                                                        FieldSizeList.Add(TenantMedia.Content.Length);
                                                        TableRecCount += 1;
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
                for i := 1 to FieldNameList.Count do begin
                    if TempTenantMediaFieldDetail.Get(TableID, FieldNameList.Get(i)) then begin
                        TempTenantMediaFieldDetail."Field Size" += FieldSizeList.Get(i);
                        TempTenantMediaFieldDetail.Modify();
                    end
                    else begin
                        TempTenantMediaFieldDetail.Init();
                        TempTenantMediaFieldDetail."Table ID" := TableID;
                        TempTenantMediaFieldDetail."Field Name" := CopyStr(FieldNameList.Get(i), 1, MaxStrLen(TempTenantMediaFieldDetail."Field Name"));
                        TempTenantMediaFieldDetail."Field Size" := FieldSizeList.Get(i);
                        TempTenantMediaFieldDetail.Insert();
                    end;
                end;
            end;
            Rec.Copy(TempTenantMediaFieldDetail, true);
        end;
    end;

    [TryFunction]
    local procedure TryOpenRecRefInternal(var RecRef: RecordRef; TableID: Integer)
    begin
        RecRef.Open(TableID);
    end;

    var
        PageCaptionText: Text;
}
