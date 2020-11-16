table 6151185 "NPR MM Sponsors. Ticket Setup"
{

    Caption = 'Sponsorship Ticket Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(2; "External Membership No."; Code[20])
        {
            Caption = 'External Membership No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership"."External Membership No.";

            trigger OnLookup()
            var
                Membership: Record "NPR MM Membership";
                MembershipsListPage: Page "NPR MM Memberships";
                PageAction: Action;
            begin

                Membership.SetFilter(Blocked, '=%1', false);
                MembershipsListPage.LookupMode(true);
                MembershipsListPage.SetTableView(Membership);

                PageAction := MembershipsListPage.RunModal();

                if (PageAction = ACTION::LookupOK) then begin
                    MembershipsListPage.GetRecord(Membership);
                    "External Membership No." := Membership."External Membership No.";
                end;
            end;
        }
        field(3; "Event Type"; Option)
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
            OptionCaption = 'On New,On Renew,On Demand';
            OptionMembers = ONNEW,ONRENEW,ONDEMAND;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Ticket Admission BOM"."Item No.";
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(40; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(45; "Delivery Method"; Option)
        {
            Caption = 'Delivery Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Admin Member,Pick-Up';
            OptionMembers = ADMIN_MEMBER,PICKUP;
        }
        field(46; "Distribution Mode"; Option)
        {
            Caption = 'Distribution Mode';
            DataClassification = CustomerContent;
            OptionCaption = 'Batch,Individual';
            OptionMembers = BATCH,INDIVIDUAL;
        }
        field(50; "Once Per Period (On Demand)"; DateFormula)
        {
            Caption = 'Once Per Period (On Demand)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Membership Code", "External Membership No.", "Event Type", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        SponsorshipTicketSetup: Record "NPR MM Sponsors. Ticket Setup";
    begin

        if ("Line No." = 0) then begin
            SponsorshipTicketSetup.SetFilter("Membership Code", '=%1', Rec."Membership Code");
            SponsorshipTicketSetup.SetFilter("External Membership No.", '=%1', Rec."External Membership No.");
            SponsorshipTicketSetup.SetFilter("Event Type", '=%1', Rec."Event Type");
            "Line No." := 1000;
            if (SponsorshipTicketSetup.FindLast()) then
                Rec."Line No." += 1000;
        end;
    end;
}

