table 6151141 "NPR NpIa POSEntrySaleLineAddOn"
{
    Access = Internal;
    Caption = 'Item AddOn POS Entry Sale Line AddOn';
    DataClassification = CustomerContent;

    fields
    {
        field(1; POSEntrySaleLineId; Guid)
        {
            Caption = 'POS Entry Sale Line Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry Sales Line".SystemId;
        }
        field(2; PosEntrySaleLineNo; Integer)
        {
            Caption = 'POS Entry Sale Line No.';
            DataClassification = CustomerContent;
        }

        field(10; AppliesToSaleLineId; Guid)
        {
            Caption = 'Applies-To Sale Line Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry Sales Line".SystemId;
        }
        field(11; AppliesToSaleLineNo; Integer)
        {
            Caption = 'Applies-To Sale Line No.';
            DataClassification = CustomerContent;
        }

        field(40; AddOnNo; Code[20])
        {
            Caption = 'AddOn No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpIa Item AddOn"."No.";
        }
        field(41; AddOnLineNo; Integer)
        {
            Caption = 'AddOn Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpIa Item AddOn Line"."Line No." where("AddOn No." = field(AddOnNo));
        }
        field(60; AddToWallet; Boolean)
        {
            Caption = 'Add to Wallet';
            DataClassification = CustomerContent;
        }
        field(70; AddOnItemNo; Code[20])
        {
            Caption = 'AddOn Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
    }

    keys
    {
        key(PK; POSEntrySaleLineId)
        {
            Clustered = true;
        }
        key(MemberLines; AppliesToSaleLineId)
        { }
    }
}