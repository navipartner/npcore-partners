codeunit 6060081 "MCS Rec. Service API"
{

    trigger OnRun()
    begin
        GetModelList;

        //MESSAGE(CreateDotNetDateTime(WORKDATE));
    end;

    var
        RecServiceAPI: DotNet npNetRecommendationServiceAPI;
        ConfirmDeleteModel: Label 'Delete model %1?';
        ErrorModelExists: Label 'Model already exists in Azure';
        ModelInfo: DotNet npNetModelInfo;
        ModelInfoList: DotNet npNetModelInfoList;
        CatalogImportStats: DotNet npNetCatalogImportStats;
        UsageImportStats: DotNet npNetUsageImportStats;
        BuildRequestInfo: DotNet npNetBuildRequestInfo;
        BuildParameters: DotNet npNetBuildParameters;
        RandomSplitterParameters: DotNet npNetRandomSplitterParameters;
        RecommendationBuildParameters: DotNet npNetRecommendationBuildParameters;
        SplitterStrategy: DotNet npNetSplitterStrategy;
        BuildType: DotNet npNetBuildType;
        OperationId: Text;
        OperationStatus: DotNet npNetOperationStatus;
        OperationInfo: DotNet npNetOperationInfo;
        RecommendedItemSetInfoList: DotNet npNetRecommendedItemSetInfoList;
        RecommendedItemSetInfo: DotNet npNetRecommendedItemSetInfo;
        RecommendedItemInfo: DotNet npNetRecommendedItemInfo;
        UpdateActiveBuildInfo: DotNet npNetUpdateActiveBuildInfo;
        DotNetString: DotNet npNetString;
        DotNetDateTime: DotNet npNetDateTime;
        MsgCatalogUploaded: Label 'Catalog uploaded for model %1';
        MsgUsageDataUploaded: Label 'Usage data uploaded for model %1';
        MsgBuildCreated: Label 'Created build %1 for model %2';
        MsgModelDeleted: Label 'Model %1 deleted from Azure';
        JsonConvert: DotNet npNetJsonConvert;
        DebugTxt: Text;
        ErrorDataImport: Label 'Error in data import. Not all records is imported.';
        MsgOperationStatus: Label 'Operation Status: #1\Operation status check: #2\\Will check again in 10 seconds.';
        TaskDialog: Dialog;
        TaskStatus: Text;
        MsgIsActivBuild: Label 'Activated build %1 for model %2';
        MsgUploadUsageStatus: Label 'Uploading Usage data...';
        MsgUploadCatalogStatus: Label 'Uploading Catalog data...';
        MsgCreatingModelStatus: Label 'Creating Model #1';
        MsgGetRecStatus: Label 'Requesting recommendations for item no. #1';
        MsgDeletingModelStatus: Label 'Deleting model #1';
        MsgSetActivBuildlStatus: Label 'Activating build #1 For model #2';
        MsgCreatingBuildStatus: Label 'Creating build for model #1';

    local procedure InitializeClient(): Boolean
    var
        CognitivityAPISetup: Record "MCS API Setup";
    begin
        if not CognitivityAPISetup.Get(CognitivityAPISetup.API::Recommendation) then
          exit(false);

        if not CognitivityAPISetup."Use Cognitive Services" then
          exit(false);

        CognitivityAPISetup.TestField("Key 1");

        RecServiceAPI := RecServiceAPI.RecommendationServiceAPI(CognitivityAPISetup."Key 1",'https://westus.api.cognitive.microsoft.com/recommendations/v4.0');

        exit(true);
    end;

    procedure GetModelList()
    var
        MCSRecommendationsModel: Record "MCS Recommendations Model";
    begin
        if not InitializeClient then
          exit;

        ModelInfoList := RecServiceAPI.GetModels();
        //DebugString := JsonConvert.SerializeObject(ResponseEntity);

        foreach ModelInfo in ModelInfoList.Models do begin
          Clear(MCSRecommendationsModel);
          MCSRecommendationsModel.SetRange("Model ID",ModelInfo.Id);
          if not MCSRecommendationsModel.FindSet then begin
            MCSRecommendationsModel.Init;
            MCSRecommendationsModel."Model ID" := ModelInfo.Id;
            MCSRecommendationsModel.Code := ModelInfo.Name;
            MCSRecommendationsModel.Description := ModelInfo.Description;
            MCSRecommendationsModel.Insert(true);
          end;
        end;
    end;

    procedure CreateModel(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    begin
        if not InitializeClient then
          exit;

        if MCSRecommendationsModel."Model ID" <> '' then
          Error(ErrorModelExists);

        MCSRecommendationsModel.TestField(Code);

        if GuiAllowed then
          TaskDialog.Open(MsgCreatingModelStatus,MCSRecommendationsModel.Code);

        ModelInfo := RecServiceAPI.CreateModel(MCSRecommendationsModel.Code,MCSRecommendationsModel.Description);
        MCSRecommendationsModel."Model ID" := ModelInfo.Id;
        MCSRecommendationsModel.Modify(true);

        if GuiAllowed then
          TaskDialog.Close();
    end;

    procedure UploadCatalog(var MCSRecommendationsModel: Record "MCS Recommendations Model";CatalogFilePath: Text)
    begin
        if not InitializeClient then
          exit;

        MCSRecommendationsModel.TestField(MCSRecommendationsModel."Model ID");

        if GuiAllowed then
          TaskDialog.Open(MsgUploadCatalogStatus);

        CatalogImportStats := RecServiceAPI.UploadCatalog(MCSRecommendationsModel."Model ID",CatalogFilePath,'catalog.csv');
        MCSRecommendationsModel."Catalog Uploaded" := CatalogImportStats.ErrorLineCount = 0;
        MCSRecommendationsModel.Modify(true);

        if (CatalogImportStats.ErrorLineCount > 0) then begin
        //  IF GUIALLOWED THEN
        //    MESSAGE(ErrorDataImport);
        end else begin
        //  IF GUIALLOWED THEN
        //    MESSAGE(MsgCatalogUploaded,MCSRecommendationsModel.Name);
        end;

        if GuiAllowed then
          TaskDialog.Close();
    end;

    procedure UploadUsageData(var MCSRecommendationsModel: Record "MCS Recommendations Model";UsageFilePath: Text)
    begin
        if not InitializeClient then
          exit;

        MCSRecommendationsModel.TestField(MCSRecommendationsModel."Model ID");

        if GuiAllowed then
          TaskDialog.Open(MsgUploadUsageStatus);

        DotNetDateTime := DotNetDateTime.UtcNow;
        DotNetString := 'usage_' + DotNetDateTime.ToString('yyyyMMddHHmmss') + '.csv';

        UsageImportStats := RecServiceAPI.UploadUsage(MCSRecommendationsModel."Model ID",UsageFilePath,DotNetString);
        MCSRecommendationsModel."Usage Data Uploaded" := UsageImportStats.ErrorLineCount = 0;
        MCSRecommendationsModel.Modify(true);

        if (UsageImportStats.ErrorLineCount > 0) then begin
        //  IF GUIALLOWED THEN
        //    MESSAGE(ErrorDataImport);
        end else begin
        //  IF GUIALLOWED THEN
        //    MESSAGE(MsgUsageDataUploaded,MCSRecommendationsModel.Name);
        end;

        if GuiAllowed then
          TaskDialog.Close();
    end;

    procedure CreateRecommendationsBuild(var MCSRecommendationsModel: Record "MCS Recommendations Model";WaitForOperationCompletion: Boolean)
    var
        BuildId: BigInteger;
        OperationIsRunning: Boolean;
        LoopCounter: Integer;
    begin
        if not InitializeClient then
          exit;

        MCSRecommendationsModel.TestField("Model ID");

        if GuiAllowed then
          TaskDialog.Open(MsgCreatingBuildStatus,MCSRecommendationsModel.Code);

        DotNetDateTime := DotNetDateTime.UtcNow;
        DotNetString := 'Recommendation Build ' + DotNetDateTime.ToString('yyyyMMddHHmmss');
        BuildId := RecServiceAPI.CreateRecommendationsBuild(MCSRecommendationsModel."Model ID", DotNetString, false, OperationId);
        MCSRecommendationsModel."Last Build ID" := BuildId;
        MCSRecommendationsModel."Last Build Date Time" := CurrentDateTime;
        MCSRecommendationsModel.Modify(true);

        OperationId := RecServiceAPI.GetOperationId(OperationId);

        if GuiAllowed then
          TaskDialog.Close();

        if WaitForOperationCompletion then begin
          // Operation status {NotStarted, Running, Cancelling, Cancelled, Succeded, Failed}
          OperationIsRunning := true;
          LoopCounter := 1;
          TaskStatus := Format(OperationStatus.NotStarted);
          if GuiAllowed then
            TaskDialog.Open(MsgOperationStatus,TaskStatus,LoopCounter);
          while(OperationIsRunning) do begin

            OperationInfo := RecServiceAPI.WaitForOperationCompletion(OperationId);
            if (OperationInfo.Status = Format(OperationStatus.Succeeded)) then begin
              //Waiting for 40 sec for propagation of the built model. Azure API requirement.
              //SLEEP(40000);
              //UpdateActiveBuildInfo := UpdateActiveBuildInfo.UpdateActiveBuildInfo();
              //UpdateActiveBuildInfo.ActiveBuildId := MCSRecommendationsModel."Last Build ID";
              //RecServiceAPI.SetActiveBuild(MCSRecommendationsModel."Model ID",UpdateActiveBuildInfo);
              OperationIsRunning := false;
            end else if ((OperationInfo.Status = Format(OperationStatus.Failed)) or (OperationInfo.Status = Format(OperationStatus.Cancelled))) then
              OperationIsRunning := false;

            TaskStatus := OperationInfo.Status;
            LoopCounter += 1;

            if GuiAllowed then
              TaskDialog.Update();

            if OperationIsRunning then
              Sleep(10000);

          end;
          if GuiAllowed then
            TaskDialog.Close();
        end;

        //IF GUIALLOWED THEN
        //  MESSAGE(MsgBuildCreated,BuildId,MCSRecommendationsModel.Name);
    end;

    local procedure BuildModel(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        BuildId: BigInteger;
    begin
        if not InitializeClient then
          exit;

        MCSRecommendationsModel.TestField("Model ID");
        RandomSplitterParameters := RandomSplitterParameters.RandomSplitterParameters();
        RandomSplitterParameters.RandomSeed := 0;
        RandomSplitterParameters.TestPercent := 10;

        //DebugTxt := JsonConvert.SerializeObject(RandomSplitterParameters);
        //MESSAGE('RandomSplitterParameters:\' + DebugTxt);

        RecommendationBuildParameters := RecommendationBuildParameters.RecommendationBuildParameters();
        RecommendationBuildParameters.NumberOfModelIterations := 10;
        RecommendationBuildParameters.NumberOfModelDimensions := 20;
        RecommendationBuildParameters.ItemCutOffLowerBound := 1;
        RecommendationBuildParameters.EnableModelingInsights := false;
        RecommendationBuildParameters.SplitterStrategy := SplitterStrategy.LastEventSplitter;
        RecommendationBuildParameters.RandomSplitterParameters := RandomSplitterParameters;
        RecommendationBuildParameters.EnableU2I := true;
        RecommendationBuildParameters.UseFeaturesInModel := false;
        RecommendationBuildParameters.AllowColdItemPlacement := false;

        //DebugTxt := JsonConvert.SerializeObject(RecommendationBuildParameters);
        //MESSAGE('RecommendationBuildParameters:\' + DebugTxt);

        BuildRequestInfo := BuildRequestInfo.BuildRequestInfo();
        DotNetDateTime := DotNetDateTime.UtcNow;
        BuildRequestInfo.Description := 'Recommendation Build ' + DotNetDateTime.ToString('yyyyMMddHHmmss') ;

        //DebugTxt := JsonConvert.SerializeObject(BuildRequestInfo);
        //MESSAGE('BuildRequestInfo:\' + DebugTxt);

        BuildRequestInfo.BuildType := BuildType.Recommendation;

        BuildParameters := BuildParameters.BuildParameters();
        BuildParameters.Recommendation := RecommendationBuildParameters;

        //DebugTxt := JsonConvert.SerializeObject(BuildParameters);
        //MESSAGE('BuildParameters:\' + DebugTxt);

        BuildRequestInfo.BuildParameters := BuildParameters;

        //DebugTxt := JsonConvert.SerializeObject(BuildRequestInfo);
        //MESSAGE('BuildRequestInfo:\' + DebugTxt);

        BuildId := RecServiceAPI.BuildModel(MCSRecommendationsModel."Model ID", BuildRequestInfo, OperationId);
        MCSRecommendationsModel."Last Build ID" := BuildId;
        MCSRecommendationsModel."Last Build Date Time" := CurrentDateTime;
        MCSRecommendationsModel.Modify(true);
    end;

    procedure DeleteModel(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    begin
        if not InitializeClient then
          exit;

        MCSRecommendationsModel.TestField("Model ID");

        if not Confirm(ConfirmDeleteModel,true,MCSRecommendationsModel.Code) then
          exit;

        if GuiAllowed then
          TaskDialog.Open(MsgDeletingModelStatus,MCSRecommendationsModel.Code);

        RecServiceAPI.DeleteModel(MCSRecommendationsModel."Model ID");
        MCSRecommendationsModel."Model ID" := '';
        MCSRecommendationsModel."Last Build ID" := 0;
        MCSRecommendationsModel."Last Build Date Time" := 0DT;
        MCSRecommendationsModel."Last Item Ledger Entry No." := 0;
        MCSRecommendationsModel.Enabled := false;
        MCSRecommendationsModel.Modify(true);

        if GuiAllowed then begin
          TaskDialog.Close();
          //MESSAGE(MsgModelDeleted,MCSRecommendationsModel.Name);
        end;
    end;

    procedure SetActiveBuild(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    begin
        if not InitializeClient then
          exit;

        MCSRecommendationsModel.TestField("Model ID");
        MCSRecommendationsModel.TestField("Last Build ID");

        if GuiAllowed then
          TaskDialog.Open(MsgSetActivBuildlStatus,MCSRecommendationsModel."Last Build ID",MCSRecommendationsModel.Code);

        //Waiting for 40 sec for propagation of the built model. Azure API requirement.
        Sleep(40000);

        UpdateActiveBuildInfo := UpdateActiveBuildInfo.UpdateActiveBuildInfo();
        UpdateActiveBuildInfo.ActiveBuildId := MCSRecommendationsModel."Last Build ID";

        RecServiceAPI.SetActiveBuild(MCSRecommendationsModel."Model ID",UpdateActiveBuildInfo);
        MCSRecommendationsModel.Enabled := true;
        MCSRecommendationsModel.Modify(true);

        if GuiAllowed then begin
          TaskDialog.Close();
          Message(MsgIsActivBuild,MCSRecommendationsModel."Last Build ID",MCSRecommendationsModel.Code);
        end;
    end;

    procedure GetRecommendations(var MCSRecommendationsModel: Record "MCS Recommendations Model";ItemNo: Code[20];ShowStatusDialog: Boolean)
    begin
        if not InitializeClient then
          exit;

        if GuiAllowed and ShowStatusDialog then
          TaskDialog.Open(MsgGetRecStatus,ItemNo);

        //Move to setup
        RecommendedItemSetInfoList := RecServiceAPI.GetRecommendations(MCSRecommendationsModel."Model ID",MCSRecommendationsModel."Last Build ID",ItemNo,5);

        foreach RecommendedItemSetInfo in RecommendedItemSetInfoList.RecommendedItemSetInfo do begin
          foreach RecommendedItemInfo in RecommendedItemSetInfo.Items do begin
            Message(RecommendedItemInfo.Id + '\' + RecommendedItemInfo.Name + '\' + Format(RecommendedItemSetInfo.Rating));
          end;
        end;

        if GuiAllowed and ShowStatusDialog then
          TaskDialog.Close();
    end;

    procedure GetRecommendationsLines(var TempMCSRecommendationsLine: Record "MCS Recommendations Line" temporary;ShowStatusDialog: Boolean)
    var
        MCSRecommendationsModel: Record "MCS Recommendations Model";
    begin
        if not InitializeClient then
          exit;

        if GuiAllowed and ShowStatusDialog then
          TaskDialog.Open(MsgGetRecStatus,TempMCSRecommendationsLine."Seed Item No.");

        MCSRecommendationsModel.Get(TempMCSRecommendationsLine."Model No.");
        RecommendedItemSetInfoList := RecServiceAPI.GetRecommendations(MCSRecommendationsModel."Model ID",MCSRecommendationsModel."Last Build ID",TempMCSRecommendationsLine."Seed Item No.",MCSRecommendationsModel."Recommendations per Seed");

        foreach RecommendedItemSetInfo in RecommendedItemSetInfoList.RecommendedItemSetInfo do begin
          foreach RecommendedItemInfo in RecommendedItemSetInfo.Items do begin
            //MESSAGE(RecommendedItemInfo.Id + '\' + RecommendedItemInfo.Name + '\' + FORMAT(RecommendedItemSetInfo.Rating));
            TempMCSRecommendationsLine."Entry No." := TempMCSRecommendationsLine."Entry No." + 1;
            TempMCSRecommendationsLine."Item No." := RecommendedItemInfo.Id;
            TempMCSRecommendationsLine.Description := RecommendedItemInfo.Name;
            TempMCSRecommendationsLine.Rating := RecommendedItemSetInfo.Rating;
            TempMCSRecommendationsLine."Date Time" := CurrentDateTime;
            TempMCSRecommendationsLine.Insert;
          end;
        end;

        if GuiAllowed and ShowStatusDialog then
          TaskDialog.Close();
    end;

    procedure CreateRecommendationsModel(var Rec: Record "MCS Recommendations Model";CatalogFilePath: Text;UsageFilePath: Text;WaitForOperationCompletion: Boolean)
    begin
        CreateModel(Rec);
        UploadCatalog(Rec,CatalogFilePath);
        UploadUsageData(Rec,UsageFilePath);
        CreateRecommendationsBuild(Rec,WaitForOperationCompletion);
        SetActiveBuild(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6060081, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteModel(var Rec: Record "MCS Recommendations Model";RunTrigger: Boolean)
    var
        RecRef: RecordRef;
        MCSFaces: Record "MCS Faces";
        MCSPersonBusinessEntities: Record "MCS Person Business Entities";
    begin
        if not RunTrigger then
          exit;

        RecRef.GetTable(Rec);
        if RecRef.IsTemporary then
          exit;

        if not InitializeClient then
          exit;

        if (Rec."Model ID" <> '') then begin
          RecServiceAPI.DeleteModel(Rec."Model ID");
        end;
    end;

    procedure CreateDotNetDateTime(CurrentDate: Date): Text
    var
        DateTimeDotNet: DotNet npNetDateTime;
        DateTimeTxt: Text;
        CultureInfoDotNet: DotNet npNetCultureInfo;
    begin
        //YYYY-MM-DDTHH:MM:SS
        DateTimeTxt := Format(CurrentDate) + ' ' + '12:00:00.00';
        DateTimeDotNet := DateTimeDotNet.Parse(DateTimeTxt);
        exit(DateTimeDotNet.ToString('yyyy-MM-ddThh:mm:ss',CultureInfoDotNet.InvariantCulture));
    end;
}

