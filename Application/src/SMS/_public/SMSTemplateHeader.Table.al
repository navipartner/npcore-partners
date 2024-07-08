table 6059940 "NPR SMS Template Header"
{
    Caption = 'SMS Template Header';
    DrillDownPageID = "NPR SMS Template List";
    LookupPageID = "NPR SMS Template List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = "Table Metadata";
            DataClassification = CustomerContent;
        }
        field(25; "Table Caption"; Text[80])
        {
            CalcFormula = Lookup("Table Metadata".Caption WHERE(ID = FIELD("Table No.")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Alt. Sender"; Text[30])
        {
            Caption = 'Alt. Sender';
            DataClassification = CustomerContent;
        }
        field(50; Recipient; Text[30])
        {
            Caption = 'Recipient';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
                SMSFieldList: Page "NPR SMS Field List";
                RecipientLbl: Label '{%1}', Locked = true;
            begin
                if "Table No." = 0 then
                    exit;
                Field.SetRange(TableNo, "Table No.");
                SMSFieldList.LookupMode := true;
                SMSFieldList.SetTableView(Field);
                if SMSFieldList.RunModal() = ACTION::OK then begin
                    SMSFieldList.GetRecord(Field);
                    Recipient := StrSubstNo(RecipientLbl, Field."No.");
                end;
            end;
        }
        field(51; "Recipient Type"; Enum "NPR SMS Recipient Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Recipient Type';
        }
        field(52; "Recipient Group"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Recipient Group';
            TableRelation = "NPR SMS Recipient Group";
        }
        field(100; "Table Filters"; BLOB)
        {
            Caption = 'Table Filters';
            DataClassification = CustomerContent;
        }
        field(120; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Report));
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        SMSTemplateLine: Record "NPR SMS Template Line";
    begin
        SMSTemplateLine.SetRange("Template Code", Code);
        SMSTemplateLine.DeleteAll();
    end;

    trigger OnModify()
    begin
        if "Table No." <> xRec."Table No." then
            Clear("Table Filters");
    end;

    var
        SMSFilterCaption: Label 'Filters for table %1';

    internal procedure OpenFilterPage()
    var
        FiltersOutStream: OutStream;
        CurrentFilters: Text;
        ReturnFilters: Text;
        UserClickedOK: Boolean;
    begin
        CurrentFilters := GetTableFilters();
        UserClickedOK := OpenRequestPage(ReturnFilters, CurrentFilters);
        if UserClickedOK and (ReturnFilters <> CurrentFilters) then begin
            if ReturnFilters = CreateDefaultRequestPageFilters() then
                Clear("Table Filters")
            else begin
                "Table Filters".CreateOutStream(FiltersOutStream);
                FiltersOutStream.Write(ReturnFilters);
            end;
            Modify(true);
        end;
    end;

    internal procedure GetTableFilters() Filters: Text
    var
        FiltersInStream: InStream;
    begin
        if "Table Filters".HasValue() then begin
            CalcFields("Table Filters");
            "Table Filters".CreateInStream(FiltersInStream);
            FiltersInStream.Read(Filters);
        end else
            Filters := CreateDefaultRequestPageFilters();
    end;

    local procedure CreateDefaultRequestPageFilters(): Text
    var
        TableMetadata: Record "Table Metadata";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not TableMetadata.Get("Table No.") then
            exit('');

        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, '', "Table No.") then
            exit('');

        exit(RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, '', "Table No."));
    end;

    local procedure OpenRequestPage(var ReturnFilters: Text; Filters: Text): Boolean
    var
        TableMetadata: Record "Table Metadata";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not TableMetadata.Get("Table No.") then
            exit(false);

        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, '', "Table No.") then
            exit(false);

        if Filters <> '' then
            if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(
                 FilterPageBuilder, Filters, '', "Table No.")
            then
                exit(false);

        FilterPageBuilder.PageCaption := StrSubstNo(SMSFilterCaption, TableMetadata.Caption);
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters :=
          RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, '', "Table No.");

        exit(true);
    end;
}

