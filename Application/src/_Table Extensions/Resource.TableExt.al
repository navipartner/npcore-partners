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
            ObsoleteState = Pending;
            ObsoleteReason = 'Flowfields should not be used on the TableExt.';
            Caption = 'Qty. Planned (Job)';
            Description = 'NPR5.40';
            Editable = false;
            DataClassification = CustomerContent;
            FieldClass = Normal;
        }
    }
}