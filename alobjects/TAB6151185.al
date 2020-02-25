table 6151185 "MM Sponsorship Ticket Setup"
{
    // MM1.41/TSA /20191004 CASE 367471 Initial Version
    // MM1.42/TSA /20191122 CASE 378827 The relation to variant table omitted which field, which broke during Item rename when item has variant.

    Caption = 'Sponsorship Ticket Setup';

    fields
    {
        field(1;"Membership Code";Code[20])
        {
            Caption = 'Membership Code';
            TableRelation = "MM Membership Setup";
        }
        field(2;"External Membership No.";Code[20])
        {
            Caption = 'External Membership No.';
            TableRelation = "MM Membership"."External Membership No.";

            trigger OnLookup()
            var
                Membership: Record "MM Membership";
                MembershipsListPage: Page "MM Memberships";
                PageAction: Action;
            begin

                Membership.SetFilter (Blocked, '=%1', false);
                MembershipsListPage.LookupMode (true);
                MembershipsListPage.SetTableView (Membership);

                PageAction := MembershipsListPage.RunModal ();

                if (PageAction = ACTION::LookupOK) then begin
                  MembershipsListPage.GetRecord (Membership);
                  "External Membership No." := Membership."External Membership No.";
                end;
            end;
        }
        field(3;"Event Type";Option)
        {
            Caption = 'Event Type';
            OptionCaption = 'On New,On Renew,On Demand';
            OptionMembers = ONNEW,ONRENEW,ONDEMAND;
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "TM Ticket Admission BOM"."Item No.";
        }
        field(11;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(30;Quantity;Integer)
        {
            Caption = 'Quantity';
        }
        field(40;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(45;"Delivery Method";Option)
        {
            Caption = 'Delivery Method';
            OptionCaption = 'Admin Member,Pick-Up';
            OptionMembers = ADMIN_MEMBER,PICKUP;
        }
        field(46;"Distribution Mode";Option)
        {
            Caption = 'Distribution Mode';
            OptionCaption = 'Batch,Individual';
            OptionMembers = BATCH,INDIVIDUAL;
        }
        field(50;"Once Per Period (On Demand)";DateFormula)
        {
            Caption = 'Once Per Period (On Demand)';
        }
    }

    keys
    {
        key(Key1;"Membership Code","External Membership No.","Event Type","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        SponsorshipTicketSetup: Record "MM Sponsorship Ticket Setup";
    begin

        if ("Line No." = 0) then begin
          SponsorshipTicketSetup.SetFilter ("Membership Code",'=%1', Rec."Membership Code");
          SponsorshipTicketSetup.SetFilter ("External Membership No.", '=%1', Rec."External Membership No.");
          SponsorshipTicketSetup.SetFilter ("Event Type", '=%1', Rec."Event Type");
          "Line No." := 1000;
          if (SponsorshipTicketSetup.FindLast ()) then
            Rec."Line No." += 1000;
        end;
    end;
}

