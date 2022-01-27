table 6059771 "NPR Member Card Types"
{
    Access = Internal;

    Caption = 'Point Card';
    DataCaptionFields = "Code";
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used.';
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Card No. Series"; Code[20])
        {
            Caption = 'Card No. Series';
            Description = 'Nummerserie til point kort';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(4; "EAN Prefix"; Code[10])
        {
            Caption = 'EAN Prefix';
            DataClassification = CustomerContent;
        }
        field(5; "Expiration Calculation"; DateFormula)
        {
            Caption = 'Expiration Calculation';
            DataClassification = CustomerContent;
        }
        field(6; "Card Code Eqauls Customer Code"; Boolean)
        {
            Caption = 'Card Code Eqauls Customer Code';
            DataClassification = CustomerContent;
        }
        field(7; "Card Code Length"; Integer)
        {
            Caption = 'Card Code Length';
            DataClassification = CustomerContent;
        }
        field(10; "Calc Excluding VAT"; Boolean)
        {
            Caption = 'Calc. Excluding VAT';
            DataClassification = CustomerContent;
        }
        field(20; "Payment Method Code"; Code[20])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            DataClassification = CustomerContent;
        }
        field(25; "Point Account"; Code[20])
        {
            Caption = 'Point Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(30; "Post Point Earnings"; Boolean)
        {
            Caption = 'Post Point Earnings';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(50; "Card Expiration Formula"; DateFormula)
        {
            Caption = 'Card Expiration Formula';
            DataClassification = CustomerContent;
        }
        field(55; "Customer Template"; Code[20])
        {
            Caption = 'Customer Template';
            TableRelation = "Customer Templ.";
            DataClassification = CustomerContent;
        }
        field(60; "Member Name Required"; Boolean)
        {
            Caption = 'Member Name Mandatory';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(61; "Member Address Required"; Boolean)
        {
            Caption = 'Member Address Mandatory';
            DataClassification = CustomerContent;
        }
        field(62; "Member Phone Required"; Boolean)
        {
            Caption = 'Member Phone Mandatory';
            DataClassification = CustomerContent;
        }
        field(63; "Member E-Mail Required"; Boolean)
        {
            Caption = 'Member E-Mail Mandatory';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(100; "Sync Points To Company"; Text[50])
        {
            Caption = 'Sync Points To Company';
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(101; "Sync Cards To Company"; Text[50])
        {
            Caption = 'Sync Cards To Company';
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(102; "Sync Loyalty Cust. To Company"; Text[50])
        {
            Caption = 'Sync Loyalty Cust. To Company';
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(200; "Card Action 1 Codeunit"; Integer)
        {
            Caption = 'Card Action 1 Codeunit';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;
        }
        field(201; "Card Action 1 Parameter"; Code[20])
        {
            Caption = 'Card Action 1 Parameter';
            DataClassification = CustomerContent;
        }
        field(202; "Card Action 1 Description"; Text[30])
        {
            Caption = 'Card Action 1 Description';
            DataClassification = CustomerContent;
        }
        field(203; "Card Action 2 Codeunit"; Integer)
        {
            Caption = 'Card Action 2 Codeunit';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;
        }
        field(204; "Card Action 2 Parameter"; Code[20])
        {
            Caption = 'Card Action 2 Parameter';
            DataClassification = CustomerContent;
        }
        field(205; "Card Action 2 Description"; Text[30])
        {
            Caption = 'Card Action 2 Description';
            DataClassification = CustomerContent;
        }
        field(206; "Card Action 3 Codeunit"; Integer)
        {
            Caption = 'Card Action 3 Codeunit';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;
        }
        field(207; "Card Action 3 Parameter"; Code[20])
        {
            Caption = 'Card Action 3 Parameter';
            DataClassification = CustomerContent;
        }
        field(208; "Card Action 3 Description"; Text[30])
        {
            Caption = 'Card Action 3 Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

}

