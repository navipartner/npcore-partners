tableextension 6014446 tableextension6014446 extends "Shipping Agent Services" 
{
    // PS1.00/LS/20140509  CASE 190533 Versioned Fields 6014440..6014442 as part of Pacsoft module
    // NPR5.29/BHR/20161024 CASE 248684 Fields for Pakkelabels 6014451.. 6014452
    fields
    {
        field(6014440;"Service Demand";Option)
        {
            Caption = 'Service Demand';
            Description = 'PS1.00';
            OptionCaption = ',Selected E-mail,Selected Mobile No.';
            OptionMembers = " ","Selected E-mail","Selected Mobile No.";
        }
        field(6014441;"Notification Service";Boolean)
        {
            Caption = 'Notification Service';
            Description = 'PS1.00';
        }
        field(6014442;"Default Option";Boolean)
        {
            Caption = 'Default Option';
            Description = 'PS1.00';
        }
        field(6014451;"Email Mandatory";Boolean)
        {
            Caption = 'Email Mandatory';
        }
        field(6014452;"Phone Mandatory";Boolean)
        {
            Caption = 'Phone Mandatory';
        }
    }
}

