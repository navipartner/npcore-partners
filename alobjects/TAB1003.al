tableextension 6014401 tableextension6014401 extends "Job Planning Line" 
{
    // NPR5.29/TJ/20161013 CASE 248723 New fields 6060150..6060160
    // NPR5.31/TJ/20170315 CASE 269162 Added new option "Ready to be Invoiced" to field "Event Status"
    //                                 Removed value from property InitValue on field "Event Status" (was Order)
    // NPR5.38/TJ/20170104 CASE 261965 Added new fields 6060163..6060166 and 6151575
    // NPR5.38/NPKNAV/20180126  CASE 291965 Transport NPR5.38 - 26 January 2018
    // NPR5.43/TJ/20170817 CASE 262079 Added field "Ticket Collect Status"
    // NPR5.48/JDH /20181109 CASE 334163 Added option caption to Ticket Collect Status
    // NPR5.48/TJ  /20190201 CASE 335824 Removed Field "Ticket No."
    // NPR5.49/TJ  /20190218 CASE 345047 New field Att. to Line No.
    // NPR5.55/TJ  /20200326 CASE 397741 New fields "Group Source Line No.", "Group Line" and "Skip Cap./Avail. Check"
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
        field(6060152;"Event Status";Option)
        {
            Caption = 'Event Status';
            Description = 'NPR5.29';
            Editable = false;
            OptionCaption = 'Planning,Quote,Order,Completed,,,,,,Postponed,Cancelled,Ready to be Invoiced';
            OptionMembers = Planning,Quote,"Order",Completed,,,,,,Postponed,Cancelled,"Ready to be Invoiced";
        }
        field(6060153;"Resource E-Mail";Text[80])
        {
            Caption = 'Resource E-Mail';
            Description = 'NPR5.29';
            ExtendedDatatype = EMail;
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
            OptionCaption = ' ,Send,Error,Removed,Sent,Received';
            OptionMembers = " ",Send,Error,Removed,Sent,Received;
        }
        field(6060156;"Mail Item Status";Option)
        {
            Caption = 'Mail Item Status';
            Description = 'NPR5.29';
            OptionCaption = ' ,Sent,Error';
            OptionMembers = " ",Sent,Error;
        }
        field(6060157;"Meeting Request Response";Option)
        {
            Caption = 'Meeting Request Response';
            Description = 'NPR5.29';
            OptionCaption = ' ,Unknown,Organizer,Tentative,Accepted,Declined,No Response';
            OptionMembers = " ",Unknown,Organizer,Tentative,Accepted,Declined,"No Response";
        }
        field(6060158;"Ticket Token";Text[100])
        {
            Caption = 'Ticket Token';
            Description = 'NPR5.29';
        }
        field(6060159;"Ticket Status";Option)
        {
            Caption = 'Ticket Status';
            Description = 'NPR5.29';
            OptionCaption = ' ,Registered,Issued,Revoked,Confirmed';
            OptionMembers = " ",Registered,Issued,Revoked,Confirmed;
        }
        field(6060160;"Att. to Line No.";Integer)
        {
            Caption = 'Att. to Line No.';
            Description = 'NPR5.49';
        }
        field(6060162;"Ticket Collect Status";Option)
        {
            Caption = 'Ticket Collect Status';
            Description = 'NPR5.43';
            OptionCaption = ' ,Not Collected,Collected,Error';
            OptionMembers = " ","Not Collected",Collected,Error;
        }
        field(6060163;"Est. Unit Price Incl. VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Est. Unit Price Incl. VAT';
            Description = 'NPR5.38';
        }
        field(6060164;"Est. Line Amount Incl. VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Est. Line Amount Incl. VAT';
            Description = 'NPR5.38';
        }
        field(6060165;"Est. VAT %";Decimal)
        {
            BlankZero = true;
            Caption = 'Est. VAT %';
            DecimalPlaces = 0:5;
            Description = 'NPR5.38';
        }
        field(6060166;"Est. Unit Price Incl VAT (LCY)";Decimal)
        {
            Caption = 'Est. Unit Price Incl VAT (LCY)';
            Description = 'NPR5.38';
            Editable = false;
        }
        field(6151575;"Est. Line Amt. Incl. VAT (LCY)";Decimal)
        {
            Caption = 'Est. Line Amt. Incl. VAT (LCY)';
            Description = 'NPR5.38';
            Editable = false;
        }
        field(6151579;"Group Source Line No.";Integer)
        {
            Caption = 'Group Source Line No.';
            Description = 'NPR5.55';
        }
        field(6151580;"Group Line";Boolean)
        {
            Caption = 'Group Line';
            Description = 'NPR5.55';
        }
        field(6151581;"Skip Cap./Avail. Check";Boolean)
        {
            Caption = 'Skip Cap./Avail. Check';
            Description = 'NPR5.55';
        }
    }
}

