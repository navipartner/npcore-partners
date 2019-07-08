table 6150613 "NP Retail Setup"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.31/MMV /20170403 CASE 263473 Added environment fields 20000 - 20005
    // NPR5.32/AP  /20170426 CASE 262628 Added Field 10010 to activate and de-activate Poseidon POS Entries
    // NPR5.32/AP  /20170501 CASE 274285 Possible to re-run Build Steps. Better visibilty for log entries.
    // NPR5.33/AP  /20170426 CASE 262628 Trigger upgrade CUs when activating Poseidon POS Entries
    // NPR5.36/BR  /20170727 Case 279552 Added Default No. Series
    // NPR5.36/BR  /20170907 CASE 277103 Added fields Max. POS Posting Diff. (LCY) and POS Posting Diff. Account
    // NPR5.36/BR  /20170918 CASE 277103 Added field Poseidon Posting Activated
    // NPR5.37/BR  /20170910 CASE 292364 Changed "Poseidon" Names and Captions to Advanced Posting
    // NPR5.38/BR  /20180105 CASE 294723 Added Fields Automatic Item Posting, Automatic POS Posting, Automatic Posting Method
    // NPR5.38/CLVA/20180124 CASE 293179 Added field Enable Client Diagnostics
    // NPR5.39/BR  /20180215 CASE 305016 Added field Fiscal No. Series
    // NPR5.40/MMV /20180316 CASE 308457 Renamed field 150 and added field 151, 160
    // NPR5.40/MHA /20180328 CASE 308907 Added InitValue = 1 to field 30000 "Enable Client Diagnostics"
    // NPR5.42/TSA /20180502 CASE 312104 "Allow Zero Amount Sales" to allow cash-back on non-sales.
    // NPR5.45/MHA /20180803 CASE 323705 Added fields 300, 305, 310 to enable overload of Item Price functionality
    // NPR5.50/MHA /20190422 CASE 337539 Added field 400 "Global POS Sales Setup"

    Caption = 'NP Retail Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Source Code";Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(100;"Default POS Entry No. Series";Code[10])
        {
            Caption = 'Default POS Entry No. Series';
            TableRelation = "No. Series";
        }
        field(140;"Max. POS Posting Diff. (LCY)";Decimal)
        {
            Caption = 'Max. POS Posting Diff. (LCY)';
            Description = 'NPR5.36';
        }
        field(141;"POS Posting Diff. Account";Code[20])
        {
            Caption = 'Differences Account';
            Description = 'NPR5.36';
            TableRelation = "G/L Account";
        }
        field(150;"Sale Fiscal No. Series";Code[10])
        {
            Caption = 'Sale Fiscal No. Series';
            Description = 'NPR5.39';
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeries: Record "No. Series";
            begin
                //-NPR5.39 [305016]
                if "Sale Fiscal No. Series" <> '' then begin
                  NoSeries.Get("Sale Fiscal No. Series");
                  NoSeries.TestField("Default Nos.",true);
                end;
                //+NPR5.39 [305016]
            end;
        }
        field(151;"Balancing Fiscal No. Series";Code[10])
        {
            Caption = 'Balancing Fiscal No. Series';
            Description = 'NPR5.40';
            TableRelation = "No. Series";
        }
        field(160;"Fill Sale Fiscal No. On";Option)
        {
            Caption = 'Fill Sale Fiscal No. On';
            Description = 'NPR5.40';
            OptionCaption = 'All Sales,Successful Sales';
            OptionMembers = All,Successful;
        }
        field(200;"Allow Zero Amount Sales";Boolean)
        {
            Caption = 'Allow Zero Amount Sales';
            Description = 'NPR5.42 [312104]';
        }
        field(300;"Item Price Codeunit ID";Integer)
        {
            BlankZero = true;
            Caption = 'Item Price Codeunit ID';
            Description = 'NPR5.45';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.45 [323705]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetPublisherFunction());
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Item Price Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Item Price Function" := EventSubscription."Subscriber Function";
                //+NPR5.45 [323705]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.45 [323705]
                if "Item Price Codeunit ID" = 0 then begin
                  "Item Price Function" := '';
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetPublisherFunction());
                EventSubscription.SetRange("Subscriber Codeunit ID","Item Price Codeunit ID");
                if "Item Price Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Item Price Function");
                EventSubscription.FindFirst;
                //+NPR5.45 [323705]
            end;
        }
        field(305;"Item Price Codeunit Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Item Price Codeunit ID")));
            Caption = 'Item Price Codeunit Name';
            Description = 'NPR5.45';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310;"Item Price Function";Text[250])
        {
            Caption = 'Item Price Function';
            Description = 'NPR5.45';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.45 [323705]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetPublisherFunction());
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Item Price Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Item Price Function" := EventSubscription."Subscriber Function";
                //+NPR5.45 [323705]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.45 [323705]
                if "Item Price Function" = '' then begin
                  "Item Price Codeunit ID" := 0;
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetPublisherFunction());
                EventSubscription.SetRange("Subscriber Codeunit ID","Item Price Codeunit ID");
                if "Item Price Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Item Price Function");
                EventSubscription.FindFirst;
                //+NPR5.45 [323705]
            end;
        }
        field(400;"Global POS Sales Setup";Code[10])
        {
            Caption = 'Global POS Sales Setup';
            Description = 'NPR5.50';
            TableRelation = "NpGp POS Sales Setup";
        }
        field(10000;"Data Model Build";Integer)
        {
            Caption = 'Data Model Build';
        }
        field(10001;"Last Data Model Build Upgrade";DateTime)
        {
            Caption = 'Last Data Model Build Upgrade';
        }
        field(10002;"Last Data Model Build User ID";Code[50])
        {
            Caption = 'Last Data Model Build User ID';
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("Last Data Model Build User ID");
            end;
        }
        field(10003;"Prev. Data Model Build";Integer)
        {
            Caption = 'Prev. Data Model Build';
        }
        field(10010;"Advanced POS Entries Activated";Boolean)
        {
            Caption = 'Advanced POS Entries Activated';
            Description = 'NPR5.32';

            trigger OnValidate()
            var
                RetailDataModelARUpgrade: Codeunit "Retail Data Model AR Upgrade";
            begin
                //-NPR5.33
                if "Advanced POS Entries Activated" then
                  RetailDataModelARUpgrade.ActivatePoseidonPOSEntries
                else
                  RetailDataModelARUpgrade.DeactivatePoseidonPOSEntries;
                //+NPR5.33
            end;
        }
        field(10020;"Advanced Posting Activated";Boolean)
        {
            Caption = 'Advanced Posting Activated';
            Description = 'NPR5.36';

            trigger OnValidate()
            var
                RetailDataModelARUpgrade: Codeunit "Retail Data Model AR Upgrade";
            begin
                //-NPR5.36 [277103]
                if "Advanced Posting Activated" then
                  RetailDataModelARUpgrade.ActivatePoseidonPosting
                else
                  RetailDataModelARUpgrade.DeactivatePoseidonPosting;
                //+NPR5.36 [277103]
            end;
        }
        field(10030;"Automatic Item Posting";Option)
        {
            Caption = 'Automatic Item Posting';
            Description = 'NPR5.38';
            OptionCaption = 'No,After Sale,After End Of Day,After Last End Of Day in Store,After Last End Of Day Companywide';
            OptionMembers = No,AfterSale,AfterEndOfDay,AfterLastEndofDayStore,AfterLastEndofDayCompany;
        }
        field(10032;"Automatic POS Posting";Option)
        {
            Caption = 'Automatic POS Posting';
            Description = 'NPR5.38';
            OptionCaption = 'No,After Sale,After End Of Day,After Last End Of Day in Store,After Last End Of Day Companywide';
            OptionMembers = No,AfterSale,AfterEndOfDay,AfterLastEndofDayStore,AfterLastEndofDayCompany;
        }
        field(10033;"Automatic Posting Method";Option)
        {
            Caption = 'Automatic Posting Method';
            Description = 'NPR5.38';
            OptionCaption = 'Start New Session,Direct';
            OptionMembers = StartNewSession,Direct;
        }
        field(10035;"Adj. Cost after Item Posting";Boolean)
        {
            Caption = 'Adj. Cost after Item Posting';
            Description = 'NPR5.38';
        }
        field(10036;"Post to G/L after Item Posting";Boolean)
        {
            Caption = 'Post to G/L after Item Posting';
            Description = 'NPR5.38';
        }
        field(20000;"Environment Database Name";Text[250])
        {
            Caption = 'Environment Database Name';
        }
        field(20001;"Environment Company Name";Text[250])
        {
            Caption = 'Environment Company Name';
        }
        field(20002;"Environment Tenant Name";Text[250])
        {
            Caption = 'Environment Tenant Name';
        }
        field(20003;"Environment Type";Option)
        {
            Caption = 'Environment Type';
            OptionCaption = 'PROD,DEMO,TEST,DEV';
            OptionMembers = PROD,DEMO,TEST,DEV;
        }
        field(20004;"Environment Verified";Boolean)
        {
            Caption = 'Environment Verified';

            trigger OnValidate()
            var
                ActiveSession: Record "Active Session";
            begin
                //-NPR5.31 [263473]
                if "Environment Verified" then begin
                  ActiveSession.Get(ServiceInstanceId, SessionId);
                  "Environment Database Name" := ActiveSession."Database Name";
                  "Environment Company Name" := CompanyName;
                  "Environment Tenant Name" := TenantId;
                  Modify;
                end;
                //+NPR5.31 [263473]
            end;
        }
        field(20005;"Environment Template";Boolean)
        {
            Caption = 'Environment Template';
        }
        field(30000;"Enable Client Diagnostics";Boolean)
        {
            Caption = 'Enable Client Diagnostics';
            Description = 'NPR5.38,NPR5.40';
            InitValue = true;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure GetPublisherCodeunitId(): Integer
    begin
        //-NPR5.45 [323705]
        exit(CODEUNIT::"POS Sales Price Calc. Mgt.");
        //+NPR5.45 [323705]
    end;

    local procedure GetPublisherFunction(): Text
    begin
        //-NPR5.45 [323705]
        exit('OnFindItemPrice');
        //+NPR5.45 [323705]
    end;
}

