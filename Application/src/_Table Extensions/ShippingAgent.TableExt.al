tableextension 6014429 "NPR Shipping Agent" extends "Shipping Agent"
{
    Caption = 'Shipping Agent';
    fields
    {
        modify("Code")
        {
            Caption = 'Code';
        }
        modify(Name)
        {
            Caption = 'Name';
        }
        modify("Internet Address")
        {
            Caption = 'Internet Address';
        }
        modify("Account No.")
        {
            Caption = 'Account No.';
        }
        field(6014440; "NPR Shipping Agent Demand"; Option)
        {
            Caption = 'Shipping Agent Demand';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
            OptionCaption = ' ,Select a Service,Customs Information';
            OptionMembers = " ","Select a Service","Customs Information";
        }
        field(6014441; "NPR Pacsoft Product"; Boolean)
        {
            Caption = 'Pacsoft Product';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
        }
        field(6014442; "NPR Custom Print Layout"; Code[20])
        {
            Caption = 'Custom Print Layout';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
        }
        field(6014450; "NPR Shipping Method"; Option)
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
            OptionCaption = ' ,GLS,PDK';
            OptionMembers = " ",GLS,PDK;
        }
        field(6014451; "NPR Ship to Contact Mandatory"; Boolean)
        {
            Caption = 'Ship to Contact Mandatory';
            DataClassification = CustomerContent;
        }
        field(6014452; "NPR Drop Point Service"; Boolean)
        {
            Caption = 'Drop Point Service';
            DataClassification = CustomerContent;
        }
        field(6014453; "NPR Return Shipping agent"; Boolean)
        {
            Caption = 'Return Shipping agent';
            DataClassification = CustomerContent;
        }
    }
}

