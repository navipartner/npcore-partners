table 6150671 "Upgrade NP Retail Setup"
{
    // [VLOBJUPG] Object may be deleted after upgrade
    // NPR5.52/ALPO/20190923 CASE 365326 Upgrade table to handle schema change (Posting related fields moved to POS Posting Profiles from NP Retail Setup)

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
        }
        field(10003;"Prev. Data Model Build";Integer)
        {
            Caption = 'Prev. Data Model Build';
        }
        field(10010;"Advanced POS Entries Activated";Boolean)
        {
            Caption = 'Advanced POS Entries Activated';
            Description = 'NPR5.32';
        }
        field(10020;"Advanced Posting Activated";Boolean)
        {
            Caption = 'Advanced Posting Activated';
            Description = 'NPR5.36';
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
}

