tableextension 6014421 tableextension6014421 extends Resource
{
    // NPR5.29/TJ/20161013 CASE 248723 New field 6060150 E-Mail
    // NPR5.32/TJ/20170519 CASE 275966 New field 6060151 Over Capacitate Resource
    // NPR5.34/TJ/20170725 CASE 275991 New fields 6060152 E-Mail Password and 6060153 Exchange Url
    // NPR5.38/TJ/20171027 CASE 285194 Removed fields 6060152 and 6060153
    //                                 Changed TableRelation property of field "E-Mail" from default to "Event Exch. Int. E-Mail"
    // NPR5.40/TJ/20180124 CASE 301375 New field 6060152 Qty. Planned (Job)
    fields
    {
        field(6060150; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
            TableRelation = "Event Exch. Int. E-Mail";
        }
        field(6060151; "Over Capacitate Resource"; Option)
        {
            Caption = 'Over Capacitate Resource';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            OptionCaption = ' ,Allow,Warn,Disallow';
            OptionMembers = " ",Allow,Warn,Disallow;
        }
        field(6060152; "Qty. Planned (Job)"; Decimal)
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

