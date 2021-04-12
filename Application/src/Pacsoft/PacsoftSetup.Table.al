table 6014574 "NPR Pacsoft Setup"
{
    // PS1.00/LS/20140509  CASE 191871 Creation of Setup table to record Pacsoft settings
    // PS1.01/LS/20141216  CASE 200974 Added fields 14 & 15
    // NPR5.26/RA/20160426  CASE 237639 Added field 100 over time pacsoft and consignor modules should be merged
    // NPR5.26/BHR/20160831 CASE 248912 Add field 150 for module Pakkelabels
    // NPR5.29/BHR/20160831 CASE 248912 Add field Default Weight for module Pakkelabels
    // NPR5.34/BHR/20170711 CASE 283061 Add Field "Use Pakkelable Printer API","Pakkelable Test Mode","Order No. to Ext Doc No"
    // NPR5.36/BHR/20170926 CASE 290780 Add field Send Delivery Instrutions
    // NPR5.38/BHR/20181101 CASE 290780 Set default weight from gram to decimal
    // NPR5.43/BHR/20180508 CASE 304453 Add field "Print Return Ticket"
    // NPR5.43/BHR/20180517 CASE 314692 Add field "Skip Pakkelabel Agreement"

    Caption = 'Pacsoft Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Use Pacsoft integration"; Boolean)
        {
            Caption = 'Use Pacsoft integration';
            DataClassification = CustomerContent;
        }
        field(3; "Send Doc. Immediately(Pacsoft)"; Boolean)
        {
            Caption = 'Send Document Immediately';
            DataClassification = CustomerContent;
        }
        field(4; "Sender QuickID"; Code[10])
        {
            Caption = 'Sender QuickID';
            DataClassification = CustomerContent;
        }
        field(5; "Send Order URI"; Text[100])
        {
            Caption = 'Send Order URI';
            DataClassification = CustomerContent;
        }
        field(6; Session; Text[30])
        {
            Caption = 'Session';
            DataClassification = CustomerContent;
        }
        field(7; User; Text[10])
        {
            Caption = 'User';
            DataClassification = CustomerContent;
        }
        field(8; Pin; Text[20])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
        }
        field(9; "Link to Print Message"; Text[100])
        {
            Caption = 'Link to Print Message';
            DataClassification = CustomerContent;
        }
        field(10; "Order No. to Reference"; Boolean)
        {
            Caption = 'Order No. to Reference';
            DataClassification = CustomerContent;
        }
        field(11; "ENOT Message"; Text[250])
        {
            Caption = 'ENOT Message';
            DataClassification = CustomerContent;
        }
        field(12; "Return Label Both"; Boolean)
        {
            Caption = 'Return Label Both';
            DataClassification = CustomerContent;
        }
        field(13; "Shipping Agent Services Code"; Code[10])
        {
            Caption = 'Shipping Agent Services Code';
            TableRelation = "Shipping Agent Services".Code;
            DataClassification = CustomerContent;
        }
        field(14; "Create Pacsoft Document"; Boolean)
        {
            Caption = 'Create Pacsoft Document';
            Description = 'PS1.01';
            DataClassification = CustomerContent;
        }
        field(15; "Create Shipping Services Line"; Boolean)
        {
            Caption = 'Create Shipping Services Line';
            Description = 'PS1.01';
            DataClassification = CustomerContent;
        }
        field(100; "Use Consignor"; Boolean)
        {
            Caption = 'Use Consignor';
            DataClassification = CustomerContent;
        }
        field(150; "Use Pakkelabels"; Boolean)
        {
            Caption = 'Use Pakkelabels';
            DataClassification = CustomerContent;
        }
        field(151; "Api User"; Text[50])
        {
            Caption = 'Api User';
            DataClassification = CustomerContent;
        }
        field(152; "Api Key"; Text[50])
        {
            Caption = 'Api Key';
            DataClassification = CustomerContent;
        }
        field(153; "Send Package Doc. Immediately"; Boolean)
        {
            Caption = 'Send Package Doc. Immediately';
            DataClassification = CustomerContent;
        }
        field(154; "Default Weight"; Decimal)
        {
            Caption = 'Default Weight';
            DataClassification = CustomerContent;
        }
        field(156; "Package Service Codeunit ID"; Integer)
        {
            Caption = 'Package Service Codeunit ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = FILTER(Codeunit));
            DataClassification = CustomerContent;
        }
        field(157; "Package ServiceCodeunit Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Package Service Codeunit ID")));
            Caption = 'Package ServiceCodeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(158; "Use Pakkelable Printer API"; Boolean)
        {
            Caption = 'Use Pakkelable Printer API';
            DataClassification = CustomerContent;
        }
        field(159; "Pakkelable Test Mode"; Boolean)
        {
            Caption = 'Pakkelable Test Mode';
            DataClassification = CustomerContent;
        }
        field(160; "Order No. or Ext Doc No to ref"; Boolean)
        {
            Caption = 'Order No. or Ext Doc No to ref';
            Description = 'set field "reference No" to either "order no" or "External Document No"';
            DataClassification = CustomerContent;
        }
        field(161; "Send Delivery Instructions"; Boolean)
        {
            Caption = 'Send Delivery Instructions';
            DataClassification = CustomerContent;
        }
        field(162; "Print Return Label"; Boolean)
        {
            Caption = 'Print Return Label';
            DataClassification = CustomerContent;
        }
        field(163; "Skip Own Agreement"; Boolean)
        {
            Caption = 'Skip Own Agreement';
            InitValue = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

