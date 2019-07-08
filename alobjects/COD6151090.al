codeunit 6151090 "Nc RapidConnect Setup Mgt."
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.14/MHA /20180716  CASE 322308 Updated Trigger fields to support Partial Trigger functionality


    trigger OnRun()
    begin
    end;

    local procedure "--- InitSetup"()
    begin
    end;

    local procedure RunInitExportSetup(NcRapidConnectSetup: Record "Nc RapidConnect Setup")
    var
        NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table";
    begin
        if not ExportEnabled(NcRapidConnectSetup) then
          exit;

        InitExportTriggers(NcRapidConnectSetup);
        NcRapidConnectTrigger.SetRange("Setup Code",NcRapidConnectSetup.Code);
        if NcRapidConnectTrigger.IsEmpty then
          exit;

        NcRapidConnectTrigger.FindSet;
        repeat
          RunInitNcSetup(NcRapidConnectSetup,NcRapidConnectTrigger);
        until NcRapidConnectTrigger.Next = 0;
    end;

    local procedure RunInitImportSetup(var NcRapidConnectSetup: Record "Nc RapidConnect Setup")
    begin
        if not ImportEnabled(NcRapidConnectSetup) then
          exit;

        InitImportType(NcRapidConnectSetup);
    end;

    local procedure RunInitNcSetup(NcRapidConnectSetup: Record "Nc RapidConnect Setup";NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table")
    begin
        if not ExportEnabled(NcRapidConnectSetup) then
          exit;
        //-NC2.14 [322308]
        //IF NOT (NcRapidConnectTrigger."Insert Trigger" OR NcRapidConnectTrigger."Modify Trigger") THEN
        //  EXIT;
        if not (InsertTriggerEnabled(NcRapidConnectTrigger) or ModifyTriggerEnabled(NcRapidConnectTrigger)) then
          exit;
        //+NC2.14 [322308]

        InitNcTaskSetup(NcRapidConnectSetup,NcRapidConnectTrigger);
        InitDataLogSetup(NcRapidConnectTrigger);
        InitDataLogSubscriber(NcRapidConnectSetup,NcRapidConnectTrigger);
    end;

    local procedure InitDataLogSetup(NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table")
    var
        DataLogSetup: Record "Data Log Setup (Table)";
        PrevRec: Text;
    begin
        if not DataLogSetup.Get(NcRapidConnectTrigger."Table ID") then begin
          DataLogSetup.Init;
          DataLogSetup."Table ID" := NcRapidConnectTrigger."Table ID";
          //-NC2.14 [322308]
          // IF NcRapidConnectTrigger."Insert Trigger" THEN
          //  DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
          // IF NcRapidConnectTrigger."Modify Trigger" THEN
          //  DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
          if InsertTriggerEnabled(NcRapidConnectTrigger) then
            DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
          if ModifyTriggerEnabled(NcRapidConnectTrigger) then
            DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
          //+NC2.14 [322308]
          DataLogSetup."Keep Log for" := 1000 * 60;
          DataLogSetup.Insert(true);
        end;

        PrevRec := Format(DataLogSetup);

        //-NC2.14 [322308]
        // IF NcRapidConnectTrigger."Insert Trigger" AND (DataLogSetup."Log Insertion" < DataLogSetup."Log Insertion"::Simple) THEN
        //  DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
        // IF NcRapidConnectTrigger."Modify Trigger" AND (DataLogSetup."Log Modification" < DataLogSetup."Log Modification"::Changes) THEN
        //  DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
        if InsertTriggerEnabled(NcRapidConnectTrigger) and (DataLogSetup."Log Insertion" < DataLogSetup."Log Insertion"::Simple) then
          DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
        if ModifyTriggerEnabled(NcRapidConnectTrigger) and (DataLogSetup."Log Modification" < DataLogSetup."Log Modification"::Changes) then
          DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
        //+NC2.14 [322308]

        if PrevRec <> Format(DataLogSetup) then
          DataLogSetup.Modify(true);
    end;

    local procedure InitDataLogSubscriber(NcRapidConnectSetup: Record "Nc RapidConnect Setup";NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table")
    var
        DataLogSubscriber: Record "Data Log Subscriber";
    begin
        if DataLogSubscriber.Get(NcRapidConnectSetup."Task Processor Code",NcRapidConnectTrigger."Table ID",'') then
          exit;

        DataLogSubscriber.Init;
        DataLogSubscriber.Code := NcRapidConnectSetup."Task Processor Code";
        DataLogSubscriber."Table ID" := NcRapidConnectTrigger."Table ID";
        DataLogSubscriber."Company Name" := '';
        DataLogSubscriber.Insert(true);
    end;

    local procedure InitNcTaskSetup(NcRapidConnectSetup: Record "Nc RapidConnect Setup";NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table")
    var
        NcTaskSetup: Record "Nc Task Setup";
    begin
        NcTaskSetup.SetRange("Table No.",NcRapidConnectTrigger."Table ID");
        NcTaskSetup.SetRange("Codeunit ID",CODEUNIT::"Nc RapidConnect Export Mgt.");
        NcTaskSetup.SetRange("Task Processor Code",NcRapidConnectSetup."Task Processor Code");
        if NcTaskSetup.FindFirst then
          exit;

        NcTaskSetup.Init;
        NcTaskSetup."Entry No." := 0;
        NcTaskSetup."Table No." := NcRapidConnectTrigger."Table ID";
        NcTaskSetup."Codeunit ID" := CODEUNIT::"Nc RapidConnect Export Mgt.";
        NcTaskSetup."Task Processor Code" := NcRapidConnectSetup."Task Processor Code";
        NcTaskSetup.Insert(true);
    end;

    procedure InitExportTriggers(NcRapidConnectSetup: Record "Nc RapidConnect Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
        NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table";
    begin
        if NcRapidConnectSetup."Package Code" = '' then
          exit;

        SetConfigPackageTableFilter(NcRapidConnectSetup,ConfigPackageTable);
        if ConfigPackageTable.IsEmpty then
          exit;

        ConfigPackageTable.FindSet;
        repeat
          if not NcRapidConnectTrigger.Get(NcRapidConnectSetup.Code,ConfigPackageTable."Table ID") then begin
            NcRapidConnectTrigger.Init;
            NcRapidConnectTrigger."Setup Code" := NcRapidConnectSetup.Code;
            NcRapidConnectTrigger."Table ID" := ConfigPackageTable."Table ID";
            //-NC2.14 [322308]
            //NcRapidConnectTrigger."Insert Trigger" := FALSE;
            //NcRapidConnectTrigger."Modify Trigger" := FALSE;
            NcRapidConnectTrigger."Insert Trigger" := NcRapidConnectTrigger."Insert Trigger"::None;
            NcRapidConnectTrigger."Modify Trigger" := NcRapidConnectTrigger."Modify Trigger"::None;
            //+NC2.14 [322308]
            NcRapidConnectTrigger.Insert(true);
          end;
        until ConfigPackageTable.Next = 0;
    end;

    local procedure InitImportType(var NcRapidConnectSetup: Record "Nc RapidConnect Setup")
    var
        NcImportType: Record "Nc Import Type";
        ImportTypeCode: Code[20];
        PrevRec: Text;
    begin
        ImportTypeCode := FindImportTypeCode(NcRapidConnectSetup);

        if not ImportEnabled(NcRapidConnectSetup) then begin
          if NcImportType.Get(ImportTypeCode) and NcImportType."Ftp Enabled" then begin
            NcImportType."Ftp Enabled" := false;
            NcImportType.Modify(true);
          end;

          exit;
        end;

        if not NcImportType.Get(ImportTypeCode) then begin
          NcImportType.Init;
          NcImportType.Code := ImportTypeCode;
          NcImportType.Description := NcRapidConnectSetup.Description;
          NcImportType."Import Codeunit ID" := ImportCodeunitId();
          NcImportType."Lookup Codeunit ID" := LookupCodeunitId();
          NcImportType."Webservice Enabled" := false;
          NcImportType."Ftp Enabled" := true;
          NcImportType."Ftp Host" := NcRapidConnectSetup."Ftp Host";
          NcImportType."Ftp Port" := NcRapidConnectSetup."Ftp Port";
          NcImportType."Ftp User" := NcRapidConnectSetup."Ftp User";
          NcImportType."Ftp Password" := NcRapidConnectSetup."Ftp Password";
          NcImportType."Ftp Passive" := NcRapidConnectSetup."Ftp Passive";
          NcImportType."Ftp Path" := NcRapidConnectSetup."Ftp Path";
          NcImportType."Ftp Backup Path" := NcRapidConnectSetup."Ftp Backup Path";
          NcImportType."Ftp Binary" := NcRapidConnectSetup."Ftp Binary";
          NcImportType.Insert(true);
        end;

        PrevRec := Format(NcImportType);

        NcImportType."Import Codeunit ID" := ImportCodeunitId();
        NcImportType."Lookup Codeunit ID" := LookupCodeunitId();
        NcImportType."Webservice Enabled" := false;
        NcImportType."Ftp Enabled" := true;
        NcImportType."Ftp Host" := NcRapidConnectSetup."Ftp Host";
        NcImportType."Ftp Port" := NcRapidConnectSetup."Ftp Port";
        NcImportType."Ftp User" := NcRapidConnectSetup."Ftp User";
        NcImportType."Ftp Password" := NcRapidConnectSetup."Ftp Password";
        NcImportType."Ftp Passive" := NcRapidConnectSetup."Ftp Passive";
        NcImportType."Ftp Path" := NcRapidConnectSetup."Ftp Path";
        NcImportType."Ftp Backup Path" := NcRapidConnectSetup."Ftp Backup Path";
        NcImportType."Ftp Binary" := NcRapidConnectSetup."Ftp Binary";

        if PrevRec <> Format(NcImportType) then
          NcImportType.Modify(true);

        NcRapidConnectSetup."Import Type" := NcImportType.Code;
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151091, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertExportTrigger(var Rec: Record "Nc RapidConnect Trigger Table")
    var
        NcRapidConnectSetup: Record "Nc RapidConnect Setup";
    begin
        if Rec.IsTemporary then
          exit;
        if not NcRapidConnectSetup.Get(Rec."Setup Code") then
          exit;
        if not ExportEnabled(NcRapidConnectSetup) then
          exit;

        RunInitNcSetup(NcRapidConnectSetup,Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151091, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyExportTrigger(var Rec: Record "Nc RapidConnect Trigger Table")
    var
        NcRapidConnectSetup: Record "Nc RapidConnect Setup";
    begin
        if Rec.IsTemporary then
          exit;
        if not NcRapidConnectSetup.Get(Rec."Setup Code") then
          exit;
        if not ExportEnabled(NcRapidConnectSetup) then
          exit;

        RunInitNcSetup(NcRapidConnectSetup,Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151090, 'OnAfterValidateEvent', 'Export Enabled', true, true)]
    local procedure OnValidateExportEnabled(var Rec: Record "Nc RapidConnect Setup")
    begin
        if Rec.IsTemporary then
          exit;

        Rec.Modify(true);
        RunInitExportSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151090, 'OnAfterValidateEvent', 'Import Enabled', true, true)]
    local procedure OnValidateImportEnabled(var Rec: Record "Nc RapidConnect Setup")
    begin
        if Rec.IsTemporary then
          exit;

        RunInitImportSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151090, 'OnBeforeValidateEvent', 'Import Type', true, true)]
    local procedure OnValidateImportType(var Rec: Record "Nc RapidConnect Setup";CurrFieldNo: Integer)
    var
        NcImportType: Record "Nc Import Type";
    begin
        if Rec."Import Type" = '' then
          exit;

        NcImportType.Get(Rec."Import Type");
        NcImportType.TestField("Import Codeunit ID",ImportCodeunitId());

        Rec."Ftp Host" := NcImportType."Ftp Host";
        Rec."Ftp Port" := NcImportType."Ftp Port";
        Rec."Ftp User" := NcImportType."Ftp User";
        Rec."Ftp Password" := NcImportType."Ftp Password";
        Rec."Ftp Passive" := NcImportType."Ftp Passive";
        Rec."Ftp Path" := NcImportType."Ftp Path";
        Rec."Ftp Backup Path" := NcImportType."Ftp Backup Path";
        Rec."Ftp Binary" := NcImportType."Ftp Binary";
    end;

    [EventSubscriber(ObjectType::Table, 6151090, 'OnAfterValidateEvent', 'Task Processor Code', true, true)]
    local procedure OnValidateTaskProcessorCode(var Rec: Record "Nc RapidConnect Setup")
    begin
        if Rec.IsTemporary then
          exit;

        Rec.Modify(true);
        RunInitExportSetup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151090, 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnModifyRapidConnectSetup(var Rec: Record "Nc RapidConnect Setup";RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
          exit;

        RunInitImportSetup(Rec);
    end;

    local procedure "--- Lookup"()
    begin
    end;

    procedure IsValidTableID(SetupCode: Code[20];TableID: Integer): Boolean
    var
        ConfigPackageTable: Record "Config. Package Table";
        NcRapidConnectSetup: Record "Nc RapidConnect Setup";
    begin
        if not NcRapidConnectSetup.Get(SetupCode) then
          exit(false);
        if NcRapidConnectSetup."Package Code" = '' then
          exit(false);

        SetConfigPackageTableFilter(NcRapidConnectSetup,ConfigPackageTable);
        ConfigPackageTable.FilterGroup(40);
        ConfigPackageTable.SetRange("Table ID",TableID);
        exit(ConfigPackageTable.FindFirst);
    end;

    procedure LookupTriggerTableID(SetupCode: Code[20];var ObjectID: Integer): Boolean
    var
        NcRapidConnectSetup: Record "Nc RapidConnect Setup";
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        Objects: Page Objects;
    begin
        if not NcRapidConnectSetup.Get(SetupCode) then
          exit(false);

        SetupTempTableObjects(NcRapidConnectSetup,TempAllObjWithCaption);
        if PAGE.RunModal(PAGE::Objects,TempAllObjWithCaption) = ACTION::LookupOK then begin
          ObjectID := TempAllObjWithCaption."Object ID";
          exit(true);
        end;

        exit(false);
    end;

    local procedure SetupTempTableObjects(NcRapidConnectSetup: Record "Nc RapidConnect Setup";var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        AllObjWithCaption: Record AllObjWithCaption;
        ConfigPackageTable: Record "Config. Package Table";
        NcRapidConnectExportTrigger: Record "Nc RapidConnect Trigger Table";
    begin
        SetConfigPackageTableFilter(NcRapidConnectSetup,ConfigPackageTable);
        if ConfigPackageTable.FindSet then
          repeat
            if (not NcRapidConnectExportTrigger.Get(NcRapidConnectSetup.Code,ConfigPackageTable."Table ID")) and
              AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table,ConfigPackageTable."Table ID")
            then begin
              TempAllObjWithCaption.Init;
              TempAllObjWithCaption := AllObjWithCaption;
              TempAllObjWithCaption.Insert;
            end;
          until ConfigPackageTable.Next = 0;
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure ExportEnabled(NcRapidConnectSetup: Record "Nc RapidConnect Setup"): Boolean
    begin
        if not NcRapidConnectSetup."Export Enabled" then
          exit(false);

        exit(NcRapidConnectSetup."Task Processor Code" <> '');
    end;

    local procedure ImportEnabled(NcRapidConnectSetup: Record "Nc RapidConnect Setup"): Boolean
    begin
        exit(NcRapidConnectSetup."Import Enabled");
    end;

    local procedure FindImportTypeCode(NcRapidConnectSetup: Record "Nc RapidConnect Setup") ImportTypeCode: Code[20]
    var
        NcImportType: Record "Nc Import Type";
        PostFix: Code[20];
    begin
        if NcRapidConnectSetup."Import Type" <> '' then
          exit(NcRapidConnectSetup."Import Type");

        ImportTypeCode := NcRapidConnectSetup.Code;
        if (not NcImportType.Get(ImportTypeCode)) or (NcImportType."Import Codeunit ID" = ImportCodeunitId()) then
          exit(ImportTypeCode);

        PostFix := '01';
        ImportTypeCode := DelStr(NcRapidConnectSetup.Code + PostFix,1,StrLen(NcRapidConnectSetup.Code + PostFix) - MaxStrLen(NcImportType.Code));
        while NcImportType.Get(ImportTypeCode) and (NcImportType."Import Codeunit ID" <> ImportCodeunitId()) do begin
          PostFix := IncStr(PostFix);
          ImportTypeCode := DelStr(NcRapidConnectSetup.Code + PostFix,1,StrLen(NcRapidConnectSetup.Code + PostFix) - MaxStrLen(NcImportType.Code));
        end;

        exit(ImportTypeCode);
    end;

    procedure SetConfigPackageTableFilter(NcRapidConnectSetup: Record "Nc RapidConnect Setup";var ConfigPackageTable: Record "Config. Package Table")
    var
        ConfigPackage: Record "Config. Package";
    begin
        ConfigPackage.Get(NcRapidConnectSetup."Package Code");
        if ConfigPackage."Exclude Config. Tables" then
          ConfigPackageTable.SetFilter("Table ID",'<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
            DATABASE::"Config. Template Header",DATABASE::"Config. Template Line",
            DATABASE::"Config. Questionnaire",DATABASE::"Config. Question Area",DATABASE::"Config. Question",
            DATABASE::"Config. Line",DATABASE::"Config. Package Filter",DATABASE::"Config. Field Mapping");

        ConfigPackageTable.SetRange("Package Code",NcRapidConnectSetup."Package Code");
    end;

    local procedure ImportCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Nc RapidConnect Import Mgt.");
    end;

    local procedure LookupCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Nc RapidConnect Import Lookup");
    end;

    local procedure InsertTriggerEnabled(NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table"): Boolean
    begin
        //-NC2.14 [322308]
        exit(NcRapidConnectTrigger."Insert Trigger" <> NcRapidConnectTrigger."Insert Trigger"::None);
        //+NC2.14 [322308]
    end;

    local procedure ModifyTriggerEnabled(NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table"): Boolean
    begin
        //-NC2.14 [322308]
        exit(NcRapidConnectTrigger."Modify Trigger" <> NcRapidConnectTrigger."Modify Trigger"::None);
        //+NC2.14 [322308]
    end;
}

