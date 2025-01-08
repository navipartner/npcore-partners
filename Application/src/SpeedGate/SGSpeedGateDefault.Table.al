table 6150975 "NPR SG SpeedGateDefault"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }

        field(20; RequireScannerId; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Require Scanner Id';
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
        }
        field(41; DefaultTicketProfileCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Ticket Profile';
            TableRelation = "NPR SG TicketProfile";
        }

        field(50; PermitMemberCards; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Permit Member Cards';
        }
        field(51; DefaultMemberCardProfileCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Member Card Profile';
            TableRelation = "NPR SG MemberCardProfile";
        }

        field(60; PermitWallets; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Permit Wallets';
        }
        field(70; AllowedNumbersList; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Allowed Numbers List';
            TableRelation = "NPR SG AllowedNumbersList";
        }
    }


    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}