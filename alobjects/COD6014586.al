codeunit 6014586 "RP Template Mgt."
{
    // NPR5.39/MMV /20180207 CASE 304745 Added data upgrade functions


    trigger OnRun()
    begin
    end;

    var
        Caption_RollbackVersion: Label 'Are you sure you want to roll back the template to version %1 ?';
        Caption_AutoArchive: Label 'Auto archived version before rollback';
        Caption_InsertNewCode: Label 'Insert new template code';
        Error_TemplateAlreadyExists: Label 'Template %1 already exists. Please pick a new code.';
        Error_VersionDown: Label 'Cannot version down from %1 to %2';

    local procedure "//Print"()
    begin
    end;

    procedure PrintTemplate(TemplateCode: Code[20]; "Record": Variant; MatrixIterationField: Integer)
    var
        TemplateHeader: Record "RP Template Header";
        MatrixPrintMgt: Codeunit "RP Matrix Print Mgt.";
        LinePrintMgt: Codeunit "RP Line Print Mgt.";
        RecRef: RecordRef;
    begin
        if Record.IsRecordRef then
            RecRef := Record
        else
            RecRef.GetTable(Record);

        TemplateHeader.Get(TemplateCode);
        case TemplateHeader."Printer Type" of
            TemplateHeader."Printer Type"::Line:
                LinePrintMgt.ProcessTemplate(TemplateCode, RecRef);

            TemplateHeader."Printer Type"::Matrix:
                begin
                    MatrixPrintMgt.SetPrintIterationFieldNo(MatrixIterationField);
                    MatrixPrintMgt.ProcessTemplate(TemplateCode, RecRef);
                end;
        end;
    end;

    local procedure "// Versioning"()
    begin
    end;

    procedure GetNextVersionNumber(var TemplateHeader: Record "RP Template Header") NewVersion: Text
    var
        TemplateArchive: Record "RP Template Archive";
        TemplateSetup: Record "RP Template Setup";
    begin
        if not TemplateSetup.Get then begin
            TemplateSetup.Init;
            TemplateSetup.Insert(true);
        end;

        NewVersion := IncrementVersionNumber(TemplateHeader.Version);
        if TemplateArchive.Get(TemplateHeader.Code, NewVersion) then begin //Assume RPTemplateArchive holds the highest version number instead.
            TemplateArchive.SetCurrentKey("Archived at");
            TemplateArchive.FindLast;
            NewVersion := IncrementVersionNumber(TemplateArchive.Version);
        end;
    end;

    local procedure IncrementVersionNumber(VersionIn: Text): Text
    var
        VersionArray: DotNet npNetArray;
        Regex: DotNet npNetRegex;
        Version: DotNet npNetString;
        NewVersion: Text;
        VersionMatch: Boolean;
        MajorVersion: Integer;
        TemplateSetup: Record "RP Template Setup";
    begin
        TemplateSetup.Get;

        VersionArray := Regex.Split(VersionIn, ',');
        foreach Version in VersionArray do begin
            if StrPos(Version, TemplateSetup."Version Prefix") = 1 then
                if Evaluate(MajorVersion, CopyStr(Version, StrLen(TemplateSetup."Version Prefix") + 1, (StrPos(Version, '.') - StrLen(TemplateSetup."Version Prefix")))) then begin
                    if MajorVersion = TemplateSetup."Version Major Number" then
                        Version := IncStr(Version)
                    else
                        if MajorVersion < TemplateSetup."Version Major Number" then
                            Version := Format(TemplateSetup."Version Major Number") + '.00'
                        else
                            Error(Error_VersionDown, MajorVersion, TemplateSetup."Version Major Number");
                    VersionMatch := true;
                end;

            if NewVersion <> '' then
                NewVersion += ',';
            NewVersion += Format(Version);
        end;

        if not VersionMatch then begin
            if NewVersion <> '' then
                NewVersion += ',';
            NewVersion += TemplateSetup."Version Prefix" + Format(TemplateSetup."Version Major Number") + '.00';
        end;

        exit(NewVersion);
    end;

    procedure CreateNewVersion(var TemplateHeader: Record "RP Template Header")
    begin
        if not TemplateHeader.Archived then
            exit;

        TemplateHeader.Version := GetNextVersionNumber(TemplateHeader);
        TemplateHeader."Version Comments" := '';
        TemplateHeader.Archived := false;
        TemplateHeader.Modify(true);
    end;

    procedure RollbackVersion(TemplateArchive: Record "RP Template Archive")
    var
        TemplateHeader: Record "RP Template Header";
        RPPackageHandler: Codeunit "RP Package Handler";
        TempBlob: Codeunit "Temp Blob";
    begin
        if not Confirm(Caption_RollbackVersion, false, TemplateArchive.Version) then
            exit;

        //Archive current version, if any is present, before rolling back
        TemplateHeader.SetRange(Code, TemplateArchive.Code);
        if TemplateHeader.FindFirst then begin
            TemplateHeader."Version Comments" := Caption_AutoArchive;
            TemplateHeader.Validate(Archived, true);
            TemplateHeader.Delete(true);
        end;

        TemplateArchive.CalcFields(Template);
        TempBlob.FromRecord(TemplateArchive, TemplateArchive.FieldNo(Template));
        RPPackageHandler.ImportPackageFromBlob(TempBlob);
    end;

    procedure CreateCopy(var TemplateHeader: Record "RP Template Header")
    var
        InputDialog: Page "Input Dialog";
        NewTemplateCode: Code[20];
        ID: Integer;
        TemplateHeader2: Record "RP Template Header";
        TemplateLine: Record "RP Template Line";
        DataItem: Record "RP Data Items";
        DataItemLink: Record "RP Data Item Links";
        DataItemConstraint: Record "RP Data Item Constraint";
        DataItemConstraintLink: Record "RP Data Item Constraint Links";
        DeviceSettings: Record "RP Device Settings";
        MediaInfo: Record "RP Template Media Info";
        CopyTemplateLine: Record "RP Template Line";
        CopyDataItem: Record "RP Data Items";
        CopyDataItemLink: Record "RP Data Item Links";
        CopyDataItemConstraint: Record "RP Data Item Constraint";
        CopyDataItemConstraintLink: Record "RP Data Item Constraint Links";
        CopyDeviceSettings: Record "RP Device Settings";
        CopyMediaInfo: Record "RP Template Media Info";
    begin
        if not TemplateHeader.FindFirst then
            exit;

        InputDialog.LookupMode := true;
        InputDialog.SetInput(1, NewTemplateCode, Caption_InsertNewCode);
        if InputDialog.RunModal = ACTION::LookupOK then
            ID := InputDialog.InputCode(1, NewTemplateCode);

        if ID = 0 then
            exit;

        if TemplateHeader2.Get(NewTemplateCode) then
            Error(Error_TemplateAlreadyExists, NewTemplateCode);

        TemplateLine.SetRange("Template Code", TemplateHeader.Code);
        DataItem.SetRange(Code, TemplateHeader.Code);
        DataItemLink.SetRange("Data Item Code", TemplateHeader.Code);
        DataItemConstraint.SetRange("Data Item Code", TemplateHeader.Code);
        DataItemConstraintLink.SetRange("Data Item Code", TemplateHeader.Code);
        DeviceSettings.SetRange(Template, TemplateHeader.Code);
        MediaInfo.SetAutoCalcFields(Picture);
        MediaInfo.SetRange(Template, TemplateHeader.Code);

        TemplateHeader.Code := NewTemplateCode;
        TemplateHeader.Archived := false;
        TemplateHeader.Version := '';
        TemplateHeader."Version Comments" := '';
        TemplateHeader.Insert(true);

        if DataItem.FindSet then
            repeat
                CopyDataItem := DataItem;
                CopyDataItem.Code := NewTemplateCode;
                CopyDataItem.Insert;
            until DataItem.Next = 0;

        if DataItemLink.FindSet then
            repeat
                CopyDataItemLink := DataItemLink;
                CopyDataItemLink."Data Item Code" := NewTemplateCode;
                CopyDataItemLink.Insert;
            until DataItemLink.Next = 0;

        if DataItemConstraint.FindSet then
            repeat
                CopyDataItemConstraint := DataItemConstraint;
                CopyDataItemConstraint."Data Item Code" := NewTemplateCode;
                CopyDataItemConstraint.Insert;
            until DataItemConstraint.Next = 0;

        if DataItemConstraintLink.FindSet then
            repeat
                CopyDataItemConstraintLink := DataItemConstraintLink;
                CopyDataItemConstraintLink."Data Item Code" := NewTemplateCode;
                CopyDataItemConstraintLink.Insert;
            until DataItemConstraintLink.Next = 0;

        if TemplateLine.FindSet then
            repeat
                CopyTemplateLine := TemplateLine;
                CopyTemplateLine."Template Code" := NewTemplateCode;
                CopyTemplateLine.Insert;
            until TemplateLine.Next = 0;

        if DeviceSettings.FindSet then
            repeat
                CopyDeviceSettings := DeviceSettings;
                CopyDeviceSettings.Template := NewTemplateCode;
                CopyDeviceSettings.Insert;
            until DeviceSettings.Next = 0;

        if MediaInfo.FindSet then
            repeat
                CopyMediaInfo := MediaInfo;
                CopyMediaInfo.Template := NewTemplateCode;
                CopyMediaInfo.Insert;
            until MediaInfo.Next = 0;
    end;

    procedure ExportArchived(var TemplateArchive: Record "RP Template Archive")
    var
        InStream: InStream;
        FileName: Variant;
    begin
        if not TemplateArchive.Template.HasValue then
            exit;

        TemplateArchive.CalcFields(Template);
        TemplateArchive.Template.CreateInStream(InStream);

        FileName := StrSubstNo('%1, Version %2.json', TemplateArchive.Code, TemplateArchive.Version);
        DownloadFromStream(InStream, 'Export archived template to file', '', 'JSON File (*.json)|*.json', FileName);
    end;

    local procedure "// Table Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyTemplateLine(var Rec: Record "RP Template Line"; var xRec: Record "RP Template Line"; RunTrigger: Boolean)
    var
        TemplateLine: Record "RP Template Line";
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;

        //Was parent before
        TemplateLine.SetRange("Parent Line No.", Rec."Line No.");
        if TemplateLine.FindSet then
            repeat
                TemplateLine.FindParentLine();
                TemplateLine.Modify;
            until TemplateLine.Next = 0;

        TemplateLine.Reset;
        //Is parent now
        TemplateLine.SetFilter("Line No.", '>%1', Rec."Line No.");
        TemplateLine.SetFilter(Level, '>%1', 0);
        TemplateLine.SetFilter("Parent Line No.", '<%1', Rec."Line No.");
        if TemplateLine.FindSet then
            repeat
                TemplateLine.FindParentLine();
                TemplateLine.Modify;
            until TemplateLine.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertTemplateLine(var Rec: Record "RP Template Line"; RunTrigger: Boolean)
    var
        TemplateLine: Record "RP Template Line";
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;

        TemplateLine.SetFilter("Line No.", '>%1', Rec."Line No.");
        TemplateLine.SetFilter(Level, '>%1', 0);
        TemplateLine.SetFilter("Parent Line No.", '<%1', Rec."Line No.");
        if TemplateLine.FindSet then
            repeat
                TemplateLine.FindParentLine();
                TemplateLine.Modify;
            until TemplateLine.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteTemplateLine(var Rec: Record "RP Template Line"; RunTrigger: Boolean)
    var
        TemplateLine: Record "RP Template Line";
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;

        TemplateLine.SetRange("Parent Line No.", Rec."Line No.");
        if TemplateLine.FindSet then
            repeat
                TemplateLine.FindParentLine();
                TemplateLine.Modify;
            until TemplateLine.Next = 0;
    end;

    local procedure "// Data Upgrade"()
    begin
    end;

    procedure UpgradeField(TableId: Integer; FromFieldId: Integer; ToFieldId: Integer)
    begin
        //-NPR5.39 [304745]
        UpgradeDataItemConstraintLink(TableId, FromFieldId, ToFieldId);
        UpgradeDataItemLink(TableId, FromFieldId, ToFieldId);
        UpgradeTemplateLine(TableId, FromFieldId, ToFieldId);
        //+NPR5.39 [304745]
    end;

    procedure RemoveField(TableId: Integer; FieldId: Integer)
    begin
        //-NPR5.39 [304745]
        DeleteDataItemConstraintLink(TableId, FieldId);
        DeleteDataItemLink(TableId, FieldId);
        DeleteTemplateLine(TableId, FieldId);
        //+NPR5.39 [304745]
    end;

    local procedure UpgradeTemplateLine(TableId: Integer; FromFieldId: Integer; ToFieldId: Integer)
    var
        RPTemplateLine: Record "RP Template Line";
    begin
        //-NPR5.39 [304745]
        RPTemplateLine.SetRange("Data Item Table", TableId);
        RPTemplateLine.SetRange(Field, FromFieldId);
        if RPTemplateLine.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                RPTemplateLine.Validate(Field, ToFieldId);
                if RPTemplateLine."Field 2" = FromFieldId then
                    RPTemplateLine.Validate("Field 2", ToFieldId);
                RPTemplateLine.Modify;
            until RPTemplateLine.Next = 0;
        RPTemplateLine.SetRange(Field);

        RPTemplateLine.SetRange("Field 2", FromFieldId);
        if RPTemplateLine.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                RPTemplateLine.Validate("Field 2", ToFieldId);
                RPTemplateLine.Modify;
            until RPTemplateLine.Next = 0;
        //+NPR5.39 [304745]
    end;

    local procedure UpgradeDataItemLink(TableId: Integer; FromFieldId: Integer; ToFieldId: Integer)
    var
        RPDataItemLinks: Record "RP Data Item Links";
    begin
        //-NPR5.39 [304745]
        RPDataItemLinks.SetRange("Table ID", TableId);
        RPDataItemLinks.SetRange("Field ID", FromFieldId);
        if RPDataItemLinks.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPDataItemLinks."Data Item Code");
                RPDataItemLinks.Validate("Field ID", ToFieldId);
                RPDataItemLinks.Modify;
            until RPDataItemLinks.Next = 0;
        RPDataItemLinks.Reset;

        RPDataItemLinks.SetRange("Parent Table ID", TableId);
        RPDataItemLinks.SetRange("Parent Field ID", FromFieldId);
        if RPDataItemLinks.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPDataItemLinks."Data Item Code");
                RPDataItemLinks.Validate("Parent Field ID", ToFieldId);
                RPDataItemLinks.Modify;
            until RPDataItemLinks.Next = 0;
        //+NPR5.39 [304745]
    end;

    local procedure UpgradeDataItemConstraintLink(TableId: Integer; FromFieldId: Integer; ToFieldId: Integer)
    var
        RPDataItemConstraintLinks: Record "RP Data Item Constraint Links";
        RPDataItemConstraint: Record "RP Data Item Constraint";
    begin
        //-NPR5.39 [304745]
        RPDataItemConstraintLinks.SetRange("Data Item Table ID", TableId);
        RPDataItemConstraintLinks.SetRange("Data Item Field ID", FromFieldId);
        if RPDataItemConstraintLinks.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPDataItemConstraintLinks."Data Item Code");
                RPDataItemConstraintLinks.Validate("Data Item Field ID", ToFieldId);
                RPDataItemConstraintLinks.Modify;
            until RPDataItemConstraintLinks.Next = 0;
        RPDataItemConstraintLinks.Reset;

        RPDataItemConstraint.SetRange("Table ID", TableId);
        if RPDataItemConstraint.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPDataItemConstraint."Data Item Code");
                RPDataItemConstraintLinks.SetRange("Data Item Code", RPDataItemConstraint."Data Item Code");
                RPDataItemConstraintLinks.SetRange("Constraint Line No.", RPDataItemConstraint."Line No.");
                RPDataItemConstraintLinks.SetRange("Field ID", FromFieldId);
                RPDataItemConstraintLinks.ModifyAll("Field ID", ToFieldId, true);
            until RPDataItemConstraint.Next = 0;
        //+NPR5.39 [304745]
    end;

    local procedure DeleteTemplateLine(TableId: Integer; FieldId: Integer)
    var
        RPTemplateLine: Record "RP Template Line";
    begin
        //-NPR5.39 [304745]
        RPTemplateLine.SetRange("Data Item Table", TableId);
        RPTemplateLine.SetRange(Field, FieldId);
        if RPTemplateLine.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                RPTemplateLine.Delete;
            until RPTemplateLine.Next = 0;
        RPTemplateLine.SetRange(Field);

        RPTemplateLine.SetRange("Field 2", FieldId);
        if RPTemplateLine.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPTemplateLine."Template Code");
                RPTemplateLine.Delete;
            until RPTemplateLine.Next = 0;
        //+NPR5.39 [304745]
    end;

    local procedure DeleteDataItemLink(TableId: Integer; FieldId: Integer)
    var
        RPDataItemLinks: Record "RP Data Item Links";
    begin
        //-NPR5.39 [304745]
        RPDataItemLinks.SetRange("Table ID", TableId);
        RPDataItemLinks.SetRange("Field ID", FieldId);
        if RPDataItemLinks.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPDataItemLinks."Data Item Code");
                RPDataItemLinks.Delete;
            until RPDataItemLinks.Next = 0;
        RPDataItemLinks.Reset;

        RPDataItemLinks.SetRange("Parent Table ID", TableId);
        RPDataItemLinks.SetRange("Parent Field ID", FieldId);
        if RPDataItemLinks.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPDataItemLinks."Data Item Code");
                RPDataItemLinks.Delete;
            until RPDataItemLinks.Next = 0;
        //+NPR5.39 [304745]
    end;

    local procedure DeleteDataItemConstraintLink(TableId: Integer; FieldId: Integer)
    var
        RPDataItemConstraintLinks: Record "RP Data Item Constraint Links";
        RPDataItemConstraint: Record "RP Data Item Constraint";
    begin
        //-NPR5.39 [304745]
        RPDataItemConstraintLinks.SetRange("Data Item Table ID", TableId);
        RPDataItemConstraintLinks.SetRange("Data Item Field ID", FieldId);
        if RPDataItemConstraintLinks.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPDataItemConstraintLinks."Data Item Code");
                RPDataItemConstraintLinks.Delete;
            until RPDataItemConstraintLinks.Next = 0;
        RPDataItemConstraintLinks.Reset;

        RPDataItemConstraint.SetRange("Table ID", TableId);
        if RPDataItemConstraint.FindSet then
            repeat
                IncreaseVersionIfNecessary(RPDataItemConstraint."Data Item Code");
                RPDataItemConstraintLinks.SetRange("Data Item Code", RPDataItemConstraint."Data Item Code");
                RPDataItemConstraintLinks.SetRange("Constraint Line No.", RPDataItemConstraint."Line No.");
                RPDataItemConstraintLinks.SetRange("Field ID", FieldId);
                RPDataItemConstraintLinks.DeleteAll;
            until RPDataItemConstraint.Next = 0;
        //+NPR5.39 [304745]
    end;

    local procedure IncreaseVersionIfNecessary(Template: Text)
    var
        RPTemplateHeader: Record "RP Template Header";
        TemplateMgt: Codeunit "RP Template Mgt.";
    begin
        //-NPR5.39 [304745]
        if RPTemplateHeader.Get(Template) then
            if RPTemplateHeader.Archived then begin
                TemplateMgt.CreateNewVersion(RPTemplateHeader);
                RPTemplateHeader."Version Comments" := 'Auto created version for field upgrade';
                RPTemplateHeader.Modify;
            end;
        //+NPR5.39 [304745]
    end;
}

