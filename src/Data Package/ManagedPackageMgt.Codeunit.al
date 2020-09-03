codeunit 6014628 "NPR Managed Package Mgt."
{
    // NPR5.26/MMV /20160915 CASE 252131 Created object.
    // 
    // This codeunit allows for import of data packages either manually from a manifest file/blob or straight from ground control.
    // 
    // If you wish to add custom import logic to your specific package, subscribe to event:
    // OnLoadPackage()
    // and check for a match on PrimaryPackageTable number. This will allow you to overwrite the default import flow and instead build custom merging rules for your specific tables.
    // 
    // If you wish to use the default import logic but bypass load method dialogs use:
    // SetLoadMethod()
    // 
    // NPR5.38/MMV /20171201 CASE 294095 Expanded event OnLoadPackage() with LoadType.
    //                                   Ignore DateTime while parsing json.
    // NPR5.39/MMV /20180222 CASE 306227 Replaced system captions with hardcoded text.
    // NPR5.55/MMV /20200615 CASE 409573 Added support for importing from devops feed.


    trigger OnRun()
    begin
    end;

    var
        Caption_LoadMethod: Label 'Select one of the following package load methods:';
        Caption_DeleteWarning: Label 'WARNING: This will delete ALL existing data in tables:\%1.\\Are you sure you want to continue?';
        Caption_ModifyWarning: Label 'WARNING: This could change existing data in tables:\%1.\\Are you sure you want to continue?';
        Caption_DeleteFirst: Label 'Delete all data first and then insert';
        Caption_InsertModify: Label 'Insert and modify existing records';
        Caption_OnlyInsert: Label 'Only Insert';
        GlobalTableListTmp: Record AllObj temporary;
        Caption_SelectPackage: Label 'Select JSON Package';
        GlobalTableString: Text;
        Caption_PackageSuccess: Label 'Package loaded successfully:\Records deleted: %1\Records modified: %2\Records inserted: %3';
        Error_MissingPermission: Label 'Missing write permissions to table %1';
        Error_PackageLoad: Label 'An error occured while loading the package data. No data changes has been made.';
        GlobalLoadMethod: Integer;
        GlobalLoadMethodOverwritten: Boolean;
        IsDialogOpen: Boolean;
        ProgressDialog: Dialog;
        DialogValues: array[2] of Integer;

    procedure AddExpectedTableID(ID: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, ID);

        GlobalTableListTmp."Object Type" := GlobalTableListTmp."Object Type"::Table;
        GlobalTableListTmp."Object ID" := ID;
        GlobalTableListTmp.Insert;

        GlobalTableString += '\' + StrSubstNo('%1: %2', AllObjWithCaption."Object ID", AllObjWithCaption."Object Caption");
    end;

    procedure SetLoadMethod(LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst)
    begin
        GlobalLoadMethod := LoadMethod;
        GlobalLoadMethodOverwritten := true;
    end;

    procedure ImportFromFile()
    var
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        JObject: DotNet JObject;
        InStream: InStream;
        JSON: Text;
        Handled: Boolean;
        PrimaryPackageTable: Integer;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, Caption_SelectPackage, '', 'JSON File (*.json)|*.json', 'json') = '' then
            exit;

        //-NPR5.38 [294095]
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);

        InStream.Read(JSON);
        ManagedDependencyMgt.ParseJSON(JSON, JObject);
        Evaluate(PrimaryPackageTable, Format(JObject.Item('Primary Package Table')));
        JObject := JObject.Item('Data');

        OnLoadPackage(Handled, PrimaryPackageTable, JObject, 0);
        if Handled then
            exit;

        LoadPackage(JObject);

        //ImportFromBlob(TempBlob);
        //+NPR5.38 [294095]
    end;

    procedure ImportFromBlob(var TempBlob: Codeunit "Temp Blob")
    var
        JObject: DotNet JObject;
        InStream: InStream;
        JSON: Text;
        Handled: Boolean;
        PrimaryPackageTable: Integer;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
    begin
        // Note: This function is made for manually importing a package manifest file/blob, so it will not expect
        // the JArray "Data" to be the root which is the case when parsing the base64 blob straight from ground control.

        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);

        InStream.Read(JSON);
        //-NPR5.38 [294095]
        //JObject := JObject.Parse(JSON);
        ManagedDependencyMgt.ParseJSON(JSON, JObject);
        //+NPR5.38 [294095]
        Evaluate(PrimaryPackageTable, Format(JObject.Item('Primary Package Table')));
        JObject := JObject.Item('Data');

        //-NPR5.38 [294095]
        OnLoadPackage(Handled, PrimaryPackageTable, JObject, 1);
        //OnLoadPackage(Handled, PrimaryPackageTable, JObject);
        //+NPR5.38 [294095]
        if Handled then
            exit;

        LoadPackage(JObject);
    end;

    procedure DeployPackageFromGroundControl(PrimaryPackageTable: Integer): Boolean
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        DepMgtSetup: Record "NPR Dependency Mgt. Setup";
        JObject: DotNet JObject;
        i: Integer;
        Package: DotNet JObject;
        FilterSpecific: Label '&$filter=Type eq ''%1'' and Name eq ''%2'' and Version eq ''%3''';
        Data: DotNet JObject;
        TmpManagedPackageLookup: Record "NPR Managed Package Lookup" temporary;
        Handled: Boolean;
    begin
        with ManagedDependencyMgt do begin
            GetDependencyMgtSetup(DepMgtSetup);
            if not DepMgtSetup.Configured then
                exit(false);

            if not GetJSON(DepMgtSetup, 'ManagedDataPackageList', JObject, CreateFilterText(PrimaryPackageTable, DepMgtSetup), false) then
                exit(false);

            for i := 0 to JObject.Count - 1 do begin
                Package := JObject.Item(i);
                TmpManagedPackageLookup.Index := i;
                TmpManagedPackageLookup.Name := Format(Package.Item('Name'));
                TmpManagedPackageLookup.Version := Format(Package.Item('Version'));
                TmpManagedPackageLookup.Description := Format(Package.Item('Description'));
                TmpManagedPackageLookup.Status := Format(Package.Item('Status'));
                TmpManagedPackageLookup.Tags := Format(Package.Item('Tags'));
                TmpManagedPackageLookup.Insert;
            end;

            if TmpManagedPackageLookup.IsEmpty then
                exit(false);

            if not (PAGE.RunModal(PAGE::"NPR Managed Package Lookup", TmpManagedPackageLookup) = ACTION::LookupOK) then
                exit(false);

            Package := JObject.Item(TmpManagedPackageLookup.Index);
            if GetJSON(DepMgtSetup, 'ManagedDependency', Package, StrSubstNo(FilterSpecific, Package.Item('Type'), Package.Item('Name'), Package.Item('Version')), true) then
                if Base64StringToJObject(Package.Item('BLOB').ToString(), Data) then begin
                    //-NPR5.38 [294095]
                    //OnLoadPackage(Handled, PrimaryPackageTable, Data)
                    OnLoadPackage(Handled, PrimaryPackageTable, Data, 2);
                    //+NPR5.38 [294095]
                    if Handled then
                        exit(UpdateLog(Package));

                    if LoadPackage(Data) then
                        exit(UpdateLog(Package));
                end;

            exit(false);
        end;
    end;

    procedure DeployPackageFromURL(URL: Text)
    var
        WebClient: DotNet NPRNetWebClient;
        Credential: DotNet NPRNetNetworkCredential;
        JSON: Text;
        JObject: DotNet NPRNetJObject;
        PrimaryPackageTable: Integer;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        Handled: Boolean;
        Encoding: DotNet NPRNetEncoding;
    begin
        //-NPR5.55 [409573]
        WebClient := WebClient.WebClient();
        WebClient.Encoding := Encoding.UTF8;
        ManagedDependencyMgt.ParseJSON(WebClient.DownloadString(URL), JObject);
        Evaluate(PrimaryPackageTable, Format(JObject.Item('Primary Package Table')));
        JObject := JObject.Item('Data');

        OnLoadPackage(Handled, PrimaryPackageTable, JObject, 0);
        if Handled then
            exit;

        LoadPackage(JObject);
        //+NPR5.55 [409573]
    end;

    local procedure LoadPackage(JObject: DotNet JObject): Boolean
    var
        Selection: Integer;
        LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst;
        RecRef: RecordRef;
    begin
        if JObject.Count < 1 then
            exit;

        if GlobalLoadMethodOverwritten then
            LoadMethod := GlobalLoadMethod
        else begin
            Selection := StrMenu(StrSubstNo('%1,%2,%3', Caption_OnlyInsert, Caption_InsertModify, Caption_DeleteFirst), 1, Caption_LoadMethod);
            if Selection = 0 then
                exit(false);

            LoadMethod := Selection - 1;

            case LoadMethod of
                LoadMethod::DeleteFirst:
                    if not Confirm(StrSubstNo(Caption_DeleteWarning, GlobalTableString), false) then
                        exit(false);
                LoadMethod::InsertOrModify:
                    if not Confirm(StrSubstNo(Caption_ModifyWarning, GlobalTableString), false) then
                        exit(false);
            end;
        end;

        if (LoadMethod = LoadMethod::DeleteFirst) and GlobalTableListTmp.FindSet then
            repeat
                RecRef.Open(GlobalTableListTmp."Object ID");

                if not RecRef.WritePermission then
                    Error(Error_MissingPermission, RecRef.Number);

                RecRef.DeleteAll;
                RecRef.Close;
            until GlobalTableListTmp.Next = 0;

        if not LoadRecords(JObject, LoadMethod) then
            Error(Error_PackageLoad);

        exit(true);
    end;

    local procedure LoadRecords(JObject: DotNet JObject; LoadMethod: Option OnlyInsert,InsertOrModify,DeleteFirst): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyValuePair: DotNet NPRNetKeyValuePair_Of_T_U;
        "Record": Integer;
        i: Integer;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
        FieldsJObject: DotNet JObject;
        Total: Integer;
        Itt: Integer;
    begin
        Total := JObject.Count;

        OpenDialog;

        for i := 0 to Total - 1 do begin
            Itt += 1;

            Evaluate(Record, JObject.Item(i).Item('Record').ToString());

            UpdateDialog(1, Record);
            UpdateProgressDialog(2, Itt, Total);

            if not GlobalTableListTmp.Get(GlobalTableListTmp."Object Type"::Table, Record) then //Only accept data for expected tables.
                exit(false);

            RecRef.Open(Record);

            FieldsJObject := JObject.Item(i).Item('Fields');
            foreach KeyValuePair in FieldsJObject do
                if FieldRefByID(RecRef, KeyValuePair.Key, FieldRef) then
                    if not ManagedDependencyMgt.TextToFieldRef(KeyValuePair.Value, FieldRef) then
                        exit(false);

            case LoadMethod of
                LoadMethod::DeleteFirst:
                    if not RecRef.Insert then
                        exit(false);
                LoadMethod::OnlyInsert:
                    if not RecRef.Insert then
                        ;
                LoadMethod::InsertOrModify:
                    if not RecRef.Insert then
                        if not RecRef.Modify then
                            exit(false);
            end;

            RecRef.Close;
        end;

        CloseDialog;

        exit(true);
    end;

    local procedure CreateFilterText(PrimaryPackageTable: Integer; var DepMgtSetup: Record "NPR Dependency Mgt. Setup") "Filter": Text
    var
        Uri: DotNet NPRNetUri;
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
    begin
        // If we later want to add some auto-update logic for specific data packages, we will have to expand this filter with company name,
        // and expand ground control with support for individual companies in its log to as data packages are not targeted at global tables.

        //-NPR5.39 [306227]
        // Filter := STRSUBSTNO(FilterString, Uri.EscapeDataString(ManagedDependencyMgt.GetServerID()));
        // Filter += SELECTSTR(DepMgtSetup."Accept Statuses" + 1, FilterByStatus);
        Filter := StrSubstNo('&$filter=(Service_Tier_Name eq ''%1'') and ', Uri.EscapeDataString(ManagedDependencyMgt.GetServerID()));
        Filter += SelectStr(DepMgtSetup."Accept Statuses" + 1, '(Status eq ''Released'') and ,(Status eq ''Staging'' or Status eq ''Released'') and ,');
        //+NPR5.39 [306227]
        Filter += StrSubstNo('(Primary_Package_Table eq %1)', PrimaryPackageTable);
    end;

    procedure FieldRefByID(var RecRef: RecordRef; ID: Text; var FieldRef: FieldRef): Boolean
    var
        IntBuffer: Integer;
    begin
        if not Evaluate(IntBuffer, ID) then
            exit(false);

        if not RecRef.FieldExist(IntBuffer) then
            exit(false);

        FieldRef := RecRef.Field(IntBuffer);
        exit(true);
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLoadPackage(var Handled: Boolean; PrimaryPackageTable: Integer; JObject: DotNet JObject; LoadType: Option File,Blob,Download)
    begin
        // Use this event to overwrite default import dialog flow and logic for your specific package type.
    end;

    local procedure "// Dialog"()
    begin
    end;

    local procedure OpenDialog()
    begin
        if GuiAllowed then
            if not IsDialogOpen then begin
                ProgressDialog.Open('Table ##1######\@@2@@@@@@@@@@@@@@@@@');
                IsDialogOpen := true;
            end;
    end;

    local procedure UpdateDialog(ValueNo: Integer; Value: Integer)
    begin
        if GuiAllowed then
            if Value <> DialogValues[ValueNo] then begin
                DialogValues[ValueNo] := Value;
                ProgressDialog.Update(ValueNo, Value);
            end;
    end;

    local procedure UpdateProgressDialog(ValueNo: Integer; Progress: Integer; Total: Integer)
    begin
        if GuiAllowed then begin
            Progress := Round(Progress / Total * 10000, 1, '>');
            if Progress <> DialogValues[ValueNo] then begin
                DialogValues[ValueNo] := Progress;
                ProgressDialog.Update(ValueNo, DialogValues[ValueNo]);
            end;
        end;
    end;

    local procedure CloseDialog()
    begin
        if GuiAllowed then
            ProgressDialog.Close;

        IsDialogOpen := false;
    end;
}

