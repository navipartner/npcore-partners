codeunit 6151373 "CS Helper Functions"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180604 CASE 307239 Updated PublishWebService to cs_service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.47/CLVA/20181019 CASE 307282 Added functions CreateOfflineRfidData and DeleteRfidTagsInItemCrossRef
    // NPR5.48/CLVA/20181119 CASE 335051 Added Tag family and model info
    // NPR5.48/CLVA/20181214 CASE 335051 Added Timestamp filter and UpdateRfidTagsInItemCrossRef
    // NPR5.50/CLVA/20190206 CASE 344466 Added device Id to log functionality
    // NPR5.50/CLVA/20190227 CASE 346068 Added Event subscriber T5717OnAfterInsert, T5717OnAfterModify and T5717OnAfterDelete
    // NPR5.50/CLVA/20190425 CASE 352134 Deleted functions GetRfidMasterData, GetRfidData, CreateOfflineRfidData, DeleteRfidTagsInItemCrossRef, UpdateRfidTagsInItemCrossRef and
    // NPR5.50/CLVA/20190502 CASE 353741 Added elements to DeviceInfo
    // NPR5.51/CLVA/20190820 CASE 365659 Removed ItemTags from export
    //                                   Added missing WritePropertyName
    //                                   Handling empty Item Group Code in export data
    // NPR5.51/CLVA/20190822 CASE 365967 Added function PostTransferOrder and TryPostTransferOrder
    // NPR5.51/CLVA/20190701 CASE 350696 Added function GetRfidOfflineDataDeltaV2
    // NPR5.52/CLVA/20190904 CASE 365967 Removed function PostTransferOrder and TryPostTransferOrder
    // NPR5.52/CLVA/20190910 CASE 364063 Added functions CreateNewCounting and CancelCounting
    // NPR5.52/CLVA/20191102 CASE 375749 Changed code to support version specific changes (NAV 2018+).
    // NPR5.53/CLVA/20191203 CASE 375919 Added Counting Supervisor functionality. Added function CreateNewCountingV2
    // NPR5.53/CLVA/20200207 CASE 389864 Changed code to support version specific changes (NAV 2018+).


    trigger OnRun()
    begin
    end;

    var
        Err_CSStockTakes: Label 'There is already an open Stock-Take with id %1';
        Err_PostingIsScheduled: Label 'Phy. Inventory Journal is scheduled for posting: %1 %2';
        Err_StockTakeWorksheetNotEmpty: Label 'Phy. Inventory Journal is not empty: %1 %2';
        Err_MissingLocation: Label 'Location is missing on POS Store';
        Err_ConfirmForceClose: Label 'This will delete Phy. Inventory Journal: %1 %2';
        Txt_CountingCancelled: Label 'Counting was cancelled';
        Text001: Label 'Location %1';
        Text002: Label 'Calculate Inventory for Location %1';
        Text003: Label 'There is no Items on Location %1';
        Err_PostingNotDone: Label 'The posting of the last counting is not finalised. Try again later.';
        Txt013: Label 'User Id is not setup as Store User';

    procedure PublishWebService(Enable: Boolean)
    var
        WebService: Record "Web Service";
    begin
        if Enable then begin
          if not WebService.Get(WebService."Object Type"::Codeunit,'cs_service') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Service Name" := 'cs_service';
            WebService."Object ID" := 6151372;
            WebService.Published := true;
            WebService.Insert(true);
          end;
        end else begin
          if WebService.Get(WebService."Object Type"::Codeunit,'cs_service') then
            WebService.Delete(true);
        end;
    end;

    local procedure "-- Log functions"()
    begin
    end;

    procedure CreateLogEntry(var CSCommunicationLog: Record "CS Communication Log";Document: Text;var IsEnable: Boolean;var LogCommunication: Boolean)
    var
        Ostream: OutStream;
        CSSetup: Record "CS Setup";
        BigTextDocument: BigText;
    begin
        if not CSSetup.Get then
          exit;

        if not CSSetup."Enable Capture Service" then
          exit;

        IsEnable := true;

        if not CSSetup."Log Communication" then
          exit;

        LogCommunication := true;

        BigTextDocument.AddText(Document);

        CSCommunicationLog.Init;
        CSCommunicationLog.Id := CreateGuid;
        CSCommunicationLog."Request Start" := CurrentDateTime;
        CSCommunicationLog."Request Data".CreateOutStream(Ostream);

        BigTextDocument.Write(Ostream);

        CSCommunicationLog.Insert;
        Commit;
    end;

    procedure UpdateLogEntry(var CSCommunicationLog: Record "CS Communication Log";FunctionCalled: Text;IsInternalRequest: Boolean;InternalRequestId: Guid;Document: Text;LogCommunication: Boolean;"Device Id": Code[10])
    var
        Ostream: OutStream;
        BigTextDocument: BigText;
    begin
        if not LogCommunication then
          exit;

        BigTextDocument.AddText(Document);

        CSCommunicationLog."Request End" := CurrentDateTime;
        CSCommunicationLog."Request Function" := FunctionCalled;
        CSCommunicationLog."Internal Request" := IsInternalRequest;
        CSCommunicationLog."Internal Log No." := InternalRequestId;
        CSCommunicationLog.User := UserId;
        //-NPR5.50 [344466]
        CSCommunicationLog."Device Id" := "Device Id";
        //+NPR5.50 [344466]
        CSCommunicationLog."Response Data".CreateOutStream(Ostream);

        BigTextDocument.Write(Ostream);

        CSCommunicationLog.Modify(true);
    end;

    local procedure "-- Debug"()
    begin
    end;

    procedure InternalRequest(Request: Text;IsInternal: Boolean;InternalId: Guid)
    var
        CSWS: Codeunit "CS WS";
    begin
        CSWS.IsInternalCall(IsInternal,InternalId);
        CSWS.ProcessDocument(Request);
    end;

    local procedure "-- Helper functions"()
    begin
    end;

    procedure ResetFieldDefaults(CSUIHeader: Record "CS UI Header")
    var
        CSFieldDefaults: Record "CS Field Defaults";
    begin
        Clear(CSFieldDefaults);
        CSFieldDefaults.SetRange("Use Case Code",CSUIHeader.Code);
        CSFieldDefaults.DeleteAll(true);
    end;

    procedure InitOfflineRfidData() Result: Text
    var
        CSRfidOfflineData: Record "CS Rfid Data";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if not Confirm('Re-create the offline datastore?',true) then
          exit;

        CSRfidOfflineData.DeleteAll(true);

        ItemCrossReference.SetRange("Is Retail Serial No.",true);
        ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
        if ItemCrossReference.FindSet then begin
          repeat
            CreateCSRfidOfflineDataRecord(ItemCrossReference);
          until ItemCrossReference.Next = 0;
        end;

        Clear(CSRfidOfflineData);
        CSRfidOfflineData.FindSet;
        Message('Offline data updated with: ' + Format(CSRfidOfflineData.Count) + ' records');
    end;

    procedure CreateOfflineRfidDataDelta(DeviceId: Code[20]) Result: Text
    var
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CSRfidItemGroups: Query "CS Rfid Item Groups";
        CSRfidItems: Query "CS Rfid Items";
        CSRfidItemTags: Query "CS Rfid Item Tags";
        CSRfidItemHandling: Record "CS Rfid Item Handling";
        CSRfidTagModelsQuery: Query "CS Rfid Tag Models";
        CSSetup: Record "CS Setup";
        CSDevices: Record "CS Devices";
        CSRfidData: Record "CS Rfid Data";
        CurrentTimestamp: BigInteger;
    begin
        CSSetup.Get;

        if not CSSetup."Enable Capture Service" then
          exit;

        if not CSDevices.Get(DeviceId) then begin
          CSDevices.Init;
          CSDevices."Device Id" := DeviceId;
          CSDevices.Insert(true);
        end;

        CurrentTimestamp := CSDevices."Last Download Timestamp";

        CSRfidData.SetCurrentKey("Time Stamp");
        if CSDevices."Last Download Timestamp" <> 0 then
          CSRfidData.SetFilter("Time Stamp",StrSubstNo('>%1',CSDevices."Last Download Timestamp"));
        CSRfidData.SetRange("Cross-Reference Discontinue",false);

        // JTokenWriter := JTokenWriter.JTokenWriter;
        // WITH JTokenWriter DO BEGIN
        //  WriteStartObject;
        //  WritePropertyName('itemtag');
        //  WriteStartArray;
            if CSRfidData.FindLast then begin
              CSDevices."Current Tag Count" := CSRfidData.Count;
              CurrentTimestamp := CSRfidData."Time Stamp";
        //      REPEAT
        //        WriteStartObject;
        //        WritePropertyName('key');
        //        WriteValue(CSRfidData.Key);
        //        WritePropertyName('item');
        //        WriteValue(CSRfidData."Combined key");
        //        WritePropertyName('itemgroup');
        //        WriteValue(CSRfidData."Item Group Code");
        //        WriteEndObject;

        //        CurrentTimestamp := CSRfidData."Time Stamp";

        //      UNTIL CSRfidData.NEXT = 0;
            end;
        //  WriteEndArray;
        //  WriteEndObject;
        //  JObject := Token;
        //END;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
        WriteStartObject;

        WritePropertyName('itemgroup');
        WriteStartArray;

        WriteStartObject;
        WritePropertyName('key');
        WriteValue('UNKNOWNTAGS');
        WritePropertyName('title');
        WriteValue('UNKNOWN TAGS');
        WriteEndObject;

        if CSDevices."Last Download Timestamp" <> 0 then
          CSRfidItemGroups.SetFilter(Time_Stamp,StrSubstNo('>%1',CSDevices."Last Download Timestamp"));
        CSRfidItemGroups.Open;
        while CSRfidItemGroups.Read do begin
          WriteStartObject;
          WritePropertyName('key');
          WriteValue(CSRfidItemGroups.Item_Group_Code);
          WritePropertyName('title');
          WriteValue(CSRfidItemGroups.Item_Group_Description);
          WriteEndObject;
        end;
        CSRfidItemGroups.Close;
        WriteEndArray;

        WritePropertyName('item');
        WriteStartArray;

        WriteStartObject;
        WritePropertyName('key');
        WriteValue('UNKNOWNITEM');
        WritePropertyName('title');
        WriteValue('UNKNOWN ITEM');
        WritePropertyName('itemno');
        WriteValue('UNKNOWNITEMNO');
        WritePropertyName('variantcode');
        WriteValue('');
        WritePropertyName('varianttitle');
        WriteValue('');
        WritePropertyName('itemgroup');
        WriteValue('UNKNOWNTAGS');
        WritePropertyName('imageurl');
        WriteValue('');
        WriteEndObject;

        if CSDevices."Last Download Timestamp" <> 0 then
          CSRfidItems.SetFilter(Time_Stamp,StrSubstNo('>%1',CSDevices."Last Download Timestamp"));
        CSRfidItems.Open;
        while CSRfidItems.Read do begin
          WriteStartObject;
          WritePropertyName('key');
          WriteValue(CSRfidItems.Combined_key);
          WritePropertyName('title');
          WriteValue(CSRfidItems.Item_Description);
          WritePropertyName('itemno');
          WriteValue(CSRfidItems.Cross_Reference_Item_No);
          WritePropertyName('variantcode');
          WriteValue(CSRfidItems.Cross_Reference_Variant_Code);
          WritePropertyName('varianttitle');
          WriteValue(CSRfidItems.Variant_Description);
          WritePropertyName('itemgroup');
          WriteValue(CSRfidItems.Item_Group_Code);
          WritePropertyName('imageurl');
          WriteValue(CSRfidItems.Image_Url);
          WriteEndObject;
        end;
        CSRfidItems.Close;
        WriteEndArray;

        //-NPR5.51
        // WritePropertyName('itemtag');
        // WriteStartArray;
        // IF CSDevices."Last Download Timestamp" <> 0 THEN
        //  CSRfidItemTags.SETFILTER(Time_Stamp,STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
        // CSRfidItemTags.OPEN;
        // WHILE CSRfidItemTags.READ DO BEGIN
        //  WriteStartObject;
        //  WritePropertyName('key');
        //  WriteValue(CSRfidItemTags.Key);
        //  WritePropertyName('item');
        //  WriteValue(CSRfidItemTags.Combined_key);
        //  WritePropertyName('itemgroup');
        //  WriteValue(CSRfidItemTags.Item_Group_Code);
        //  WriteEndObject;
        // END;
        // CSRfidItemTags.CLOSE;
        // WriteEndArray;
        //+NPR5.51

        //-NPR5.50 [335051]
        WritePropertyName('supportedTagModels');
        WriteStartArray;
          CSRfidTagModelsQuery.Open;
          while CSRfidTagModelsQuery.Read do begin
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRfidTagModelsQuery.Family+CSRfidTagModelsQuery.Model);
            WritePropertyName('family');
            WriteValue(CSRfidTagModelsQuery.Family);
            WritePropertyName('model');
            WriteValue(CSRfidTagModelsQuery.Model);
            WriteEndObject;
          end;
          CSRfidTagModelsQuery.Close;
        WriteEndArray;
        //+NPR5.50 [335051]

        //-NPR5.50 [335051]
        WritePropertyName('deviceinfo');
        WriteStartArray;
            WriteStartObject;
            WritePropertyName('lasttimestamp');
            WriteValue(CurrentTimestamp);
            WritePropertyName('medialibrary');
            WriteValue(CSSetup."Media Library");
            WritePropertyName('refreshItemCatelog');
            if CSDevices."Refresh Item Catalog" then
              WriteValue('TRUE')
            else
              WriteValue('FALSE');
            //-NPR5.50 [35374]
            //-NPR5.51
            WritePropertyName('currenttagcount');
            //+NPR5.51
            WriteValue(CSDevices."Current Tag Count");
            //+NPR5.50 [35374]
            WriteEndObject;
        WriteEndArray;
        //+NPR5.50 [335051]

        WriteEndObject;
        JObject := Token;
        end;

        CSDevices."Current Download Timestamp" := CurrentTimestamp;
        CSDevices.Modify(true);

        Result := JObject.ToString();
    end;

    procedure CreateOfflineRfidDataDeltaV2(DeviceId: Code[20]) Result: Text
    var
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CSRfidItemGroups: Query "CS Rfid Item Groups";
        CSRfidItems: Query "CS Rfid Items";
        CSRfidItemTags: Query "CS Rfid Item Tags";
        CSRfidItemHandling: Record "CS Rfid Item Handling";
        CSRfidTagModelsQuery: Query "CS Rfid Tag Models";
        CSSetup: Record "CS Setup";
        CSDevices: Record "CS Devices";
        CSRfidData: Record "CS Rfid Data";
        CurrentTimestamp: BigInteger;
    begin
        CSSetup.Get;

        if not CSSetup."Enable Capture Service" then
          exit;

        if not CSDevices.Get(DeviceId) then begin
          CSDevices.Init;
          CSDevices."Device Id" := DeviceId;
          CSDevices.Insert(true);
        end;

        CurrentTimestamp := CSDevices."Last Download Timestamp";

        CSRfidData.SetCurrentKey("Time Stamp");
        if CSDevices."Last Download Timestamp" <> 0 then
          CSRfidData.SetFilter("Time Stamp",StrSubstNo('>%1',CSDevices."Last Download Timestamp"));
        CSRfidData.SetRange("Cross-Reference Discontinue",false);

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
          WriteStartObject;

          WritePropertyName('itemtag');
          WriteStartArray;
          if CSRfidData.FindSet then begin
            CSDevices."Current Tag Count" := CSRfidData.Count;
            repeat
              WriteStartObject;
              WritePropertyName('key');
              WriteValue(CSRfidData.Key);
              WritePropertyName('item');
              WriteValue(CSRfidData."Combined key");
              WritePropertyName('itemgroup');
              WriteValue(CSRfidData."Item Group Code");
              WriteEndObject;

              CurrentTimestamp := CSRfidData."Time Stamp";

            until CSRfidData.Next = 0;
          end;
          WriteEndArray;

          WritePropertyName('itemgroup');
          WriteStartArray;

          WriteStartObject;
          WritePropertyName('key');
          WriteValue('UNKNOWNTAGS');
          WritePropertyName('title');
          WriteValue('UNKNOWN TAGS');
          WriteEndObject;

          if CSDevices."Last Download Timestamp" <> 0 then
            CSRfidItemGroups.SetFilter(Time_Stamp,StrSubstNo('>%1',CSDevices."Last Download Timestamp"));
          CSRfidItemGroups.Open;
          while CSRfidItemGroups.Read do begin
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRfidItemGroups.Item_Group_Code);
            WritePropertyName('title');
            WriteValue(CSRfidItemGroups.Item_Group_Description);
            WriteEndObject;
          end;
          CSRfidItemGroups.Close;
          WriteEndArray;

          WritePropertyName('item');
          WriteStartArray;

          WriteStartObject;
          WritePropertyName('key');
          WriteValue('UNKNOWNITEM');
          WritePropertyName('title');
          WriteValue('UNKNOWN ITEM');
          WritePropertyName('itemno');
          WriteValue('UNKNOWNITEMNO');
          WritePropertyName('variantcode');
          WriteValue('');
          WritePropertyName('varianttitle');
          WriteValue('');
          WritePropertyName('itemgroup');
          WriteValue('UNKNOWNTAGS');
          WritePropertyName('imageurl');
          WriteValue('');
          WriteEndObject;

          if CSDevices."Last Download Timestamp" <> 0 then
            CSRfidItems.SetFilter(Time_Stamp,StrSubstNo('>%1',CSDevices."Last Download Timestamp"));
          CSRfidItems.Open;
          while CSRfidItems.Read do begin
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRfidItems.Combined_key);
            WritePropertyName('title');
            WriteValue(CSRfidItems.Item_Description);
            WritePropertyName('itemno');
            WriteValue(CSRfidItems.Cross_Reference_Item_No);
            WritePropertyName('variantcode');
            WriteValue(CSRfidItems.Cross_Reference_Variant_Code);
            WritePropertyName('varianttitle');
            WriteValue(CSRfidItems.Variant_Description);
            WritePropertyName('itemgroup');
            WriteValue(CSRfidItems.Item_Group_Code);
            WritePropertyName('imageurl');
            WriteValue(CSRfidItems.Image_Url);
            WriteEndObject;
          end;
          CSRfidItems.Close;
          WriteEndArray;

          WritePropertyName('itemtag');
          WriteStartArray;
          if CSDevices."Last Download Timestamp" <> 0 then
            CSRfidItemTags.SetFilter(Time_Stamp,StrSubstNo('>%1',CSDevices."Last Download Timestamp"));
          CSRfidItemTags.Open;
          while CSRfidItemTags.Read do begin
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRfidItemTags.Key);
            WritePropertyName('item');
            WriteValue(CSRfidItemTags.Combined_key);
            WritePropertyName('itemgroup');
            WriteValue(CSRfidItemTags.Item_Group_Code);
            WriteEndObject;
          end;
          CSRfidItemTags.Close;
          WriteEndArray;

          //-#335051 [335051]
          WritePropertyName('supportedTagModels');
          WriteStartArray;
            CSRfidTagModelsQuery.Open;
            while CSRfidTagModelsQuery.Read do begin
              WriteStartObject;
              WritePropertyName('key');
              WriteValue(CSRfidTagModelsQuery.Family+CSRfidTagModelsQuery.Model);
              WritePropertyName('family');
              WriteValue(CSRfidTagModelsQuery.Family);
              WritePropertyName('model');
              WriteValue(CSRfidTagModelsQuery.Model);
              WriteEndObject;
            end;
            CSRfidTagModelsQuery.Close;
          WriteEndArray;
          //+#335051 [335051]

          //-#335051 [335051]
          WritePropertyName('deviceinfo');
          WriteStartArray;
              WriteStartObject;
              WritePropertyName('key');
              WriteValue(CSDevices."Device Id");
              WritePropertyName('lasttimestamp');
              WriteValue(CurrentTimestamp);
              WritePropertyName('medialibrary');
              WriteValue(CSSetup."Media Library");
              WritePropertyName('refreshItemCatelog');
              if CSDevices."Refresh Item Catalog" then
                WriteValue('TRUE')
              else
                WriteValue('FALSE');
              WriteEndObject;
          WriteEndArray;
          //+#335051 [335051]

          WriteEndObject;
          JObject := Token;
        end;

        CSDevices."Current Download Timestamp" := CurrentTimestamp;
        CSDevices."Refresh Item Catalog" := false;
        CSDevices.Modify(true);

        Result := JObject.ToString();
    end;

    procedure CreateRefillData(StockTakeId: Text) Result: Text
    var
        CSRefillData: Record "CS Refill Data";
        Item: Record Item;
        ItemGroup: Record "Item Group";
        MagentoPicture: Record "Magento Picture";
        MagentoPictureLink: Record "Magento Picture Link";
        JObject: DotNet npNetJObject;
        JTokenWriter: DotNet npNetJTokenWriter;
        CSSetup: Record "CS Setup";
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        StockTakeWorkSheetLine: Record "Stock-Take Worksheet Line";
        CSRefillItems: Query "CS Refill Items";
        CSRefillSections: Query "CS Refill Sections";
        CSStockTakes: Record "CS Stock-Takes";
    begin
        if not CSSetup.Get then
          exit;

        if not CSSetup."Enable Capture Service" then
          exit;

        if not CSStockTakes.Get(StockTakeId) then
          exit;

        if (CSStockTakes."Create Refill Data Started" = 0DT) then begin

          CSStockTakes."Create Refill Data Started" := CurrentDateTime;

          StockTakeWorksheet.Get(CSStockTakes.Location,'SALESFLOOR');
          StockTakeWorkSheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
          StockTakeWorkSheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
          if StockTakeWorkSheetLine.FindSet then begin
            repeat
              if StockTakeWorkSheetLine."Item No." <> '' then begin
                if not CSRefillData.Get(StockTakeWorkSheetLine."Item No.",StockTakeWorkSheetLine."Variant Code",StockTakeWorksheet."Conf Location Code",CSStockTakes."Stock-Take Id") then begin
                  CSRefillData.Init;
                  CSRefillData.Validate("Item No.",StockTakeWorkSheetLine."Item No.");
                  CSRefillData.Validate("Variant Code",StockTakeWorkSheetLine."Variant Code");
                  CSRefillData.Validate(Location,StockTakeWorksheet."Conf Location Code");
                  CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                  CSRefillData.Insert(true);
                end;

                if CSRefillData."Variant Code" <> '' then
                  CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
                else
                  CSRefillData."Combined key" := CSRefillData."Item No.";

                CSRefillData."Qty. in Store" += StockTakeWorkSheetLine."Qty. (Counted)";

                if Item.Get(CSRefillData."Item No.") then begin
                  CSRefillData.Validate("Item Group Code",Item."Item Group");
                  if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
                    MagentoPictureLink.SetRange("Item No.",Item."No.");
                    MagentoPictureLink.SetRange("Base Image",true);
                    if MagentoPictureLink.FindFirst then
                      if MagentoPicture.Get(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") then
                        CSRefillData."Image Url" := MagentoPicture.GetMagentotUrl;
                    end;
                end;

                CSRefillData.Modify(true);
              end;
            until StockTakeWorkSheetLine.Next = 0;
          end;

          Clear(StockTakeWorksheet);
          Clear(StockTakeWorkSheetLine);
          StockTakeWorksheet.Get(CSStockTakes.Location,'STOCKROOM');
          StockTakeWorkSheetLine.SetRange("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
          StockTakeWorkSheetLine.SetRange("Worksheet Name", StockTakeWorksheet.Name);
          if StockTakeWorkSheetLine.FindSet then begin
            repeat
              if StockTakeWorkSheetLine."Item No." <> '' then begin
                if not CSRefillData.Get(StockTakeWorkSheetLine."Item No.",StockTakeWorkSheetLine."Variant Code",StockTakeWorksheet."Conf Location Code",CSStockTakes."Stock-Take Id") then begin
                  CSRefillData.Init;
                  CSRefillData.Validate("Item No.",StockTakeWorkSheetLine."Item No.");
                  CSRefillData.Validate("Variant Code",StockTakeWorkSheetLine."Variant Code");
                  CSRefillData.Validate(Location,StockTakeWorksheet."Conf Location Code");
                  CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                  CSRefillData.Insert(true);
                end;

                if CSRefillData."Variant Code" <> '' then
                  CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
                else
                  CSRefillData."Combined key" := CSRefillData."Item No.";

                CSRefillData."Qty. in Stock" += StockTakeWorkSheetLine."Qty. (Counted)";

                if Item.Get(CSRefillData."Item No.") then begin
                  CSRefillData.Validate("Item Group Code",Item."Item Group");
                  if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
                    MagentoPictureLink.SetRange("Item No.",Item."No.");
                    MagentoPictureLink.SetRange("Base Image",true);
                    if MagentoPictureLink.FindFirst then
                      if MagentoPicture.Get(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") then
                        CSRefillData."Image Url" := MagentoPicture.GetMagentotUrl;
                  end;
                end;

                CSRefillData.Modify(true);
              end;
            until StockTakeWorkSheetLine.Next = 0;
          end;

          CSStockTakes."Create Refill Data Ended" := CurrentDateTime;
          CSStockTakes.Modify;

        end;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
        WriteStartObject;

        WritePropertyName('section');
        WriteStartArray;
        CSRefillSections.SetFilter(Stock_Take_Id,CSStockTakes."Stock-Take Id");
        CSRefillSections.Open;
        while CSRefillSections.Read do begin
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRefillSections.Item_No);
            WritePropertyName('title');
            WriteValue(CSRefillSections.Item_Description);
            WritePropertyName('itemgroup');
            WriteValue(CSRefillSections.Item_Group_Code);
            WritePropertyName('marked');
            WriteValue(CSRefillSections.Refilled);
            WriteEndObject;
        end;
        CSRefillSections.Close;
        WriteEndArray;

        WritePropertyName('item');
        WriteStartArray;
        CSRefillItems.SetFilter(Stock_Take_Id,CSStockTakes."Stock-Take Id");
        CSRefillItems.Open;
        while CSRefillItems.Read do begin
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRefillItems.Combined_key);
            WritePropertyName('title');
            WriteValue(CSRefillItems.Item_Description);
            WritePropertyName('itemno');
            WriteValue(CSRefillItems.Item_No);
            WritePropertyName('variantcode');
            WriteValue(CSRefillItems.Variant_Code);
            WritePropertyName('varianttitle');
            WriteValue(CSRefillItems.Variant_Description);
            WritePropertyName('itemgroup');
            WriteValue(CSRefillItems.Item_Group_Code);
            WritePropertyName('imageurl');
            WriteValue(CSRefillItems.Image_Url);
            WritePropertyName('qtystock');
            WriteValue(CSRefillItems.Qty_in_Stock);
            WritePropertyName('qtystore');
            WriteValue(CSRefillItems.Qty_in_Store);
            WritePropertyName('marked');
            WriteValue(CSRefillItems.Refilled);
            WriteEndObject;
        end;
        CSRefillItems.Close;
        WriteEndArray;

        WriteEndObject;
        JObject := Token;
        end;

        Result := JObject.ToString();
    end;

    procedure ClearDeviceInfo(var CSDevices: Record "CS Devices")
    begin
        CSDevices."Last Download Timestamp" := 0;
        CSDevices."Refresh Item Catalog" := true;
        CSDevices.Modify(true);
    end;

    local procedure CreateCSRfidOfflineDataRecord(ItemCrossReference: Record "Item Cross Reference")
    var
        CSRfidOfflineData: Record "CS Rfid Data";
        CSRfidTagModels: Record "CS Rfid Tag Models";
        TagModel: Code[10];
        TagId: Code[30];
        Item: Record Item;
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoPicture: Record "Magento Picture";
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if StrLen(ItemCrossReference."Cross-Reference No.") <> MaxStrLen(ItemCrossReference."Cross-Reference No.") then
          exit;

        TagModel := CopyStr(ItemCrossReference."Cross-Reference No.",1,4);

        Clear(CSRfidTagModels);
        CSRfidTagModels.SetRange(Model,TagModel);
        if CSRfidTagModels.FindSet then begin

          TagId := CSRfidTagModels.Family + ItemCrossReference."Cross-Reference No.";

          if not CSRfidOfflineData.Get(TagId) then begin
            CSRfidOfflineData.Init;
            CSRfidOfflineData.Key := TagId;
            CSRfidOfflineData.Insert(true);
          end;

          CSRfidOfflineData.Validate("Cross-Reference Item No.",ItemCrossReference."Item No.");
          CSRfidOfflineData.Validate("Cross-Reference Variant Code",ItemCrossReference."Variant Code");
          CSRfidOfflineData.Validate("Cross-Reference UoM",ItemCrossReference."Unit of Measure");
          CSRfidOfflineData.Validate("Cross-Reference Description",ItemCrossReference.Description);
          CSRfidOfflineData.Validate("Cross-Reference Discontinue",ItemCrossReference."Discontinue Bar Code");
          CSRfidOfflineData.Validate(Heartbeat,CurrentDateTime);
          if Item.Get(CSRfidOfflineData."Cross-Reference Item No.") then begin
            CSRfidOfflineData.Validate("Item Group Code",Item."Item Group");
            if CSSetup."Media Library" = CSSetup."Media Library"::Magento then begin
              MagentoPictureLink.SetRange("Item No.",Item."No.");
              MagentoPictureLink.SetRange("Base Image",true);
              if MagentoPictureLink.FindFirst then
                if MagentoPicture.Get(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") then
                  CSRfidOfflineData."Image Url" := MagentoPicture.GetMagentotUrl;
            end;
          end;
          CSRfidOfflineData.Modify(true);
        end;
        //+NPR5.50 [346068]
    end;

    local procedure DeleteCSRfidOfflineDataRecord(ItemCrossReference: Record "Item Cross Reference")
    var
        CSRfidOfflineData: Record "CS Rfid Data";
        CSRfidTagModels: Record "CS Rfid Tag Models";
        TagModel: Code[10];
        TagId: Code[30];
        Item: Record Item;
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoPicture: Record "Magento Picture";
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if StrLen(ItemCrossReference."Cross-Reference No.") <> MaxStrLen(ItemCrossReference."Cross-Reference No.") then
          exit;

        TagModel := CopyStr(ItemCrossReference."Cross-Reference No.",1,4);

        Clear(CSRfidTagModels);
        CSRfidTagModels.SetRange(Model,TagModel);
        if CSRfidTagModels.FindSet then begin

          TagId := CSRfidTagModels.Family + ItemCrossReference."Cross-Reference No.";

          if CSRfidOfflineData.Get(TagId) then
            CSRfidOfflineData.Delete(true);

        end;
        //+NPR5.50 [346068]
    end;

    procedure CreateStockTakeWorksheet(Location: Code[20];Name: Code[10];var StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        CSSetup: Record "CS Setup";
        StockTakeConfiguration: Record "Stock-Take Configuration";
        StockTakeTemplate: Record "Stock-Take Template";
    begin
        if not CSSetup.Get then
          exit;

        if not CSSetup."Enable Capture Service" then
          exit;

        if StockTakeWorksheet.Get(Location,Name) then
          exit;

        CSSetup.TestField("Stock-Take Template");
        StockTakeTemplate.Get(CSSetup."Stock-Take Template");

        if not StockTakeConfiguration.Get(Location) then begin
          StockTakeConfiguration.Init;
          StockTakeConfiguration.Code := Location;
          StockTakeConfiguration.TransferFields(StockTakeTemplate, false);
          StockTakeConfiguration.Description := StrSubstNo('%1 Stock-Take',StockTakeConfiguration.Code);
          StockTakeConfiguration."Location Code" := Location;
          StockTakeConfiguration."Inventory Calc. Date" := WorkDate;
          StockTakeConfiguration."Stock-Take Template Code" := StockTakeTemplate.Code;
          StockTakeConfiguration.Insert();
        end;

        StockTakeWorksheet.Init;
        StockTakeWorksheet."Stock-Take Config Code" := StockTakeConfiguration.Code;
        StockTakeWorksheet.Name := Name;
        StockTakeWorksheet.Insert(true);
    end;

    procedure UpdateDeviceInfo(DeviceId: Code[10];CurrentTimestamp: BigInteger;Location: Code[20]) Result: Text
    var
        CSDevices: Record "CS Devices";
    begin
        if not CSDevices.Get(DeviceId) then
         exit;

        if CurrentTimestamp = 0 then
          exit;

        CSDevices."Last Download Timestamp" := CurrentTimestamp;
        //-NPR5.50 [353741]
        CSDevices."Refresh Item Catalog" := false;
        //+NPR5.50 [353741]
        CSDevices.Location := Location;
        CSDevices.Modify(true);

        Result := 'updated';
    end;

    procedure CreateNewCounting(Location: Record Location)
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        RecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
        CSSetup: Record "CS Setup";
        ItemJournalTemplate: Record "Item Journal Template";
        CalculateInventory: Report "Calculate Inventory";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Item: Record Item;
        QtyCalculated: Decimal;
        CSStockTakes: Record "CS Stock-Takes";
        NewCSStockTakes: Record "CS Stock-Takes";
    begin
        //IF NOT LocationRec.GET(GETFILTER(Location)) THEN
        //  ERROR(Err_MissingLocation);

        //-NPR5.52 [364063]
        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location,Location.Code);
        CSStockTakes.SetRange(Closed, 0DT);
        if CSStockTakes.FindSet then
         Error(Err_CSStockTakes,CSStockTakes."Stock-Take Id");

        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location,Location.Code);
        CSStockTakes.SetFilter(Closed, '<>%1', 0DT);
        CSStockTakes.SetRange("Journal Posted", false);
        if CSStockTakes.FindSet then
         Error(Err_PostingNotDone);

        CSSetup.Get;
        CSSetup.TestField("Phys. Inv Jour Temp Name");
        ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
        if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",Location.Code) then begin
          ItemJournalBatch.Init;
          ItemJournalBatch.Validate("Journal Template Name",CSSetup."Phys. Inv Jour Temp Name");
          ItemJournalBatch.Validate(Name,Location.Code);
          ItemJournalBatch.Description := StrSubstNo(Text001,Location.Code);
          ItemJournalBatch.Validate("No. Series",CSSetup."Phys. Inv Jour No. Series");
          ItemJournalBatch."Reason Code" := ItemJournalTemplate."Reason Code";
          ItemJournalBatch.Insert(true);
        end else begin
          RecRef.GetTable(ItemJournalBatch);
          Clear(CSPostingBuffer);
          CSPostingBuffer.SetRange("Table No.",RecRef.Number);
          CSPostingBuffer.SetRange("Record Id",RecRef.RecordId);
          CSPostingBuffer.SetRange(Executed,false);
          if CSPostingBuffer.FindSet then
            Error(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
          if ItemJournalLine.Count > 0 then
            Error(Err_StockTakeWorksheetNotEmpty,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);
        end;

        NewCSStockTakes.Init;
        NewCSStockTakes."Stock-Take Id" := CreateGuid;
        NewCSStockTakes.Created := CurrentDateTime;
        NewCSStockTakes."Created By" := UserId;
        NewCSStockTakes.Location := Location.Code;
        NewCSStockTakes."Journal Template Name" := ItemJournalBatch."Journal Template Name";
        NewCSStockTakes."Journal Batch Name" := ItemJournalBatch.Name;
        //-NPR5.53 [375919]
        NewCSStockTakes."Adjust Inventory" := true;
        //+NPR5.53 [375919]
        NewCSStockTakes.Insert(true);

        Commit;

        if GuiAllowed then begin
          if Confirm(StrSubstNo(Text002,Location.Code,true)) then begin
            Clear(ItemJournalLine);
            ItemJournalLine.Init;
            ItemJournalLine.Validate("Journal Template Name",NewCSStockTakes."Journal Template Name");
            ItemJournalLine.Validate("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
            ItemJournalLine."Location Code" := NewCSStockTakes.Location;

            Clear(NoSeriesMgt);
            ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",false);
            ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
            ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
            ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

            Clear(Item);
            Item.SetFilter("Location Filter",NewCSStockTakes.Location);
            if not Item.FindSet then
              Error(Text003,Location);

            Clear(CalculateInventory);
            CalculateInventory.UseRequestPage(false);
            CalculateInventory.SetTableView(Item);
            CalculateInventory.SetItemJnlLine(ItemJournalLine);
            //-NPR5.52 [375749]
            //CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
            CalculateInventory.InitializeRequest(WorkDate,ItemJournalLine."Document No.",false,false);
            //+NPR5.52 [375749]
            CalculateInventory.RunModal;

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name",NewCSStockTakes."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
            ItemJournalLine.SetRange("Location Code",NewCSStockTakes.Location);
            if ItemJournalLine.FindSet then begin
              repeat
                QtyCalculated += ItemJournalLine."Qty. (Calculated)"
              until ItemJournalLine.Next = 0;
            end;

            NewCSStockTakes."Predicted Qty." := QtyCalculated;
            NewCSStockTakes."Inventory Calculated" := true;
            NewCSStockTakes.Modify(true);
          end;
        end else begin
          Clear(ItemJournalLine);
          ItemJournalLine.Init;
          ItemJournalLine.Validate("Journal Template Name",NewCSStockTakes."Journal Template Name");
          ItemJournalLine.Validate("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
          ItemJournalLine."Location Code" := NewCSStockTakes.Location;

          Clear(NoSeriesMgt);
          ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",false);
          ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
          ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
          ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

          Clear(Item);
          Item.SetFilter("Location Filter",NewCSStockTakes.Location);
          if not Item.FindSet then
            Error(Text003,Location);

          Clear(CalculateInventory);
          CalculateInventory.UseRequestPage(false);
          CalculateInventory.SetTableView(Item);
          CalculateInventory.SetItemJnlLine(ItemJournalLine);
          //-NPR5.52 [375749]
          //CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
          CalculateInventory.InitializeRequest(WorkDate,ItemJournalLine."Document No.",false,false);
          //+NPR5.52 [375749]
          CalculateInventory.RunModal;

          Clear(ItemJournalLine);
          ItemJournalLine.SetRange("Journal Template Name",NewCSStockTakes."Journal Template Name");
          ItemJournalLine.SetRange("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
          ItemJournalLine.SetRange("Location Code",NewCSStockTakes.Location);
          if ItemJournalLine.FindSet then begin
            repeat
              QtyCalculated += ItemJournalLine."Qty. (Calculated)"
            until ItemJournalLine.Next = 0;
          end;

          NewCSStockTakes."Predicted Qty." := QtyCalculated;
          NewCSStockTakes."Inventory Calculated" := true;
          NewCSStockTakes.Modify(true);
        end;
    end;

    procedure CancelCounting(var CSStockTakes: Record "CS Stock-Takes")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        LocationRec: Record Location;
        RecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
    begin
        if CSStockTakes.Closed <> 0DT then
          exit;

        //-NPR5.52 [364063]
        if not LocationRec.Get(CSStockTakes.Location) then
          Error(Err_MissingLocation);

        if ItemJournalBatch.Get(CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name") then begin
          RecRef.GetTable(ItemJournalBatch);
          Clear(CSPostingBuffer);
          CSPostingBuffer.SetRange("Table No.",RecRef.Number);
          CSPostingBuffer.SetRange("Record Id",RecRef.RecordId);
          CSPostingBuffer.SetRange(Executed,false);
          if CSPostingBuffer.FindSet then
            Error(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

          if not Confirm(StrSubstNo(Err_ConfirmForceClose,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name),true) then
            exit;

          ItemJournalBatch.Delete(true);

        end;
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",Location);
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",'SALESFLOOR');
        // StockTakeWorksheetLine.DELETEALL(TRUE);
        //
        // CLEAR(StockTakeWorksheetLine);
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",Location);
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",'STOCKROOM');
        // StockTakeWorksheetLine.DELETEALL(TRUE);
        //+NPR5.52 [364063]

        //-NPR5.53
        CSStockTakes."Journal Posted" := CSStockTakes."Adjust Inventory";
        //+NPR5.53
        CSStockTakes.Closed := CurrentDateTime;
        CSStockTakes."Closed By" := UserId;
        CSStockTakes.Note := Txt_CountingCancelled;

        CSStockTakes.Modify(true);
    end;

    procedure CreateNewCountingV2(Location: Record Location)
    var
        CSHelperFunctions: Codeunit "CS Helper Functions";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        RecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
        CSSetup: Record "CS Setup";
        ItemJournalTemplate: Record "Item Journal Template";
        CalculateInventory: Report "Calculate Inventory";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Item: Record Item;
        QtyCalculated: Decimal;
        CSStockTakes: Record "CS Stock-Takes";
        NewCSStockTakes: Record "CS Stock-Takes";
        CSCountingSupervisor: Record "CS Counting Supervisor";
        AdjustInventory: Boolean;
        CSStoreUsers: Record "CS Store Users";
    begin
        //IF NOT LocationRec.GET(GETFILTER(Location)) THEN
        //  ERROR(Err_MissingLocation);

        //-NPR5.52 [364063]
        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location,Location.Code);
        CSStockTakes.SetRange(Closed, 0DT);
        if CSStockTakes.FindSet then
         Error(Err_CSStockTakes,CSStockTakes."Stock-Take Id");

        Clear(CSStockTakes);
        CSStockTakes.SetRange(Location,Location.Code);
        CSStockTakes.SetFilter(Closed, '<>%1', 0DT);
        CSStockTakes.SetRange("Journal Posted", false);
        //-NPR5.53
        CSStockTakes.SetRange("Adjust Inventory",true);
        //+NPR5.53
        if CSStockTakes.FindSet then
         Error(Err_PostingNotDone);

        //-NPR5.53
        if CSCountingSupervisor.Get(UserId) then begin
          AdjustInventory := true;
        end else begin
          Clear(CSStoreUsers);
          CSStoreUsers.SetRange("User ID",UserId);
          CSStoreUsers.SetRange("Adjust Inventory",true);
          if CSStoreUsers.FindFirst then
            AdjustInventory := true;
        end;

        if AdjustInventory then begin
        //+NPR5.53
          CSSetup.Get;
          CSSetup.TestField("Phys. Inv Jour Temp Name");
          ItemJournalTemplate.Get(CSSetup."Phys. Inv Jour Temp Name");
          if not ItemJournalBatch.Get(CSSetup."Phys. Inv Jour Temp Name",Location.Code) then begin
            ItemJournalBatch.Init;
            ItemJournalBatch.Validate("Journal Template Name",CSSetup."Phys. Inv Jour Temp Name");
            ItemJournalBatch.Validate(Name,Location.Code);
            ItemJournalBatch.Description := StrSubstNo(Text001,Location.Code);
            ItemJournalBatch.Validate("No. Series",CSSetup."Phys. Inv Jour No. Series");
            ItemJournalBatch."Reason Code" := ItemJournalTemplate."Reason Code";
            ItemJournalBatch.Insert(true);
          end else begin
            RecRef.GetTable(ItemJournalBatch);
            Clear(CSPostingBuffer);
            CSPostingBuffer.SetRange("Table No.",RecRef.Number);
            CSPostingBuffer.SetRange("Record Id",RecRef.RecordId);
            CSPostingBuffer.SetRange(Executed,false);
            if CSPostingBuffer.FindSet then
              Error(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name",ItemJournalBatch."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name",ItemJournalBatch.Name);
            if ItemJournalLine.Count > 0 then
              Error(Err_StockTakeWorksheetNotEmpty,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);
          end;
        //-NPR5.53
        end;
        //+NPR5.53

        NewCSStockTakes.Init;
        NewCSStockTakes."Stock-Take Id" := CreateGuid;
        NewCSStockTakes.Created := CurrentDateTime;
        NewCSStockTakes."Created By" := UserId;
        NewCSStockTakes.Location := Location.Code;
        //-NPR5.53
        if AdjustInventory then begin
          NewCSStockTakes."Adjust Inventory" := true;
        //+NPR5.53
          NewCSStockTakes."Journal Template Name" := ItemJournalBatch."Journal Template Name";
          NewCSStockTakes."Journal Batch Name" := ItemJournalBatch.Name;
        //-NPR5.53
        end;
        //+NPR5.53
        NewCSStockTakes.Insert(true);

        Commit;

        if GuiAllowed then begin
          if Confirm(StrSubstNo(Text002,Location.Code,true)) then begin
            Clear(ItemJournalLine);
            ItemJournalLine.Init;
            ItemJournalLine.Validate("Journal Template Name",NewCSStockTakes."Journal Template Name");
            ItemJournalLine.Validate("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
            ItemJournalLine."Location Code" := NewCSStockTakes.Location;

            Clear(NoSeriesMgt);
            ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",false);
            ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
            ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
            ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

            Clear(Item);
            Item.SetFilter("Location Filter",NewCSStockTakes.Location);
            if not Item.FindSet then
              Error(Text003,Location);

            Clear(CalculateInventory);
            CalculateInventory.UseRequestPage(false);
            CalculateInventory.SetTableView(Item);
            CalculateInventory.SetItemJnlLine(ItemJournalLine);
            //-NPR5.53 [389864]
            //CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
            CalculateInventory.InitializeRequest(WorkDate,ItemJournalLine."Document No.",false,false);
            //+NPR5.53 [389864]
            CalculateInventory.RunModal;

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name",NewCSStockTakes."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
            ItemJournalLine.SetRange("Location Code",NewCSStockTakes.Location);
            if ItemJournalLine.FindSet then begin
              repeat
                QtyCalculated += ItemJournalLine."Qty. (Calculated)"
              until ItemJournalLine.Next = 0;
            end;

            NewCSStockTakes."Predicted Qty." := QtyCalculated;
            NewCSStockTakes."Inventory Calculated" := true;
            NewCSStockTakes.Modify(true);
          end;
        end else begin
          //-NPR5.53
          if AdjustInventory then begin
          //+NPR5.53
            Clear(ItemJournalLine);
            ItemJournalLine.Init;
            ItemJournalLine.Validate("Journal Template Name",NewCSStockTakes."Journal Template Name");
            ItemJournalLine.Validate("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
            ItemJournalLine."Location Code" := NewCSStockTakes.Location;

            Clear(NoSeriesMgt);
            ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",false);
            ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
            ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
            ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

            Clear(Item);
            Item.SetFilter("Location Filter",NewCSStockTakes.Location);
            if not Item.FindSet then
              Error(Text003,Location);

            Clear(CalculateInventory);
            CalculateInventory.UseRequestPage(false);
            CalculateInventory.SetTableView(Item);
            CalculateInventory.SetItemJnlLine(ItemJournalLine);
            //-NPR5.53 [389864]
            //CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
            CalculateInventory.InitializeRequest(WorkDate,ItemJournalLine."Document No.",false,false);
            //+NPR5.53 [389864]
            CalculateInventory.RunModal;

            Clear(ItemJournalLine);
            ItemJournalLine.SetRange("Journal Template Name",NewCSStockTakes."Journal Template Name");
            ItemJournalLine.SetRange("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
            ItemJournalLine.SetRange("Location Code",NewCSStockTakes.Location);
            if ItemJournalLine.FindSet then begin
              repeat
                QtyCalculated += ItemJournalLine."Qty. (Calculated)"
              until ItemJournalLine.Next = 0;
            end;

            NewCSStockTakes."Predicted Qty." := QtyCalculated;
            NewCSStockTakes."Inventory Calculated" := true;
            NewCSStockTakes.Modify(true);
          //-NPR5.53
          end;
          //+NPR5.53
        end;
    end;

    local procedure "-- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterInsertEvent', '', true, true)]
    local procedure T5717OnAfterInsert(var Rec: Record "Item Cross Reference";RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if not CSSetup.Get then
          exit;

        if not CSSetup."Enable Capture Service" then
          exit;

        if Rec.IsTemporary then
          exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
          exit;

        if not Rec."Is Retail Serial No." then
          exit;

        CreateCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterModifyEvent', '', true, true)]
    local procedure T5717OnAfterModify(var Rec: Record "Item Cross Reference";var xRec: Record "Item Cross Reference";RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if not CSSetup.Get then
          exit;

        if not CSSetup."Enable Capture Service" then
          exit;

        if Rec.IsTemporary then
          exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
          exit;

        if not Rec."Is Retail Serial No." then
          exit;

        CreateCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterDeleteEvent', '', true, true)]
    local procedure T5717OnAfterDelete(var Rec: Record "Item Cross Reference";RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        if not CSSetup.Get then
          exit;

        if not CSSetup."Enable Capture Service" then
          exit;

        if Rec.IsTemporary then
          exit;

        if Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" then
          exit;

        if not Rec."Is Retail Serial No." then
          exit;

        DeleteCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;
}

