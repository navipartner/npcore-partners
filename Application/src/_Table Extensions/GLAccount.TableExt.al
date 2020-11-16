tableextension 6014419 "NPR G/L Account" extends "G/L Account"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                Fields Added  : 6014400..6014404
    fields
    {
        field(6014400; "NPR Retail Payment"; Boolean)
        {
            Caption = 'NPR payment';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014401; "NPR G/L Entry in Audit Roll"; Decimal)
        {
            CalcFormula = Sum ("NPR Audit Roll"."Amount Including VAT" WHERE("Sale Type" = CONST("Out payment"),
                                                                         Type = CONST("G/L"),
                                                                         "No." = FIELD("No."),
                                                                         "Sale Date" = FIELD("Date Filter"),
                                                                         "Register No." = FIELD("NPR Register Filter"),
                                                                         "Sales Ticket No." = FIELD("NPR Sales Ticket No. Filter")));
            Caption = 'G/L Entry in Audit Roll';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014402; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            InitValue = true;
        }
        field(6014403; "NPR Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014404; "NPR Sales Ticket No. Filter"; Code[10])
        {
            Caption = 'Sales Ticket No. Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
    }
}

