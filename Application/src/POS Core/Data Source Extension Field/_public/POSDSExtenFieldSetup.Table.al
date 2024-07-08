table 6060087 "NPR POS DS Exten. Field Setup"
{
    Access = Public;
    Caption = 'POS Data Source Exten. Field Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Extension Module"; Enum "NPR POS DS Extension Module")
        {
            Caption = 'Extension Module';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                xDataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
            begin
                xDataSourceExtFieldSetup := Rec;
                Init();
                "Extension Module" := xDataSourceExtFieldSetup."Extension Module";

                _DataSourceExtFieldSetupInt := "Extension Module";
                _DataSourceExtFieldSetupInt.ValidateDataSourceExtensionModule(Rec);
            end;
        }
        field(20; "Data Source Name"; Text[50])
        {
            Caption = 'Data Source Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                xDataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
            begin
                _DataSourceExtFieldMgt.EnsureDataSourceIsValid(Rec);

                xDataSourceExtFieldSetup := Rec;
                Init();
                "Extension Module" := xDataSourceExtFieldSetup."Extension Module";
                "Data Source Name" := xDataSourceExtFieldSetup."Data Source Name";
                if "Data Source Name" = '' then
                    exit;

                TestField("Extension Module");
                _DataSourceExtFieldSetupInt := "Extension Module";
                _DataSourceExtFieldSetupInt.ValidateDataSourceName(Rec);
            end;
        }
        field(21; "Extension Name"; Text[50])
        {
            Caption = 'Extension Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                xDataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
            begin
                _DataSourceExtFieldMgt.EnsureExtensionNameIsValid(Rec);

                xDataSourceExtFieldSetup := Rec;
                Init();
                "Extension Module" := xDataSourceExtFieldSetup."Extension Module";
                "Data Source Name" := xDataSourceExtFieldSetup."Data Source Name";
                "Extension Name" := xDataSourceExtFieldSetup."Extension Name";
                if "Extension Name" = '' then
                    exit;

                TestField("Extension Module");
                _DataSourceExtFieldSetupInt := "Extension Module";
                _DataSourceExtFieldSetupInt.ValidateExtensionName(Rec);
            end;
        }
        field(22; "Extension Field"; Text[50])
        {
            Caption = 'Extension Field';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                xDataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
            begin
                _DataSourceExtFieldMgt.EnsureExtensionFieldIsValid(Rec);

                xDataSourceExtFieldSetup := Rec;
                Init();
                "Extension Module" := xDataSourceExtFieldSetup."Extension Module";
                "Data Source Name" := xDataSourceExtFieldSetup."Data Source Name";
                "Extension Name" := xDataSourceExtFieldSetup."Extension Name";
                "Extension Field" := xDataSourceExtFieldSetup."Extension Field";
                if "Extension Field" = '' then
                    exit;

                TestField("Extension Module");
                _DataSourceExtFieldSetupInt := "Extension Module";
                _DataSourceExtFieldSetupInt.ValidateExtensionField(Rec);
            end;
        }
        field(30; "Exten.Field Instance Name"; Text[50])
        {
            Caption = 'Exten.Field Instance Name';
            DataClassification = CustomerContent;
        }
        field(40; "Exten.Field Instance Descript."; Text[100])
        {
            Caption = 'Exten.Field Instance Descript.';
            DataClassification = CustomerContent;
        }
        field(50; "Parameter Set"; Blob)
        {
            Caption = 'Parameters';
            DataClassification = CustomerContent;
        }
        field(60; "Exclude from Data Source"; Boolean)
        {
            Caption = 'Exclude from Data Source';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
                WarnDefaultFldMsg: Label 'Please note that marking all instances of an extension field as excluded from a POS data source won’t result in system adding the default instance of this field to the data source. If you want the default instance of the extension field to appear in the data souce, you will have to delete all custom instances of the extension field from the setup page.';
            begin
                if "Exclude from Data Source" then begin
                    _DataSourceExtFieldMgt.FilterDataSourceExtFieldSetup(DataSourceExtFieldSetup, "Extension Module", "Data Source Name", "Extension Name", "Extension Field");
                    DataSourceExtFieldSetup.SetRange("Exclude from Data Source", false);
                    DataSourceExtFieldSetup.SetFilter("Entry No.", '<>%1', "Entry No.");
                    if DataSourceExtFieldSetup.IsEmpty() then
                        Message(WarnDefaultFldMsg);
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Extension Module", "Data Source Name", "Extension Name", "Extension Field", "Exclude from Data Source", "Exten.Field Instance Name") { }
    }

    trigger OnInsert()
    begin
        CheckDuplicates();
    end;

    trigger OnModify()
    begin
        CheckDuplicates();
    end;

    local procedure CheckDuplicates()
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        MustBeUniqueErr: Label 'Another %1 entry already exists with the same %2, %3, %4, %5, and %6. Please consider changing %6 to make the setup line unique.', Comment = '%1 - table "DataSource Ext. Field Setup" caption, %2 .. %6 - field captions: "Extension Module", "Data Source Name", "Extension Name", "Extension Field", and "Extention Field Instance Name"';
    begin
        if "Exclude from Data Source" then
            exit;
        _DataSourceExtFieldMgt.FilterDataSourceExtFieldSetup(DataSourceExtFieldSetup, "Extension Module", "Data Source Name", "Extension Name", "Extension Field");
        DataSourceExtFieldSetup.SetRange("Exclude from Data Source", false);
        DataSourceExtFieldSetup.SetRange("Exten.Field Instance Name", "Exten.Field Instance Name");
        DataSourceExtFieldSetup.SetFilter("Entry No.", '<>%1', "Entry No.");
        if not DataSourceExtFieldSetup.IsEmpty() then
            Error(MustBeUniqueErr,
                TableCaption(), FieldCaption("Extension Module"), FieldCaption("Data Source Name"), FieldCaption("Extension Name"),
                FieldCaption("Extension Field"), FieldCaption("Exten.Field Instance Name"));
    end;

    procedure SetAdditionalParameterSet(NewParameterSet: JsonToken)
    var
        NewParameterSetAsText: Text;
    begin
        NewParameterSet.AsObject().WriteTo(NewParameterSetAsText);
        SetAdditionalParameterSet(NewParameterSetAsText);
    end;

    procedure SetAdditionalParameterSet(NewParameterSet: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Parameter Set");
        if NewParameterSet = '' then
            exit;
        "Parameter Set".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewParameterSet);
    end;

#IF BC17
    procedure GetAdditionalParameterSetStream(var InStr: InStream)
#ELSE
    procedure GetAdditionalParameterSetStream() InStr: InStream
#ENDIF
    begin
        CalcFields("Parameter Set");
        "Parameter Set".CreateInStream(InStr, TextEncoding::UTF8);
    end;

    procedure GetAdditionalParameterSet(): Text
    var
        TypeHelper: Codeunit "Type Helper";
#IF BC17
        InStr: InStream;
#ENDIF
    begin
        if not "Parameter Set".HasValue then
            exit('');
#IF BC17
        GetAdditionalParameterSetStream(InStr);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator()));
