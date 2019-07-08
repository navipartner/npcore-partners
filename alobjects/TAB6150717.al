table 6150717 "POS Menu Filter"
{
    // NPR5.33/ANEN  /20170607 CASE 270854 Object created to support function for filtererd menu buttons in transcendance pos.
    // NPR5.41/TSA /20180417 CASE 310137 Added field "Current Register / POS Unit", function SetPOSUnitFilter()
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -fields 5,10,11
    // NPR5.48/TJ  /20181112  CASE 335629 Fixed the issue with wrong Object Name display

    Caption = 'POS Menu Filter';
    LookupPageID = "POS Menu Filter List";

    fields
    {
        field(1;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',,,Report,,Codeunit,XMLPort,,Page';
            OptionMembers = ,,,"Report",,"Codeunit","XMLPort",,"Page";
        }
        field(2;"Object Id";Integer)
        {
            Caption = 'Object Id';
        }
        field(3;"Filter Code";Code[20])
        {
            Caption = 'Filter Code';
            Description = 'Key';
        }
        field(5;"Object Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=FIELD("Object Type"),
                                                             "Object ID"=FIELD("Object Id")));
            Caption = 'Object Name';
            FieldClass = FlowField;
        }
        field(6;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(7;Active;Boolean)
        {
            Caption = 'Active';
        }
        field(8;"Send Sale POS";Boolean)
        {
            Caption = 'Send Sale POS';

            trigger OnValidate()
            begin
                "Send Sale Line POS" := false;
                "Table No." := 0;
                Clear("Table Filter");
            end;
        }
        field(9;"Send Sale Line POS";Boolean)
        {
            Caption = 'Send Sale Line POS';

            trigger OnValidate()
            begin
                "Send Sale POS" := false;
                "Table No." := 0;
                Clear("Table Filter");
            end;
        }
        field(10;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
            ValidateTableRelation = true;

            trigger OnValidate()
            begin
                "Send Sale Line POS" := false;
                "Send Sale POS" := false;
                if "Table No." <> xRec."Table No." then Clear("Table Filter");
            end;
        }
        field(11;"Table Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Table No.")));
            Caption = 'Table Name';
            FieldClass = FlowField;
        }
        field(12;"Table Filter";BLOB)
        {
            Caption = 'Table Filter';
        }
        field(13;"Sale POS Filter";BLOB)
        {
            Caption = 'Sale POS Filter';
        }
        field(14;"Sale Line POS Filter";BLOB)
        {
            Caption = 'Sale Line POS Filter';
        }
        field(15;"Run Modal";Boolean)
        {
            Caption = 'Run Modal';
        }
        field(20;"Current POS Register / Unit";Boolean)
        {
            Caption = 'Current POS Register / Unit';
        }
    }

    keys
    {
        key(Key1;"Filter Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ERRNOFILTER: Label 'No filter to activate.';
        ERRONLYONE: Label 'Only one record can be used when Object Type is Report.';

    procedure ActivateFilter()
    var
        POSSession: Codeunit "POS Session";
        FilterCount: Integer;
    begin
        FilterCount := 0;
        if ( "Send Sale POS" ) then FilterCount += 1;
        if ( "Send Sale Line POS" ) then FilterCount += 1;
        if ("Table No." <> 0) then FilterCount += 1;
        if FilterCount > 1 then Error(ERRONLYONE);

        Active := true;

        RunObjectWithFilter(Rec, POSSession);

        Modify;
    end;

    procedure DeActivateFilter()
    begin
        Active := false;
        Modify;
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
        if Rec."Table Filter".HasValue then begin
          Rec."Table Filter".CreateInStream(INS);
          INS.Read(FilterStringText);
        end;

        Rec.TestField("Table No.");
        MailRecordRef.Open(Rec."Table No.");
        FilterViewName := MailRecordRef.Name;
        FilterBuilder.AddRecordRef(FilterViewName, MailRecordRef);
        if FilterStringText <> '' then FilterBuilder.SetView(FilterViewName, FilterStringText);
        if FilterBuilder.RunModal then begin
          FilterStringText := FilterBuilder.GetView(FilterViewName);
        end;

        Rec."Table Filter".CreateOutStream(OUTS);
        OUTS.Write(FilterStringText);
        Rec.Modify;
    end;

    procedure RunObjectWithFilter(POSMenuFilter: Record "POS Menu Filter";POSSession: Codeunit "POS Session")
    var
        FilterRecRef: RecordRef;
        FilterStringText: Text;
        DataTypeManagement: Codeunit "Data Type Management";
        INS: InStream;
        FilterRecVariant: Variant;
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        ReportPrinterInterface: Codeunit "Report Printer Interface";
        FilterCount: Integer;
    begin
        POSMenuFilter.TestField(Active, true);

        FilterCount := 0;
        if ( "Send Sale POS" ) then FilterCount += 1;
        if ( "Send Sale Line POS" ) then FilterCount += 1;
        if ("Table No." <> 0) then FilterCount += 1;
        if FilterCount > 1 then Error(ERRONLYONE);

        if FilterCount = 1 then begin
          if ("Table No." <> 0) then begin
            FilterRecRef.Open(POSMenuFilter."Table No.");

            POSMenuFilter.CalcFields("Table Filter");
            if POSMenuFilter."Table Filter".HasValue then begin
              POSMenuFilter."Table Filter".CreateInStream(INS);
              INS.Read(FilterStringText);
            end;

            //-NPR5.41 [310137]
            if ("Current POS Register / Unit") then
              SetPOSUnitFilter ("Table No.", FilterStringText);
            //+NPR5.41 [310137]

            if FilterStringText <> '' then FilterRecRef.SetView(FilterStringText);
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
          POSMenuFilter."Object Type"::Page : begin
            if POSMenuFilter."Run Modal" then begin
              if (FilterCount = 1) then PAGE.RunModal(POSMenuFilter."Object Id", FilterRecVariant);
              if (FilterCount = 0) then PAGE.RunModal(POSMenuFilter."Object Id");
            end else begin
              if (FilterCount = 1) then PAGE.Run(POSMenuFilter."Object Id", FilterRecVariant);
              if (FilterCount = 0) then PAGE.Run(POSMenuFilter."Object Id");
            end;
          end;
          POSMenuFilter."Object Type"::Report : begin
            if POSMenuFilter."Run Modal" then begin
              if (FilterCount = 1) then REPORT.RunModal(POSMenuFilter."Object Id", false, false, FilterRecVariant);
              if (FilterCount = 0) then REPORT.RunModal(POSMenuFilter."Object Id", false, false);
            end else begin
              ReportPrinterInterface.RunReport(POSMenuFilter."Object Id", false, false, FilterRecVariant);
            end;
          end;
          POSMenuFilter."Object Type"::Codeunit : begin
            POSMenuFilter.TestField("Run Modal", false);
            if (FilterCount = 1) then CODEUNIT.Run(POSMenuFilter."Object Id", FilterRecVariant);
            if (FilterCount = 0) then CODEUNIT.Run(POSMenuFilter."Object Id");
          end;
          POSMenuFilter."Object Type"::XMLPort : begin
            POSMenuFilter.TestField("Run Modal", false);
            if (FilterCount = 1) then XMLPORT.Run(POSMenuFilter."Object Id", false, false, FilterRecVariant);
            if (FilterCount = 0) then XMLPORT.Run(POSMenuFilter."Object Id", false, false);
          end;
        end;
    end;

    local procedure SetPOSUnitFilter(TableNo: Integer;var FilterStringText: Text)
    var
        FilterRecRef: RecordRef;
        FilterRecVariant: Variant;
        AuditRoll: Record "Audit Roll";
        POSEntry: Record "POS Entry";
        FilterValue: Code[10];
    begin

        FilterRecRef.Open (TableNo);
        if FilterStringText <> '' then FilterRecRef.SetView(FilterStringText);
          FilterRecVariant := FilterRecRef;

        case TableNo of
          DATABASE::"Audit Roll" :
            begin
              AuditRoll.CopyFilters (FilterRecVariant);
              AuditRoll.SetFilter ("Register No.", '=%1', GetRegisterNo ());
              FilterStringText := AuditRoll.GetView ();
            end;
          DATABASE::"POS Entry" :
            begin
              POSEntry.CopyFilters (FilterRecVariant);
              POSEntry.SetFilter ("POS Unit No.", '=%1', GetPosUnitNo ());
              FilterStringText := POSEntry.GetView ();
            end;
        end;
    end;

    local procedure GetRegisterNo() RegisterNo: Code[10]
    var
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        POSSetup: Codeunit "POS Setup";
    begin

        if (POSSession.IsActiveSession (POSFrontEndManagement)) then begin
          POSFrontEndManagement.GetSession (POSSession);
          POSSession.GetSetup (POSSetup);
          exit (POSSetup.Register());
        end;

        exit ('');
    end;

    local procedure GetPosUnitNo(): Code[10]
    var
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        POSSetup: Codeunit "POS Setup";
        POSUnit: Record "POS Unit";
    begin

        if (POSSession.IsActiveSession (POSFrontEndManagement)) then begin
          POSFrontEndManagement.GetSession (POSSession);
          POSSession.GetSetup (POSSetup);
          POSSetup.GetPOSUnit (POSUnit);
          exit (POSUnit."No.");
        end;

        exit ('');
    end;

    local procedure GetStoreCode(): Code[10]
    var
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        POSSetup: Codeunit "POS Setup";
        POSStore: Record "POS Store";
    begin

        if (POSSession.IsActiveSession (POSFrontEndManagement)) then begin
          POSFrontEndManagement.GetSession (POSSession);
          POSSession.GetSetup (POSSetup);
          POSSetup.GetPOSStore (POSStore);
          exit (POSStore.Code);
        end;

        exit ('');
    end;
}

