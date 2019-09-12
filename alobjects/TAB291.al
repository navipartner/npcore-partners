tableextension 50030 tableextension50030 extends "Shipping Agent" 
{
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration
    //                                    Added fields 6014440, 6014441
    // NPR5.25/MMV /20160621 CASE 233533 Added field 6014442.
    // NPR5.29/BHR/20161026 CASE 248684  Added field 6014450..6014452
    // NPR5.43/BHR/20180508 CASE 304453  Added field 6014453
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
        field(6014440;"Shipping Agent Demand";Option)
        {
            Caption = 'Shipping Agent Demand';
            Description = 'PS1.00';
            OptionCaption = ' ,Select a Service,Customs Information';
            OptionMembers = " ","Select a Service","Customs Information";
        }
        field(6014441;"Pacsoft Product";Boolean)
        {
            Caption = 'Pacsoft Product';
            Description = 'PS1.00';
        }
        field(6014442;"Custom Print Layout";Code[20])
        {
            Caption = 'Custom Print Layout';
            TableRelation = "RP Template Header".Code;
        }
        field(6014450;"Shipping Method";Option)
        {
            Caption = 'Shipping Method';
            OptionCaption = ' ,GLS,PDK';
            OptionMembers = " ",GLS,PDK;
        }
        field(6014451;"Ship to Contact Mandatory";Boolean)
        {
            Caption = 'Ship to Contact Mandatory';
        }
        field(6014452;"Drop Point Service";Boolean)
        {
            Caption = 'Drop Point Service';
        }
        field(6014453;"Return Shipping agent";Boolean)
        {
            Caption = 'Return Shipping agent';
        }
    }
}

