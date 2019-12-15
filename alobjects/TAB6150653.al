table 6150653 "POS Posting Profile"
{
    // NPR5.52/ALPO/20190923 CASE 365326 Posting related fields moved to POS Posting Profiles from NP Retail Setup

    Caption = 'POS Posting Profile';
    DrillDownPageID = "POS Posting Profiles";
    LookupPageID = "POS Posting Profiles";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Default POS Entry No. Series";Code[10])
        {
            Caption = 'Default POS Entry No. Series';
            TableRelation = "No. Series";
        }
        field(30;"Max. POS Posting Diff. (LCY)";Decimal)
        {
            Caption = 'Max. POS Posting Diff. (LCY)';
        }
        field(40;"POS Posting Diff. Account";Code[20])
        {
            Caption = 'Differences Account';
            TableRelation = "G/L Account";
        }
        field(50;"Automatic Item Posting";Option)
        {
            Caption = 'Automatic Item Posting';
            OptionCaption = 'No,After Sale,After End Of Day,After Last End Of Day in Store,After Last End Of Day Companywide';
            OptionMembers = No,AfterSale,AfterEndOfDay,AfterLastEndofDayStore,AfterLastEndofDayCompany;
        }
        field(60;"Automatic POS Posting";Option)
        {
            Caption = 'Automatic POS Posting';
            OptionCaption = 'No,After Sale,After End Of Day,After Last End Of Day in Store,After Last End Of Day Companywide';
            OptionMembers = No,AfterSale,AfterEndOfDay,AfterLastEndofDayStore,AfterLastEndofDayCompany;
        }
        field(70;"Automatic Posting Method";Option)
        {
            Caption = 'Automatic Posting Method';
            OptionCaption = 'Start New Session,Direct';
            OptionMembers = StartNewSession,Direct;
        }
        field(80;"Adj. Cost after Item Posting";Boolean)
        {
            Caption = 'Adj. Cost after Item Posting';
        }
        field(90;"Post to G/L after Item Posting";Boolean)
        {
            Caption = 'Post to G/L after Item Posting';
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
}

