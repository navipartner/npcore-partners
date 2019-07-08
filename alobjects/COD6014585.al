codeunit 6014585 "RP Package Handler"
{
    // NPR5.32/MMV /20170412 CASE 241995 Retail Print 2.0
    // NPR5.38/MMV /20171201 CASE 294095 Added custom import routine
    // NPR5.39/MMV /20180222 CASE 300666 Fixed picure import bug


    trigger OnRun()
    begin
    end;

    var
        ImportedMessage: Label 'Templates imported:\Created: %1\Replaced: %2';

    procedure ExportPackageToFile(var TemplateHeader: Record "RP Template Header")
    var
        ManagedPackageBuilder: Codeunit "Managed Package Builder";
        TemplateHeader2: Record "RP Template Header";
        TemplateLine: Record "RP Template Line";
        DataItem: Record "RP Data Items";
        DataItemLinks: Record "RP Data Item Links";
        DataItemConstraint: Record "RP Data Item Constraint";
        DataItemConstraintLinks: Record "RP Data Item Constraint Links";
        DeviceSettings: Record "RP Device Settings";
        MediaInfo: Record "RP Template Media Info";
        i: Integer;
        FileName: Text;
    begin
        if not TemplateHeader.FindSet then
          exit;

        repeat
          TemplateLine.SetRange("Template Code", TemplateHeader.Code);
          DataItem.SetRange(Code, TemplateHeader.Code);
          DataItemLinks.SetRange("Data Item Code", TemplateHeader.Code);
          DataItemConstraint.SetRange("Data Item Code", TemplateHeader.Code);
          DataItemConstraintLinks.SetRange("Data Item Code", TemplateHeader.Code);
          DeviceSettings.SetRange(Template, TemplateHeader.Code);
          MediaInfo.SetRange(Template, TemplateHeader.Code);
          TemplateHeader2 := TemplateHeader;
          TemplateHeader2.SetRecFilter;

          ManagedPackageBuilder.AddRecord(TemplateHeader2);
          ManagedPackageBuilder.AddRecord(TemplateLine);
          ManagedPackageBuilder.AddRecord(DataItem);
          ManagedPackageBuilder.AddRecord(DataItemLinks);
          ManagedPackageBuilder.AddRecord(DataItemConstraint);
          ManagedPackageBuilder.AddRecord(DataItemConstraintLinks);
          ManagedPackageBuilder.AddRecord(DeviceSettings);
          ManagedPackageBuilder.AddRecord(MediaInfo);

          i += 1;
        until TemplateHeader.Next = 0;

        if i = 1 then
          FileName := StrSubstNo('%1, Version %2',TemplateHeader.Code, TemplateHeader.Version)
        else
          FileName := 'Retail Print Templates';

        ManagedPackageBuilder.ExportToFile(FileName, '1.0', 'Templates for the retail print module', DATABASE::"RP Template Header")
    end;

    procedure ExportPackageToBlob(var TemplateHeader: Record "RP Template Header";var TempBlobOut: Record TempBlob temporary)
    var
        ManagedPackageBuilder: Codeunit "Managed Package Builder";
        TemplateHeader2: Record "RP Template Header";
        TemplateLine: Record "RP Template Line";
        DataItem: Record "RP Data Items";
        DataItemLinks: Record "RP Data Item Links";
        DataItemConstraint: Record "RP Data Item Constraint";
        DataItemConstraintLinks: Record "RP Data Item Constraint Links";
        DeviceSettings: Record "RP Device Settings";
    begin
        //Does not export media info to prevent archive bloat.

        if not TemplateHeader.FindSet then
          exit;

        repeat
          TemplateLine.SetRange("Template Code", TemplateHeader.Code);
          DataItem.SetRange(Code, TemplateHeader.Code);
          DataItemLinks.SetRange("Data Item Code", TemplateHeader.Code);
          DataItemConstraint.SetRange("Data Item Code", TemplateHeader.Code);
          DataItemConstraintLinks.SetRange("Data Item Code", TemplateHeader.Code);
          DeviceSettings.SetRange(Template, TemplateHeader.Code);
          TemplateHeader2 := TemplateHeader;
          TemplateHeader2.SetRecFilter;

          ManagedPackageBuilder.AddRecord(TemplateHeader2);
          ManagedPackageBuilder.AddRecord(TemplateLine);
          ManagedPackageBuilder.AddRecord(DataItem);
          ManagedPackageBuilder.AddRecord(DataItemLinks);
          ManagedPackageBuilder.AddRecord(DataItemConstraint);
          ManagedPackageBuilder.AddRecord(DataItemConstraintLinks);
          ManagedPackageBuilder.AddRecord(DeviceSettings);
        until TemplateHeader.Next = 0;

        ManagedPackageBuilder.ExportToBlob('RP Template Archive','1.0',StrSubstNo('Archived template: %1',TemplateHeader.Code), DATABASE::"RP Template Header",TempBlobOut);
    end;

    procedure ImportPackageFromFile()
    var
        ManagedPackageMgt: Codeunit "Managed Package Mgt.";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Header");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Line");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Items");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Constraint");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Constraint Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Device Settings");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Media Info");
        ManagedPackageMgt.ImportFromFile();
    end;

    procedure ImportPackageFromBlob(var TempBlob: Record TempBlob temporary)
    var
        ManagedPackageMgt: Codeunit "Managed Package Mgt.";
    begin
        ManagedPackageMgt.SetLoadMethod(0);
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Header");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Line");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Items");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Constraint");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Constraint Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Device Settings");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Media Info");
        ManagedPackageMgt.ImportFromBlob(TempBlob);
    end;

    procedure DeployPackageFromGC()
    var
        ManagedPackageMgt: Codeunit "Managed Package Mgt.";
    begin
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Header");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Line");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Items");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Constraint");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Data Item Constraint Links");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Device Settings");
        ManagedPackageMgt.AddExpectedTableID(DATABASE::"RP Template Media Info");
        ManagedPackageMgt.DeployPackageFromGroundControl(DATABASE::"RP Template Header");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014628, 'OnLoadPackage', '', false, false)]
    local procedure OnLoadPackage(var Handled: Boolean;PrimaryPackageTable: Integer;JObject: DotNet JObject;LoadType: Option File,Blob,Download)
    var
        tmpImportWorksheet: Record "RP Import Worksheet" temporary;
        tmpTemplateHeader: Record "RP Template Header" temporary;
        tmpTemplateLine: Record "RP Template Line" temporary;
        tmpDataItem: Record "RP Data Items" temporary;
        tmpDataItemLinks: Record "RP Data Item Links" temporary;
        tmpDataItemConstraint: Record "RP Data Item Constraint" temporary;
        tmpDataItemConstraintLinks: Record "RP Data Item Constraint Links" temporary;
        tmpDeviceSettings: Record "RP Device Settings" temporary;
        tmpMediaInfo: Record "RP Template Media Info" temporary;
        TemplateHeader: Record "RP Template Header";
    begin
        //-NPR5.38 [294095]
        if Handled then
          exit;
        if LoadType = LoadType::Blob then
          exit;
        if PrimaryPackageTable <> DATABASE::"RP Template Header" then
          exit;

        Handled := true;

        if not ParsePackage(JObject, tmpTemplateHeader, tmpTemplateLine, tmpDataItem, tmpDataItemLinks, tmpDataItemConstraint, tmpDataItemConstraintLinks, tmpDeviceSettings, tmpMediaInfo) then
          exit;

        repeat
          tmpImportWorksheet.Init;
          tmpImportWorksheet."Entry No." += 1;
          tmpImportWorksheet.Template := tmpTemplateHeader.Code;
          tmpImportWorksheet."New Description" := tmpTemplateHeader.Description;
          tmpImportWorksheet."New Last Modified At" := tmpTemplateHeader."Last Modified At";
          tmpImportWorksheet."New Version" := tmpTemplateHeader.Version;
          if TemplateHeader.Get(tmpTemplateHeader.Code) then begin
            tmpImportWorksheet."Existing Description" := TemplateHeader.Description;
            tmpImportWorksheet."Existing Last Modified At" := TemplateHeader."Last Modified At";
            tmpImportWorksheet."Existing Version" := TemplateHeader.Version;
          end;
          tmpImportWorksheet.Insert(true);
        until tmpTemplateHeader.Next = 0;

        if PAGE.RunModal(PAGE::"RP Import Worksheet", tmpImportWorksheet) <> ACTION::LookupOK then
          exit;

        ImportPackage(tmpImportWorksheet, tmpTemplateHeader, tmpTemplateLine, tmpDataItem, tmpDataItemLinks, tmpDataItemConstraint, tmpDataItemConstraintLinks, tmpDeviceSettings, tmpMediaInfo);
        //+NPR5.38 [294095]
    end;

    local procedure ParsePackage(JObject: DotNet JObject;var tmpTemplateHeader: Record "RP Template Header" temporary;var tmpTemplateLine: Record "RP Template Line" temporary;var tmpDataItem: Record "RP Data Items" temporary;var tmpDataItemLinks: Record "RP Data Item Links" temporary;var tmpDataItemConstraint: Record "RP Data Item Constraint" temporary;var tmpDataItemConstraintLinks: Record "RP Data Item Constraint Links" temporary;var tmpDeviceSettings: Record "RP Device Settings" temporary;var tmpMediaInfo: Record "RP Template Media Info" temporary): Boolean
    var
        i: Integer;
        TotalRecords: Integer;
        TableNo: Integer;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyValuePair: DotNet KeyValuePair_Of_T_U;
        ManagedDependencyMgt: Codeunit "Managed Dependency Mgt.";
        ManagedPackageMgt: Codeunit "Managed Package Mgt.";
        FieldsJObject: DotNet JObject;
    begin
        //-NPR5.38 [294095]
        TotalRecords := JObject.Count;
        for i := 0 to TotalRecords - 1 do begin
          Evaluate(TableNo, JObject.Item(i).Item('Record').ToString());

          case TableNo of
            DATABASE::"RP Template Header" : RecRef.GetTable(tmpTemplateHeader);
            DATABASE::"RP Template Line" : RecRef.GetTable(tmpTemplateLine);
            DATABASE::"RP Data Items" : RecRef.GetTable(tmpDataItem);
            DATABASE::"RP Data Item Links" : RecRef.GetTable(tmpDataItemLinks);
            DATABASE::"RP Data Item Constraint" : RecRef.GetTable(tmpDataItemConstraint);
            DATABASE::"RP Data Item Constraint Links" : RecRef.GetTable(tmpDataItemConstraintLinks);
            DATABASE::"RP Device Settings" : RecRef.GetTable(tmpDeviceSettings);
            DATABASE::"RP Template Media Info" : RecRef.GetTable(tmpMediaInfo);
            else
              Error('Unexpected table.');
          end;

          FieldsJObject := JObject.Item(i).Item('Fields');
          foreach KeyValuePair in FieldsJObject do
            if ManagedPackageMgt.FieldRefByID(RecRef,KeyValuePair.Key,FieldRef) then
              if not ManagedDependencyMgt.TextToFieldRef(KeyValuePair.Value,FieldRef) then
                Error('Unexpected field data.');

          RecRef.Insert;
          RecRef.Close;
        end;

        exit(tmpTemplateHeader.FindSet);
        //+NPR5.38 [294095]
    end;

    local procedure ImportPackage(var tmpImportWorksheet: Record "RP Import Worksheet";var tmpTemplateHeader: Record "RP Template Header" temporary;var tmpTemplateLine: Record "RP Template Line" temporary;var tmpDataItem: Record "RP Data Items" temporary;var tmpDataItemLinks: Record "RP Data Item Links" temporary;var tmpDataItemConstraint: Record "RP Data Item Constraint" temporary;var tmpDataItemConstraintLinks: Record "RP Data Item Constraint Links" temporary;var tmpDeviceSettings: Record "RP Device Settings" temporary;var tmpMediaInfo: Record "RP Template Media Info" temporary)
    var
        TemplateHeader: Record "RP Template Header";
        TemplateLine: Record "RP Template Line";
        DataItem: Record "RP Data Items";
        DataItemLinks: Record "RP Data Item Links";
        DataItemConstraint: Record "RP Data Item Constraint";
        DataItemConstraintLinks: Record "RP Data Item Constraint Links";
        DeviceSettings: Record "RP Device Settings";
        MediaInfo: Record "RP Template Media Info";
        ReplaceCounter: Integer;
        CreateCounter: Integer;
    begin
        //-NPR5.38 [294095]
        with tmpImportWorksheet do begin
          SetFilter(Action, '<>%1', Action::Skip);
          if FindSet then repeat
            if Action = Action::Replace then begin
              DeleteTemplate(Template);
              ReplaceCounter += 1;
            end else
              CreateCounter += 1;

            tmpTemplateHeader.Get(Template);
            tmpTemplateLine.SetRange("Template Code", Template);
            tmpDataItem.SetRange(Code, Template);
            tmpDataItemLinks.SetRange("Data Item Code", Template);
            tmpDataItemConstraint.SetRange("Data Item Code", Template);
            tmpDataItemConstraintLinks.SetRange("Data Item Code", Template);
            tmpDeviceSettings.SetRange(Template, Template);
            tmpMediaInfo.SetRange(Template, Template);

            TemplateHeader.Init;
            TemplateHeader := tmpTemplateHeader;
            TemplateHeader.Insert;

            if tmpTemplateLine.FindSet then repeat
              TemplateLine.Init;
              TemplateLine := tmpTemplateLine;
              TemplateLine.Insert;
            until tmpTemplateLine.Next = 0;

            if tmpDataItem.FindSet then repeat
              DataItem.Init;
              DataItem := tmpDataItem;
              DataItem.Insert;
            until tmpDataItem.Next = 0;

            if tmpDataItemLinks.FindSet then repeat
              DataItemLinks.Init;
              DataItemLinks := tmpDataItemLinks;
              DataItemLinks.Insert;
            until tmpDataItemLinks.Next = 0;

            if tmpDataItemConstraint.FindSet then repeat
              DataItemConstraint.Init;
              DataItemConstraint := tmpDataItemConstraint;
              DataItemConstraint.Insert;
            until tmpDataItemConstraint.Next = 0;

            if tmpDataItemConstraintLinks.FindSet then repeat
              DataItemConstraintLinks.Init;
              DataItemConstraintLinks := tmpDataItemConstraintLinks;
              DataItemConstraintLinks.Insert;
            until tmpDataItemConstraintLinks.Next = 0;

            if tmpDeviceSettings.FindSet then repeat
              DeviceSettings.Init;
              DeviceSettings := tmpDeviceSettings;
              DeviceSettings.Insert;
            until tmpDeviceSettings.Next = 0;

            //-NPR5.39 [300666]
            tmpMediaInfo.SetAutoCalcFields(Picture);
            //+NPR5.39 [300666]
            if tmpMediaInfo.FindSet then repeat
              MediaInfo.Init;
              MediaInfo := tmpMediaInfo;
              MediaInfo.Insert;
            until tmpMediaInfo.Next = 0;

          until tmpImportWorksheet.Next = 0;
        end;

        if (ReplaceCounter > 0) or (CreateCounter > 0) then
          Message(ImportedMessage, CreateCounter, ReplaceCounter);
        //+NPR5.38 [294095]
    end;

    local procedure DeleteTemplate("Code": Text)
    var
        TemplateHeader: Record "RP Template Header";
        TemplateLine: Record "RP Template Line";
        DataItem: Record "RP Data Items";
        DataItemLinks: Record "RP Data Item Links";
        DataItemConstraint: Record "RP Data Item Constraint";
        DataItemConstraintLinks: Record "RP Data Item Constraint Links";
        DeviceSettings: Record "RP Device Settings";
        MediaInfo: Record "RP Template Media Info";
        TemplateArchive: Record "RP Template Archive";
    begin
        //-NPR5.38 [294095]
        TemplateHeader.Get(Code);
        if not TemplateHeader.Archived then begin
          if not TemplateArchive.Get(Code, TemplateHeader.Version) then begin
            TemplateHeader."Version Comments" := 'Auto archiving before import';
            TemplateHeader.Validate(Archived, true);
          end;
        end;

        TemplateHeader.SetRange(Code, Code);
        TemplateLine.SetRange("Template Code", Code);
        DataItem.SetRange(Code, Code);
        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemConstraint.SetRange("Data Item Code", Code);
        DataItemConstraintLinks.SetRange("Data Item Code", Code);
        DeviceSettings.SetRange(Template, Code);
        MediaInfo.SetRange(Template, Code);

        TemplateHeader.DeleteAll;
        TemplateLine.DeleteAll;
        DataItem.DeleteAll;
        DataItemLinks.DeleteAll;
        DataItemConstraint.DeleteAll;
        DataItemConstraintLinks.DeleteAll;
        DeviceSettings.DeleteAll;
        MediaInfo.DeleteAll;
        //+NPR5.38 [294095]
    end;
}

