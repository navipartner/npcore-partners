table 6150653 "NPR POS Posting Profile"
{
    Caption = 'POS Posting Profile';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Posting Profiles";
    LookupPageID = "NPR POS Posting Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Default POS Entry No. Series"; Code[10])
        {
            Caption = 'Default POS Entry No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(30; "Max. POS Posting Diff. (LCY)"; Decimal)
        {
            Caption = 'Max. POS Posting Diff. (LCY)';
            DataClassification = CustomerContent;
        }
        field(40; "POS Posting Diff. Account"; Code[20])
        {
            Caption = 'Differences Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(41; "Posting Diff. Account (Neg.)"; Code[20])
        {
            Caption = 'Differences Account - Neg.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(50; "Automatic Item Posting"; Option)
        {
            Caption = 'Automatic Item Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'No,After Sale,After End Of Day,After Last End Of Day in Store,After Last End Of Day Companywide';
            OptionMembers = No,AfterSale,AfterEndOfDay,AfterLastEndofDayStore,AfterLastEndofDayCompany;
        }
        field(60; "Automatic POS Posting"; Option)
        {
            Caption = 'Automatic POS Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'No,After Sale,After End Of Day,After Last End Of Day in Store,After Last End Of Day Companywide';
            OptionMembers = No,AfterSale,AfterEndOfDay,AfterLastEndofDayStore,AfterLastEndofDayCompany;
        }
        field(70; "Automatic Posting Method"; Option)
        {
            Caption = 'Automatic Posting Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Start New Session,Direct';
            OptionMembers = StartNewSession,Direct;
        }

        field(80; "Adj. Cost after Item Posting"; Boolean)
        {
            Caption = 'Adj. Cost after Item Posting';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Related code moved to job queue instead of direct execution';

        }
        field(90; "Post to G/L after Item Posting"; Boolean)
        {
            Caption = 'Post to G/L after Item Posting';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Related code moved to job queue instead of direct execution';
        }
        field(100; "POS Sales Rounding Account"; Code[20])
        {
            Caption = 'POS Sales Rounding Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." WHERE(Blocked = CONST(false));
        }
        field(110; "POS Sales Amt. Rndng Precision"; Decimal)
        {
            Caption = 'POS Sales Amt. Rndng Precision';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 0.25;
            MinValue = 0;
        }
        field(120; "Rounding Type"; Option)
        {
            Caption = 'Rounding Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(130; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }

        field(140; "POS Payment Bin"; Code[10])
        {
            Caption = 'POS Payment Bin';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ReciprocalMustBeInteger: Label 'Rounding precision must be divisible by 1.';
        ReciprocalExample: Label 'Example: 0,25 * 4 = 1';

    procedure RoundingDirection(): Text[1]
    begin
        case "Rounding Type" of
            "Rounding Type"::Nearest:
                exit('=');
            "Rounding Type"::Up:
                exit('>');
            "Rounding Type"::Down:
                exit('<');
        end;
    end;

    procedure CheckPostingDateAllowed(TestDate: Date): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        PostingAllowedFrom: Date;
        PostingAllowedTo: Date;
    begin
        GeneralLedgerSetup.Get;
        if UserId <> '' then
            if UserSetup.Get(UserId) then begin
                PostingAllowedFrom := UserSetup."Allow Posting From";
                PostingAllowedTo := UserSetup."Allow Posting To";
            end;
        if (PostingAllowedFrom = 0D) and (PostingAllowedTo = 0D) then begin
            PostingAllowedFrom := GeneralLedgerSetup."Allow Posting From";
            PostingAllowedTo := GeneralLedgerSetup."Allow Posting To";
        end;
        if PostingAllowedTo = 0D then
            PostingAllowedTo := DMY2Date(31, 12, 9999);
        if (TestDate < PostingAllowedFrom) or (TestDate > PostingAllowedTo) then
            exit(false)
        else
            exit(true);
    end;

    procedure EditPostingDateAllowed(UserIDCode: Code[20]; Date2: Date)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
    begin
        if UserIDCode <> '' then begin
            if UserSetup.Get(UserIDCode) then begin
                if UserSetup."Allow Posting From" > Date2 then begin
                    UserSetup."Allow Posting From" := Date2;
                    UserSetup.Modify(true);
                end;
                if UserSetup."Allow Posting To" < Date2 then begin
                    UserSetup."Allow Posting To" := Date2;
                    UserSetup.Modify(true);
                end;
            end;
        end;

        GeneralLedgerSetup.Get;
        if GeneralLedgerSetup."Allow Posting From" > Date2 then begin
            GeneralLedgerSetup."Allow Posting From" := Date2;
            GeneralLedgerSetup.Modify(true);
        end;
        if GeneralLedgerSetup."Allow Posting To" < Date2 then begin
            GeneralLedgerSetup."Allow Posting To" := Date2;
            GeneralLedgerSetup.Modify(true);
        end;
    end;
}

