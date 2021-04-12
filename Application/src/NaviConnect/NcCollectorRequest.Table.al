table 6151529 "NPR Nc Collector Request"
{
    // NC2.01\BR\20160909  CASE 250447 NaviConnect: Object created
    // NC2.16/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 220

    Caption = 'Nc Collector Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Direction; Option)
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
            OptionCaption = 'Incoming,Outgoing';
            OptionMembers = Incoming,Outgoing;
        }
        field(5; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "Collector Code"; Code[20])
        {
            Caption = 'Collector Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Collector";
        }
        field(30; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Processed,Rejected';
            OptionMembers = New,Processed,Rejected;
        }
        field(40; "Creation Date"; DateTime)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(50; "Processed Date"; DateTime)
        {
            Caption = 'Processed Date';
            DataClassification = CustomerContent;
        }
        field(100; "Database Name"; Text[250])
        {
            Caption = 'Database Name';
            DataClassification = CustomerContent;
        }
        field(120; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(130; "User ID"; Text[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(150; "Processing Comment"; Text[250])
        {
            Caption = 'Processing Comment';
            DataClassification = CustomerContent;
        }
        field(160; "External No."; BigInteger)
        {
            Caption = 'External No.';
            DataClassification = CustomerContent;
        }
        field(170; "Only New and Modified Records"; Boolean)
        {
            Caption = 'Only New and Modified Records';
            DataClassification = CustomerContent;
        }
        field(200; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Table No." <> xRec."Table No." then
                    Validate("Table View", '');
            end;
        }
        field(205; "Table View"; Text[250])
        {
            Caption = 'Table View';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                FilterPageBuild: FilterPageBuilder;
                RecRef: RecordRef;
            begin
                if "Table No." <> 0 then begin
                    RecRef.Open("Table No.");
                    FilterPageBuild.AddRecordRef(RecRef.Caption, RecRef);
                    if "Table View" <> '' then
                        FilterPageBuild.SetView(RecRef.Caption, "Table View");
                    FilterPageBuild.PageCaption := RecRef.Caption;
                    FilterPageBuild.RunModal();
                    Validate("Table View", FilterPageBuild.GetView(RecRef.Caption));
                end;
            end;

            trigger OnValidate()
            var
                RecRef: RecordRef;
                NcCollectorManagement: Codeunit "NPR Nc Collector Management";
            begin
                if ("Table View" <> '') and (IsTemporary = false) then begin
                    RecRef.Open("Table No.");
                    RecRef.SetView("Table View");
                    NcCollectorManagement.InsertFilterRecords(Rec, RecRef);
                end;
            end;
        }
        field(210; "Table Filter"; TableFilter)
        {
            Caption = 'Table Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TableFilter: Record "Table Filter";
                TableFilterPage: Page "Table Filter";
            begin
                TableFilter.FilterGroup(2);
                TableFilter.SetRange("Table Number", "Table No.");
                TableFilter.FilterGroup(0);
                TableFilterPage.SetTableView(TableFilter);
                TableFilterPage.SetSourceTable(Format("Table Filter"), "Table No.", '');
                if ACTION::OK = TableFilterPage.RunModal() then
                    Evaluate("Table Filter", TableFilterPage.CreateTextTableFilter(false));
            end;
        }
        field(220; "Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter";
    begin
        NcCollectorRequestFilter.SetRange("Nc Collector Request No.", "No.");
        NcCollectorRequestFilter.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        ActiveSession: Record "Active Session";
    begin
        "Creation Date" := CurrentDateTime;

        if "Database Name" = '' then begin
            ActiveSession.SetRange("Session ID", SessionId);
            if ActiveSession.FindFirst() then
                "Database Name" := CopyStr("Database Name", 1, MaxStrLen("Database Name"));
        end;

        if "User ID" = '' then
            "User ID" := CopyStr(UserId, 1, MaxStrLen("User ID"));
        if "Company Name" = '' then
            "Company Name" := CopyStr(CompanyName, 1, MaxStrLen("Company Name"));
    end;

    trigger OnModify()
    begin
        case Status of
            Status::Processed:
                "Processed Date" := CurrentDateTime;
            Status::Rejected:
                if "Processed Date" = 0DT then
                    "Processed Date" := CurrentDateTime;
        end;
    end;

    procedure ProcessRequest()
    begin
        if Status in [Status::New, Status::Rejected] then begin
            if CreateCollectionLines then
                Validate(Status, Status::Processed)
            else
                Validate(Status, Status::Rejected);
        end;
        Modify(true);
    end;

    local procedure CreateFilterLinesFromFilterText()
    begin
    end;

    procedure CreateFilterTextFromFilterLines()
    var
        NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        "Table No." := 0;
        NcCollectorRequestFilter.Reset();
        NcCollectorRequestFilter.SetRange("Nc Collector Request No.", "No.");
        if NcCollectorRequestFilter.IsEmpty then
            exit;
        if NcCollectorRequestFilter.FindFirst() then
            repeat
                //If there are mutiple tables in the filter, then it can't be stored in the Table Filter field on the query
                if ("Table No." <> 0) and ("Table No." <> NcCollectorRequestFilter."Table No.") then begin
                    "Table No." := 0;
                    Evaluate("Table Filter", '');
                    exit;
                end;
                if "Table No." = 0 then begin
                    "Table No." := NcCollectorRequestFilter."Table No.";
                    RecRef.Open("Table No.");
                end;
                if NcCollectorRequestFilter."Field No." <> 0 then begin
                    FldRef := RecRef.Field(NcCollectorRequestFilter."Field No.");
                    FldRef.SetFilter(NcCollectorRequestFilter."Filter Text");
                end;
            until NcCollectorRequestFilter.Next() = 0;
        if StrLen(RecRef.GetView) <= MaxStrLen("Table View") then begin
            "Table View" := RecRef.GetView;
        end else begin
            "Table No." := 0;
            "Table View" := '';
        end;
    end;

    procedure CreateCollectionLines(): Boolean
    var
        NcCollector: Record "NPR Nc Collector";
        NcCollectorFilter: Record "NPR Nc Collector Filter";
        NcCollectionLine: Record "NPR Nc Collection Line";
        NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter";
        NcCollectorManagement: Codeunit "NPR Nc Collector Management";
        RecRef: RecordRef;
        FldRef: FieldRef;
        TextNotInserted: Label 'The Collector Request must be inserted into the database before it can be processed.';
        TextNoCollectorFound: Label 'The Collector could not be found for this Collector Request.';
        TextNotActive: Label 'The Collector is not active.';
        TextNoRecords: Label 'There are no records within the filters to request.';
        TextCollectionLinesInserted: Label '%1 records inserted as Collection Lines.';
        NoOfRecords: Integer;
        TextResultTooLarge: Label 'The Request results in %1 Collection Lines. The maximum for this Collector is %2. ';
        TextNotAuthorised: Label '%1 in the Request must be %2.';
    begin
        if not (Direction = Direction::Incoming) then
            exit(false);

        if "No." = 0 then begin
            "Processing Comment" := TextNotInserted;
            exit(false);
        end;

        if "Collector Code" = '' then
            "Collector Code" := FindCollector(0);
        if "Collector Code" = '' then
            "Collector Code" := FindCollector(1);

        if (not NcCollector.Get("Collector Code")) or ("Collector Code" = '') then begin
            "Processing Comment" := TextNoCollectorFound;
            exit(false);
        end;

        if not NcCollector.Active then begin
            "Processing Comment" := TextNotActive;
            exit(false);
        end;

        if (NcCollector."Allow Request from Company" <> '') and (NcCollector."Allow Request from Company" <> "Company Name") then begin
            "Processing Comment" := StrSubstNo(TextNotAuthorised, FieldCaption("Company Name"), NcCollector."Allow Request from Company");
            exit(false);
        end;

        if (NcCollector."Allow Request from Database" <> '') and (NcCollector."Allow Request from Database" <> "Database Name") then begin
            "Processing Comment" := StrSubstNo(TextNotAuthorised, FieldCaption("Database Name"), NcCollector."Allow Request from Database");
            exit(false);
        end;

        if (NcCollector."Allow Request from User ID" <> '') and (NcCollector."Allow Request from User ID" <> "User ID") then begin
            "Processing Comment" := StrSubstNo(TextNotAuthorised, FieldCaption("User ID"), NcCollector."Allow Request from User ID");
            exit(false);
        end;

        RecRef.Open(NcCollector."Table No.");
        //Set the Request filters
        RecRef.FilterGroup(0);
        NcCollectorRequestFilter.Reset();
        NcCollectorRequestFilter.SetRange("Nc Collector Request No.", "No.");
        if NcCollectorRequestFilter.FindSet() then
            repeat
                if NcCollectorRequestFilter."Field No." <> 0 then begin
                    FldRef := RecRef.Field(NcCollectorRequestFilter."Field No.");
                    FldRef.SetFilter(NcCollectorRequestFilter."Filter Text");
                end;
            until NcCollectorRequestFilter.Next() = 0;

        //Set the Collector filters
        RecRef.FilterGroup(1);
        NcCollectorFilter.Reset();
        NcCollectorFilter.SetRange("Collector Code", NcCollector.Code);
        if NcCollectorFilter.FindSet() then
            repeat
                if NcCollectorFilter."Field No." <> 0 then begin
                    FldRef := RecRef.Field(NcCollectorFilter."Field No.");
                    FldRef.SetFilter(NcCollectorFilter."Filter Text");
                end;
            until NcCollectorFilter.Next() = 0;

        NoOfRecords := RecRef.Count();

        if NoOfRecords = 0 then begin
            "Processing Comment" := TextNoRecords;
            exit(false);
        end;

        if (NoOfRecords > NcCollector."Max. Lines per Request") and (NcCollector."Max. Lines per Request" > 0) then begin
            "Processing Comment" := StrSubstNo(TextResultTooLarge, NoOfRecords, NcCollector."Max. Lines per Request");
            exit(false);
        end;

        if RecRef.FindFirst() then
            repeat
                NcCollectionLine.Init();
                NcCollectionLine."No." := 0;
                NcCollectionLine."Collector Code" := NcCollector.Code;
                NcCollectionLine."Collection No." := NcCollectorManagement.GetNcCollectionNo(NcCollector.Code);
                NcCollectionLine."Type of Change" := NcCollectionLine."Type of Change"::Modify;
                NcCollectionLine."Record Position" := RecRef.GetPosition(false);
                NcCollectionLine."Table No." := RecRef.Number;
                NcCollectionLine."Data log Record No." := 0;
                NcCollectionLine."Request No." := "No.";
                NcCollectorManagement.PopulatePKFields(NcCollectionLine, RecRef);
                NcCollectionLine.Insert(true);
                NcCollectorManagement.MarkPreviousCollectionLinesAsObsolete(NcCollectionLine);
            until RecRef.Next() = 0;
        "Processing Comment" := StrSubstNo(TextCollectionLinesInserted, NoOfRecords);
        exit(true);
    end;

    local procedure FindCollector(Matching: Option ByName,ByTableID): Code[20]
    var
        NcCollector: Record "NPR Nc Collector";
    begin
        if "Collector Code" <> '' then
            exit;

        NcCollector.Reset();
        case Matching of
            Matching::ByName:
                NcCollector.SetFilter("Request Name", '=%1', Name);
            Matching::ByTableID:
                NcCollector.SetFilter("Table No.", '=%1', "Table No.");
        end;
        NcCollector.SetFilter("Allow Request from Database", '=%1', "Database Name");
        NcCollector.SetFilter("Allow Request from Company", '=%1', "Company Name");
        NcCollector.SetFilter("Allow Request from User ID", '=%1', "User ID");
        if NcCollector.FindFirst() then
            //Database, Company and user match
            exit(NcCollector.Code);

        NcCollector.SetFilter("Allow Request from User ID", '=%1', '');
        if NcCollector.FindFirst() then
            //Database and Company match, username blank
            exit(NcCollector.Code);

        NcCollector.SetFilter("Allow Request from Company", '=%1', '');
        NcCollector.SetFilter("Allow Request from User ID", '=%1', "User ID");
        if NcCollector.FindFirst() then
            //Database and User ID match, Company blank
            exit(NcCollector.Code);

        NcCollector.SetFilter("Allow Request from Database", '=%1', '');
        NcCollector.SetFilter("Allow Request from Company", '=%1', "Company Name");
        if NcCollector.FindFirst() then
            //Company and User ID match, database blank
            exit(NcCollector.Code);

        NcCollector.SetFilter("Allow Request from User ID", '=%1', '');
        NcCollector.SetFilter("Allow Request from Company", '=%1', "Company Name");
        if NcCollector.FindFirst() then
            //Company match, User ID and database blank
            exit(NcCollector.Code);

        NcCollector.SetFilter("Allow Request from Company", '=%1', '');
        NcCollector.SetFilter("Allow Request from Database", '=%1', "Database Name");
        if NcCollector.FindFirst() then
            //Database match, User ID and company blank
            exit(NcCollector.Code);

        NcCollector.SetFilter("Allow Request from Database", '=%1', '');
        NcCollector.SetFilter("Allow Request from User ID", '=%1', "User ID");
        if NcCollector.FindFirst() then
            //User ID match, Database and company blank
            exit(NcCollector.Code);

        NcCollector.SetFilter("Allow Request from User ID", '=%1', '');
        if NcCollector.FindFirst() then
            //User ID, Database and company blank
            exit(NcCollector.Code);

        exit('');
    end;
}

