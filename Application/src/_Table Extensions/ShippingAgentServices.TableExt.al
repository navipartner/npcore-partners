tableextension 6014446 "NPR Shipping Agent Services" extends "Shipping Agent Services"
{
    fields
    {
        field(6014440; "NPR Service Demand"; Option)
        {
            Caption = 'Service Demand';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
            OptionCaption = ',Selected E-mail,Selected Mobile No.';
            OptionMembers = " ","Selected E-mail","Selected Mobile No.";
        }
        field(6014441; "NPR Notification Service"; Boolean)
        {
            Caption = 'Notification Service';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
        }
        field(6014442; "NPR Default Option"; Boolean)
        {
            Caption = 'Default Option';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
        }
    }
}

