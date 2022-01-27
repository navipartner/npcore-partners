table 6014467 "NPR Customer Repair Setup"
{
    Access = Internal;
    Caption = 'Customer Repair Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Customer Repair No. Series"; Code[20])
        {
            Caption = 'Customer Repair Management';
            DataClassification = CustomerContent;
            Description = 'nummerstyring til  kunderep.';
            TableRelation = "No. Series";
        }
        field(20; "Repair Msg."; Boolean)
        {
            Caption = 'Repair Msg.';
            DataClassification = CustomerContent;
            Description = 'Send reparations SMS';
        }
        field(30; "Rep. Cust. Default"; Option)
        {
            Caption = 'Rep. Cust. Default';
            DataClassification = CustomerContent;
            Description = 'Std. debitortype ved reparation';
            OptionCaption = 'Ord. Customer,Cash Customer';
            OptionMembers = "Ord. Customer","Cash Customer";
        }
        field(40; "Fixed Price of Mending"; Decimal)
        {
            Caption = 'Fixed Price Of Mending';
            DataClassification = CustomerContent;
        }
        field(50; "Fixed Price of Denied Mending"; Decimal)
        {
            Caption = 'Fixed Price Of Denied Mending';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

}
