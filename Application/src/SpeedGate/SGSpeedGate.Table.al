table 6150974 "NPR SG SpeedGate"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; Id; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Id';
        }

        field(2; ScannerId; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Scanner Id';
        }

        field(10; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(11; CategoryCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Category Code';
            TableRelation = "NPR SG Scanner Category".CategoryCode;
        }

        field(20; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            InitValue = true;
        }
        field(30; ImageProfileCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Image Profile Code';
            TableRelation = "NPR SG ImageProfile";
        }
        field(40; PermitTickets; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Permit Tickets';
            InitValue = true;
        }
        field(41; TicketProfileCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Profile Code';
            TableRelation = "NPR SG TicketProfile";
        }

        field(50; PermitMemberCards; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Permit Member Cards';
            InitValue = true;
        }
        field(51; MemberCardProfileCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Member Card Profile Code';
            TableRelation = "NPR SG MemberCardProfile";
        }

        field(60; PermitWallets; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Permit Wallets';
            InitValue = true;
        }


        field(70; AllowedNumbersList; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Allowed Numbers List';
            TableRelation = "NPR SG AllowedNumbersList";
        }


        field(80; PermitDocLxCityCard; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Permit City Card Integration';
            InitValue = false;
        }
        field(85; DocLxCityCardProfileId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'City Card Profile';
            Editable = false;
        }

        field(90; ItemsProfileCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Items Profile Code';
            TableRelation = "NPR SG ItemsProfile";
        }

    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
        key(Key2; ScannerId)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; ScannerId, Description)
        {

        }
    }
    trigger OnInsert()
    var
        SpeedGate: Record "NPR SG SpeedGate";
        DuplicateCode: Label 'Code already exists';
    begin
        if (IsNullGuid(Rec.Id)) then
            Rec.Id := CreateGuid();

        Rec.TestField(ScannerId);
        SpeedGate.SetFilter(Id, '<>%1', Rec.Id);
        SpeedGate.SetFilter(ScannerId, '=%1', Rec.ScannerId);
        if (not SpeedGate.IsEmpty()) then
            Error(DuplicateCode);

    end;

    trigger OnModify()
    var
        SpeedGate: Record "NPR SG SpeedGate";
        DuplicateCode: Label 'Code already exists';
    begin
        Rec.TestField(ScannerId);
        SpeedGate.SetFilter(Id, '<>%1', Rec.Id);
        SpeedGate.SetFilter(ScannerId, '=%1', Rec.ScannerId);
        if (not SpeedGate.IsEmpty()) then
            Error(DuplicateCode);
    end;

    trigger OnRename()
    begin
        Error('Renaming is not allowed');
    end;

}