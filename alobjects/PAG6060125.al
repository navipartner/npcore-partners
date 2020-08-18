page 6060125 "MM Membership Sales Setup"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.10/TSA/20160331  CASE 234591 CreateMembershipAll changed signature
    // MM1.15/TSA/20160817  CASE 248625 Transport MM1.15 - 19 July 2016
    // MM1.17/TSA/20161227  CASE 262040 Added Suggested Membercount In Sales
    // MM1.18/TSA/20170217  CASE 255459 The Member Info Page needs to know the item number because it has become smarter
    // MM1.18/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // MM1.22/TSA /20170808 CASE 285403 Added "Assign Loyalty Points On Sale"
    // MM1.22/TSA /20170821 CASE 287080 Business Flow Type "Anonymous"
    // MM1.22/TSA /20170829 CASE 286922 Added field "Auto-Renew To"
    // MM1.29.02/TSA /20180530 CASE 316450 Added field "Auto-Admitt Member On Sale"
    // MM1.32/TSA /20180711 CASE 318132 Member Card Type
    // MM1.40/TSA /20190612 CASE 357360 Disallowing foreign membership management from this page;
    // MM1.40/TSA /20190726 CASE 356090 Adding field "Magento M2 Membership Sign-up"
    // MM1.40/TSA /20190808 CASE 363147 Made CreateMembership function public and changed signature, refactored to use parameter record instance instead of Rec; previous comments /  versions removed
    // MM1.44/TSA /20200529 CASE 407401 Added Age Verification
    // MM1.45/TSA /20200728 CASE 407401 Added "Requires Guardian"

    Caption = 'Membership Sales Setup';
    PageType = List;
    SourceTable = "MM Membership Sales Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Business Flow Type";"Business Flow Type")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field("Valid From Base";"Valid From Base")
                {
                }
                field("Sales Cut-Off Date Calculation";"Sales Cut-Off Date Calculation")
                {
                }
                field("Valid From Date Calculation";"Valid From Date Calculation")
                {
                }
                field("Valid Until Calculation";"Valid Until Calculation")
                {
                }
                field("Duration Formula";"Duration Formula")
                {
                }
                field("Suggested Membercount In Sales";"Suggested Membercount In Sales")
                {
                }
                field("Assign Loyalty Points On Sale";"Assign Loyalty Points On Sale")
                {
                }
                field("Auto-Renew To";"Auto-Renew To")
                {
                }
                field("Auto-Admit Member On Sale";"Auto-Admit Member On Sale")
                {
                }
                field("Member Card Type Selection";"Member Card Type Selection")
                {
                }
                field("Member Card Type";"Member Card Type")
                {
                }
                field("Magento M2 Membership Sign-up";"Magento M2 Membership Sign-up")
                {
                }
                field("Age Constraint Type";"Age Constraint Type")
                {
                }
                field("Age Constraint (Years)";"Age Constraint (Years)")
                {
                }
                field("Requires Guardian";"Requires Guardian")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CreateMembership (Rec);
                end;
            }
            separator(Separator6150632)
            {
            }
            action("Import Members From File")
            {
                Caption = 'Import Members From File';
                Image = Import;
                RunObject = Codeunit "MM Import Members";
            }
            action("Failed Import Worksheet")
            {
                Caption = 'Failed Import Worksheet';
                Image = ImportLog;

                trigger OnAction()
                var
                    MemberInfoCapturePage: Page "MM Member Info Capture";
                    MemberInfoCapture: Record "MM Member Info Capture";
                begin

                    MemberInfoCapture.SetFilter ("Originates From File Import", '=%1', true);
                    MemberInfoCapturePage.SetTableView (MemberInfoCapture);
                    MemberInfoCapturePage.SetShowImportAction ();
                    MemberInfoCapturePage.Run ();
                end;
            }
        }
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = SetupList;
                RunObject = Page "MM Membership Setup";
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Retail Item List";
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "MM Memberships";
                RunPageLink = "Membership Code"=FIELD("Membership Code");
            }
            action("Community Setup")
            {
                Caption = 'Community Setup';
                Image = Group;
                RunObject = Page "MM Member Community";
            }
        }
    }

    trigger OnOpenPage()
    begin

        //-+MM1.18 [266769]
        Rec.SetFilter (Blocked, '=%1', false);
    end;

    procedure CreateMembership(MembershipSalesSetup: Record "MM Membership Sales Setup")
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MemberCommunity: Record "MM Member Community";
        MembershipSetup: Record "MM Membership Setup";
        MemberInfoCapturePage: Page "MM Member Info Capture";
        MembershipPage: Page "MM Membership Card";
        PageAction: Action;
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
        Membership: Record "MM Membership";
        ResponseMessage: Text;
        Rec: Record Item;
    begin

        //-MM1.40 [363147] Function refactored to use parameter record instance instead of Rec; previous comments /  versions removed
        MembershipSetup.Get (MembershipSalesSetup."Membership Code");

        MemberCommunity.Get (MembershipSetup."Community Code");
        MemberCommunity.CalcFields ("Foreign Membership");
        MemberCommunity.TestField ("Foreign Membership", false);

        MemberInfoCapture.Init ();
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
        MemberInfoCapture.Insert ();

        MemberInfoCapturePage.SetRecord (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView (MemberInfoCapture);
        Commit ();

        MemberInfoCapturePage.LookupMode (true);
        PageAction := MemberInfoCapturePage.RunModal ();

        if (PageAction = ACTION::LookupOK) then begin
          MemberInfoCapturePage.GetRecord (MemberInfoCapture);

          case MembershipSalesSetup."Business Flow Type" of

            MembershipSalesSetup."Business Flow Type"::MEMBERSHIP :
              begin
                MembershipEntryNo := MembershipManagement.CreateMembershipAll (MembershipSalesSetup, MemberInfoCapture, true);
                Membership.Get (MembershipEntryNo);
                MembershipPage.SetRecord (Membership);
                MembershipPage.Run ();
              end;

            MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER :
              MembershipManagement.AddMemberAndCard (true, MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);

            MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER :
              MembershipManagement.AddAnonymousMember (MemberInfoCapture, MemberInfoCapture.Quantity);

            MembershipSalesSetup."Business Flow Type"::REPLACE_CARD :
              begin
                MembershipManagement.BlockMemberCard (MembershipManagement.GetCardEntryNoFromExtCardNo (MemberInfoCapture."Replace External Card No."), true);
                MembershipManagement.IssueMemberCard (true, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
              end;

            MembershipSalesSetup."Business Flow Type"::ADD_CARD :
              MembershipManagement.IssueMemberCard (true, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
          end;
        end;
        //+MM1.40 [363147]
    end;
}

