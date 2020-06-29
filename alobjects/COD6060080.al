codeunit 6060080 "MCS Rec. Build Model Data"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created
    // NPR5.30/BR  /20170220  CASE 252646 Added functionality to save data to csv. Microsoft Recommendation API only support file based transfer at the moment
    // NPR5.36/CLVA/20170829  CASE 286062 Added RefreshRecommendations to the UploadUsageData function


    trigger OnRun()
    begin
    end;

    var
        TextContinued: Label 'Continued....';

    procedure PreviewDataToSend(SendType: Option Catalog,History,BusinessRules; MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        OStr: OutStream;
        IStr: InStream;
        DisplayText: Text;
        TempBlob: Codeunit "Temp Blob";
        HasMoreLines: Boolean;
    begin
        TempBlob.CreateOutStream(OStr);
        case SendType of
            SendType::Catalog:
                GetCatalogStream(MCSRecommendationsModel, false, false, OStr);
            SendType::History:
                begin
                    MCSRecommendationsModel."Last Item Ledger Entry No." := 0;
                    repeat
                        GetHistoryStream(MCSRecommendationsModel, false, OStr, HasMoreLines);
                        if HasMoreLines then begin
                            TempBlob.CreateInStream(IStr);
                            IStr.Read(DisplayText);
                            Message(DisplayText + TextContinued);
                            Clear(IStr);
                            Clear(OStr);
                            Clear(DisplayText);
                            Clear(TempBlob);
                            TempBlob.CreateOutStream(OStr);
                        end;
                    until HasMoreLines = false;
                end;
            SendType::BusinessRules:
                ;
        end;

        TempBlob.CreateInStream(IStr);
        IStr.Read(DisplayText);
        Message(DisplayText);
    end;

    procedure GetCatalogStream(MCSRecommendationsModel: Record "MCS Recommendations Model"; ModifiedItemsOnly: Boolean; MarkAsModified: Boolean; var Outstr: OutStream)
    var
        MCSRecommendationsCatalog: XMLport "MCS Recommendations Catalog";
    begin
        Clear(MCSRecommendationsCatalog);
        MCSRecommendationsCatalog.SetModel(MCSRecommendationsModel);
        if MCSRecommendationsModel."Language Code" <> '' then
            MCSRecommendationsCatalog.SetLanguageCode(MCSRecommendationsModel."Language Code");
        if ModifiedItemsOnly then
            if MCSRecommendationsModel."Last Catalog Export Date Time" <> 0DT then
                MCSRecommendationsCatalog.SetLastModifiedDate(DT2Date(MCSRecommendationsModel."Last Catalog Export Date Time"));
        MCSRecommendationsCatalog.SetDestination(Outstr);
        MCSRecommendationsCatalog.Export;
        if MarkAsModified then begin
            MCSRecommendationsModel."Last Catalog Export Date Time" := CurrentDateTime;
            MCSRecommendationsModel.Modify(true);
        end;
    end;

    procedure GetHistoryStream(var MCSRecommendationsModel: Record "MCS Recommendations Model"; MarkAsModified: Boolean; var Outstr: OutStream; var HasMoreLines: Boolean)
    var
        MCSRecommendationsHistory: XMLport "MCS Recommendations History";
        ItemLedgerEntry: Record "Item Ledger Entry";
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
    begin
        GetSetup(MCSRecommendationsSetup);
        //ItemLedgerEntry.LOCKTABLE;
        Clear(MCSRecommendationsHistory);
        MCSRecommendationsHistory.SetModel(MCSRecommendationsModel);
        MCSRecommendationsHistory.SetMaxNumberOfLines(MCSRecommendationsSetup."Max. History Records per Call");
        MCSRecommendationsHistory.SetLastLedgerEntryNo(MCSRecommendationsModel."Last Item Ledger Entry No.");
        MCSRecommendationsHistory.SetDestination(Outstr);
        MCSRecommendationsHistory.Export;
        MCSRecommendationsModel."Last Item Ledger Entry No." := MCSRecommendationsHistory.GetLastEntryNo;
        HasMoreLines := MCSRecommendationsHistory.GetHasMoreLines;
        if MarkAsModified then
            MCSRecommendationsModel.Modify(true);
    end;

    procedure GetCatalogCSV(MCSRecommendationsModel: Record "MCS Recommendations Model"; ModifiedItemsOnly: Boolean; MarkAsModified: Boolean) Filename: Text
    var
        MCSRecommendationsCatalog: XMLport "MCS Recommendations Catalog";
        TempFile: File;
        Outstr: OutStream;
    begin
        Filename := TemporaryPath + 'catalog.csv';
        TempFile.Create(Filename);
        TempFile.CreateOutStream(Outstr);

        Clear(MCSRecommendationsCatalog);
        MCSRecommendationsCatalog.SetModel(MCSRecommendationsModel);
        if MCSRecommendationsModel."Language Code" <> '' then
            MCSRecommendationsCatalog.SetLanguageCode(MCSRecommendationsModel."Language Code");
        if ModifiedItemsOnly then
            if MCSRecommendationsModel."Last Catalog Export Date Time" <> 0DT then
                MCSRecommendationsCatalog.SetLastModifiedDate(DT2Date(MCSRecommendationsModel."Last Catalog Export Date Time"));
        MCSRecommendationsCatalog.SetDestination(Outstr);
        MCSRecommendationsCatalog.Export;
        if MarkAsModified then begin
            MCSRecommendationsModel."Last Catalog Export Date Time" := CurrentDateTime;
            MCSRecommendationsModel.Modify(true);
        end;

        TempFile.Close();
        exit(Filename);
    end;

    procedure GetHistoryCSV(var MCSRecommendationsModel: Record "MCS Recommendations Model"; MarkAsModified: Boolean; var HasMoreLines: Boolean) Filename: Text
    var
        MCSRecommendationsHistory: XMLport "MCS Recommendations History";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Tempfile: File;
        Outstr: OutStream;
        MCSRecommendationsSetup: Record "MCS Recommendations Setup";
    begin
        GetSetup(MCSRecommendationsSetup);
        Filename := TemporaryPath + 'usage.csv';
        if Exists(Filename) then
            Erase(Filename);
        Tempfile.Create(Filename);
        Tempfile.CreateOutStream(Outstr);

        ItemLedgerEntry.LockTable;
        Clear(MCSRecommendationsHistory);

        MCSRecommendationsHistory.SetModel(MCSRecommendationsModel);
        MCSRecommendationsHistory.SetMaxNumberOfLines(MCSRecommendationsSetup."Max. History Records per Call");
        MCSRecommendationsHistory.SetLastLedgerEntryNo(MCSRecommendationsModel."Last Item Ledger Entry No.");
        MCSRecommendationsHistory.SetDestination(Outstr);
        MCSRecommendationsHistory.Export;
        MCSRecommendationsModel."Last Item Ledger Entry No." := MCSRecommendationsHistory.GetLastEntryNo;
        HasMoreLines := MCSRecommendationsHistory.GetHasMoreLines;
        if MarkAsModified then
            MCSRecommendationsModel.Modify(true);

        Tempfile.Close();
        exit(Filename);
    end;

    local procedure GetSetup(var MCSRecommendationsSetup: Record "MCS Recommendations Setup")
    begin
        if MCSRecommendationsSetup.Get then
            exit;
        MCSRecommendationsSetup.Init;
        MCSRecommendationsSetup.Insert(true);
    end;

    procedure CreateModel(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
    begin
        MCSRecServiceAPI.CreateModel(MCSRecommendationsModel);
    end;

    procedure DeleteModel(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
    begin
        MCSRecServiceAPI.DeleteModel(MCSRecommendationsModel);
    end;

    procedure UploadData(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
        CatalogFile: Text;
        UsageFile: Text;
        HasMoreLines: Boolean;
    begin
        CatalogFile := GetCatalogCSV(MCSRecommendationsModel, false, true);
        MCSRecServiceAPI.UploadCatalog(MCSRecommendationsModel, CatalogFile);
        repeat
            UsageFile := GetHistoryCSV(MCSRecommendationsModel, true, HasMoreLines);
            MCSRecServiceAPI.UploadUsageData(MCSRecommendationsModel, UsageFile);
        until HasMoreLines = false;
    end;

    procedure CreateRecommendationsBuild(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
    begin
        MCSRecServiceAPI.CreateRecommendationsBuild(MCSRecommendationsModel, true);
    end;

    procedure SetActiveBuild(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
    begin
        MCSRecServiceAPI.SetActiveBuild(MCSRecommendationsModel);
    end;

    procedure TestGetRecommendations(var MCSRecommendationsModel: Record "MCS Recommendations Model"; ItemNo: Code[20])
    var
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
    begin
        MCSRecServiceAPI.GetRecommendations(MCSRecommendationsModel, ItemNo, true);
    end;

    procedure CreateRecommendationsModel(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
        DataFilePath: Text;
    begin
        MCSRecServiceAPI.CreateModel(MCSRecommendationsModel);
        Commit;
        UploadData(MCSRecommendationsModel);
        //DataFilePath := GetCatalogCSV(MCSRecommendationsModel,FALSE,FALSE);
        //MCSRecServiceAPI.UploadCatalog(MCSRecommendationsModel,DataFilePath);

        //DataFilePath := GetHistoryCSV(MCSRecommendationsModel,FALSE,FALSE);
        //MCSRecServiceAPI.UploadUsageData(MCSRecommendationsModel,DataFilePath);
        MCSRecServiceAPI.CreateRecommendationsBuild(MCSRecommendationsModel, true);
        Commit;
        MCSRecServiceAPI.SetActiveBuild(MCSRecommendationsModel);
    end;

    procedure UploadUsageData(var MCSRecommendationsModel: Record "MCS Recommendations Model")
    var
        MCSRecServiceAPI: Codeunit "MCS Rec. Service API";
        CatalogFile: Text;
        UsageFile: Text;
        HasMoreLines: Boolean;
        MCSRecommendationsHandler: Codeunit "MCS Recommendations Handler";
    begin
        repeat
            UsageFile := GetHistoryCSV(MCSRecommendationsModel, true, HasMoreLines);
            MCSRecServiceAPI.UploadUsageData(MCSRecommendationsModel, UsageFile);
        until HasMoreLines = false;

        MCSRecServiceAPI.CreateRecommendationsBuild(MCSRecommendationsModel, true);
        Commit;
        MCSRecServiceAPI.SetActiveBuild(MCSRecommendationsModel);
        //NPR5.36-
        MCSRecommendationsHandler.RefreshRecommendations(MCSRecommendationsModel, true);
        //NPR5.36+
    end;
}

