table 6014678 "NPR Endpoint Query"
{
    // NPR5.25/BR  /20160801  CASE 234602 Object created
    // NPR5.38/MHA /20180104  CASE 301054 Corrected Calcformula for field 220 "Table Name"
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj field 220

    Caption = 'Endpoint Query';
    DrillDownPageID = "NPR Endpoint Query List";
    LookupPageID = "NPR Endpoint Query List";
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
            OptionCaption = 'Incoming,Outgoing';
            OptionMembers = Incoming,Outgoing;
            DataClassification = CustomerContent;
        }
        field(5; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "Endpoint Code"; Code[20])
        {
            Caption = 'Endpoint Code';
            TableRelation = "NPR Endpoint";
            DataClassification = CustomerContent;
        }
        field(30; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'New,Processed,Rejected';
            OptionMembers = New,Processed,Rejected;
            DataClassification = CustomerContent;
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
                    FilterPageBuild.RunModal;
                    Validate("Table View", FilterPageBuild.GetView(RecRef.Caption));
                end;
            end;

            trigger OnValidate()
            var
                RecRef: RecordRef;
                EndpointManagement: Codeunit "NPR Endpoint Management";
            begin
                if ("Table View" <> '') and (IsTemporary = false) then begin
                    RecRef.Open("Table No.");
                    RecRef.SetView("Table View");
                    EndpointManagement.InsertFilterRecords(Rec, RecRef);
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
                if ACTION::OK = TableFilterPage.RunModal then
                    Evaluate("Table Filter", TableFilterPage.CreateTextTableFilter(false));
            end;
        }
        field(220; "Table Name"; Text[30])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Description = 'NPR5.38';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Endpoint Code", Status)
        {
        }
        key(Key3; "Endpoint Code", "No.")
        {
        }
        key(Key4; Direction, "No.")
        {
        }
        key(Key5; Direction, Status)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        EndpointRequest: Record "NPR Endpoint Request";
        EndpointQueryFilter: Record "NPR Endpoint Query Filter";
    begin
        EndpointQueryFilter.SetRange("Endpoint Query No.", "No.");
        DeleteAll(true);
    end;

    trigger OnInsert()
    var
        ActiveSession: Record "Active Session";
    begin
        "Creation Date" := CurrentDateTime;

        if "Database Name" = '' then begin
            ActiveSession.SetRange("Session ID", SessionId);
            if ActiveSession.FindFirst then
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

    procedure ProcessQuery()
    begin
        if Status in [Status::New, Status::Rejected] then begin
            if CreateEndpointRequests then
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
        EndpointQueryFilter: Record "NPR Endpoint Query Filter";
        LastTableNo: Integer;
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        "Table No." := 0;
        EndpointQueryFilter.Reset;
        EndpointQueryFilter.SetRange("Endpoint Query No.", "No.");
        if EndpointQueryFilter.IsEmpty then
            exit;
        if EndpointQueryFilter.FindFirst then
            repeat
                //If there are mutiple tables in the filter, then it can't be stored in the Table Filter field on the query
                if ("Table No." <> 0) and ("Table No." <> EndpointQueryFilter."Table No.") then begin
                    "Table No." := 0;
                    Evaluate("Table Filter", '');
                    exit;
                end;
                if "Table No." = 0 then begin
                    "Table No." := EndpointQueryFilter."Table No.";
                    RecRef.Open("Table No.");
                end;
                if EndpointQueryFilter."Field No." <> 0 then begin
                    FldRef := RecRef.Field(EndpointQueryFilter."Field No.");
                    FldRef.SetFilter(EndpointQueryFilter."Filter Text");
                end;
            until EndpointQueryFilter.Next = 0;
        if StrLen(RecRef.GetView) <= MaxStrLen("Table View") then begin
            "Table View" := RecRef.GetView
        end else begin
            "Table No." := 0;
            "Table View" := '';
        end;
    end;

    procedure CreateEndpointRequests(): Boolean
    var
        Endpoint: Record "NPR Endpoint";
        EndpointQueryFilter: Record "NPR Endpoint Query Filter";
        EndpointFilter: Record "NPR Endpoint Filter";
        EndpointRequest: Record "NPR Endpoint Request";
        EndpointManagement: Codeunit "NPR Endpoint Management";
        RecRef: RecordRef;
        FldRef: FieldRef;
        TextNotInserted: Label 'The Endpoint Query must be inserted into the database before it can be processed.';
        TextNoEndpointFound: Label 'The Endpoint could not be found for this Endpoint Query.';
        TextNotActive: Label 'The Endpoint is not active.';
        TextNoRecords: Label 'There are no records within the filters to request.';
        TextRequestsInserted: Label '%1 records inserted as Endpoint Request.';
        NoOfRecords: Integer;
        TextResultTooLarge: Label 'The query results in %1 records. The maximum for this Endpoint is %2. ';
        TextNotAuthorised: Label '%1 in the Query must be %2.';
    begin
        if not (Direction = Direction::Incoming) then
            exit(false);

        if "No." = 0 then begin
            "Processing Comment" := TextNotInserted;
            exit(false);
        end;

        if "Endpoint Code" = '' then
            "Endpoint Code" := FindEndpoint(0);
        if "Endpoint Code" = '' then
            "Endpoint Code" := FindEndpoint(1);

        if (not Endpoint.Get("Endpoint Code")) or ("Endpoint Code" = '') then begin
            "Processing Comment" := TextNoEndpointFound;
            exit(false);
        end;

        if not Endpoint.Active then begin
            "Processing Comment" := TextNotActive;
            exit(false);
        end;

        if (Endpoint."Allow Query from Company Name" <> '') and (Endpoint."Allow Query from Company Name" <> "Company Name") then begin
            "Processing Comment" := StrSubstNo(TextNotAuthorised, FieldCaption("Company Name"), Endpoint."Allow Query from Company Name");
            exit(false);
        end;

        if (Endpoint."Allow Query from Database" <> '') and (Endpoint."Allow Query from Database" <> "Database Name") then begin
            "Processing Comment" := StrSubstNo(TextNotAuthorised, FieldCaption("Database Name"), Endpoint."Allow Query from Database");
            exit(false);
        end;

        if (Endpoint."Allow Query from User ID" <> '') and (Endpoint."Allow Query from User ID" <> "User ID") then begin
            "Processing Comment" := StrSubstNo(TextNotAuthorised, FieldCaption("User ID"), Endpoint."Allow Query from User ID");
            exit(false);
        end;

        RecRef.Open(Endpoint."Table No.");
        //Set the Query filters
        RecRef.FilterGroup(0);
        EndpointQueryFilter.Reset;
        EndpointQueryFilter.SetRange("Endpoint Query No.", "No.");
        if EndpointQueryFilter.FindSet then
            repeat
                if EndpointQueryFilter."Field No." <> 0 then begin
                    FldRef := RecRef.Field(EndpointQueryFilter."Field No.");
                    FldRef.SetFilter(EndpointQueryFilter."Filter Text");
                end;
            until EndpointQueryFilter.Next = 0;

        //Set the Endpoint filters
        RecRef.FilterGroup(1);
        EndpointFilter.Reset;
        EndpointFilter.SetRange("Endpoint Code", Endpoint.Code);
        if EndpointQueryFilter.FindSet then
            repeat
                if EndpointQueryFilter."Field No." <> 0 then begin
                    FldRef := RecRef.Field(EndpointQueryFilter."Field No.");
                    FldRef.SetFilter(EndpointQueryFilter."Filter Text");
                end;
            until EndpointQueryFilter.Next = 0;

        NoOfRecords := RecRef.Count;

        if NoOfRecords = 0 then begin
            "Processing Comment" := TextNoRecords;
            exit(false);
        end;

        if (NoOfRecords > Endpoint."Max. Requests per Query") and (Endpoint."Max. Requests per Query" > 0) then begin
            "Processing Comment" := StrSubstNo(TextResultTooLarge, NoOfRecords, Endpoint."Max. Requests per Query");
            exit(false);
        end;

        if RecRef.FindFirst then
            repeat
                EndpointRequest.Init;
                EndpointRequest."No." := 0;
                EndpointRequest."Endpoint Code" := Endpoint.Code;
                EndpointRequest."Request Batch No." := EndpointManagement.GetEndpointRequestBatchNo(Endpoint.Code);
                EndpointRequest."Type of Change" := EndpointRequest."Type of Change"::Modify;
                EndpointRequest."Record Position" := RecRef.GetPosition(false);
                EndpointRequest."Table No." := RecRef.Number;
                EndpointRequest."Data log Record No." := 0;
                EndpointRequest."Query No." := "No.";
                EndpointManagement.PopulatePKFields(EndpointRequest, RecRef);
                EndpointRequest.Insert(true);
                EndpointManagement.MarkPreviousRequestsAsObsolete(EndpointRequest);
            until RecRef.Next = 0;
        "Processing Comment" := StrSubstNo(TextRequestsInserted, NoOfRecords);
        exit(true);
    end;

    local procedure FindEndpoint(Matching: Option ByName,ByTableID): Code[20]
    var
        Endpoint: Record "NPR Endpoint";
    begin
        if "Endpoint Code" <> '' then
            exit;

        Endpoint.Reset;
        case Matching of
            Matching::ByName:
                Endpoint.SetFilter("Query Name", '=%1', Name);
            Matching::ByTableID:
                Endpoint.SetFilter("Table No.", '=%1', "Table No.");
        end;
        Endpoint.SetFilter("Allow Query from Database", '=%1', "Database Name");
        Endpoint.SetFilter("Allow Query from Company Name", '=%1', "Company Name");
        Endpoint.SetFilter("Allow Query from User ID", '=%1', "User ID");
        if Endpoint.FindFirst then
            //Database, Company and user match
            exit(Endpoint.Code);

        Endpoint.SetFilter("Allow Query from User ID", '=%1', '');
        if Endpoint.FindFirst then
            //Database and Company match, username blank
            exit(Endpoint.Code);

        Endpoint.SetFilter("Allow Query from Company Name", '=%1', '');
        Endpoint.SetFilter("Allow Query from User ID", '=%1', "User ID");
        if Endpoint.FindFirst then
            //Database and User ID match, Company blank
            exit(Endpoint.Code);

        Endpoint.SetFilter("Allow Query from Database", '=%1', '');
        Endpoint.SetFilter("Allow Query from Company Name", '=%1', "Company Name");
        if Endpoint.FindFirst then
            //Company and User ID match, database blank
            exit(Endpoint.Code);

        Endpoint.SetFilter("Allow Query from User ID", '=%1', '');
        Endpoint.SetFilter("Allow Query from Company Name", '=%1', "Company Name");
        if Endpoint.FindFirst then
            //Company match, User ID and database blank
            exit(Endpoint.Code);

        Endpoint.SetFilter("Allow Query from Company Name", '=%1', '');
        Endpoint.SetFilter("Allow Query from Database", '=%1', "Database Name");
        if Endpoint.FindFirst then
            //Database match, User ID and company blank
            exit(Endpoint.Code);

        Endpoint.SetFilter("Allow Query from Database", '=%1', '');
        Endpoint.SetFilter("Allow Query from User ID", '=%1', "User ID");
        if Endpoint.FindFirst then
            //User ID match, Database and company blank
            exit(Endpoint.Code);

        Endpoint.SetFilter("Allow Query from User ID", '=%1', '');
        if Endpoint.FindFirst then
            //User ID, Database and company blank
            exit(Endpoint.Code);

        exit('');
    end;
}

