table 6060127 "NPR MM Membership"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM80.1.08/TSA/20160223  CASE 234913 - Include company name field on membership
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.15/TSA/20160811  CASE 248625 Change ondelete code to remove the membercard when deleting membership
    // MM1.17/TSA/20161214  CASE 243075 Member Point System - Added key to "Customer No.", Added Point flow fields 100-120
    // MM1.18/TSA/20170302  CASE 265340 Added Customer and Contact sync on modify ();
    // MM1.22/TSA /20170829 CASE 286922 Added field "Auto Renew", and "Auto-Renew Payment Method Code"
    // MM1.23/TSA /20171025 CASE 257011 Added fields "Modified At", "Replicated At", "Synchronized At"
    // MM1.24/TSA /20171129 CASE 298110 Refactored OnDelete trigger
    // MM1.26/TSA /20180316 CASE 308332 Added validation code to handle customer number change
    // MM1.29/TSA /20180503 CASE 313795 Add field 18 "Block Reason"
    // MM1.32/TSA /20180522 CASE 316251 Added index on "External Membership No."
    // MM1.33/TSA /20180824 CASE 326087 Testfield in onModify is not very good.
    // MM1.38/TSA /20190527 CASE 356057 Minor change
    // MM1.39/TSA /20190527 CASE 350968 Changed Auto-Renew from boolean to option
    // MM1.41/TSA /20191021 CASE 369123 Block cascasde
    // MM1.44/TSA /20200507 CASE 407401 Touched
    // MM1.45/TSA /20200707 CASE 413622 Incorrect and not required filter and loop on membership role
    // MM1.45/TSA /20200708 CASE 413622 Added field Has Membership Entries flow field

    Caption = 'Membership';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Memberships";
    LookupPageID = "NPR MM Memberships";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(9; "External Membership No."; Code[20])
        {
            Caption = 'External Membership No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(15; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MembershipRole: Record "NPR MM Membership Role";
                Contact: Record Contact;
            begin
                "Blocked At" := CreateDateTime(0D, 0T);
                "Blocked By" := '';
                if (Blocked) then begin
                    "Blocked At" := CurrentDateTime();
                    "Blocked By" := UserId;
                end;

                //-MM1.41 [369123]
                MembershipRole.SetFilter("Membership Entry No.", '=%1', "Entry No.");
                MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
                if (MembershipRole.FindSet()) then begin
                    repeat

                        MembershipRole.Validate(Blocked, Blocked);
                        MembershipRole.Modify();

                        if (Contact.Get(MembershipRole."Contact No.")) then begin
                            Contact.Validate("NPR Magento Contact", not Blocked);
                            Contact.Modify();
                        end;
                    until (MembershipRole.Next() = 0);
                end;
                //+MM1.41 [369123]
            end;
        }
        field(16; "Blocked At"; DateTime)
        {
            Caption = 'Blocked At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Blocked By"; Code[30])
        {
            Caption = 'Blocked By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "Block Reason"; Option)
        {
            Caption = 'Block Reason';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Expired,User Request,Internal,Anonymized';
            OptionMembers = UNKNOWN,EXPIRED,USER_REQUEST,INTERNAL,ANONYMIZED;
        }
        field(20; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(21; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
                Membership: Record "NPR MM Membership";
                Community: Record "NPR MM Member Community";
                MembershipRole: Record "NPR MM Membership Role";
            begin

                //-#308332 [308332]
                Community.Get("Community Code");

                if ((Rec."Customer No." <> '') and (xRec."Customer No." <> Rec."Customer No.")) then begin
                    if not Confirm(RELINK_MEMBERSHIP, false, Membership.TableCaption, Rec."External Membership No.", Customer.TableCaption, Rec."Customer No.") then
                        Error('');

                    Membership.SetFilter("Customer No.", '=%1', Rec."Customer No.");
                    Membership.SetFilter(Blocked, '=%1', false);
                    Membership.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
                    if (Membership.FindFirst()) then begin

                        if (Community."Activate Loyalty Program") then
                            Error(DUPLICATE_CUSTOMERNO, Community.FieldCaption("Activate Loyalty Program"), Rec."External Membership No.", Membership."External Membership No.",
                              Membership.FieldCaption("Customer No."), Rec."Customer No.");

                        MembershipRole.SetFilter("Membership Entry No.", '=%1', Rec."Entry No.");
                        MembershipRole.ModifyAll("Contact No.", '');

                    end;
                    Modify(); // membership must be updated before OnModify table trigger executes
                end;
                //+#308332 [308332]
            end;
        }
        field(22; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(23; "Issued Date"; Date)
        {
            Caption = 'Issued Date';
            DataClassification = CustomerContent;
        }
        field(30; "Auto-Renew"; Option)
        {
            Caption = 'Auto-Renew';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Yes (Internal),Yes (External)';
            OptionMembers = NO,YES_INTERNAL,YES_EXTERNAL;

            trigger OnValidate()
            begin
                TestField("Customer No.");
            end;
        }
        field(35; "Auto-Renew Payment Method Code"; Code[10])
        {
            Caption = 'Auto-Renew Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(36; "Auto-Renew External Data"; Text[200])
        {
            Caption = 'Auto-Renew External Data';
            DataClassification = CustomerContent;
        }
        field(100; "Awarded Points (Sale)"; Integer)
        {
            CalcFormula = Sum ("NPR MM Members. Points Entry".Points WHERE("Membership Entry No." = FIELD("Entry No."),
                                                                         "Entry Type" = CONST(SALE),
                                                                         "Posting Date" = FIELD("Date Filter")));
            Caption = 'Awarded Points (Sale)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Awarded Points (Refund)"; Integer)
        {
            CalcFormula = Sum ("NPR MM Members. Points Entry".Points WHERE("Membership Entry No." = FIELD("Entry No."),
                                                                         "Entry Type" = CONST(REFUND),
                                                                         "Posting Date" = FIELD("Date Filter")));
            Caption = 'Awarded Points (Refund)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; "Redeemed Points (Withdrawl)"; Integer)
        {
            CalcFormula = Sum ("NPR MM Members. Points Entry".Points WHERE("Membership Entry No." = FIELD("Entry No."),
                                                                         "Entry Type" = CONST(POINT_WITHDRAW),
                                                                         "Posting Date" = FIELD("Date Filter")));
            Caption = 'Redeemed Points (Withdrawl)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; "Redeemed Points (Deposit)"; Integer)
        {
            CalcFormula = Sum ("NPR MM Members. Points Entry".Points WHERE("Membership Entry No." = FIELD("Entry No."),
                                                                         "Entry Type" = CONST(POINT_DEPOSIT),
                                                                         "Posting Date" = FIELD("Date Filter")));
            Caption = 'Redeemed Points (Deposit)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(104; "Expired Points"; Integer)
        {
            CalcFormula = Sum ("NPR MM Members. Points Entry".Points WHERE("Membership Entry No." = FIELD("Entry No."),
                                                                         "Entry Type" = CONST(EXPIRED),
                                                                         "Posting Date" = FIELD("Date Filter")));
            Caption = 'Expired Points';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Remaining Points"; Integer)
        {
            CalcFormula = Sum ("NPR MM Members. Points Entry".Points WHERE("Membership Entry No." = FIELD("Entry No."),
                                                                         "Posting Date" = FIELD("Date Filter")));
            Caption = 'Remaining Points';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(199; "Document ID"; Text[100])
        {
            Caption = 'Document ID';
            DataClassification = CustomerContent;
        }
        field(200; "Modified At"; DateTime)
        {
            Caption = 'Modified At';
            DataClassification = CustomerContent;
        }
        field(210; "Replicated At"; DateTime)
        {
            Caption = 'Replicated At';
            DataClassification = CustomerContent;
        }
        field(215; "Synchronized At"; DateTime)
        {
            Caption = 'Synchronized At';
            DataClassification = CustomerContent;
        }
        field(1000; "Has Membership Entry"; Boolean)
        {
            CalcFormula = Exist ("NPR MM Membership Entry" WHERE("Membership Entry No." = FIELD("Entry No."),
                                                             Blocked = CONST(false),
                                                             Context = CONST(NEW)));
            Caption = 'Has Membership Entry';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Customer No.")
        {
        }
        key(Key3; "Membership Code")
        {
        }
        key(Key4; "External Membership No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipLedgerEntry: Record "NPR MM Membership Entry";
        MemberCard: Record "NPR MM Member Card";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        MembershipManagement.DeleteMembership("Entry No.", false);
    end;

    trigger OnModify()
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipRole: Record "NPR MM Membership Role";
        Community: Record "NPR MM Member Community";
    begin

        //+#308332 [308332]
        Community.Get("Community Code");
        if ("Customer No." = '') then
            if (Community."Membership to Cust. Rel.") then
                //-MM1.33 [326087]
                //TESTFIELD(Blocked);
                exit;
        //+MM1.33 [326087]

        //+#308332 [308332]

        //-MM1.45 [413622]
        // MembershipRole.SETFILTER ("Member Entry No.", '=%1', "Entry No.");
        // IF (MembershipRole.FINDSET ()) THEN BEGIN
        //  REPEAT
        //    MembershipManagement.SynchronizeCustomerAndContact (MembershipRole."Membership Entry No.");
        //  UNTIL (MembershipRole.NEXT () = 0);
        // END;
        MembershipManagement.SynchronizeCustomerAndContact(Rec."Entry No.");
        //+MM1.45 [413622]
    end;

    var
        RELINK_MEMBERSHIP: Label 'Are you sure you want to link %1 %2 with %3 %4?';
        DUPLICATE_CUSTOMERNO: Label 'When %1 is activated, memberships must have unique customer numbers. Membership %2 and %3 can not have the same %4 %5.';
}

