table 6150616 "POS Payment Method"
{
    // NPR5.29/AP  /20170126  CASE 261728 Recreated ENU-captions
    // NPR5.36/BR  /20170925  CASE 289641 Delete related records
    // NPR5.38/BR  /20171024  CASE 294311 Set TableRelation Currency Code
    // NPR5.38/BR  /20171109  CASE 294722 Added field Condensed Posting Description
    // NPR5.46/TSA /20181002 CASE 322769 Added option "Auto" for field "Include In Counting" and field "Bin for Auto-Count"
    // NPR5.47/TSA /20181018 CASE 322769 Changed name on "Auto" option and field to Virtual, add lookup filter to only virtual bins

    Caption = 'POS Payment Method';
    DrillDownPageID = "POS Payment Method List";
    LookupPageID = "POS Payment Method List";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;"Processing Type";Option)
        {
            Caption = 'Processing Type';
            OptionCaption = 'Cash,Voucher,Check,EFT,Customer,PayOut';
            OptionMembers = CASH,VOUCHER,CHECK,EFT,CUSTOMER,PAYOUT;
        }
        field(15;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(20;"Vouched By";Option)
        {
            Caption = 'Vouched By';
            OptionCaption = 'Internal,External';
            OptionMembers = INTERNAL,EXTERNAL;
        }
        field(25;"Is Finance Agreement";Boolean)
        {
            Caption = 'Is Finance Agreement';
        }
        field(30;"Include In Counting";Option)
        {
            Caption = 'Include In Counting';
            OptionCaption = 'No,Yes,Yes - Blind,Virtual';
            OptionMembers = NO,YES,BLIND,VIRTUAL;
        }
        field(35;"Bin for Virtual-Count";Code[10])
        {
            Caption = 'Bin for Virtual-Count';
            TableRelation = "POS Payment Bin" WHERE ("Bin Type"=CONST(VIRTUAL));
        }
        field(40;"Post Condensed";Boolean)
        {
            Caption = 'Post Condensed';
            Description = 'NPR5.36';
        }
        field(41;"Condensed Posting Description";Text[50])
        {
            Caption = 'Condensed Posting Description';
            Description = 'NPR5.38';
        }
        field(50;"Rounding Precision";Decimal)
        {
            AutoFormatExpression = Code;
            AutoFormatType = 1;
            Caption = 'Rounding Precision';
            Description = 'NPR5.36';
            InitValue = 1;
        }
        field(51;"Rounding Type";Option)
        {
            Caption = 'Rounding Type';
            Description = 'NPR5.36';
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(52;"Rounding Gains Account";Code[20])
        {
            Caption = 'Rounding Gains Account';
            Description = 'NPR5.36';
            TableRelation = "G/L Account";
        }
        field(53;"Rounding Losses Account";Code[20])
        {
            Caption = 'Rounding Losses Account';
            Description = 'NPR5.36';
            TableRelation = "G/L Account";
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

    trigger OnDelete()
    var
        POSPostingSetup: Record "POS Posting Setup";
    begin
        //-NPR5.36 [289641]
        POSPostingSetup.SetRange("POS Payment Method Code",Code);
        POSPostingSetup.DeleteAll(true);
        //+NPR5.36 [289641]
    end;
}

