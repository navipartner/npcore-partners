codeunit 6014586 "NPR RP Template Mgt."
{
    var
        Caption_RollbackVersion: Label 'Are you sure you want to roll back the template to version %1 ?';
        Caption_AutoArchive: Label 'Auto archived version before rollback';
        Caption_InsertNewCode: Label 'Insert new template code';
        Error_TemplateAlreadyExists: Label 'Template %1 already exists. Please pick a new code.';
        Error_VersionDown: Label 'Cannot version down from %1 to %2';

    procedure PrintTemplate(TemplateCode: Code[20]; "Record": Variant)
    begin
        PrintTemplate(TemplateCode, "Record", 0);
    end;

    procedure PrintTemplate(TemplateCode: Code[20]; var RecRef: RecordRef)
    begin
        PrintTemplate(TemplateCode, RecRef, 0);
    end;

    procedure PrintTemplate(TemplateCode: Code[20]; "Record": Variant; MatrixIterationField: Integer)
    var
        RecRef: RecordRef;
    begin
        if Record.IsRecordRef() then begin
            RecRef := Record;
        end else begin
            RecRef.GetTable(Record);
        end;

        PrintTemplate(TemplateCode, RecRef, MatrixIterationField);
    end;

    procedure PrintTemplate(TemplateCode: Code[20]; var RecRef: RecordRef; MatrixIterationField: Integer)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
        StartTime: Time;
        EndTime: Time;
        DurationMs: Integer;
        Sentry: Codeunit "NPR Sentry";
        SentryPrintSpan: Codeunit "NPR Sentry Span";
    begin
        Sentry.StartSpan(SentryPrintSpan, 'bc.print_template');

        RPTemplateHeader.Get(TemplateCode);

        case RPTemplateHeader."Printer Type" of
            RPTemplateHeader."Printer Type"::Line:
                begin
                    StartTime := Time();
                    LinePrintMgt.ProcessTemplate(TemplateCode, RecRef);
                    EndTime := Time();
                end;
            RPTemplateHeader."Printer Type"::Matrix:
                begin
                    MatrixPrintMgt.SetPrintIterationFieldNo(MatrixIterationField);
                    StartTime := Time();
                    MatrixPrintMgt.ProcessTemplate(TemplateCode, RecRef);
                    EndTime := Time();
                end;
        end;

        SentryPrintSpan.Finish();

        DurationMs := EndTime - StartTime;

        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");

        CustomDimensions.Add('NPR_RP_TemplateCode', TemplateCode);
        CustomDimensions.Add('NPR_RP_PrinterType', Format(RPTemplateHeader."Printer Type"));
        CustomDimensions.Add('NPR_RP_PrinterDevice', Format(RPTemplateHeader."Line Device"));
        CustomDimensions.Add('NPR_RP_MatrixIterationField', Format(MatrixIterationField, 0, 9));
        CustomDimensions.Add('NPR_RP_TemplateVersion', RPTemplateHeader.Version);
        CustomDimensions.Add('NPR_RP_TemplateLastModifiedAt', Format(RPTemplateHeader."Last Modified At"));
        CustomDimensions.Add('NPR_RP_TemplateLastModifiedBy', RPTemplateHeader."Last Modified By");

        CustomDimensions.Add('NPR_RP_PrintDurationMs', Format(DurationMs, 0, 9));

        CustomDimensions.Add('NPR_RP_RecRefSystemId', Format(RecRef.Field(RecRef.SystemIdNo())));

        Session.LogMessage('NPR_PrintTemplate', StrSubstNo('Processing of print template (%1) took %2 ms.', TemplateCode, DurationMs), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    internal procedure GetNextVersionNumber(var TemplateHeader: Record "NPR RP Template Header") NewVersion: Text
    var
        RPTemplateArchive: Record "NPR RP Template Archive";
        RPTemplateSetup: Record "NPR RP Template Setup";
        VersionList: list of [Text];
        Version: Text;
        VersionFilter: Text;
    begin
        if not RPTemplateSetup.Get() then begin
            RPTemplateSetup.Init();
            RPTemplateSetup.Insert(true);
        end;

        NewVersion := IncrementVersionNumber(TemplateHeader.Version);

        if RPTemplateArchive.Get(TemplateHeader.Code, NewVersion) then begin //Assume RPTemplateArchive holds the highest version number    
            VersionList := NewVersion.Split(',');
            foreach Version in VersionList do begin
                if VersionFilter <> '' then
                    VersionFilter += ',';

                if StrPos(Version, RPTemplateSetup."Version Prefix") = 1 then
                    VersionFilter += '*'
                else
                    VersionFilter += Version;
            end;

            RPTemplateArchive.SetFilter(Code, TemplateHeader.Code);
            RPTemplateArchive.SetFilter(Version, VersionFilter);
            RPTemplateArchive.SetCurrentKey(Version);
            RPTemplateArchive.FindLast();

            NewVersion := IncrementVersionNumber(RPTemplateArchive.Version);
        end;
    end;

    local procedure IncrementVersionNumber(VersionIn: Text): Text
    var
        VersionList: list of [Text];
        Version: Text;
        NewVersion: Text;
        VersionMatch: Boolean;
        MajorVersion: Integer;
        RPTemplateSetup: Record "NPR RP Template Setup";
    begin
        RPTemplateSetup.Get();

        VersionList := VersionIn.Split(',');
        foreach Version in VersionList do begin
            if StrPos(Version, RPTemplateSetup."Version Prefix") = 1 then
                if Evaluate(MajorVersion, CopyStr(Version, StrLen(RPTemplateSetup."Version Prefix") + 1, (StrPos(Version, '.') - StrLen(RPTemplateSetup."Version Prefix")))) then begin
                    if MajorVersion = RPTemplateSetup."Version Major Number" then
                        Version := IncStr(Version)
                    else
                        if MajorVersion < RPTemplateSetup."Version Major Number" then
                            Version := Format(RPTemplateSetup."Version Major Number") + '.00'
                        else
                            Error(Error_VersionDown, MajorVersion, RPTemplateSetup."Version Major Number");
                    VersionMatch := true;
                end;

            if NewVersion <> '' then
                NewVersion += ',';
            NewVersion += Format(Version);
        end;

        if not VersionMatch then begin
            if NewVersion <> '' then
                NewVersion += ',';
            NewVersion += RPTemplateSetup."Version Prefix" + Format(RPTemplateSetup."Version Major Number") + '.00';
        end;

        exit(NewVersion);
    end;

    internal procedure CreateNewVersion(var TemplateHeader: Record "NPR RP Template Header")
    begin
        if not TemplateHeader.Archived then
            exit;

#pragma warning disable AA0139
        TemplateHeader.Version := GetNextVersionNumber(TemplateHeader);
#pragma warning restore AA0139
        TemplateHeader."Version Comments" := '';
        TemplateHeader.Archived := false;
        TemplateHeader.Modify(true);
    end;

    internal procedure RollbackVersion(TemplateArchive: Record "NPR RP Template Archive")
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        RPPackageHandler: Codeunit "NPR RP Package Handler";
        TempBlob: Codeunit "Temp Blob";
    begin
        if not Confirm(Caption_RollbackVersion, false, TemplateArchive.Version) then
            exit;

        //Archive current version, if any is present, before rolling back
        RPTemplateHeader.SetRange(Code, TemplateArchive.Code);
        if RPTemplateHeader.FindFirst() then begin
            RPTemplateHeader."Version Comments" := Caption_AutoArchive;
            RPTemplateHeader.Validate(Archived, true);
            RPTemplateHeader.Delete(true);
        end;

        TemplateArchive.CalcFields(Template);
        TempBlob.FromRecord(TemplateArchive, TemplateArchive.FieldNo(Template));
        RPPackageHandler.ImportPackageFromBlob(TempBlob);
    end;

    internal procedure CreateCopy(var TemplateHeader: Record "NPR RP Template Header")
    var
        InputDialog: Page "NPR Input Dialog";
        NewTemplateCode: Code[20];
        ID: Integer;
        RPTemplateHeader2: Record "NPR RP Template Header";
        RPTemplateLine: Record "NPR RP Template Line";
        DataItem: Record "NPR RP Data Items";
        DataItemLink: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLink: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        MediaInfo: Record "NPR RP Template Media Info";
        CopyTemplateLine: Record "NPR RP Template Line";
        CopyDataItem: Record "NPR RP Data Items";
        CopyDataItemLink: Record "NPR RP Data Item Links";
        CopyDataItemConstraint: Record "NPR RP Data Item Constr.";
        CopyDataItemConstraintLink: Record "NPR RP Data Item Constr. Links";
        CopyDeviceSettings: Record "NPR RP Device Settings";
        CopyMediaInfo: Record "NPR RP Template Media Info";
    begin
        if not TemplateHeader.FindFirst() then
            exit;

        InputDialog.LookupMode := true;
        InputDialog.SetInput(1, NewTemplateCode, Caption_InsertNewCode);
        if InputDialog.RunModal() = ACTION::LookupOK then
#pragma warning disable AA0139
            ID := InputDialog.InputCodeValue(1, NewTemplateCode);
#pragma warning restore AA0139

        if ID = 0 then
            exit;

        if RPTemplateHeader2.Get(NewTemplateCode) then
            Error(Error_TemplateAlreadyExists, NewTemplateCode);

        RPTemplateLine.SetRange("Template Code", TemplateHeader.Code);
        DataItem.SetRange(Code, TemplateHeader.Code);
        DataItemLink.SetRange("Data Item Code", TemplateHeader.Code);
        DataItemConstraint.SetRange("Data Item Code", TemplateHeader.Code);
        DataItemConstraintLink.SetRange("Data Item Code", TemplateHeader.Code);
        DeviceSettings.SetRange(Template, TemplateHeader.Code);
        MediaInfo.SetRange(Template, TemplateHeader.Code);

        TemplateHeader.Code := NewTemplateCode;
        TemplateHeader.Archived := false;
        TemplateHeader.Version := '';
        TemplateHeader."Version Comments" := '';
        TemplateHeader.Insert(true);

        if DataItem.FindSet() then
            repeat
                CopyDataItem := DataItem;
                CopyDataItem.Code := NewTemplateCode;
                CopyDataItem.Insert();
            until DataItem.Next() = 0;

        if DataItemLink.FindSet() then
            repeat
                CopyDataItemLink := DataItemLink;
                CopyDataItemLink."Data Item Code" := NewTemplateCode;
                CopyDataItemLink.Insert();
            until DataItemLink.Next() = 0;

        if DataItemConstraint.FindSet() then
            repeat
                CopyDataItemConstraint := DataItemConstraint;
                CopyDataItemConstraint."Data Item Code" := NewTemplateCode;
                CopyDataItemConstraint.Insert();
            until DataItemConstraint.Next() = 0;

        if DataItemConstraintLink.FindSet() then
            repeat
                CopyDataItemConstraintLink := DataItemConstraintLink;
                CopyDataItemConstraintLink."Data Item Code" := NewTemplateCode;
                CopyDataItemConstraintLink.Insert();
            until DataItemConstraintLink.Next() = 0;

        if RPTemplateLine.FindSet() then
            repeat
                CopyTemplateLine := RPTemplateLine;
                CopyTemplateLine."Template Code" := NewTemplateCode;
                CopyTemplateLine.Insert();
            until RPTemplateLine.Next() = 0;

        if DeviceSettings.FindSet() then
            repeat
                CopyDeviceSettings := DeviceSettings;
                CopyDeviceSettings.Template := NewTemplateCode;
                CopyDeviceSettings.Insert();
            until DeviceSettings.Next() = 0;

        if MediaInfo.FindSet() then
            repeat
                CopyMediaInfo := MediaInfo;
                CopyMediaInfo.Template := NewTemplateCode;
                CopyMediaInfo.Insert();
            until MediaInfo.Next() = 0;
    end;

    internal procedure ExportArchived(var TemplateArchive: Record "NPR RP Template Archive")
    var
        InStream: InStream;
        FileName: Variant;
        FileNameLbl: Label '%1, Version %2.json', Locked = true;
    begin
        if not TemplateArchive.Template.HasValue() then
            exit;

        TemplateArchive.CalcFields(Template);
        TemplateArchive.Template.CreateInStream(InStream);

        FileName := StrSubstNo(FileNameLbl, TemplateArchive.Code, TemplateArchive.Version);
        DownloadFromStream(InStream, 'Export archived template to file', '', 'JSON File (*.json)|*.json', FileName);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyTemplateLine(var Rec: Record "NPR RP Template Line"; var xRec: Record "NPR RP Template Line"; RunTrigger: Boolean)
    var
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;

        //Was parent before
        RPTemplateLine.SetRange("Parent Line No.", Rec."Line No.");
        if RPTemplateLine.FindSet() then
            repeat
                RPTemplateLine.FindParentLine();
                RPTemplateLine.Modify();
            until RPTemplateLine.Next() = 0;

        RPTemplateLine.Reset();
        //Is parent now
        RPTemplateLine.SetFilter("Line No.", '>%1', Rec."Line No.");
        RPTemplateLine.SetFilter(Level, '>%1', 0);
        RPTemplateLine.SetFilter("Parent Line No.", '<%1', Rec."Line No.");
        if RPTemplateLine.FindSet() then
            repeat
                RPTemplateLine.FindParentLine();
                RPTemplateLine.Modify();
            until RPTemplateLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertTemplateLine(var Rec: Record "NPR RP Template Line"; RunTrigger: Boolean)
    var
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;

        RPTemplateLine.SetFilter("Line No.", '>%1', Rec."Line No.");
        RPTemplateLine.SetFilter(Level, '>%1', 0);
        RPTemplateLine.SetFilter("Parent Line No.", '<%1', Rec."Line No.");
        if RPTemplateLine.FindSet() then
            repeat
                RPTemplateLine.FindParentLine();
                RPTemplateLine.Modify();
            until RPTemplateLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteTemplateLine(var Rec: Record "NPR RP Template Line"; RunTrigger: Boolean)
    var
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;

        RPTemplateLine.SetRange("Parent Line No.", Rec."Line No.");
        if RPTemplateLine.FindSet() then
            repeat
                RPTemplateLine.FindParentLine();
                RPTemplateLine.Modify();
            until RPTemplateLine.Next() = 0;
    end;

    internal procedure UpgradeField(TableId: Integer; FromFieldId: Integer; ToFieldId: Integer)
    begin
        UpgradeDataItemConstraintLink(TableId, FromFieldId, ToFieldId);
        UpgradeDataItemLink(TableId, FromFieldId, ToFieldId);
        UpgradeTemplateLine(TableId, FromFieldId, ToFieldId);
    end;

    internal procedure RemoveField(TableId: Integer; FieldId: Integer)
    begin
        DeleteDataItemConstraintLink(TableId, FieldId);
        DeleteDataItemLink(TableId, FieldId);
        DeleteTemplateLine(TableId, FieldId);
    end;

    local procedure UpgradeTemplateLine(TableId: Integer; FromFieldId: Integer; ToFieldId: Integer)
    var
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        RPTemplateLine.SetRange("Data Item Table", TableId);
        RPTemplateLine.SetRange(Field, FromFieldId);
        if RPTemplateLine.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                RPTemplateLine.Validate(Field, ToFieldId);
                if RPTemplateLine."Field 2" = FromFieldId then
                    RPTemplateLine.Validate("Field 2", ToFieldId);
                RPTemplateLine.Modify();
            until RPTemplateLine.Next() = 0;
        RPTemplateLine.SetRange(Field);

        RPTemplateLine.SetRange("Field 2", FromFieldId);
        if RPTemplateLine.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                RPTemplateLine.Validate("Field 2", ToFieldId);
                RPTemplateLine.Modify();
            until RPTemplateLine.Next() = 0;
    end;

    local procedure UpgradeDataItemLink(TableId: Integer; FromFieldId: Integer; ToFieldId: Integer)
    var
        RPDataItemLinks: Record "NPR RP Data Item Links";
    begin
        RPDataItemLinks.SetRange("Table ID", TableId);
        RPDataItemLinks.SetRange("Field ID", FromFieldId);
        if RPDataItemLinks.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPDataItemLinks."Data Item Code");
                RPDataItemLinks.Validate("Field ID", ToFieldId);
                RPDataItemLinks.Modify();
            until RPDataItemLinks.Next() = 0;
        RPDataItemLinks.Reset();

        RPDataItemLinks.SetRange("Parent Table ID", TableId);
        RPDataItemLinks.SetRange("Parent Field ID", FromFieldId);
        if RPDataItemLinks.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPDataItemLinks."Data Item Code");
                RPDataItemLinks.Validate("Parent Field ID", ToFieldId);
                RPDataItemLinks.Modify();
            until RPDataItemLinks.Next() = 0;
    end;

    local procedure UpgradeDataItemConstraintLink(TableId: Integer; FromFieldId: Integer; ToFieldId: Integer)
    var
        RPDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        RPDataItemConstraint: Record "NPR RP Data Item Constr.";
    begin
        RPDataItemConstraintLinks.SetRange("Data Item Table ID", TableId);
        RPDataItemConstraintLinks.SetRange("Data Item Field ID", FromFieldId);
        if RPDataItemConstraintLinks.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPDataItemConstraintLinks."Data Item Code");
                RPDataItemConstraintLinks.Validate("Data Item Field ID", ToFieldId);
                RPDataItemConstraintLinks.Modify();
            until RPDataItemConstraintLinks.Next() = 0;
        RPDataItemConstraintLinks.Reset();

        RPDataItemConstraint.SetRange("Table ID", TableId);
        if RPDataItemConstraint.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPDataItemConstraint."Data Item Code");
                RPDataItemConstraintLinks.SetRange("Data Item Code", RPDataItemConstraint."Data Item Code");
                RPDataItemConstraintLinks.SetRange("Constraint Line No.", RPDataItemConstraint."Line No.");
                RPDataItemConstraintLinks.SetRange("Field ID", FromFieldId);
                RPDataItemConstraintLinks.ModifyAll("Field ID", ToFieldId, true);
            until RPDataItemConstraint.Next() = 0;
    end;

    local procedure DeleteTemplateLine(TableId: Integer; FieldId: Integer)
    var
        RPTemplateLine: Record "NPR RP Template Line";
    begin
        RPTemplateLine.SetRange("Data Item Table", TableId);
        RPTemplateLine.SetRange(Field, FieldId);
        if RPTemplateLine.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                RPTemplateLine.Delete();
            until RPTemplateLine.Next() = 0;
        RPTemplateLine.SetRange(Field);

        RPTemplateLine.SetRange("Field 2", FieldId);
        if RPTemplateLine.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                RPTemplateLine.Delete();
            until RPTemplateLine.Next() = 0;
    end;

    local procedure DeleteDataItemLink(TableId: Integer; FieldId: Integer)
    var
        RPDataItemLinks: Record "NPR RP Data Item Links";
    begin
        RPDataItemLinks.SetRange("Table ID", TableId);
        RPDataItemLinks.SetRange("Field ID", FieldId);
        if RPDataItemLinks.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPDataItemLinks."Data Item Code");
                RPDataItemLinks.Delete();
            until RPDataItemLinks.Next() = 0;
        RPDataItemLinks.Reset();

        RPDataItemLinks.SetRange("Parent Table ID", TableId);
        RPDataItemLinks.SetRange("Parent Field ID", FieldId);
        if RPDataItemLinks.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPDataItemLinks."Data Item Code");
                RPDataItemLinks.Delete();
            until RPDataItemLinks.Next() = 0;
    end;

    local procedure DeleteDataItemConstraintLink(TableId: Integer; FieldId: Integer)
    var
        RPDataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        RPDataItemConstraint: Record "NPR RP Data Item Constr.";
    begin
        RPDataItemConstraintLinks.SetRange("Data Item Table ID", TableId);
        RPDataItemConstraintLinks.SetRange("Data Item Field ID", FieldId);
        if RPDataItemConstraintLinks.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPDataItemConstraintLinks."Data Item Code");
                RPDataItemConstraintLinks.Delete();
            until RPDataItemConstraintLinks.Next() = 0;
        RPDataItemConstraintLinks.Reset();

        RPDataItemConstraint.SetRange("Table ID", TableId);
        if RPDataItemConstraint.FindSet() then
            repeat
                IncreaseVersionIfNecessary(RPDataItemConstraint."Data Item Code");
                RPDataItemConstraintLinks.SetRange("Data Item Code", RPDataItemConstraint."Data Item Code");
                RPDataItemConstraintLinks.SetRange("Constraint Line No.", RPDataItemConstraint."Line No.");
                RPDataItemConstraintLinks.SetRange("Field ID", FieldId);
                RPDataItemConstraintLinks.DeleteAll();
            until RPDataItemConstraint.Next() = 0;
    end;

    local procedure IncreaseVersionIfNecessary(Template: Text)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        if RPTemplateHeader.Get(Template) then
            if RPTemplateHeader.Archived then begin
                TemplateMgt.CreateNewVersion(RPTemplateHeader);
                RPTemplateHeader."Version Comments" := 'Auto created version for field upgrade';
                RPTemplateHeader.Modify();
            end;
    end;

    internal procedure GetDataItemTableId(Code: Code[10]; Level: Integer): Integer
    var
        RPDataItems: Record "NPR RP Data Items";
    begin
        RPDataItems.SetRange(Code, Code);
        RPDataItems.SetRange(Level, Level);
        if RPDataItems.FindFirst() then
            exit(RPDataItems."Table ID");

        exit(0);
    end;
}