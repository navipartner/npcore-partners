table 6014574 "NPR Shipping Provider Setup"
{
    Access = Public;
    Caption = 'Shipping Provider Setup';
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
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'replaced by "Shipping Provider"';
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
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'replaced by "Shipping Provider"';
        }
        field(150; "Use Pakkelabels"; Boolean)
        {
            Caption = 'Use Pakkelabels';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'replaced by "Shipping Provider"';

        }
        field(151; "Api User"; Text[250])
        {
            Caption = 'Api User';
            DataClassification = CustomerContent;
        }
        field(152; "Api Key"; Text[250])
        {
            Caption = 'Api Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
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
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by enum "Shipping Provider"';
        }
        field(157; "Package ServiceCodeunit Name"; Text[249])
        {
            Caption = 'Package ServiceCodeunit Name';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by enum "Shipping Provider"';
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
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used Anymore';
        }
        field(164; "Enable Shipping"; Boolean)
        {
            Caption = 'Enable Shipping';
            DataClassification = CustomerContent;
        }

        field(165; "Shipping Provider"; Enum "NPR Shipping Provider Enum")
        {
            Caption = 'Shipping Provider';
            DataClassification = CustomerContent;
        }
        field(200; "Use Online Connect"; Boolean)
        {
            Caption = 'Use Online Connect';
            DataClassification = CustomerContent;
        }
        field(201; "Online Connect file Path"; Text[250])
        {
            Caption = 'Online Connect file Path';
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

