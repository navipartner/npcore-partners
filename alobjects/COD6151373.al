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

    procedure PublishWebService(Enable: Boolean)
    var
        WebService: Record "Web Service";
    begin
        IF Enable THEN BEGIN
          IF NOT WebService.GET(WebService."Object Type"::Codeunit,'cs_service') THEN BEGIN
            WebService.INIT;
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Service Name" := 'cs_service';
            WebService."Object ID" := 6151372;
            WebService.Published := TRUE;
            WebService.INSERT(TRUE);
          END;
        END ELSE BEGIN
          IF WebService.GET(WebService."Object Type"::Codeunit,'cs_service') THEN
            WebService.DELETE(TRUE);
        END;
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
        IF NOT CSSetup.GET THEN
          EXIT;

        IF NOT CSSetup."Enable Capture Service" THEN
          EXIT;

        IsEnable := TRUE;

        IF NOT CSSetup."Log Communication" THEN
          EXIT;

        LogCommunication := TRUE;

        BigTextDocument.ADDTEXT(Document);

        CSCommunicationLog.INIT;
        CSCommunicationLog.Id := CREATEGUID;
        CSCommunicationLog."Request Start" := CURRENTDATETIME;
        CSCommunicationLog."Request Data".CREATEOUTSTREAM(Ostream);

        BigTextDocument.WRITE(Ostream);

        CSCommunicationLog.INSERT;
        COMMIT;
    end;

    procedure UpdateLogEntry(var CSCommunicationLog: Record "CS Communication Log";FunctionCalled: Text;IsInternalRequest: Boolean;InternalRequestId: Guid;Document: Text;LogCommunication: Boolean;"Device Id": Code[10])
    var
        Ostream: OutStream;
        BigTextDocument: BigText;
    begin
        IF NOT LogCommunication THEN
          EXIT;

        BigTextDocument.ADDTEXT(Document);

        CSCommunicationLog."Request End" := CURRENTDATETIME;
        CSCommunicationLog."Request Function" := FunctionCalled;
        CSCommunicationLog."Internal Request" := IsInternalRequest;
        CSCommunicationLog."Internal Log No." := InternalRequestId;
        CSCommunicationLog.User := USERID;
        //-NPR5.50 [344466]
        CSCommunicationLog."Device Id" := "Device Id";
        //+NPR5.50 [344466]
        CSCommunicationLog."Response Data".CREATEOUTSTREAM(Ostream);

        BigTextDocument.WRITE(Ostream);

        CSCommunicationLog.MODIFY(TRUE);
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
        CLEAR(CSFieldDefaults);
        CSFieldDefaults.SETRANGE("Use Case Code",CSUIHeader.Code);
        CSFieldDefaults.DELETEALL(TRUE);
    end;

    procedure InitOfflineRfidData() Result: Text
    var
        CSRfidOfflineData: Record "CS Rfid Data";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        IF NOT CONFIRM('Re-create the offline datastore?',TRUE) THEN
          EXIT;

        CSRfidOfflineData.DELETEALL(TRUE);

        ItemCrossReference.SETRANGE("Is Retail Serial No.",TRUE);
        ItemCrossReference.SETRANGE("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
        IF ItemCrossReference.FINDSET THEN BEGIN
          REPEAT
            CreateCSRfidOfflineDataRecord(ItemCrossReference);
          UNTIL ItemCrossReference.NEXT = 0;
        END;

        CLEAR(CSRfidOfflineData);
        CSRfidOfflineData.FINDSET;
        MESSAGE('Offline data updated with: ' + FORMAT(CSRfidOfflineData.COUNT) + ' records');
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
        CSSetup.GET;

        IF NOT CSSetup."Enable Capture Service" THEN
          EXIT;

        IF NOT CSDevices.GET(DeviceId) THEN BEGIN
          CSDevices.INIT;
          CSDevices."Device Id" := DeviceId;
          CSDevices.INSERT(TRUE);
        END;

        CurrentTimestamp := CSDevices."Last Download Timestamp";

        CSRfidData.SETCURRENTKEY("Time Stamp");
        IF CSDevices."Last Download Timestamp" <> 0 THEN
          CSRfidData.SETFILTER("Time Stamp",STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
        CSRfidData.SETRANGE("Cross-Reference Discontinue",FALSE);

        // JTokenWriter := JTokenWriter.JTokenWriter;
        // WITH JTokenWriter DO BEGIN
        //  WriteStartObject;
        //  WritePropertyName('itemtag');
        //  WriteStartArray;
            IF CSRfidData.FINDLAST THEN BEGIN
              CSDevices."Current Tag Count" := CSRfidData.COUNT;
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
            END;
        //  WriteEndArray;
        //  WriteEndObject;
        //  JObject := Token;
        //END;

        JTokenWriter := JTokenWriter.JTokenWriter;
        WITH JTokenWriter DO BEGIN
        WriteStartObject;

        WritePropertyName('itemgroup');
        WriteStartArray;

        WriteStartObject;
        WritePropertyName('key');
        WriteValue('UNKNOWNTAGS');
        WritePropertyName('title');
        WriteValue('UNKNOWN TAGS');
        WriteEndObject;

        IF CSDevices."Last Download Timestamp" <> 0 THEN
          CSRfidItemGroups.SETFILTER(Time_Stamp,STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
        CSRfidItemGroups.OPEN;
        WHILE CSRfidItemGroups.READ DO BEGIN
          WriteStartObject;
          WritePropertyName('key');
          WriteValue(CSRfidItemGroups.Item_Group_Code);
          WritePropertyName('title');
          WriteValue(CSRfidItemGroups.Item_Group_Description);
          WriteEndObject;
        END;
        CSRfidItemGroups.CLOSE;
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

        IF CSDevices."Last Download Timestamp" <> 0 THEN
          CSRfidItems.SETFILTER(Time_Stamp,STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
        CSRfidItems.OPEN;
        WHILE CSRfidItems.READ DO BEGIN
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
        END;
        CSRfidItems.CLOSE;
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
          CSRfidTagModelsQuery.OPEN;
          WHILE CSRfidTagModelsQuery.READ DO BEGIN
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRfidTagModelsQuery.Family+CSRfidTagModelsQuery.Model);
            WritePropertyName('family');
            WriteValue(CSRfidTagModelsQuery.Family);
            WritePropertyName('model');
            WriteValue(CSRfidTagModelsQuery.Model);
            WriteEndObject;
          END;
          CSRfidTagModelsQuery.CLOSE;
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
            IF CSDevices."Refresh Item Catalog" THEN
              WriteValue('TRUE')
            ELSE
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
        END;

        CSDevices."Current Download Timestamp" := CurrentTimestamp;
        CSDevices.MODIFY(TRUE);

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
        CSSetup.GET;

        IF NOT CSSetup."Enable Capture Service" THEN
          EXIT;

        IF NOT CSDevices.GET(DeviceId) THEN BEGIN
          CSDevices.INIT;
          CSDevices."Device Id" := DeviceId;
          CSDevices.INSERT(TRUE);
        END;

        CurrentTimestamp := CSDevices."Last Download Timestamp";

        CSRfidData.SETCURRENTKEY("Time Stamp");
        IF CSDevices."Last Download Timestamp" <> 0 THEN
          CSRfidData.SETFILTER("Time Stamp",STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
        CSRfidData.SETRANGE("Cross-Reference Discontinue",FALSE);

        JTokenWriter := JTokenWriter.JTokenWriter;
        WITH JTokenWriter DO BEGIN
          WriteStartObject;

          WritePropertyName('itemtag');
          WriteStartArray;
          IF CSRfidData.FINDSET THEN BEGIN
            CSDevices."Current Tag Count" := CSRfidData.COUNT;
            REPEAT
              WriteStartObject;
              WritePropertyName('key');
              WriteValue(CSRfidData.Key);
              WritePropertyName('item');
              WriteValue(CSRfidData."Combined key");
              WritePropertyName('itemgroup');
              WriteValue(CSRfidData."Item Group Code");
              WriteEndObject;

              CurrentTimestamp := CSRfidData."Time Stamp";

            UNTIL CSRfidData.NEXT = 0;
          END;
          WriteEndArray;

          WritePropertyName('itemgroup');
          WriteStartArray;

          WriteStartObject;
          WritePropertyName('key');
          WriteValue('UNKNOWNTAGS');
          WritePropertyName('title');
          WriteValue('UNKNOWN TAGS');
          WriteEndObject;

          IF CSDevices."Last Download Timestamp" <> 0 THEN
            CSRfidItemGroups.SETFILTER(Time_Stamp,STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
          CSRfidItemGroups.OPEN;
          WHILE CSRfidItemGroups.READ DO BEGIN
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRfidItemGroups.Item_Group_Code);
            WritePropertyName('title');
            WriteValue(CSRfidItemGroups.Item_Group_Description);
            WriteEndObject;
          END;
          CSRfidItemGroups.CLOSE;
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

          IF CSDevices."Last Download Timestamp" <> 0 THEN
            CSRfidItems.SETFILTER(Time_Stamp,STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
          CSRfidItems.OPEN;
          WHILE CSRfidItems.READ DO BEGIN
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
          END;
          CSRfidItems.CLOSE;
          WriteEndArray;

          WritePropertyName('itemtag');
          WriteStartArray;
          IF CSDevices."Last Download Timestamp" <> 0 THEN
            CSRfidItemTags.SETFILTER(Time_Stamp,STRSUBSTNO('>%1',CSDevices."Last Download Timestamp"));
          CSRfidItemTags.OPEN;
          WHILE CSRfidItemTags.READ DO BEGIN
            WriteStartObject;
            WritePropertyName('key');
            WriteValue(CSRfidItemTags.Key);
            WritePropertyName('item');
            WriteValue(CSRfidItemTags.Combined_key);
            WritePropertyName('itemgroup');
            WriteValue(CSRfidItemTags.Item_Group_Code);
            WriteEndObject;
          END;
          CSRfidItemTags.CLOSE;
          WriteEndArray;

          //-#335051 [335051]
          WritePropertyName('supportedTagModels');
          WriteStartArray;
            CSRfidTagModelsQuery.OPEN;
            WHILE CSRfidTagModelsQuery.READ DO BEGIN
              WriteStartObject;
              WritePropertyName('key');
              WriteValue(CSRfidTagModelsQuery.Family+CSRfidTagModelsQuery.Model);
              WritePropertyName('family');
              WriteValue(CSRfidTagModelsQuery.Family);
              WritePropertyName('model');
              WriteValue(CSRfidTagModelsQuery.Model);
              WriteEndObject;
            END;
            CSRfidTagModelsQuery.CLOSE;
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
              IF CSDevices."Refresh Item Catalog" THEN
                WriteValue('TRUE')
              ELSE
                WriteValue('FALSE');
              WriteEndObject;
          WriteEndArray;
          //+#335051 [335051]

          WriteEndObject;
          JObject := Token;
        END;

        CSDevices."Current Download Timestamp" := CurrentTimestamp;
        CSDevices."Refresh Item Catalog" := FALSE;
        CSDevices.MODIFY(TRUE);

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
        IF NOT CSSetup.GET THEN
          EXIT;

        IF NOT CSSetup."Enable Capture Service" THEN
          EXIT;

        IF NOT CSStockTakes.GET(StockTakeId) THEN
          EXIT;

        IF (CSStockTakes."Create Refill Data Started" = 0DT) THEN BEGIN

          CSStockTakes."Create Refill Data Started" := CURRENTDATETIME;

          StockTakeWorksheet.GET(CSStockTakes.Location,'SALESFLOOR');
          StockTakeWorkSheetLine.SETRANGE("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
          StockTakeWorkSheetLine.SETRANGE("Worksheet Name", StockTakeWorksheet.Name);
          IF StockTakeWorkSheetLine.FINDSET THEN BEGIN
            REPEAT
              IF StockTakeWorkSheetLine."Item No." <> '' THEN BEGIN
                IF NOT CSRefillData.GET(StockTakeWorkSheetLine."Item No.",StockTakeWorkSheetLine."Variant Code",StockTakeWorksheet."Conf Location Code",CSStockTakes."Stock-Take Id") THEN BEGIN
                  CSRefillData.INIT;
                  CSRefillData.VALIDATE("Item No.",StockTakeWorkSheetLine."Item No.");
                  CSRefillData.VALIDATE("Variant Code",StockTakeWorkSheetLine."Variant Code");
                  CSRefillData.VALIDATE(Location,StockTakeWorksheet."Conf Location Code");
                  CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                  CSRefillData.INSERT(TRUE);
                END;

                IF CSRefillData."Variant Code" <> '' THEN
                  CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
                ELSE
                  CSRefillData."Combined key" := CSRefillData."Item No.";

                CSRefillData."Qty. in Store" += StockTakeWorkSheetLine."Qty. (Counted)";

                IF Item.GET(CSRefillData."Item No.") THEN BEGIN
                  CSRefillData.VALIDATE("Item Group Code",Item."Item Group");
                  IF CSSetup."Media Library" = CSSetup."Media Library"::Magento THEN BEGIN
                    MagentoPictureLink.SETRANGE("Item No.",Item."No.");
                    MagentoPictureLink.SETRANGE("Base Image",TRUE);
                    IF MagentoPictureLink.FINDFIRST THEN
                      IF MagentoPicture.GET(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") THEN
                        CSRefillData."Image Url" := MagentoPicture.GetMagentotUrl;
                    END;
                END;

                CSRefillData.MODIFY(TRUE);
              END;
            UNTIL StockTakeWorkSheetLine.NEXT = 0;
          END;

          CLEAR(StockTakeWorksheet);
          CLEAR(StockTakeWorkSheetLine);
          StockTakeWorksheet.GET(CSStockTakes.Location,'STOCKROOM');
          StockTakeWorkSheetLine.SETRANGE("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
          StockTakeWorkSheetLine.SETRANGE("Worksheet Name", StockTakeWorksheet.Name);
          IF StockTakeWorkSheetLine.FINDSET THEN BEGIN
            REPEAT
              IF StockTakeWorkSheetLine."Item No." <> '' THEN BEGIN
                IF NOT CSRefillData.GET(StockTakeWorkSheetLine."Item No.",StockTakeWorkSheetLine."Variant Code",StockTakeWorksheet."Conf Location Code",CSStockTakes."Stock-Take Id") THEN BEGIN
                  CSRefillData.INIT;
                  CSRefillData.VALIDATE("Item No.",StockTakeWorkSheetLine."Item No.");
                  CSRefillData.VALIDATE("Variant Code",StockTakeWorkSheetLine."Variant Code");
                  CSRefillData.VALIDATE(Location,StockTakeWorksheet."Conf Location Code");
                  CSRefillData."Stock-Take Id" := CSStockTakes."Stock-Take Id";
                  CSRefillData.INSERT(TRUE);
                END;

                IF CSRefillData."Variant Code" <> '' THEN
                  CSRefillData."Combined key" := CSRefillData."Item No." + '-' + CSRefillData."Variant Code"
                ELSE
                  CSRefillData."Combined key" := CSRefillData."Item No.";

                CSRefillData."Qty. in Stock" += StockTakeWorkSheetLine."Qty. (Counted)";

                IF Item.GET(CSRefillData."Item No.") THEN BEGIN
                  CSRefillData.VALIDATE("Item Group Code",Item."Item Group");
                  IF CSSetup."Media Library" = CSSetup."Media Library"::Magento THEN BEGIN
                    MagentoPictureLink.SETRANGE("Item No.",Item."No.");
                    MagentoPictureLink.SETRANGE("Base Image",TRUE);
                    IF MagentoPictureLink.FINDFIRST THEN
                      IF MagentoPicture.GET(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") THEN
                        CSRefillData."Image Url" := MagentoPicture.GetMagentotUrl;
                  END;
                END;

                CSRefillData.MODIFY(TRUE);
              END;
            UNTIL StockTakeWorkSheetLine.NEXT = 0;
          END;

          CSStockTakes."Create Refill Data Ended" := CURRENTDATETIME;
          CSStockTakes.MODIFY;

        END;

        JTokenWriter := JTokenWriter.JTokenWriter;
        WITH JTokenWriter DO BEGIN
        WriteStartObject;

        WritePropertyName('section');
        WriteStartArray;
        CSRefillSections.SETFILTER(Stock_Take_Id,CSStockTakes."Stock-Take Id");
        CSRefillSections.OPEN;
        WHILE CSRefillSections.READ DO BEGIN
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
        END;
        CSRefillSections.CLOSE;
        WriteEndArray;

        WritePropertyName('item');
        WriteStartArray;
        CSRefillItems.SETFILTER(Stock_Take_Id,CSStockTakes."Stock-Take Id");
        CSRefillItems.OPEN;
        WHILE CSRefillItems.READ DO BEGIN
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
        END;
        CSRefillItems.CLOSE;
        WriteEndArray;

        WriteEndObject;
        JObject := Token;
        END;

        Result := JObject.ToString();
    end;

    procedure ClearDeviceInfo(var CSDevices: Record "CS Devices")
    begin
        CSDevices."Last Download Timestamp" := 0;
        CSDevices."Refresh Item Catalog" := TRUE;
        CSDevices.MODIFY(TRUE);
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
        IF STRLEN(ItemCrossReference."Cross-Reference No.") <> MAXSTRLEN(ItemCrossReference."Cross-Reference No.") THEN
          EXIT;

        TagModel := COPYSTR(ItemCrossReference."Cross-Reference No.",1,4);

        CLEAR(CSRfidTagModels);
        CSRfidTagModels.SETRANGE(Model,TagModel);
        IF CSRfidTagModels.FINDSET THEN BEGIN

          TagId := CSRfidTagModels.Family + ItemCrossReference."Cross-Reference No.";

          IF NOT CSRfidOfflineData.GET(TagId) THEN BEGIN
            CSRfidOfflineData.INIT;
            CSRfidOfflineData.Key := TagId;
            CSRfidOfflineData.INSERT(TRUE);
          END;

          CSRfidOfflineData.VALIDATE("Cross-Reference Item No.",ItemCrossReference."Item No.");
          CSRfidOfflineData.VALIDATE("Cross-Reference Variant Code",ItemCrossReference."Variant Code");
          CSRfidOfflineData.VALIDATE("Cross-Reference UoM",ItemCrossReference."Unit of Measure");
          CSRfidOfflineData.VALIDATE("Cross-Reference Description",ItemCrossReference.Description);
          CSRfidOfflineData.VALIDATE("Cross-Reference Discontinue",ItemCrossReference."Discontinue Bar Code");
          CSRfidOfflineData.VALIDATE(Heartbeat,CURRENTDATETIME);
          IF Item.GET(CSRfidOfflineData."Cross-Reference Item No.") THEN BEGIN
            CSRfidOfflineData.VALIDATE("Item Group Code",Item."Item Group");
            IF CSSetup."Media Library" = CSSetup."Media Library"::Magento THEN BEGIN
              MagentoPictureLink.SETRANGE("Item No.",Item."No.");
              MagentoPictureLink.SETRANGE("Base Image",TRUE);
              IF MagentoPictureLink.FINDFIRST THEN
                IF MagentoPicture.GET(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") THEN
                  CSRfidOfflineData."Image Url" := MagentoPicture.GetMagentotUrl;
            END;
          END;
          CSRfidOfflineData.MODIFY(TRUE);
        END;
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
        IF STRLEN(ItemCrossReference."Cross-Reference No.") <> MAXSTRLEN(ItemCrossReference."Cross-Reference No.") THEN
          EXIT;

        TagModel := COPYSTR(ItemCrossReference."Cross-Reference No.",1,4);

        CLEAR(CSRfidTagModels);
        CSRfidTagModels.SETRANGE(Model,TagModel);
        IF CSRfidTagModels.FINDSET THEN BEGIN

          TagId := CSRfidTagModels.Family + ItemCrossReference."Cross-Reference No.";

          IF CSRfidOfflineData.GET(TagId) THEN
            CSRfidOfflineData.DELETE(TRUE);

        END;
        //+NPR5.50 [346068]
    end;

    procedure CreateStockTakeWorksheet(Location: Code[20];Name: Code[10];var StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        CSSetup: Record "CS Setup";
        StockTakeConfiguration: Record "Stock-Take Configuration";
        StockTakeTemplate: Record "Stock-Take Template";
    begin
        IF NOT CSSetup.GET THEN
          EXIT;

        IF NOT CSSetup."Enable Capture Service" THEN
          EXIT;

        IF StockTakeWorksheet.GET(Location,Name) THEN
          EXIT;

        CSSetup.TESTFIELD("Stock-Take Template");
        StockTakeTemplate.GET(CSSetup."Stock-Take Template");

        IF NOT StockTakeConfiguration.GET(Location) THEN BEGIN
          StockTakeConfiguration.INIT;
          StockTakeConfiguration.Code := Location;
          StockTakeConfiguration.TRANSFERFIELDS(StockTakeTemplate, FALSE);
          StockTakeConfiguration.Description := STRSUBSTNO('%1 Stock-Take',StockTakeConfiguration.Code);
          StockTakeConfiguration."Location Code" := Location;
          StockTakeConfiguration."Inventory Calc. Date" := WORKDATE;
          StockTakeConfiguration."Stock-Take Template Code" := StockTakeTemplate.Code;
          StockTakeConfiguration.INSERT();
        END;

        StockTakeWorksheet.INIT;
        StockTakeWorksheet."Stock-Take Config Code" := StockTakeConfiguration.Code;
        StockTakeWorksheet.Name := Name;
        StockTakeWorksheet.INSERT(TRUE);
    end;

    procedure UpdateDeviceInfo(DeviceId: Code[10];CurrentTimestamp: BigInteger;Location: Code[20]) Result: Text
    var
        CSDevices: Record "CS Devices";
    begin
        IF NOT CSDevices.GET(DeviceId) THEN
         EXIT;

        IF CurrentTimestamp = 0 THEN
          EXIT;

        CSDevices."Last Download Timestamp" := CurrentTimestamp;
        //-NPR5.50 [353741]
        CSDevices."Refresh Item Catalog" := FALSE;
        //+NPR5.50 [353741]
        CSDevices.Location := Location;
        CSDevices.MODIFY(TRUE);

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
        CLEAR(CSStockTakes);
        CSStockTakes.SETRANGE(Location,Location.Code);
        CSStockTakes.SETRANGE(Closed, 0DT);
        IF CSStockTakes.FINDSET THEN
         ERROR(Err_CSStockTakes,CSStockTakes."Stock-Take Id");

        CLEAR(CSStockTakes);
        CSStockTakes.SETRANGE(Location,Location.Code);
        CSStockTakes.SETFILTER(Closed, '<>%1', 0DT);
        CSStockTakes.SETRANGE("Journal Posted", FALSE);
        IF CSStockTakes.FINDSET THEN
         ERROR(Err_PostingNotDone);

        CSSetup.GET;
        CSSetup.TESTFIELD("Phys. Inv Jour Temp Name");
        ItemJournalTemplate.GET(CSSetup."Phys. Inv Jour Temp Name");
        IF NOT ItemJournalBatch.GET(CSSetup."Phys. Inv Jour Temp Name",Location.Code) THEN BEGIN
          ItemJournalBatch.INIT;
          ItemJournalBatch.VALIDATE("Journal Template Name",CSSetup."Phys. Inv Jour Temp Name");
          ItemJournalBatch.VALIDATE(Name,Location.Code);
          ItemJournalBatch.Description := STRSUBSTNO(Text001,Location.Code);
          ItemJournalBatch.VALIDATE("No. Series",CSSetup."Phys. Inv Jour No. Series");
          ItemJournalBatch."Reason Code" := ItemJournalTemplate."Reason Code";
          ItemJournalBatch.INSERT(TRUE);
        END ELSE BEGIN
          RecRef.GETTABLE(ItemJournalBatch);
          CLEAR(CSPostingBuffer);
          CSPostingBuffer.SETRANGE("Table No.",RecRef.NUMBER);
          CSPostingBuffer.SETRANGE("Record Id",RecRef.RECORDID);
          CSPostingBuffer.SETRANGE(Executed,FALSE);
          IF CSPostingBuffer.FINDSET THEN
            ERROR(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

          CLEAR(ItemJournalLine);
          ItemJournalLine.SETRANGE("Journal Template Name",ItemJournalBatch."Journal Template Name");
          ItemJournalLine.SETRANGE("Journal Batch Name",ItemJournalBatch.Name);
          IF ItemJournalLine.COUNT > 0 THEN
            ERROR(Err_StockTakeWorksheetNotEmpty,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);
        END;

        NewCSStockTakes.INIT;
        NewCSStockTakes."Stock-Take Id" := CREATEGUID;
        NewCSStockTakes.Created := CURRENTDATETIME;
        NewCSStockTakes."Created By" := USERID;
        NewCSStockTakes.Location := Location.Code;
        NewCSStockTakes."Journal Template Name" := ItemJournalBatch."Journal Template Name";
        NewCSStockTakes."Journal Batch Name" := ItemJournalBatch.Name;
        NewCSStockTakes.INSERT(TRUE);

        COMMIT;

        IF GUIALLOWED THEN BEGIN
          IF CONFIRM(STRSUBSTNO(Text002,Location.Code,TRUE)) THEN BEGIN
            CLEAR(ItemJournalLine);
            ItemJournalLine.INIT;
            ItemJournalLine.VALIDATE("Journal Template Name",NewCSStockTakes."Journal Template Name");
            ItemJournalLine.VALIDATE("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
            ItemJournalLine."Location Code" := NewCSStockTakes.Location;

            CLEAR(NoSeriesMgt);
            ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",FALSE);
            ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
            ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
            ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

            CLEAR(Item);
            Item.SETFILTER("Location Filter",NewCSStockTakes.Location);
            IF NOT Item.FINDSET THEN
              ERROR(Text003,Location);

            CLEAR(CalculateInventory);
            CalculateInventory.USEREQUESTPAGE(FALSE);
            CalculateInventory.SETTABLEVIEW(Item);
            CalculateInventory.SetItemJnlLine(ItemJournalLine);
            CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
            CalculateInventory.RUNMODAL;

            CLEAR(ItemJournalLine);
            ItemJournalLine.SETRANGE("Journal Template Name",NewCSStockTakes."Journal Template Name");
            ItemJournalLine.SETRANGE("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
            ItemJournalLine.SETRANGE("Location Code",NewCSStockTakes.Location);
            IF ItemJournalLine.FINDSET THEN BEGIN
              REPEAT
                QtyCalculated += ItemJournalLine."Qty. (Calculated)"
              UNTIL ItemJournalLine.NEXT = 0;
            END;

            NewCSStockTakes."Predicted Qty." := QtyCalculated;
            NewCSStockTakes."Inventory Calculated" := TRUE;
            NewCSStockTakes.MODIFY(TRUE);
          END;
        END ELSE BEGIN
          CLEAR(ItemJournalLine);
          ItemJournalLine.INIT;
          ItemJournalLine.VALIDATE("Journal Template Name",NewCSStockTakes."Journal Template Name");
          ItemJournalLine.VALIDATE("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
          ItemJournalLine."Location Code" := NewCSStockTakes.Location;

          CLEAR(NoSeriesMgt);
          ItemJournalLine."Document No." := NoSeriesMgt.GetNextNo(ItemJournalBatch."No. Series",ItemJournalLine."Posting Date",FALSE);
          ItemJournalLine."Source Code" := ItemJournalTemplate."Source Code";
          ItemJournalLine."Reason Code" := ItemJournalBatch."Reason Code";
          ItemJournalLine."Posting No. Series" := ItemJournalBatch."Posting No. Series";

          CLEAR(Item);
          Item.SETFILTER("Location Filter",NewCSStockTakes.Location);
          IF NOT Item.FINDSET THEN
            ERROR(Text003,Location);

          CLEAR(CalculateInventory);
          CalculateInventory.USEREQUESTPAGE(FALSE);
          CalculateInventory.SETTABLEVIEW(Item);
          CalculateInventory.SetItemJnlLine(ItemJournalLine);
          CalculateInventory.InitializeRequest(WORKDATE,ItemJournalLine."Document No.",FALSE);
          CalculateInventory.RUNMODAL;

          CLEAR(ItemJournalLine);
          ItemJournalLine.SETRANGE("Journal Template Name",NewCSStockTakes."Journal Template Name");
          ItemJournalLine.SETRANGE("Journal Batch Name",NewCSStockTakes."Journal Batch Name");
          ItemJournalLine.SETRANGE("Location Code",NewCSStockTakes.Location);
          IF ItemJournalLine.FINDSET THEN BEGIN
            REPEAT
              QtyCalculated += ItemJournalLine."Qty. (Calculated)"
            UNTIL ItemJournalLine.NEXT = 0;
          END;

          NewCSStockTakes."Predicted Qty." := QtyCalculated;
          NewCSStockTakes."Inventory Calculated" := TRUE;
          NewCSStockTakes.MODIFY(TRUE);
        END;
    end;

    procedure CancelCounting(var CSStockTakes: Record "CS Stock-Takes")
    var
        ItemJournalBatch: Record "Item Journal Batch";
        LocationRec: Record Location;
        RecRef: RecordRef;
        CSPostingBuffer: Record "CS Posting Buffer";
    begin
        IF CSStockTakes.Closed <> 0DT THEN
          EXIT;

        //-NPR5.52 [364063]
        IF NOT LocationRec.GET(CSStockTakes.Location) THEN
          ERROR(Err_MissingLocation);

        IF ItemJournalBatch.GET(CSStockTakes."Journal Template Name",CSStockTakes."Journal Batch Name") THEN BEGIN
          RecRef.GETTABLE(ItemJournalBatch);
          CLEAR(CSPostingBuffer);
          CSPostingBuffer.SETRANGE("Table No.",RecRef.NUMBER);
          CSPostingBuffer.SETRANGE("Record Id",RecRef.RECORDID);
          CSPostingBuffer.SETRANGE(Executed,FALSE);
          IF CSPostingBuffer.FINDSET THEN
            ERROR(Err_PostingIsScheduled,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name);

          IF NOT CONFIRM(STRSUBSTNO(Err_ConfirmForceClose,ItemJournalBatch."Journal Template Name",ItemJournalBatch.Name),TRUE) THEN
            EXIT;

          ItemJournalBatch.DELETE(TRUE);

        END;
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",Location);
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",'SALESFLOOR');
        // StockTakeWorksheetLine.DELETEALL(TRUE);
        //
        // CLEAR(StockTakeWorksheetLine);
        // StockTakeWorksheetLine.SETRANGE("Stock-Take Config Code",Location);
        // StockTakeWorksheetLine.SETRANGE("Worksheet Name",'STOCKROOM');
        // StockTakeWorksheetLine.DELETEALL(TRUE);
        //+NPR5.52 [364063]

        CSStockTakes.Closed := CURRENTDATETIME;
        CSStockTakes."Closed By" := USERID;
        CSStockTakes.Note := Txt_CountingCancelled;

        CSStockTakes.MODIFY(TRUE);
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
        IF NOT CSSetup.GET THEN
          EXIT;

        IF NOT CSSetup."Enable Capture Service" THEN
          EXIT;

        IF Rec.ISTEMPORARY THEN
          EXIT;

        IF Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" THEN
          EXIT;

        IF NOT Rec."Is Retail Serial No." THEN
          EXIT;

        CreateCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterModifyEvent', '', true, true)]
    local procedure T5717OnAfterModify(var Rec: Record "Item Cross Reference";var xRec: Record "Item Cross Reference";RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        IF NOT CSSetup.GET THEN
          EXIT;

        IF NOT CSSetup."Enable Capture Service" THEN
          EXIT;

        IF Rec.ISTEMPORARY THEN
          EXIT;

        IF Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" THEN
          EXIT;

        IF NOT Rec."Is Retail Serial No." THEN
          EXIT;

        CreateCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterDeleteEvent', '', true, true)]
    local procedure T5717OnAfterDelete(var Rec: Record "Item Cross Reference";RunTrigger: Boolean)
    var
        CSSetup: Record "CS Setup";
    begin
        //-NPR5.50 [346068]
        IF NOT CSSetup.GET THEN
          EXIT;

        IF NOT CSSetup."Enable Capture Service" THEN
          EXIT;

        IF Rec.ISTEMPORARY THEN
          EXIT;

        IF Rec."Cross-Reference Type" <> Rec."Cross-Reference Type"::"Bar Code" THEN
          EXIT;

        IF NOT Rec."Is Retail Serial No." THEN
          EXIT;

        DeleteCSRfidOfflineDataRecord(Rec);
        //+NPR5.50 [346068]
    end;
}

