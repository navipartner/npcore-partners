tableextension 6014422 tableextension6014422 extends Job 
{
    // NPR5.29/TJ/20161206 CASE 248723 Added new fields 6060150..6060161
    // NPR5.31/TJ/20170315 CASE 269162 Added new option "Ready to be Invoiced" to field "Event Status"
    //                                 Removed value from property InitValue on field "Event Status" (was Order)
    //                                 New fields "Total Amount", "Person Responsible Name" and "Event Attribute Template Name"
    // NPR5.32/TJ/20170515 CASE 275946 New field "Organizer Exchange Url"
    // NPR5.33/TJ/20170607 CASE 277972 Removed field "Event Attribute Template Name"
    // NPR5.35/TJ/20170731 CASE 275959 New field "Customer No."
    // NPR5.38/TJ/20171027 CASE 285194 Removed fields 6060160 and 6060165
    //                                 Changed TableRelation property of field "Organizer E-Mail" from default to "Event Exch. Int. E-Mail"
    // NPR5.48/TJ/20190131 CASE 342308 Added field "Est. Total Amount Incl. VAT"
    // NPR5.53/TJ/20191119 CASE 374886 Added field Locked
    fields
    {
        field(6060150;"Starting Time";Time)
        {
            Caption = 'Starting Time';
            Description = 'NPR5.29';
        }
        field(6060151;"Ending Time";Time)
        {
            Caption = 'Ending Time';
            Description = 'NPR5.29';
        }
        field(6060152;"Preparation Period";DateFormula)
        {
            Caption = 'Preparation Period';
            Description = 'NPR5.29';
        }
        field(6060153;"Event Status";Option)
        {
            Caption = 'Event Status';
            Description = 'NPR5.29';
            OptionCaption = 'Planning,Quote,Order,Completed,,,,,,Postponed,Cancelled,Ready to be Invoiced';
            OptionMembers = Planning,Quote,"Order",Completed,,,,,,Postponed,Cancelled,"Ready to be Invoiced";
        }
        field(6060154;"Calendar Item ID";Text[250])
        {
            Caption = 'Calendar Item ID';
            Description = 'NPR5.29';
        }
        field(6060155;"Calendar Item Status";Option)
        {
            Caption = 'Calendar Item Status';
            Description = 'NPR5.29';
            OptionCaption = ' ,Send,Error,Removed,Sent';
            OptionMembers = " ",Send,Error,Removed,Sent;
        }
        field(6060156;"Mail Item Status";Option)
        {
            Caption = 'Mail Item Status';
            Description = 'NPR5.29';
            OptionCaption = ' ,Sent,Error';
            OptionMembers = " ",Sent,Error;
        }
        field(6060157;"Event";Boolean)
        {
            Caption = 'Event';
            Description = 'NPR5.29';
        }
        field(6060158;"Bill-to E-Mail";Text[80])
        {
            Caption = 'Bill-to E-Mail';
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
        }
        field(6060159;"Organizer E-Mail";Text[80])
        {
            Caption = 'Organizer E-Mail';
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
            TableRelation = "Event Exch. Int. E-Mail";
        }
        field(6060160;"Est. Total Amount Incl. VAT";Decimal)
        {
            CalcFormula = Sum("Job Planning Line"."Est. Line Amt. Incl. VAT (LCY)" WHERE ("Job No."=FIELD("No.")));
            Caption = 'Est. Total Amount Incl. VAT';
            Description = 'NPR5.48';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6060161;"Source Job No.";Code[20])
        {
            Caption = 'Source Job No.';
            Description = 'NPR5.29';
            TableRelation = Job;
        }
        field(6060162;"Total Amount";Decimal)
        {
            CalcFormula = Sum("Job Planning Line"."Line Amount (LCY)" WHERE ("Job No."=FIELD("No.")));
            Caption = 'Total Amount';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6060163;"Person Responsible Name";Text[50])
        {
            CalcFormula = Lookup(Resource.Name WHERE ("No."=FIELD("Person Responsible")));
            Caption = 'Person Responsible Name';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6060164;"Event Customer No.";Code[20])
        {
            Caption = 'Event Customer No.';
            Description = 'NPR5.35';
            TableRelation = Customer;
        }
        field(6151578;Locked;Boolean)
        {
            Caption = 'Locked';
            Description = 'NPR5.53';
        }
    }
}

