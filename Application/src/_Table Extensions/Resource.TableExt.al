tableextension 6014421 "NPR Resource" extends Resource
{
    fields
    {
        field(6060150; "NPR E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
            TableRelation = "NPR Event Exch. Int. E-Mail";
        }
        field(6060151; "NPR Over Capacitate Resource"; Enum "NPR Over Capacitate Resource")
        {
            Caption = 'Over Capacitate Resource';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
        }
        field(6060152; "NPR Qty. Planned (Job)"; Decimal)
        {
            CalcFormula = Sum ("Job Planning Line"."Quantity (Base)" WHERE(Status = CONST(Planning),
                                                                           "Schedule Line" = CONST(true),
                                                                           Type = CONST(Resource),
                                                                           "No." = FIELD("No."),
                                                                           "Planning Date" = FIELD("Date Filter")));
            Caption = 'Qty. Planned (Job)';
            Description = 'NPR5.40';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}