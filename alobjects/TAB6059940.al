table 6059940 "SMS Template Header"
{
    // NPR5.26/THRO/20160908 CASE 244114 SMS Module
    // NPR5.30/THRO/20170203 CASE 263182 Added field 50 Recipient
    // NPR5.40/THRO/20180314 CASE 304312 Added field 120 "Report ID"
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 120

    Caption = 'SMS Template Header';
    DrillDownPageID = "SMS Template List";
    LookupPageID = "SMS Template List";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(20;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = "Table Metadata";
        }
        field(25;"Table Caption";Text[80])
        {
            CalcFormula = Lookup("Table Metadata".Caption WHERE (ID=FIELD("Table No.")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30;"Alt. Sender";Text[30])
        {
            Caption = 'Alt. Sender';
        }
        field(50;Recipient;Text[30])
        {
            Caption = 'Recipient';

            trigger OnLookup()
            var
                "Field": Record "Field";
                SMSFieldList: Page "SMS Field List";
            begin
                //-NPR5.30 [263182]
                if "Table No." = 0 then
                  exit;
                Field.SetRange(TableNo,"Table No.");
                SMSFieldList.LookupMode := true;
                SMSFieldList.SetTableView(Field);
                if SMSFieldList.RunModal = ACTION::OK then begin
                  SMSFieldList.GetRecord(Field);
                  Recipient := StrSubstNo('{%1}',Field."No.");
                end;
                //+NPR5.30 [263182]
            end;
        }
        field(100;"Table Filters";BLOB)
        {
            Caption = 'Table Filters';
        }
        field(120;"Report ID";Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
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
    }

    trigger OnDelete()
    var
        SMSTemplateLine: Record "SMS Template Line";
    begin
        SMSTemplateLine.SetRange("Template Code",Code);
        SMSTemplateLine.DeleteAll;
    end;

    trigger OnModify()
    begin
        if "Table No." <> xRec."Table No." then
          Clear("Table Filters");
    end;

    var
        SMSFilterCaption: Label 'Filters for table %1';

    procedure OpenFilterPage()
    var
        FiltersOutStream: OutStream;
        CurrentFilters: Text;
        ReturnFilters: Text;
        UserClickedOK: Boolean;
    begin
        CurrentFilters := GetTableFilters;
        UserClickedOK := OpenRequestPage(ReturnFilters,CurrentFilters);
        if UserClickedOK and (ReturnFilters <> CurrentFilters) then begin
          if ReturnFilters = CreateDefaultRequestPageFilters then
            Clear("Table Filters")
          else begin
            "Table Filters".CreateOutStream(FiltersOutStream);
            FiltersOutStream.Write(ReturnFilters);
          end;
          Modify(true);
        end;
    end;

    procedure GetTableFilters() Filters: Text
    var
        FiltersInStream: InStream;
    begin
        if "Table Filters".HasValue then begin
          CalcFields("Table Filters");
          "Table Filters".CreateInStream(FiltersInStream);
          FiltersInStream.Read(Filters);
        end else
          Filters := CreateDefaultRequestPageFilters;
    end;

    local procedure CreateDefaultRequestPageFilters(): Text
    var
        TableMetadata: Record "Table Metadata";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not TableMetadata.Get("Table No.") then
          exit('');

        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder,'',"Table No.") then
          exit('');

        exit(RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder,'',"Table No."));
    end;

    local procedure OpenRequestPage(var ReturnFilters: Text;Filters: Text): Boolean
    var
        TableMetadata: Record "Table Metadata";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not TableMetadata.Get("Table No.") then
          exit(false);

        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder,'',"Table No.") then
          exit(false);

        if Filters <> '' then
          if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(
               FilterPageBuilder,Filters,'',"Table No.")
          then
            exit(false);

        FilterPageBuilder.PageCaption := StrSubstNo(SMSFilterCaption,TableMetadata.Caption);
        if not FilterPageBuilder.RunModal then
          exit(false);

        ReturnFilters :=
          RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder,'',"Table No.");

        exit(true);
    end;
}