#ELSE
        exit(TypeHelper.ReadAsTextWithSeparator(GetAdditionalParameterSetStream(), TypeHelper.LFSeparator()));
#ENDIF
    end;

    internal procedure SetExtensionModuleFromFilter()
    var
        ExtensionModule: Enum "NPR POS DS Extension Module";
    begin
        ExtensionModule := GetExtensionModuleFromFilter();
        Validate("Extension Module", ExtensionModule);
    end;

    internal procedure GetExtensionModuleFromFilter() ExtensionModule: Enum "NPR POS DS Extension Module"
    begin
        ExtensionModule := GetFilterExtensionModule();
        if ExtensionModule = ExtensionModule::Undefined then begin
            FilterGroup(2);
            ExtensionModule := GetFilterExtensionModule();
            if ExtensionModule = ExtensionModule::Undefined then
                ExtensionModule := GetFilterExtensionModuleByApplyingFilter();
            FilterGroup(0);
        end;
    end;

    local procedure GetFilterExtensionModule(): Enum "NPR POS DS Extension Module"
    var
        MinValue: Enum "NPR POS DS Extension Module";
        MaxValue: Enum "NPR POS DS Extension Module";
    begin
        if GetFilter("Extension Module") <> '' then
            if TryGetFilterExtensionModuleRange(MinValue, MaxValue) then
                if MinValue = MaxValue then
                    exit(MaxValue);
    end;

    [TryFunction]
    local procedure TryGetFilterExtensionModuleRange(var MinValue: Enum "NPR POS DS Extension Module"; var MaxValue: Enum "NPR POS DS Extension Module")
    begin
        MinValue := GetRangeMin("Extension Module");
        MaxValue := GetRangeMax("Extension Module");
    end;

    local procedure GetFilterExtensionModuleByApplyingFilter(): Enum "NPR POS DS Extension Module"
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        MinValue: Enum "NPR POS DS Extension Module";
        MaxValue: Enum "NPR POS DS Extension Module";
    begin
        if GetFilter("Extension Module") <> '' then begin
            DataSourceExtFieldSetup.CopyFilters(Rec);
            DataSourceExtFieldSetup.SetCurrentKey("Extension Module");
            if DataSourceExtFieldSetup.FindFirst() then
                MinValue := DataSourceExtFieldSetup."Extension Module";
            if DataSourceExtFieldSetup.FindLast() then
                MaxValue := DataSourceExtFieldSetup."Extension Module";
            if MinValue = MaxValue then
                exit(MaxValue);
        end;
    end;

    var
        _DataSourceExtFieldMgt: Codeunit "NPR POS DS Exten. Field Mgt.";
        _DataSourceExtFieldSetupInt: Interface "NPR POS DS Exten. Field Setup";
}