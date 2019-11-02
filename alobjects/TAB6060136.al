table 6060136 "MM Membership Alteration Setup"
{
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.14/TSA/20160503  CASE 240697 Added Price fraction calculations.
    // MM1.19/TSA/20170322  CASE 268166 New field "Upgrade With New Duration"
    // MM1.22/TSA /20170816 CASE 287080 Added field Anonymous Member Unit Price
    // MM1.22/TSA /20170829 CASE 286922 New fields and type "Auto-Renew To" and type "Auto-Renew"
    // MM1.23/TSA /20170918 CASE 276869 Added a filter for web service "Not Available Via Web Service"
    // MM1.24/NPKNAV/20171207  CASE 297852 Transport MM1.24 - 7 December 2017
    // MM1.25/TSA /20180119 CASE 300256 Card Expired Action
    // MM1.30/TSA /20180605 CASE 317428 Added "Grace Period Calculation"
    // MM1.40/TSA /20190730 CASE 360275 Added field 85 "Auto-Admit Member On Sale"
    // MM1.41/TSA /20191016 CASE 373297 Added Grace Period Preset

    Caption = 'Membership Alteration Setup';

    fields
    {
        field(1;"Alteration Type";Option)
        {
            Caption = 'Alteration Type';
            InitValue = RENEW;
            OptionCaption = 'Regret,Renew,Upgrade,Extend,Cancel,Auto-Renew';
            OptionMembers = REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW;
        }
        field(2;"From Membership Code";Code[20])
        {
            Caption = 'From Membership Code';
            TableRelation = "MM Membership Setup";

            trigger OnValidate()
            begin

                if ("Alteration Type" in ["Alteration Type"::REGRET, "Alteration Type"::CANCEL]) then
                  "To Membership Code" := '';
            end;
        }
        field(4;"Sales Item No.";Code[20])
        {
            Caption = 'Sales Item No.';
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin

                if (Item.Get ("Sales Item No.")) then
                  Description := Item.Description;
            end;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(15;"To Membership Code";Code[20])
        {
            Caption = 'To Membership Code';
            TableRelation = "MM Membership Setup";
        }
        field(20;"Alteration Activate From";Option)
        {
            Caption = 'Alteration Activate From';
            OptionCaption = 'As soon as possible,Date Formula';
            OptionMembers = ASAP,DF;
        }
        field(25;"Alteration Date Formula";DateFormula)
        {
            Caption = 'Alteration Date Formula';
        }
        field(30;"Activate Grace Period";Boolean)
        {
            Caption = 'Activate Grace Period';
        }
        field(32;"Grace Period Presets";Option)
        {
            Caption = 'Grace Period Presets';
            OptionCaption = ' ,Valid for Expired Memberships,Valid for Active Memberships';
            OptionMembers = NA,EXPIRED_MEMBERSHIP,ACTIVE_MEMBERSHIP;

            trigger OnValidate()
            var
                MembershipManagement: Codeunit "MM Membership Management";
            begin

                MembershipManagement.ApplyGracePeriodPreset (Rec."Grace Period Presets", Rec);
            end;
        }
        field(35;"Grace Period Relates To";Option)
        {
            Caption = 'Grace Period Relates To';
            OptionCaption = 'Start Date,End Date';
            OptionMembers = START_DATE,END_DATE;
        }
        field(40;"Grace Period Before";DateFormula)
        {
            Caption = 'Grace Period Before';
        }
        field(45;"Grace Period After";DateFormula)
        {
            Caption = 'Grace Period After';
        }
        field(46;"Grace Period Calculation";Option)
        {
            Caption = 'Grace Period Calculation';
            OptionCaption = 'Simple,Advanced';
            OptionMembers = SIMPLE,ADVANCED;
        }
        field(50;"Membership Duration";DateFormula)
        {
            Caption = 'Membership Duration';
        }
        field(60;"Price Calculation";Option)
        {
            Caption = 'Price Calculation';
            OptionCaption = 'Unit Price,Price Difference,Time Difference';
            OptionMembers = UNIT_PRICE,PRICE_DIFFERENCE,TIME_DIFFERENCE;
        }
        field(70;"Stacking Allowed";Boolean)
        {
            Caption = 'Stacking Allowed';
        }
        field(80;"Upgrade With New Duration";Boolean)
        {
            Caption = 'Upgrade With New Duration';
        }
        field(85;"Auto-Admit Member On Sale";Option)
        {
            Caption = 'Auto-Admit Member On Sale';
            OptionCaption = 'No,Yes,Ask';
            OptionMembers = NO,YES,ASK;
        }
        field(90;"Member Unit Price";Decimal)
        {
            Caption = 'Member Unit Price';
        }
        field(95;"Member Count Calculation";Option)
        {
            Caption = 'Member Count Calculation';
            OptionCaption = ' ,Named Members,Anonymous Members,All Members';
            OptionMembers = NA,NAMED,ANONYMOUS,ALL;
        }
        field(100;"Auto-Renew To";Code[20])
        {
            Caption = 'Auto-Renew To';
            TableRelation = "MM Membership Alteration Setup"."Sales Item No." WHERE ("Alteration Type"=CONST(AUTORENEW));
        }
        field(110;"Not Available Via Web Service";Boolean)
        {
            Caption = 'Not Available Via Web Service';
        }
        field(120;"Assign Loyalty Points On Sale";Boolean)
        {
            Caption = 'Assign Loyalty Points On Sale';
        }
        field(130;"Card Expired Action";Option)
        {
            Caption = 'Card Expired Action';
            OptionCaption = 'Ignore,Prevent,Update Existing,Issue New';
            OptionMembers = IGNORE,PREVENT,UPDATE,NEW;
        }
    }

    keys
    {
        key(Key1;"Alteration Type","From Membership Code","Sales Item No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        ValidateRec();
    end;

    trigger OnModify()
    begin
        ValidateRec();
    end;

    trigger OnRename()
    begin
        ValidateRec();
    end;

    var
        NOT_SAME_COMMUNITY: Label 'The commity must be the same for both memberships.';

    local procedure ValidateRec()
    var
        FromMembershipSetup: Record "MM Membership Setup";
        ToMembershipSetup: Record "MM Membership Setup";
        BlankDateformula: DateFormula;
    begin
        TestField ("From Membership Code");

        if ("Alteration Type" = "Alteration Type"::UPGRADE) then
          TestField ("To Membership Code");

        //-+MM1.19 [268166] IF ("Alteration Type" IN ["Alteration Type"::EXTEND, "Alteration Type"::RENEW]) THEN begin
        //-+MM1.22 [286922] IF (("Alteration Type" IN ["Alteration Type"::EXTEND, "Alteration Type"::RENEW]) OR
        if (("Alteration Type" in ["Alteration Type"::EXTEND, "Alteration Type"::RENEW, "Alteration Type"::AUTORENEW]) or
          (("Alteration Type" = "Alteration Type"::UPGRADE) and ("Upgrade With New Duration")) ) then begin
          TestField ("Membership Duration");
        end else begin
          TestField ("Membership Duration", BlankDateformula);
        end;

        TestField ("Sales Item No.");

        if ("Activate Grace Period") then begin
          if ("Alteration Type" <> "Alteration Type"::REGRET) then
            TestField ("Grace Period Before");
          TestField ("Grace Period After");
        end;

        if (FromMembershipSetup.Get ("From Membership Code")) then
          if (ToMembershipSetup.Get ("To Membership Code")) then
            if (ToMembershipSetup."Community Code" <> FromMembershipSetup."Community Code") then
              Error (NOT_SAME_COMMUNITY);
    end;
}

