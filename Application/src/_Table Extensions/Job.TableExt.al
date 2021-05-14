tableextension 6014422 "NPR Job" extends Job
{
    fields
    {
        field(6060150; "NPR Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060151; "NPR Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060152; "NPR Preparation Period"; DateFormula)
        {
            Caption = 'Preparation Period';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060153; "NPR Event Status"; Enum "NPR Event Status")
        {
            Caption = 'Event Status';
            DataClassification = CustomerContent;
        }
        field(6060154; "NPR Calendar Item ID"; Text[250])
        {
            Caption = 'Calendar Item ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060155; "NPR Calendar Item Status"; Enum "NPR Job Calendar Item Status")
        {
            Caption = 'Calendar Item Status';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            ValuesAllowed = " ", Send, Error, Removed, Sent;
        }
        field(6060156; "NPR Mail Item Status"; Enum "NPR Job Mail Item Status")
        {
            Caption = 'Mail Item Status';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060157; "NPR Event"; Boolean)
        {
            Caption = 'Event';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
        }
        field(6060158; "NPR Bill-to E-Mail"; Text[80])
        {
            Caption = 'Bill-to E-Mail';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
        }
        field(6060159; "NPR Organizer E-Mail"; Text[80])
        {
            Caption = 'Organizer E-Mail';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
            TableRelation = "NPR Event Exch. Int. E-Mail";
        }
        field(6060160; "NPR Est. Total Amt. Incl. VAT"; Decimal)
        {
            CalcFormula = Sum("Job Planning Line"."NPR Est. L.Amt. Inc VAT (LCY)" WHERE("Job No." = FIELD("No.")));
            Caption = 'Est. Total Amount Incl. VAT';
            Description = 'NPR5.48';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6060161; "NPR Source Job No."; Code[20])
        {
            Caption = 'Source Job No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            TableRelation = Job;
        }
        field(6060162; "NPR Total Amount"; Decimal)
        {
            CalcFormula = Sum("Job Planning Line"."Line Amount (LCY)" WHERE("Job No." = FIELD("No.")));
            Caption = 'Total Amount';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6060163; "NPR Person Responsible Name"; Text[100])
        {
            CalcFormula = Lookup(Resource.Name WHERE("No." = FIELD("Person Responsible")));
            Caption = 'Person Responsible Name';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6060164; "NPR Event Customer No."; Code[20])
        {
            Caption = 'Event Customer No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.35';
            TableRelation = Customer;
        }
        field(6151578; "NPR Locked"; Boolean)
        {
            Caption = 'Locked';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(6151580; "NPR Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR TM Admission";
        }
    }
}