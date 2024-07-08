tableextension 6014401 "NPR Job Planning Line" extends "Job Planning Line"
{
    fields
    {
        field(6060150; "NPR Starting Time"; Time)
        {
            Caption = 'Starting Time';
            Description = 'NPR5.29';
            DataClassification = CustomerContent;
        }
        field(6060151; "NPR Ending Time"; Time)
        {
            Caption = 'Ending Time';
            Description = 'NPR5.29';
            DataClassification = CustomerContent;
        }
        field(6060152; "NPR Event Status"; Enum "NPR Event Status")
        {
            Caption = 'Event Status';
            Description = 'NPR5.29';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6060153; "NPR Resource E-Mail"; Text[80])
        {
            Caption = 'Resource E-Mail';
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
        field(6060154; "NPR Calendar Item ID"; Text[250])
        {
            Caption = 'Calendar Item ID';
            Description = 'NPR5.29';
            DataClassification = CustomerContent;
        }
        field(6060155; "NPR Calendar Item Status"; Enum "NPR Job Calendar Item Status")
        {
            Caption = 'Calendar Item Status';
            Description = 'NPR5.29';
            DataClassification = CustomerContent;
        }
        field(6060156; "NPR Mail Item Status"; Enum "NPR Job Mail Item Status")
        {
            Caption = 'Mail Item Status';
            Description = 'NPR5.29';
            DataClassification = CustomerContent;
        }
        field(6060157; "NPR Meeting Request Response"; Enum "NPR Meeting Request Response")
        {
            Caption = 'Meeting Request Response';
            Description = 'NPR5.29';
            DataClassification = CustomerContent;
        }
        field(6060158; "NPR Ticket Token"; Text[100])
        {
            Caption = 'Ticket Token';
            Description = 'NPR5.29';
            DataClassification = CustomerContent;
        }
        field(6060159; "NPR Ticket Status"; Enum "NPR Ticket Status")
        {
            Caption = 'Ticket Status';
            Description = 'NPR5.29';
            DataClassification = CustomerContent;
        }
        field(6060160; "NPR Att. to Line No."; Integer)
        {
            Caption = 'Att. to Line No.';
            Description = 'NPR5.49';
            DataClassification = CustomerContent;
        }
        field(6060162; "NPR Ticket Collect Status"; Enum "NPR Ticket Collect Status")
        {
            Caption = 'Ticket Collect Status';
            Description = 'NPR5.43';
            DataClassification = CustomerContent;
        }
        field(6060163; "NPR Est. Unit Price Incl. VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Est. Unit Price Incl. VAT';
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(6060164; "NPR Est. Line Amount Incl. VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Est. Line Amount Incl. VAT';
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(6060165; "NPR Est. VAT %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Est. VAT %';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(6060166; "NPR Est. U.Price Inc VAT (LCY)"; Decimal)
        {
            Caption = 'Est. Unit Price Incl VAT (LCY)';
            Description = 'NPR5.38';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6151575; "NPR Est. L.Amt. Inc VAT (LCY)"; Decimal)
        {
            Caption = 'Est. Line Amt. Incl. VAT (LCY)';
            Description = 'NPR5.38';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6151579; "NPR Group Source Line No."; Integer)
        {
            Caption = 'Group Source Line No.';
            Description = 'NPR5.55';
            DataClassification = CustomerContent;
        }
        field(6151580; "NPR Group Line"; Boolean)
        {
            Caption = 'Group Line';
            Description = 'NPR5.55';
            DataClassification = CustomerContent;
        }
        field(6151581; "NPR Skip Cap./Avail. Check"; Boolean)
        {
            Caption = 'Skip Cap./Avail. Check';
            Description = 'NPR5.55';
            DataClassification = CustomerContent;
        }
    }
}