table 6150717 "NPR POS Menu Filter"
{
    Access = Internal;
    Caption = 'POS Menu Filter';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Menu Filter List";

    fields
    {
        field(1; "Object Type"; Option)
        {
            Caption = 'Object Type';
            DataClassification = CustomerContent;
            OptionCaption = ',,,Report,,Codeunit,XMLPort,,Page';
            OptionMembers = ,,,"Report",,"Codeunit","XMLPort",,"Page";
        }
        field(2; "Object Id"; Integer)
        {
            Caption = 'Object Id';
            DataClassification = CustomerContent;
        }
        field(3; "Filter Code"; Code[20])
        {
            Caption = 'Filter Code';
            DataClassification = CustomerContent;
            Description = 'Key';
        }
        field(5; "Object Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = FIELD("Object Type"),
                                                             "Object ID" = FIELD("Object Id")));
            Caption = 'Object Name';
            FieldClass = FlowField;
        }
        field(6; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(8; "Send Sale POS"; Boolean)
        {
            Caption = 'Send Sale POS';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Send Sale Line POS" := false;
                "Table No." := 0;
                Clear("Table Filter");
            end;
        }
        field(9; "Send Sale Line POS"; Boolean)
        {
            Caption = 'Send Sale Line POS';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Send Sale POS" := false;
                "Table No." := 0;
                Clear("Table Filter");
            end;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            ValidateTableRelation = true;

            trigger OnValidate()
            begin
                "Send Sale Line POS" := false;
                "Send Sale POS" := false;
                if "Table No." <> xRec."Table No." then Clear("Table Filter");
            end;
        }
        field(11; "Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            FieldClass = FlowField;
        }
        field(12; "Table Filter"; BLOB)
        {
            Caption = 'Table Filter';
            DataClassification = CustomerContent;
        }
        field(13; "Sale POS Filter"; BLOB)
        {
            Caption = 'Sale POS Filter';
            DataClassification = CustomerContent;
        }
        field(14; "Sale Line POS Filter"; BLOB)
        {
            Caption = 'Sale Line POS Filter';
            DataClassification = CustomerContent;
        }
        field(15; "Run Modal"; Boolean)
        {
            Caption = 'Run Modal';
            DataClassification = CustomerContent;
        }
        field(20; "Current POS Register / Unit"; Boolean)
        {
            Caption = 'Current POS Register / Unit';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Filter Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ERRONLYONE: Label 'Only one record can be used when Object Type is Report.';

    procedure ActivateFilter()
    var
        POSSession: Codeunit "NPR POS Session";
        FilterCount: Integer;
    begin
        FilterCount := 0;
        if ("Send Sale POS") then FilterCount += 1;
        if ("Send Sale Line POS") then FilterCount += 1;
        if ("Table No." <> 0) then FilterCount += 1;
        if FilterCount > 1 then Error(ERRONLYONE);

        Active := true;

        RunObjectWithFilter(Rec, POSSession);

        Modify();
    end;

    procedure DeActivateFilter()
    begin
        Active := false;
        Modify();
    end;

    procedure TableFilter()
    var
        FilterBuilder: FilterPageBuilder;
        MailRecordRef: RecordRef;
        FilterStringText: Text;
        FilterViewName: Text;
        INS: InStream;
        OUTS: OutStream;
    begin
        Rec.CalcFields("Table Filter");
        if Rec."Table Filter".HasValue() then begin
            Rec."Table Filter".CreateInStream(INS);
            INS.Read(FilterStringText);
        end;

        Rec.TestField("Table No.");
        MailRecordRef.Open(Rec."Table No.");
        FilterViewName := MailRecordRef.Name;
        FilterBuilder.AddRecordRef(FilterViewName, MailRecordRef);
        if FilterStringText <> '' then FilterBuilder.SetView(FilterViewName, FilterStringText);
        if FilterBuilder.RunModal() then begin
            FilterStringText := FilterBuilder.GetView(FilterViewName);
        end;

        Rec."Table Filter".CreateOutStream(OUTS);
        OUTS.Write(FilterStringText);
        Rec.Modify();
    end;

    procedure RunObjectWithFilter(POSMenuFilter: Record "NPR POS Menu Filter"; POSSession: Codeunit "NPR POS Session")
    var
        FilterRecRef: RecordRef;
        FilterStringText: Text;
        INS: InStream;
        FilterRecVariant: Variant;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
        FilterCount: Integer;
    begin
        POSMenuFilter.TestField(Active, true);

        FilterCount := 0;
        if ("Send Sale POS") then FilterCount += 1;
        if ("Send Sale Line POS") then FilterCount += 1;
        if ("Table No." <> 0) then FilterCount += 1;
        if FilterCount > 1 then Error(ERRONLYONE);

        if FilterCount = 1 then begin
            if ("Table No." <> 0) then begin
                FilterRecRef.Open(POSMenuFilter."Table No.");

                POSMenuFilter.CalcFields("Table Filter");
                if POSMenuFilter."Table Filter".HasValue() then begin
                    POSMenuFilter."Table Filter".CreateInStream(INS);
                    INS.Read(FilterStringText);
                end;

                if ("Current POS Register / Unit") then
                    SetPOSUnitFilter("Table No.", FilterStringText);

                if FilterStringText <> '' then begin
                    FilterRecRef.SetView(FilterStringText);
                    if FilterRecRef.FindFirst() then;
                end;
                FilterRecVariant := FilterRecRef;

            end;

            if POSMenuFilter."Send Sale POS" then begin
                POSSession.GetSale(POSSale);
                POSSale.GetCurrentSale(SalePOS);
                FilterRecVariant := SalePOS;
            end;

            if POSMenuFilter."Send Sale Line POS" then begin
                POSSession.GetSaleLine(POSSaleLine);
                POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
                FilterRecVariant := SaleLinePOS;
            end;
        end;

        case POSMenuFilter."Object Type" of
            POSMenuFilter."Object Type"::Page:
                begin
                    if POSMenuFilter."Run Modal" then begin
                        if (FilterCount = 1) then PAGE.RunModal(POSMenuFilter."Object Id", FilterRecVariant);
                        if (FilterCount = 0) then PAGE.RunModal(POSMenuFilter."Object Id");
                    end else begin
                        if (FilterCount = 1) then PAGE.Run(POSMenuFilter."Object Id", FilterRecVariant);
                        if (FilterCount = 0) then PAGE.Run(POSMenuFilter."Object Id");
                    end;
                end;
            POSMenuFilter."Object Type"::Report:
                begin
                    if POSMenuFilter."Run Modal" then begin
                        if (FilterCount = 1) then REPORT.RunModal(POSMenuFilter."Object Id", false, false, FilterRecVariant);
                        if (FilterCount = 0) then REPORT.RunModal(POSMenuFilter."Object Id", false, false);
                    end else begin
                        ReportPrinterInterface.RunReport(POSMenuFilter."Object Id", false, false, FilterRecVariant);
                    end;
                end;
            POSMenuFilter."Object Type"::Codeunit:
                begin
                    POSMenuFilter.TestField("Run Modal", false);
                    if (FilterCount = 1) then CODEUNIT.Run(POSMenuFilter."Object Id", FilterRecVariant);
                    if (FilterCount = 0) then CODEUNIT.Run(POSMenuFilter."Object Id");
                end;
            POSMenuFilter."Object Type"::XMLPort:
                begin
                    POSMenuFilter.TestField("Run Modal", false);
                    if (FilterCount = 1) then XMLPORT.Run(POSMenuFilter."Object Id", false, false, FilterRecVariant);
                    if (FilterCount = 0) then XMLPORT.Run(POSMenuFilter."Object Id", false, false);
                end;
        end;
    end;

    local procedure SetPOSUnitFilter(TableNo: Integer; var FilterStringText: Text)
    var
        FilterRecRef: RecordRef;
        FilterRecVariant: Variant;
        POSEntry: Record "NPR POS Entry";
    begin

        FilterRecRef.Open(TableNo);
        if FilterStringText <> '' then FilterRecRef.SetView(FilterStringText);
        FilterRecVariant := FilterRecRef;

        case TableNo of
            DATABASE::"NPR POS Entry":
                begin
                    POSEntry.SetView(FilterRecRef.GetView());
                    POSEntry.CopyFilters(FilterRecVariant);
                    POSEntry.SetFilter("POS Unit No.", '=%1', GetPosUnitNo());
                    FilterStringText := POSEntry.GetView();
                end;
        end;
    end;

    local procedure GetPosUnitNo(): Code[10]
    var
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin

        if (POSSession.IsActiveSession(POSFrontEndManagement)) then begin
            POSFrontEndManagement.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            POSSetup.GetPOSUnit(POSUnit);
            exit(POSUnit."No.");
        end;

        exit('');
    end;
}
