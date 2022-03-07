codeunit 6014605 "NPR Rep. Get BC Generic Data" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label '%1_%2';
        ImageCouldNotBeReadErr: Label 'Image for %1 could not be read. Please check Replication Error Log Entry No. %2 for more details';
        BLOBCouldNotBeReadErr: Label 'Blob field %1 for record %2 could not be read. Please check Replication Error Log Entry No. %3 for more details';
        PKFieldErr: Label 'Could not find Primary Key field %1 in the API Response';
        GetItemVariantsEventSubs: Codeunit "NPR Rep. Get Item Var. Subs.";

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetBCData(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetBCData(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        // each entity can have it's own 'Get' logic
        URI := ReplicationAPI.CreateURI(ReplicationSetup, ReplicationEndPoint, NextLinkURI);
        ReplicationAPI.GetBCAPIResponse(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ReplicationEndPoint: Record "NPR Replication Endpoint"): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        JTokenMainObject: JsonToken;
        JArrayValues: JsonArray;
        JTokenEntity: JsonToken;
        i: integer;
    begin
        if ReplicationEndPoint."Table ID" = 0 then
            exit;

        if Not ReplicationAPI.GetJTokenMainObjectFromContent(Content, JTokenMainObject) then
            exit;

        if not ReplicationAPI.GetJsonArrayFromJsonToken(JTokenMainObject, '$.value', JArrayValues) then
            exit;

        BindEventSubscribersForReplication();

        for i := 0 to JArrayValues.Count - 1 do begin
            JArrayValues.Get(i, JTokenEntity);
            HandleArrayElementEntity(JTokenEntity, ReplicationEndPoint);
        end;

        ReplicationAPI.UpdateReplicationCounter(JTokenEntity, ReplicationEndPoint);

        UnBindEventSubscribersForReplication();

        exit(true);
    end;

    local procedure HandleArrayElementEntity(JToken: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint")
    var
        TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping" temporary;
        ReplicationAPI: Codeunit "NPR Replication API";
        RecRef: RecordRef;
    begin
        if Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        InitializeTempSpecialFieldMapping(TempSpecialFieldMapping, ReplicationEndPoint);
        InitializeRecRef(RecRef, JToken, TempSpecialFieldMapping, ReplicationEndPoint);
        if CheckFieldsChanged(RecRef, JToken, TempSpecialFieldMapping, ReplicationEndPoint) then begin
            RecRef.Modify(ReplicationEndPoint."Run OnModify Trigger");
            OnAfterRecordIsModified(RecRef, ReplicationEndPoint);
        end;
    end;

    local procedure InitializeRecRef(var RecRef: RecordRef; JToken: JsonToken; var TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping" temporary; ReplicationEndPoint: Record "NPR Replication Endpoint")
    var
        TempPKField: Record Field temporary;
        TempFoundAPIField: Record "NPR Rep. Special Field Mapping" temporary;
        RecRef2: RecordRef;
        FieldRec: Record Field;
        SystemId: Text;
        SourceText: Text;
        RecFoundBySystemId: Boolean;
        ReplicationAPI: Codeunit "NPR Replication API";
        NeedsRename: Boolean;
    begin
        RecRef.Open(ReplicationEndPoint."Table ID");
        GetPrimaryKeyFields(RecRef, TempPKField);
        if FieldRec.Get(RecRef.Number, 2000000000) then //SystemId;
            if GetSourceTxt(FieldRec, JToken, SystemId, TempSpecialFieldMapping, TempFoundAPIField) then
                if RecRef.GetBySystemId(SystemId) then begin
                    RecFoundBySystemId := true;
                    RecRef2 := RecRef.Duplicate();
                    if TempPKField.FindSet() then
                        repeat // check if existing record was renamed
                            if GetSourceTxt(TempPKField, JToken, SourceText, TempSpecialFieldMapping, TempFoundAPIField) then
                                if ReplicationAPI.CheckFieldValue(RecRef2, TempPKField."No.", SourceText, false) then
                                    NeedsRename := true;
                        until TempPKField.Next() = 0;

                    if NeedsRename then begin
                        RecRef.Delete();
                        RecFoundBySystemId := false;
                    end;
                end;

        if Not RecFoundBySystemId then
            FindRecByPKFields(RecRef, JToken, SystemId, TempPKField, TempSpecialFieldMapping, ReplicationEndPoint);
    end;

    local procedure GetPrimaryKeyFields(var RecRef: RecordRef; var TempPKField: Record Field temporary)
    var
        FRef: FieldRef;
        i: Integer;
    begin
        for i := 1 to RecRef.KeyIndex(1).FieldCount() do begin
            FRef := RecRef.KeyIndex(1).FieldIndex(i);
            TempPKField.Init();
            TempPKField.TableNo := RecRef.Number;
            TempPKField."No." := FRef.Number;
            TempPKField.FieldName := FRef.Name;
            Evaluate(TempPKField.Type, Format(FRef.Type));
            TempPKField.Len := FRef.Length;
            TempPKField.Insert();
        end;
    end;

    local procedure FindRecByPKFields(var RecRef: RecordRef; JToken: JsonToken; SystemID: Text; var TempPKField: Record Field; var TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping"; ReplicationEndpoint: Record "NPR Replication Endpoint")
    var
        TempFoundAPIField: Record "NPR Rep. Special Field Mapping" temporary;
        ReplicationAPI: Codeunit "NPR Replication API";
        SourceText: Text;
    begin
        if TempPKField.FindSet() then begin
            repeat
                if GetSourceTxt(TempPKField, JToken, SourceText, TempSpecialFieldMapping, TempFoundAPIField) then
                    ReplicationAPI.CheckFieldValue(RecRef, TempPKField."No.", SourceText, TempFoundAPIField."With Validation")
                Else
                    Error(PKFieldErr, TempPKField.FieldName);
            until TempPKField.Next() = 0;

            if not RecRef.Find('=') then
                InsertNewRec(RecRef, SystemID, ReplicationEndpoint);
        end;
    end;

    local procedure InsertNewRec(var RecRef: RecordRef; SystemID: Text; ReplicationEndpoint: Record "NPR Replication Endpoint")
    var
        SysIdGuid: GUID;
        FRef: FieldRef;
    begin
        if SystemID <> '' then begin
            FRef := RecRef.Field(2000000000); // systemId
            if Evaluate(SysIdGuid, SystemID) then begin
                FRef.Value := SysIdGuid;
                RecRef.Insert(ReplicationEndpoint."Run OnInsert Trigger", true);
            end else
                RecRef.Insert(ReplicationEndpoint."Run OnInsert Trigger");
        end else
            RecRef.Insert(ReplicationEndpoint."Run OnInsert Trigger");
    end;

    local procedure CheckFieldsChanged(var RecRef: RecordRef; JToken: JsonToken; var TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping"; ReplicationEndPoint: Record "NPR Replication Endpoint") FieldsChanged: Boolean
    var
        TempFoundAPIField: Record "NPR Rep. Special Field Mapping" temporary;
        ReplicationAPI: Codeunit "NPR Replication API";
        Client: HttpClient; // reuse HttpClient for Blob/Media/MediaSet requests for better performance and to avoid potential errors
        FieldRec: Record Field;
        SourceText: Text;
    begin
        FieldRec.SetRange(TableNo, RecRef.Number);
        FieldRec.SetRange(Class, FieldRec.Class::Normal);
        FieldRec.SetRange(Enabled, true);
        FieldRec.SetRange(IsPartOfPrimaryKey, false);
        FieldRec.SetFilter(ObsoleteState, '<>%1', FieldRec.ObsoleteState::Removed);
        FieldRec.SetFilter(Type, '<>%1&<>%2&<>%3', FieldRec.Type::Binary, FieldRec.Type::TableFilter, FieldRec.Type::RecordID);
        if FieldRec.FindSet() then
            repeat
                if GetSourceTxt(FieldRec, JToken, SourceText, TempSpecialFieldMapping, TempFoundAPIField) then
                    if Not TempFoundAPIField.Skip then
                        case FieldRec.Type of
                            FieldRec.Type::Media:
                                if CheckMedia(JToken, RecRef, FieldRec."No.", SourceText, TempFoundAPIField, ReplicationEndPoint, Client) then
                                    FieldsChanged := true;
                            FieldRec.Type::MediaSet:
                                if CheckMediaSet(JToken, RecRef, FieldRec."No.", SourceText, TempFoundAPIField, ReplicationEndPoint, Client) then
                                    FieldsChanged := true;
                            FieldRec.Type::BLOB:
                                if CheckBLOB(RecRef, FieldRec."No.", SourceText, TempFoundAPIField, ReplicationEndPoint, Client) then
                                    FieldsChanged := true;
                            else
                                if ReplicationAPI.CheckFieldValue(RecRef, FieldRec."No.", SourceText, TempFoundAPIField."With Validation") then
                                    FieldsChanged := true;
                        end;
            until FieldRec.Next() = 0;
    end;

    local procedure GetSourceTxt(FieldRec: Record Field; JToken: JsonToken; var SourceText: Text; var TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping"; var TempFoundAPIField: Record "NPR Rep. Special Field Mapping"): Boolean;
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        TextFunctions: Codeunit "NPR Text Functions";
        APIPageFieldName: Text;
    begin
        Clear(TempFoundAPIField);
        Clear(SourceText);
        //try find by Replication Special Name Mappings settings
        TempSpecialFieldMapping.SetRange("Field ID", FieldRec."No.");
        if TempSpecialFieldMapping.FindSet() then
            repeat
                if ReplicationAPI.SelectJsonToken(JToken.AsObject(), GetJPathFieldFromSpecialFieldMapping(TempSpecialFieldMapping), SourceText) then begin
                    TempFoundAPIField := TempSpecialFieldMapping;
                    exit(true);
                end;
            until TempSpecialFieldMapping.Next() = 0;

        // try find by Field Name in camelcase
        APIPageFieldName := TextFunctions.Camelize(FieldRec.FieldName);
        if ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.' + APIPageFieldName, SourceText) then begin
            TempFoundAPIField."API Field Name" := APIPageFieldName;
            exit(true);
        end;

        Exit(false);
    end;

    local procedure CheckBLOB(var RecRef: RecordRef; FieldNo: integer; BlobURL: Text; var TempFoundAPIField: Record "NPR Rep. Special Field Mapping"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient): Boolean
    var
        RecRef2: RecordRef;
        Response: Codeunit "Temp Blob";
        SourceFRef: FieldRef;
        DestinationFRef: FieldRef;
        WebRequestHelper: Codeunit "Web Request Helper";
    begin
        if not WebRequestHelper.IsValidUri(BlobURL) then
            exit(false);

        GetBLOBResponse(RecRef, BlobURL, TempFoundAPIField, ReplicationEndPoint, Client, Response);

        RecRef2 := RecRef.Duplicate();
        SourceFRef := RecRef2.Field(FieldNo);
        Response.ToFieldRef(SourceFRef);
        DestinationFRef := RecRef.Field(FieldNo);
        DestinationFRef.CalcField();
        if DestinationFRef.Value <> SourceFRef.Value then begin
            DestinationFRef.Value := SourceFRef.Value;
            if TempFoundAPIField."With Validation" then
                DestinationFRef.Validate();
            exit(true);
        end;
        Exit(false);
    end;

    local procedure GetBLOBResponse(var RecRef: RecordRef; BlobURL: Text; var TempFoundAPIField: Record "NPR Rep. Special Field Mapping"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob")
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ErrLog: Record "NPR Replication Error Log";
        ReplicationAPI: Codeunit "NPR Replication API";
        StatusCode: Integer;
    begin
        ServiceSetup.Get(ReplicationEndPoint."Service Code");
        ReplicationAPI.GetBCAPIResponseImage(ServiceSetup, ReplicationEndPoint, Client, Response, StatusCode, BlobURL);

        if ReplicationAPI.FoundErrorInResponse(Response, StatusCode) then
            if not (StatusCode in [204, 500]) then begin //if BLOB is empty, server return status code 500 --> Description: Internal Server Error or 204 --> No Content
                ErrLog.InsertLog(ReplicationEndPoint."Service Code", ReplicationEndPoint."EndPoint ID", 'GET', BlobURL, Response, ServiceSetup."Error Notify Email Address");
                Commit();
                Error(BLOBCouldNotBeReadErr, TempFoundAPIField."API Field Name", RecRef.RecordId, ErrLog."Entry No.");
            end else
                Clear(Response);
    end;

    local procedure CheckMedia(JToken: JsonToken; var RecRef: RecordRef; FieldNo: integer; BlobURL: Text; var TempFoundAPIField: Record "NPR Rep. Special Field Mapping"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient): Boolean
    var
        Media: Record "Tenant Media";
        TempConfigMediaBuffer: Record "Config. Media Buffer" temporary;
        Response: Codeunit "Temp Blob";
        DestinationFRef: FieldRef;
        WebRequestHelper: Codeunit "Web Request Helper";
        ExistingMediaTempBlob: Codeunit "Temp Blob";
        ReplicationAPI: Codeunit "NPR Replication API";
        EmptyGuid: Guid;
        OStr: OutStream;
        IStr: InStream;
    begin
        if CheckMasterPictureImportIsSupported(RecRef, FieldNo) then
            exit(CheckMasterPicture(JToken, RecRef, FieldNo, TempFoundAPIField, ReplicationEndPoint, Client))
        else begin
            if not WebRequestHelper.IsValidUri(BlobURL) then
                exit(false);
            GetBLOBResponse(RecRef, BlobURL, TempFoundAPIField, ReplicationEndPoint, Client, Response);
            DestinationFRef := RecRef.Field(FieldNo);
            if Format(DestinationFRef.Value) <> format(EmptyGuid) then
                Media.Get(Format(DestinationFRef.Value));
            Media.CalcFields(Content);
            Media.Content.CreateInStream(IStr);
            ExistingMediaTempBlob.CreateOutStream(OStr);
            CopyStream(OStr, IStr);
            if ReplicationAPI.GetImageHash(Response) <> ReplicationAPI.GetImageHash(ExistingMediaTempBlob) then begin
                TempConfigMediaBuffer.Init();
                if Response.HasValue() then begin
                    Response.CreateInStream(IStr);
                    TempConfigMediaBuffer.Media.ImportStream(IStr, '');
                    TempConfigMediaBuffer.Insert();
                end;
                DestinationFRef.Value := Format(TempConfigMediaBuffer.Media);
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure CheckMediaSet(JToken: JsonToken; var RecRef: RecordRef; FieldNo: integer; BlobURL: Text; var TempFoundAPIField: Record "NPR Rep. Special Field Mapping"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient): Boolean
    var
        MediaSet: Record "Tenant Media Set";
        Media: Record "Tenant Media";
        TempConfigMediaBuffer: Record "Config. Media Buffer" temporary;
        Response: Codeunit "Temp Blob";
        DestinationFRef: FieldRef;
        WebRequestHelper: Codeunit "Web Request Helper";
        ExistingMediaTempBlob: Codeunit "Temp Blob";
        ReplicationAPI: Codeunit "NPR Replication API";
        EmptyGuid: Guid;
        OStr: OutStream;
        IStr: InStream;
    begin
        if CheckMasterPictureImportIsSupported(RecRef, FieldNo) then
            exit(CheckMasterPicture(JToken, RecRef, FieldNo, TempFoundAPIField, ReplicationEndPoint, Client))
        else begin
            if not WebRequestHelper.IsValidUri(BlobURL) then
                exit(false);
            GetBLOBResponse(RecRef, BlobURL, TempFoundAPIField, ReplicationEndPoint, Client, Response);
            DestinationFRef := RecRef.Field(FieldNo);
            if Format(DestinationFRef.Value) <> format(EmptyGuid) then begin
                MediaSet.SetRange(ID, Format(DestinationFRef.Value));
                if MediaSet.FindFirst() and (Format(MediaSet."Media ID") <> format(EmptyGuid)) then
                    Media.Get(Format(MediaSet."Media ID"));
            end;
            Media.CalcFields(Content);
            Media.Content.CreateInStream(IStr);
            ExistingMediaTempBlob.CreateOutStream(OStr);
            CopyStream(OStr, IStr);
            if ReplicationAPI.GetImageHash(Response) <> ReplicationAPI.GetImageHash(ExistingMediaTempBlob) then begin
                TempConfigMediaBuffer.Init();
                if Response.HasValue() then begin
                    Response.CreateInStream(IStr);
                    TempConfigMediaBuffer."Media Set".ImportStream(IStr, '');
                    TempConfigMediaBuffer.Insert();
                end;
                DestinationFRef.Value := Format(TempConfigMediaBuffer."Media Set");
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure CheckMasterPicture(JToken: JsonToken; var RecRef: RecordRef; FieldNo: Integer; var TempFoundAPIField: Record "NPR Rep. Special Field Mapping"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient): Boolean
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ErrLog: Record "NPR Replication Error Log";
        ReplicationAPI: Codeunit "NPR Replication API";
        Response: Codeunit "Temp Blob";
        FRef: FieldRef;
        StatusCode: Integer;
        NewImageIStr: InStream;
        TempBlobNewImage: Codeunit "Temp Blob";
        TempBlobExistingImage: Codeunit "Temp Blob";
        NewImageURL: Text;
        MimeType: Text[100];
        ImageWidth: Integer;
        ImageHeight: Integer;
        PictureJToken: JsonToken;
    begin
        if not JToken.SelectToken('$.' + TempFoundAPIField."API Field Name", PictureJToken) then
            exit(false);

        NewImageURL := ReplicationAPI.SelectJsonToken(PictureJToken.AsObject(), '$.[''pictureContent@odata.mediaReadLink'']');
        if NewImageURL = '' then
            Exit(false);

        if EValuate(ImageWidth, ReplicationAPI.SelectJsonToken(PictureJToken.AsObject(), '$.width')) then;
        if Evaluate(ImageHeight, ReplicationAPI.SelectJsonToken(PictureJToken.AsObject(), '$.height')) then;
        MimeType := COPYSTR(ReplicationAPI.SelectJsonToken(PictureJToken.AsObject(), '$.contentType'), 1, 100);
        FRef := RecRef.Field(FieldNo);

        if (ImageWidth > 0) AND (ImageHeight > 0) and (MimeType <> '') then begin
            ServiceSetup.Get(ReplicationEndPoint."Service Code");
            ReplicationAPI.GetBCAPIResponseImage(ServiceSetup, ReplicationEndPoint, Client, Response, StatusCode, NewImageURL);

            if ReplicationAPI.FoundErrorInResponse(Response, StatusCode) then begin
                ErrLog.InsertLog(ReplicationEndPoint."Service Code", ReplicationEndPoint."EndPoint ID", 'GET', NewImageURL, Response, ServiceSetup."Error Notify Email Address");
                Commit();
                Error(ImageCouldNotBeReadErr, RecRef.RecordId, ErrLog."Entry No.");
            end;

            ReadNewImage(Response, TempBlobNewImage, MimeType); // if use directly the InStream data(without read from temptable) sometimes the hash of 2 same png images is different.
            ReadExistingImage(FRef, TempBlobExistingImage);

            if ReplicationAPI.GetImageHash(TempBlobNewImage) <> ReplicationAPI.GetImageHash(TempBlobExistingImage) then begin
                Response.CreateInStream(NewImageIStr);
                UpdateImage(FRef, NewImageIStr, MimeType);
                Exit(true);
            end;
        end else begin // no image
            if ClearImage(FRef) then
                Exit(true);
        end;
        exit(false);
    end;

    local procedure ReadNewImage(var ResponseTempBlob: Codeunit "Temp Blob"; var TempBlob: Codeunit "Temp Blob"; MimeType: Text)
    var
        IStr: InStream;
        OStr: OutStream;
        TempMediaRepository: Record "Media Repository" temporary;
    begin
        ResponseTempBlob.CreateInStream(IStr);
        TempMediaRepository.Image.ImportStream(IStr, '', MimeType);
        if TempMediaRepository.Image.HasValue then begin
            TempBlob.CreateOutStream(OStr);
            TempMediaRepository.Image.ExportStream(OStr);
        end;
    end;

    local procedure ReadExistingImage(FRef: FieldRef; var TempBlob: Codeunit "Temp Blob")
    var
        Media: Record "Tenant Media";
        MediaSet: Record "Tenant Media Set";
        OStr: OutStream;
        IStr: InStream;
        MediaId: Guid;
        MediaSetId: Guid;
    begin
        if FRef.Type = FRef.Type::MediaSet then begin
            MediaSetId := FRef.Value;
            if not IsNullGuid(MediaSetId) then begin
                MediaSet.SetRange(ID, MediaSetId);
                if MediaSet.FindFirst() then
                    MediaId := Format(MediaSet."Media ID");
            end;
        end else
            MediaId := FRef.Value;

        if not IsNullGuid(MediaId) then begin
            Media.Get(MediaId);
            if (Media.Content.HasValue()) then begin
                Media.CalcFields(Content);
                Media.Content.CreateInStream(IStr);
                TempBlob.CreateOutStream(OStr);
                CopyStream(OStr, IStr);
            end;
        end;
    end;

    local procedure UpdateImage(var FRef: FieldRef; IStr: InStream; MimeType: Text)
    var
        TempConfigMediaBuffer: Record "Config. Media Buffer" temporary;
    begin
        TempConfigMediaBuffer.Init();
        Case FRef.Type of
            FRef.Type::Media:
                begin
                    TempConfigMediaBuffer.Media.ImportStream(IStr, '', MimeType);
                    TempConfigMediaBuffer.Insert();
                    FRef.Value := Format(TempConfigMediaBuffer.Media);
                end;
            FRef.Type::MediaSet:
                begin
                    TempConfigMediaBuffer."Media Set".ImportStream(IStr, '', MimeType);
                    TempConfigMediaBuffer.Insert();
                    FRef.Value := Format(TempConfigMediaBuffer."Media Set");
                end;
        End;
    end;

    local procedure ClearImage(var FRef: FieldRef): Boolean
    var
        EmptyGUID: Guid;
    begin
        if not IsNullGuid(Format(FRef.Value)) then begin
            FRef.Value := EmptyGUID;
            exit(true);
        end;
        Exit(false);
    end;

    local procedure CheckMasterPictureImportIsSupported(RecRef: RecordRef; FieldNo: Integer): Boolean
    var
        Cust: Record Customer;
        Item: Record Item;
        Vendor: Record Vendor;
        Employee: Record Employee;
    begin
        Case RecRef.Number of
            Database::Customer:
                exit(FieldNo = Cust.FieldNo(Image));
            Database::Item:
                exit(FieldNo = Item.FieldNo(Picture));
            Database::Vendor:
                exit(FieldNo = Vendor.FieldNo(Image));
            Database::Employee:
                exit(FieldNo = Employee.FieldNo(Image));
        end;

        exit(false);
    end;

    local procedure GetJPathFieldFromSpecialFieldMapping(var TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping") JPathField: Text
    begin
        if STRPOS(TempSpecialFieldMapping."API Field Name", '@') > 0 then
            JPathField := '$.[' + '''' + TempSpecialFieldMapping."API Field Name" + '''' + ']' // for Blob mapping is done like: apiPageBlobFieldName@odata.mediaReadLink 
        Else
            JPathField := '$.' + TempSpecialFieldMapping."API Field Name";
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text[100]
    begin
        exit(COPYSTR(StrSubstNo(DefaultFileNameLbl, ServiceEndPoint."EndPoint ID", format(Today(), 0, 9)), 1, 100));
    end;

    procedure CheckResponseContainsData(Content: Codeunit "Temp Blob"): Boolean;
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        JTokenMainObject: JsonToken;
        JArrayValues: JsonArray;
    begin
        if Not ReplicationAPI.GetJTokenMainObjectFromContent(Content, JTokenMainObject) then
            exit(false);

        if not ReplicationAPI.GetJsonArrayFromJsonToken(JTokenMainObject, '$.value', JArrayValues) then
            exit(false);

        Exit(JArrayValues.Count > 0);
    end;

    internal procedure InitializeTempSpecialFieldMapping(var TempSpecialFieldMapping: Record "NPR Rep. Special Field Mapping" temporary; ReplicationEndpoint: Record "NPR Replication Endpoint")
    var
        SpecialFieldMapping: Record "NPR Rep. Special Field Mapping";
    begin
        TempSpecialFieldMapping.Reset();
        TempSpecialFieldMapping.DeleteAll();
        SpecialFieldMapping.SetRange("Service Code", ReplicationEndpoint."Service Code");
        SpecialFieldMapping.SetRange("EndPoint ID", ReplicationEndpoint."EndPoint ID");
        SpecialFieldMapping.SetRange("Table ID", ReplicationEndpoint."Table ID");
        if SpecialFieldMapping.FindSet() then
            repeat
                TempSpecialFieldMapping := SpecialFieldMapping;
                TempSpecialFieldMapping.Insert();
            until SpecialFieldMapping.Next() = 0;
    end;

    local procedure BindEventSubscribersForReplication()
    var
    begin
        BindSubscription(GetItemVariantsEventSubs);
    end;

    local procedure UnBindEventSubscribersForReplication()
    begin
        UnbindSubscription(GetItemVariantsEventSubs)
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterRecordIsModified(var RecRef: RecordRef; ReplicationEndpoint: Record "NPR Replication Endpoint")
    begin
    end;

}