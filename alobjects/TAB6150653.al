table 6150653 "POS Posting Profile"
{
    // NPR5.52/ALPO/20190923 CASE 365326 Posting related fields moved to POS Posting Profiles from NP Retail Setup
    // NPR5.53/ALPO/20191022 CASE 371955 Rounding related fields moved to POS Posting Profiles
    //                                     100 "POS Sales Rounding Account" - moved from T6014401 "Register"
    //                                     110 "POS Sales Amt. Rndng Precision" - moved from T6014400 "Retail Setup"
    //                                     120 "Rounding Type" - new field

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
        field(100;"POS Sales Rounding Account";Code[20])
        {
            Caption = 'POS Sales Rounding Account';
            TableRelation = "G/L Account"."No." WHERE (Blocked=CONST(false));
        }
        field(110;"POS Sales Amt. Rndng Precision";Decimal)
        {
            Caption = 'POS Sales Amt. Rndng Precision';
            DecimalPlaces = 0:5;
            InitValue = 0.25;
            MinValue = 0;

            trigger OnValidate()
            var
                "Integer": Integer;
            begin
                //-NPR5.53 [371955]
                /*!!! Tempary disabled
                IF "POS Sales Amt. Rndng Precision" <> 0 THEN
                  IF NOT EVALUATE(Integer,STRSUBSTNO('%1',1 / "POS Sales Amt. Rndng Precision")) THEN
                    ERROR(ReciprocalMustBeInteger + ReciprocalExample);
                */
                //+NPR5.53 [371955]

            end;
        }
        field(120;"Rounding Type";Option)
        {
            Caption = 'Rounding Type';
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
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

    var
        ReciprocalMustBeInteger: Label 'Rounding precision must be divisible by 1.';
        ReciprocalExample: Label 'Example: 0,25 * 4 = 1';

    procedure RoundingDirection(): Text[1]
    begin
        //-NPR5.53 [371955]
        case "Rounding Type" of
          "Rounding Type"::Nearest:
            exit('=');
          "Rounding Type"::Up:
            exit('>');
          "Rounding Type"::Down:
            exit('<');
        end;
        //+NPR5.53 [371955]
    end;
}

