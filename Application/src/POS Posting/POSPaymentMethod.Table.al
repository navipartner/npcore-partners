table 6150616 "NPR POS Payment Method"
{
    // NPR5.29/AP  /20170126  CASE 261728 Recreated ENU-captions
    // NPR5.36/BR  /20170925  CASE 289641 Delete related records
    // NPR5.38/BR  /20171024  CASE 294311 Set TableRelation Currency Code
    // NPR5.38/BR  /20171109  CASE 294722 Added field Condensed Posting Description
    // NPR5.46/TSA /20181002 CASE 322769 Added option "Auto" for field "Include In Counting" and field "Bin for Auto-Count"
    // NPR5.47/TSA /20181018 CASE 322769 Changed name on "Auto" option and field to Virtual, add lookup filter to only virtual bins

    Caption = 'POS Payment Method';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Payment Method List";
    LookupPageID = "NPR POS Payment Method List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Processing Type"; Option)
        {
            Caption = 'Processing Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Cash,Voucher,Check,EFT,Customer,PayOut';
            OptionMembers = CASH,VOUCHER,CHECK,EFT,CUSTOMER,PAYOUT;
        }
        field(15; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(20; "Vouched By"; Option)
        {
            Caption = 'Vouched By';
            DataClassification = CustomerContent;
            OptionCaption = 'Internal,External';
            OptionMembers = INTERNAL,EXTERNAL;
        }
        field(25; "Is Finance Agreement"; Boolean)
        {
            Caption = 'Is Finance Agreement';
            DataClassification = CustomerContent;
        }
        field(30; "Include In Counting"; Option)
        {
            Caption = 'Include In Counting';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes,Yes - Blind,Virtual';
            OptionMembers = NO,YES,BLIND,VIRTUAL;
        }
        field(35; "Bin for Virtual-Count"; Code[10])
        {
            Caption = 'Bin for Virtual-Count';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin" WHERE("Bin Type" = CONST(VIRTUAL));
        }
        field(40; "Post Condensed"; Boolean)
        {
            Caption = 'Post Condensed';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(41; "Condensed Posting Description"; Text[50])
        {
            Caption = 'Condensed Posting Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(50; "Rounding Precision"; Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            Caption = 'Rounding Precision';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            InitValue = 1;
        }
        field(51; "Rounding Type"; Option)
        {
            Caption = 'Rounding Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(52; "Rounding Gains Account"; Code[20])
        {
            Caption = 'Rounding Gains Account';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "G/L Account";
        }
        field(53; "Rounding Losses Account"; Code[20])
        {
            Caption = 'Rounding Losses Account';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "G/L Account";
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

    trigger OnDelete()
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        //-NPR5.36 [289641]
        POSPostingSetup.SetRange("POS Payment Method Code", Code);
        POSPostingSetup.DeleteAll(true);
        //+NPR5.36 [289641]
    end;
}

