table 6014446 "RP Template Header"
{
    // NPR5.30/MMV /20170301  CASE 241995 Retail Print 2.0
    // NPR5.32/MMV /20170411  CASE 241995 Retail Print 2.0
    // NPR5.34/MHA /20170721  CASE 282799 Added FlowField 1000 "Table ID"
    // NPR5.34/MMV /20170724  CASE 284505 Expose all column distributions for custom setup.
    // NPR5.41/MMV /20180417  CASE 311633 Added field "Default Decimal Rounding"

    Caption = 'RP Template Header';
    DrillDownPageID = "RP Template List";
    LookupPageID = "RP Template List";

    fields
    {
        field(10;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(40;"Printer Type";Option)
        {
            Caption = 'Printer Type';
            OptionCaption = 'Matrix,Line';
            OptionMembers = Matrix,Line;
        }
        field(41;"Printer Device";Text[30])
        {
            Caption = 'Printer Device';

            trigger OnLookup()
            begin
                LookupDevice();
            end;

            trigger OnValidate()
            var
                DeviceSettings: Record "RP Device Settings";
            begin
                if "Printer Device" <> xRec."Printer Device" then begin
                  DeviceSettings.SetRange(Template, Code);
                  if DeviceSettings.IsEmpty then
                    exit;

                  if not Confirm(Caption_DeviceSettingsOverwrite) then
                    Error('');

                  TemplateModified();
                  DeviceSettings.DeleteAll;
                end;
            end;
        }
        field(50;Description;Text[128])
        {
            Caption = 'Comments';
        }
        field(60;Archived;Boolean)
        {
            Caption = 'Archived';

            trigger OnValidate()
            begin
                ArchiveTemplate();
            end;
        }
        field(61;Version;Code[50])
        {
            Caption = 'Version';
        }
        field(62;"Version Comments";Text[128])
        {
            Caption = 'Version Comments';
        }
        field(63;"Last Modified At";DateTime)
        {
            Caption = 'Last Modified At';
        }
        field(64;"Last Modified By";Code[50])
        {
            Caption = 'Last Modified By';
        }
        field(70;"Pre Processing Codeunit";Integer)
        {
            Caption = 'Pre Processing Codeunit';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=FILTER(Codeunit));
        }
        field(71;"Print Processing Object Type";Option)
        {
            Caption = 'Print Processing Object Type';
            OptionCaption = 'Codeunit,Report';
            OptionMembers = "Codeunit","Report";
        }
        field(72;"Print Processing Object ID";Integer)
        {
            Caption = 'Print Processing Object ID';
            TableRelation = IF ("Print Processing Object Type"=CONST(Codeunit)) AllObj."Object ID" WHERE ("Object Type"=FILTER(Codeunit))
                            ELSE IF ("Print Processing Object Type"=CONST(Report)) AllObj."Object ID" WHERE ("Object Type"=FILTER(Report));

            trigger OnValidate()
            begin
                if ("Print Processing Object ID" > 0) and (xRec."Print Processing Object ID" = 0) then begin
                  if GuiAllowed then
                    if not Confirm(Caption_PrintOverwrite) then
                      Error('');
                end;
            end;
        }
        field(73;"Post Processing Codeunit";Integer)
        {
            Caption = 'Post Processing Codeunit';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=FILTER(Codeunit));
        }
        field(78;"Two Column Width 1";Decimal)
        {
            Caption = 'Two Column Width 1';
            DecimalPlaces = 0:3;
        }
        field(79;"Two Column Width 2";Decimal)
        {
            Caption = 'Two Column Width 2';
            DecimalPlaces = 0:3;
        }
        field(80;"Three Column Width 1";Decimal)
        {
            Caption = 'Three Column Width 1';
            DecimalPlaces = 0:3;
        }
        field(81;"Three Column Width 2";Decimal)
        {
            Caption = 'Three Column Width 2';
            DecimalPlaces = 0:3;
        }
        field(82;"Three Column Width 3";Decimal)
        {
            Caption = 'Three Column Width 3';
            DecimalPlaces = 0:3;
        }
        field(84;"Four Column Width 1";Decimal)
        {
            Caption = 'Four Column Width 1';
            DecimalPlaces = 0:3;
        }
        field(85;"Four Column Width 2";Decimal)
        {
            Caption = 'Four Column Width 2';
            DecimalPlaces = 0:3;
        }
        field(86;"Four Column Width 3";Decimal)
        {
            Caption = 'Four Column Width 3';
            DecimalPlaces = 0:3;
        }
        field(87;"Four Column Width 4";Decimal)
        {
            Caption = 'Four Column Width 4';
            DecimalPlaces = 0:3;
        }
        field(90;"Default Decimal Rounding";Option)
        {
            Caption = 'Default Decimal Rounding';
            OptionCaption = '2,3,4,5';
            OptionMembers = "2","3","4","5";
        }
        field(1000;"Table ID";Integer)
        {
            CalcFormula = Lookup("RP Data Items"."Table ID" WHERE (Code=FIELD(Code),
                                                                   Level=CONST(0)));
            Caption = 'Table ID';
            Description = 'NPR5.34';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Code","Printer Type","Printer Device",Description)
        {
        }
    }

    trigger OnDelete()
    var
        TemplateLine: Record "RP Template Line";
        DataItem: Record "RP Data Items";
        DataItemLinks: Record "RP Data Item Links";
        DataItemConstraint: Record "RP Data Item Constraint";
        DataItemConstraintLinks: Record "RP Data Item Constraint Links";
        DeviceSettings: Record "RP Device Settings";
        MediaInfo: Record "RP Template Media Info";
    begin
        if IsTemporary then
          exit;

        TemplateLine.SetRange("Template Code",Code);
        TemplateLine.DeleteAll;

        DataItem.SetRange(Code, Code);
        DataItem.DeleteAll;

        DataItemLinks.SetRange("Data Item Code", Code);
        DataItemLinks.DeleteAll;

        DataItemConstraint.SetRange("Data Item Code", Code);
        DataItemConstraint.DeleteAll;

        DataItemConstraintLinks.SetRange("Data Item Code", Code);
        DataItemConstraintLinks.DeleteAll;

        DeviceSettings.SetRange(Template, Code);
        DeviceSettings.DeleteAll;

        MediaInfo.SetRange(Template, Code);
        MediaInfo.DeleteAll;
    end;

    trigger OnInsert()
    var
        TemplateMgt: Codeunit "RP Template Mgt.";
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
        Caption_PrintOverwrite: Label 'Specifying a print processing object will bypass the print engine completely!\Do you want to continue?';
        Caption_DeviceSettingsOverwrite: Label 'Changing printer device will delete all stored device settings!\Do you want to continue?';

    procedure TemplateModified()
    begin
        if IsTemporary then
          exit;

        if Archived and xRec.Archived then
          Error(Error_Archived);

        TestField(Code);
        "Last Modified At" := CreateDateTime(Today, Time);
        "Last Modified By" := UserId;
    end;

    procedure ArchiveTemplate()
    var
        TemplateHeader: Record "RP Template Header";
        PackageHandler: Codeunit "RP Package Handler";
        TempBlob: Record TempBlob temporary;
        TemplateArchive: Record "RP Template Archive";
        PrintTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        if IsTemporary then
          exit;
        if not Archived then
          exit;
        if xRec.Archived then
          exit;

        if "Version Comments" = '' then
          Error(Error_MissingVersionDesc);

        if StrLen(Version) = 0 then
          Version := PrintTemplateMgt.GetNextVersionNumber(Rec);

        Modify;

        TemplateHeader.Copy(Rec);
        TemplateHeader.SetRecFilter();
        PackageHandler.ExportPackageToBlob(TemplateHeader, TempBlob);

        TemplateArchive.Init;
        TemplateArchive.Code := TemplateHeader.Code;
        TemplateArchive.Version := TemplateHeader.Version;
        TemplateArchive."Archived at" := CreateDateTime(Today, Time);
        TemplateArchive."Archived by" := UserId;
        TemplateArchive."Version Comments" := TemplateHeader."Version Comments";
        TemplateArchive.Template := TempBlob.Blob;
        TemplateArchive.Insert;
    end;

    procedure LookupDevice()
    var
        LinePrinterInterface: Codeunit "RP Line Printer Interface";
        MatrixPrinterInterface: Codeunit "RP Matrix Printer Interface";
        TmpRetailList: Record "Retail List" temporary;
    begin
        case "Printer Type" of
          "Printer Type"::Line : LinePrinterInterface.GetDeviceList(TmpRetailList);
          "Printer Type"::Matrix : MatrixPrinterInterface.GetDeviceList(TmpRetailList);
        end;

        if TmpRetailList.IsEmpty then
          exit;

        if PAGE.RunModal(PAGE::"Retail List", TmpRetailList) = ACTION::LookupOK then
          Validate("Printer Device",TmpRetailList.Choice);
    end;
}

