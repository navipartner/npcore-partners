table 6060136 "NPR MM Members. Alter. Setup"
{

    Caption = 'Membership Alteration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Alteration Type"; Option)
        {
            Caption = 'Alteration Type';
            DataClassification = CustomerContent;
            InitValue = RENEW;
            OptionCaption = 'Regret,Renew,Upgrade,Extend,Cancel,Auto-Renew';
            OptionMembers = REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW;
        }
        field(2; "From Membership Code"; Code[20])
        {
            Caption = 'From Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";

            trigger OnValidate()
            begin

                if ("Alteration Type" in ["Alteration Type"::REGRET, "Alteration Type"::CANCEL]) then
                    "To Membership Code" := '';
            end;
        }
        field(4; "Sales Item No."; Code[20])
        {
            Caption = 'Sales Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin

                if (Item.Get("Sales Item No.")) then
                    Description := Item.Description;
            end;
        }
        field(9; "Presentation Order"; Integer)
        {
            Caption = 'Presentation Order';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "To Membership Code"; Code[20])
        {
            Caption = 'To Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(20; "Alteration Activate From"; Option)
        {
            Caption = 'Alteration Activate From';
            DataClassification = CustomerContent;
            OptionCaption = 'As soon as possible,Date Formula,Back-to-Back';
            OptionMembers = ASAP,DF,B2B;
        }
        field(25; "Alteration Date Formula"; DateFormula)
        {
            Caption = 'Alteration Date Formula';
            DataClassification = CustomerContent;
        }
        field(26; "Age Constraint Type"; Option)
        {
            Caption = 'Age Constraint Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Less Than,Less Than or Equal,Greater Than,Greater Than or Equal,Equal';
            OptionMembers = NA,LT,LTE,GT,GTE,E;
        }
        field(27; "Age Constraint (Years)"; Integer)
        {
            Caption = 'Age Constraint (Years)';
            DataClassification = CustomerContent;
        }
        field(28; "Age Constraint Applies To"; Option)
        {
            Caption = 'Age Constraint Applies To';
            DataClassification = CustomerContent;
            OptionCaption = 'All Members,Youngest Member,Oldest Member,Administrators,Dependants';
            OptionMembers = ALL,YOUNGEST,OLDEST,ADMINS,DEPENDANTS;
        }
        field(30; "Activate Grace Period"; Boolean)
        {
            Caption = 'Activate Grace Period';
            DataClassification = CustomerContent;
        }
        field(32; "Grace Period Presets"; Option)
        {
            Caption = 'Grace Period Presets';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Valid for Expired Memberships,Valid for Active Memberships';
            OptionMembers = NA,EXPIRED_MEMBERSHIP,ACTIVE_MEMBERSHIP;

            trigger OnValidate()
            var
                MembershipManagement: Codeunit "NPR MM Membership Mgt.";
            begin

                MembershipManagement.ApplyGracePeriodPreset(Rec."Grace Period Presets", Rec);
            end;
        }
        field(35; "Grace Period Relates To"; Option)
        {
            Caption = 'Grace Period Relates To';
            DataClassification = CustomerContent;
            OptionCaption = 'Start Date,End Date';
            OptionMembers = START_DATE,END_DATE;
        }
        field(40; "Grace Period Before"; DateFormula)
        {
            Caption = 'Grace Period Before';
            DataClassification = CustomerContent;
        }
        field(45; "Grace Period After"; DateFormula)
        {
            Caption = 'Grace Period After';
            DataClassification = CustomerContent;
        }
        field(46; "Grace Period Calculation"; Option)
        {
            Caption = 'Grace Period Calculation';
            DataClassification = CustomerContent;
            OptionCaption = 'Simple,Advanced';
            OptionMembers = SIMPLE,ADVANCED;
        }
        field(50; "Membership Duration"; DateFormula)
        {
            Caption = 'Membership Duration';
            DataClassification = CustomerContent;
        }
        field(60; "Price Calculation"; Option)
        {
            Caption = 'Price Calculation';
            DataClassification = CustomerContent;
            OptionCaption = 'Unit Price,Price Difference,Time Difference';
            OptionMembers = UNIT_PRICE,PRICE_DIFFERENCE,TIME_DIFFERENCE;
        }
        field(70; "Stacking Allowed"; Boolean)
        {
            Caption = 'Stacking Allowed';
            DataClassification = CustomerContent;
        }
        field(80; "Upgrade With New Duration"; Boolean)
        {
            Caption = 'Upgrade With New Duration';
            DataClassification = CustomerContent;
        }
        field(85; "Auto-Admit Member On Sale"; Option)
        {
            Caption = 'Auto-Admit Member On Sale';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes,Ask';
            OptionMembers = NO,YES,ASK;
        }
        field(90; "Member Unit Price"; Decimal)
        {
            Caption = 'Member Unit Price';
            DataClassification = CustomerContent;
        }
        field(95; "Member Count Calculation"; Option)
        {
            Caption = 'Member Count Calculation';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Named Members,Anonymous Members,All Members';
            OptionMembers = NA,NAMED,ANONYMOUS,ALL;
        }
        field(100; "Auto-Renew To"; Code[20])
        {
            Caption = 'Auto-Renew To';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Members. Alter. Setup"."Sales Item No." WHERE("Alteration Type" = CONST(AUTORENEW));
        }
        field(110; "Not Available Via Web Service"; Boolean)
        {
            Caption = 'Not Available Via Web Service';
            DataClassification = CustomerContent;
        }
        field(120; "Assign Loyalty Points On Sale"; Boolean)
        {
            Caption = 'Assign Loyalty Points On Sale';
            DataClassification = CustomerContent;
        }
        field(130; "Card Expired Action"; Option)
        {
            Caption = 'Card Expired Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Ignore,Prevent,Update Existing,Issue New';
            OptionMembers = IGNORE,PREVENT,UPDATE,NEW;
        }
    }

    keys
    {
        key(Key1; "Alteration Type", "From Membership Code", "Sales Item No.")
        {
        }
        key(Key2; "Presentation Order")
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
        FromMembershipSetup: Record "NPR MM Membership Setup";
        ToMembershipSetup: Record "NPR MM Membership Setup";
        BlankDateformula: DateFormula;
    begin
        TestField("From Membership Code");

        if ("Alteration Type" = "Alteration Type"::UPGRADE) then
            TestField("To Membership Code");

        if (("Alteration Type" in ["Alteration Type"::EXTEND, "Alteration Type"::RENEW, "Alteration Type"::AUTORENEW]) or
          (("Alteration Type" = "Alteration Type"::UPGRADE) and ("Upgrade With New Duration"))) then begin
            TestField("Membership Duration");
        end else begin
            TestField("Membership Duration", BlankDateformula);
        end;

        TestField("Sales Item No.");

        if ("Activate Grace Period") then begin
            if ("Alteration Type" <> "Alteration Type"::REGRET) then
                TestField("Grace Period Before");
            TestField("Grace Period After");
        end;

        if (FromMembershipSetup.Get("From Membership Code")) then
            if (ToMembershipSetup.Get("To Membership Code")) then
                if (ToMembershipSetup."Community Code" <> FromMembershipSetup."Community Code") then
                    Error(NOT_SAME_COMMUNITY);
    end;
}

