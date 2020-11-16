table 6151161 "NPR MM Loyalty Store Setup"
{

    Caption = 'Loyalty Store Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store Code"; Code[10])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
        }
        field(2; "Unit Code"; Code[10])
        {
            Caption = 'Unit Code';
            DataClassification = CustomerContent;
        }
        field(3; "Client Company Name"; Text[80])
        {
            Caption = 'Client Company Name';
            DataClassification = CustomerContent;
            TableRelation = Company;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5; Setup; Option)
        {
            Caption = 'Setup';
            DataClassification = CustomerContent;
            OptionCaption = 'Client,Server,Both';
            OptionMembers = CLIENT,SERVER,BOTH;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Authorization Code"; Text[40])
        {
            Caption = 'Authorization Code';
            DataClassification = CustomerContent;
        }
        field(25; "Accept Client Transactions"; Boolean)
        {
            Caption = 'Accept Client Transactions';
            DataClassification = CustomerContent;
        }
        field(27; "Loyalty Setup Code"; Code[20])
        {
            Caption = 'Loyalty Setup Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Setup";
        }
        field(30; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(31; "Customer Name"; Text[50])
        {
            CalcFormula = Lookup (Customer.Name WHERE("No." = FIELD("Customer No.")));
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Posting Model"; Option)
        {
            Caption = 'Posting Model';
            DataClassification = CustomerContent;
            OptionCaption = 'Local Currency,Burn Currency';
            OptionMembers = LCY,CURRENCY;
        }
        field(41; "Burn Points Currency Code"; Code[10])
        {
            Caption = 'Burn Points LCY Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(43; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(45; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(50; "Store Endpoint Code"; Code[10])
        {
            Caption = 'Store Endpoint Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM NPR Remote Endp. Setup" WHERE(Type = CONST(LoyaltyServices));
        }
        field(55; "Invoice No. Series"; Code[20])
        {
            Caption = 'Invoice No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(60; "Reconciliation Period"; Option)
        {
            Caption = 'Reconciliation Period';
            DataClassification = CustomerContent;
            OptionCaption = 'Today,Previous Month';
            OptionMembers = TODAY,PREVIOUS_MONTH;
        }
        field(1000; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(1100; "Outstanding Earn Points"; Integer)
        {
            CalcFormula = Sum ("NPR MM Loy. LedgerEntry (Srvr)"."Earned Points" WHERE("Company Name" = FIELD("Client Company Name"),
                                                                                      "POS Store Code" = FIELD("Store Code"),
                                                                                      "POS Unit Code" = FIELD("Unit Code"),
                                                                                      "Entry Type" = FILTER(RECEIPT | RECONCILE),
                                                                                      "Transaction Date" = FIELD("Date Filter")));
            Caption = 'Outstanding Earn Points';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1110; "Outstanding Burn Points"; Integer)
        {
            CalcFormula = Sum ("NPR MM Loy. LedgerEntry (Srvr)"."Burned Points" WHERE("Company Name" = FIELD("Client Company Name"),
                                                                                      "POS Store Code" = FIELD("Store Code"),
                                                                                      "POS Unit Code" = FIELD("Unit Code"),
                                                                                      "Entry Type" = FILTER(RECEIPT | RECONCILE),
                                                                                      "Transaction Date" = FIELD("Date Filter")));
            Caption = 'Outstanding Burn Points';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Client Company Name", "Store Code", "Unit Code")
        {
        }
    }

    fieldgroups
    {
    }
}

