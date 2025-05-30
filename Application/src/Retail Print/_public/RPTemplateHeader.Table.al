table 6014446 "NPR RP Template Header"
{
#pragma warning disable AA0139
    Caption = 'RP Template Header';
    DrillDownPageID = "NPR RP Template List";
    LookupPageID = "NPR RP Template List";
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(40; "Printer Type"; Option)
        {
            Caption = 'Printer Type';
            OptionCaption = 'Matrix,Line';
            OptionMembers = Matrix,Line;
            DataClassification = CustomerContent;
        }
        field(41; "Printer Device"; Text[30])
        {
            Caption = 'Printer Device';
            DataClassification = CustomerContent;
            ObsoleteState = Pending; //If set to removed, it'll block import of templates exported from previous customers
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by "Matrix Device" and "Line Device" enums';
        }
        field(42; "Matrix Device"; Enum "NPR Matrix Printer Device")
        {
            Caption = 'Matrix Device';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Matrix Device" <> xRec."Matrix Device" then begin
                    ClearDeviceSettings();
                end;
            end;
        }
        field(43; "Line Device"; Enum "NPR Line Printer Device")
        {
            Caption = 'Line Device';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Line Device" <> xRec."Line Device" then begin
                    ClearDeviceSettings();
                end;
            end;
        }
        field(50; Description; Text[128])
        {
            Caption = 'Comments';
            DataClassification = CustomerContent;
        }
        field(60; Archived; Boolean)
        {
            Caption = 'Archived';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ArchiveTemplate();
            end;
        }
        field(61; Version; Code[50])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
        }
        field(62; "Version Comments"; Text[128])
        {
            Caption = 'Version Comments';
            DataClassification = CustomerContent;
        }
        field(63; "Last Modified At"; DateTime)
        {
            Caption = 'Last Modified At';
            DataClassification = CustomerContent;
        }
        field(64; "Last Modified By"; Code[50])
        {
            Caption = 'Last Modified By';
            DataClassification = CustomerContent;
        }
        field(70; "Pre Processing Codeunit"; Integer)
        {
            Caption = 'Pre Processing Codeunit';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = FILTER(Codeunit));
            DataClassification = CustomerContent;
        }
        field(71; "Print Processing Object Type"; Option)
        {
            Caption = 'Print Processing Object Type';
            OptionCaption = 'Codeunit,Report';
            OptionMembers = "Codeunit","Report";
            DataClassification = CustomerContent;
        }
        field(72; "Print Processing Object ID"; Integer)
        {
            Caption = 'Print Processing Object ID';
            TableRelation = IF ("Print Processing Object Type" = CONST(Codeunit)) AllObj."Object ID" WHERE("Object Type" = FILTER(Codeunit))
            ELSE
            IF ("Print Processing Object Type" = CONST(Report)) AllObj."Object ID" WHERE("Object Type" = FILTER(Report));
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Modules should have a field for report ID if they want to support running a report directly. With newer report print event subscribers there is no need for a custom PDF handler';
        }
        field(73; "Post Processing Codeunit"; Integer)
        {
            Caption = 'Post Processing Codeunit';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = FILTER(Codeunit));
            DataClassification = CustomerContent;
        }
        field(78; "Two Column Width 1"; Decimal)
        {
            Caption = 'Two Column Width 1';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(79; "Two Column Width 2"; Decimal)
        {
            Caption = 'Two Column Width 2';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(80; "Three Column Width 1"; Decimal)
        {
            Caption = 'Three Column Width 1';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(81; "Three Column Width 2"; Decimal)
        {
            Caption = 'Three Column Width 2';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(82; "Three Column Width 3"; Decimal)
        {
            Caption = 'Three Column Width 3';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(84; "Four Column Width 1"; Decimal)
        {
            Caption = 'Four Column Width 1';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(85; "Four Column Width 2"; Decimal)
        {
            Caption = 'Four Column Width 2';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(86; "Four Column Width 3"; Decimal)
        {
            Caption = 'Four Column Width 3';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(87; "Four Column Width 4"; Decimal)
        {
            Caption = 'Four Column Width 4';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(90; "Default Decimal Rounding"; Option)
        {
            Caption = 'Default Decimal Rounding';
            OptionCaption = '2,3,4,5';
            OptionMembers = "2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(100; "Log Output"; Boolean)
        {
            Caption = 'Log Output';
            DataClassification = CustomerContent;
        }
        field(1000; "Table ID"; Integer)
        {
            CalcFormula = Lookup("NPR RP Data Items"."Table ID" WHERE(Code = FIELD(Code),
                                                                   Level = CONST(0)));
            Caption = 'Table ID';
            Description = 'NPR5.34';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", "Printer Type", Description)
        {
        }
    }

    trigger OnDelete()
    var
        RPTemplateLine: Record "NPR RP Template Line";
        DataItem: Record "NPR RP Data Items";
        DataItemLinks: Record "NPR RP Data Item Links";
        DataItemConstraint: Record "NPR RP Data Item Constr.";
        DataItemConstraintLinks: Record "NPR RP Data Item Constr. Links";
        DeviceSettings: Record "NPR RP Device Settings";
        MediaInfo: Record "NPR RP Template Media Info";
    begin
        if IsTemporary then
            exit;

        RPTemplateLine.SetRange("Template Code", Code);
        RPTemplateLine.DeleteAll();

        DataItem.SetRange(Code, Code);
        DataItem.DeleteAll();

        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemLinks.DeleteAll();

        DataItemConstraint.SetRange("Data Item Code", Code);
        DataItemConstraint.DeleteAll();

        DataItemConstraintLinks.SetRange("Data Item Code", Code);
        DataItemConstraintLinks.DeleteAll();

        DeviceSettings.SetRange(Template, Code);
        DeviceSettings.DeleteAll();

        MediaInfo.SetRange(Template, Code);
        MediaInfo.DeleteAll();
    end;

    trigger OnInsert()
    var
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        TemplateModified();

        if StrLen(Version) = 0 then
            Version := TemplateMgt.GetNextVersionNumber(Rec);
    end;

    trigger OnModify()
    begin
        TemplateModified();
    end;

    trigger OnRename()
    begin
        TemplateModified();
    end;

    var
        Error_Archived: Label 'You cannot modify an archived print template.';
        Error_MissingVersionDesc: Label 'Version comments must be written before archiving.';
        Caption_DeviceSettingsOverwrite: Label 'Changing printer device will delete all stored device settings!\Do you want to continue?';

    local procedure ClearDeviceSettings()
    var
        DeviceSettings: Record "NPR RP Device Settings";
    begin
        DeviceSettings.SetRange(Template, Code);
        if DeviceSettings.IsEmpty then
            exit;

        if not Confirm(Caption_DeviceSettingsOverwrite) then
            Error('');

        TemplateModified();
        DeviceSettings.DeleteAll();
    end;

    internal procedure TemplateModified()
    begin
        if IsTemporary then
            exit;

        if Archived and xRec.Archived then
            Error(Error_Archived);

        TestField(Code);
        "Last Modified At" := CreateDateTime(Today, Time);
        "Last Modified By" := UserId;
    end;

    internal procedure ArchiveTemplate()
    var
        RPTemplateHeader: Record "NPR RP Template Header";
        PackageHandler: Codeunit "NPR RP Package Handler";
        TempBlob: Codeunit "Temp Blob";
        RPTemplateArchive: Record "NPR RP Template Archive";
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
        RecRef: RecordRef;
    begin
        if IsTemporary then
            exit;
        if not Archived then
            exit;
        if xRec.Archived then
            exit;

        if "Version Comments" = '' then
            Error(Error_MissingVersionDesc);

        if (RPTemplateArchive.Get(Rec.Code, Rec.Version) or (StrLen(Rec.Version) = 0)) then
            Version := PrintTemplateMgt.GetNextVersionNumber(Rec);

        Modify();

        RPTemplateHeader.Copy(Rec);
        RPTemplateHeader.SetRecFilter();
        PackageHandler.ExportPackageToBlob(RPTemplateHeader, TempBlob);

        RPTemplateArchive.Init();
        RPTemplateArchive.Code := RPTemplateHeader.Code;
        RPTemplateArchive.Version := RPTemplateHeader.Version;
        RPTemplateArchive."Archived at" := CreateDateTime(Today, Time);
        RPTemplateArchive."Archived by" := UserId;
        RPTemplateArchive."Version Comments" := RPTemplateHeader."Version Comments";

        RecRef.GetTable(RPTemplateArchive);
        TempBlob.ToRecordRef(RecRef, RPTemplateArchive.FieldNo(Template));
        RecRef.SetTable(RPTemplateArchive);

        RPTemplateArchive.Insert();
    end;
#pragma warning restore AA0139
}

