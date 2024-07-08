table 6014690 "NPR MM MembershipLoyaltyJnl"
{
    DataClassification = ToBeClassified;
    Caption = 'Membership Loyalty Journal';
    Extensible = False;
    Access = Internal;
    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }

        field(10; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = EARN,WITHDRAW,DEPOSIT;
            OptionCaption = 'Earn,Withdraw,Deposit';
            DataClassification = CustomerContent;
        }
        field(20; ExternalMembershipNo; Code[20])
        {
            Caption = 'External Membership No.';
            DataClassification = CustomerContent;
        }
        field(30; JournalName; Code[20])
        {
            Caption = 'Journal Name';
            DataClassification = CustomerContent;
        }
        field(1000; ItemNo; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = "Item"."No.";
        }
        field(1005; UnitPrice; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(1007; AmountInclVat; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(1008; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(1010; PosUnitNo; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(1012; DocumentNo; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(1015; DocumentDate; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(1020; PointsToEarn; Integer)
        {
            Caption = 'Points To Earn';
            DataClassification = CustomerContent;
        }
        field(1021; PointsToDepositOrWithdraw; Integer)
        {
            Caption = 'Points To Deposit or Withdraw';
            DataClassification = CustomerContent;
        }
        field(1030; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
          field(1040; "Sales Channel"; Code[20])
        {
            Caption = 'Sales Channel';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Sales Channel".Code;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; JournalName, EntryNo) { }
        key(Key3; JournalName, ExternalMembershipNo, DocumentNo, Type) { }
    }

}