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
                field("Auto-Admitt Member On Sale";"Auto-Admitt Member On Sale")
                {
                }
                field("Member Card Type Selection";"Member Card Type Selection")
                {
                }
                field("Member Card Type";"Member Card Type")
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
                    CreateMembership ();
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

    local procedure CreateMembership()
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MemberInfoCapturePage: Page "MM Member Info Capture";
        MembershipPage: Page "MM Membership Card";
        PageAction: Action;
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
        Membership: Record "MM Membership";
        ResponseMessage: Text;
    begin

        MemberInfoCapture.Init ();
        //-+MM1.18 [255459]
        MemberInfoCapture."Item No." := "No.";
        MemberInfoCapture.Insert ();

        MemberInfoCapturePage.SetRecord (MemberInfoCapture);
        MemberInfoCapture.SetFilter ("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView (MemberInfoCapture);
        Commit ();

        MemberInfoCapturePage.LookupMode (true);
        PageAction := MemberInfoCapturePage.RunModal ();

        if (PageAction = ACTION::LookupOK) then begin
          MemberInfoCapturePage.GetRecord (MemberInfoCapture);

          //-MM1.22 [287080]
          //MembershipEntryNo := MembershipManagement.CreateMembershipAll (Rec, MemberInfoCapture, TRUE);
          case Rec."Business Flow Type" of

            Rec."Business Flow Type"::MEMBERSHIP :
              begin
                MembershipEntryNo := MembershipManagement.CreateMembershipAll (Rec, MemberInfoCapture, true);
                Membership.Get (MembershipEntryNo);
                MembershipPage.SetRecord (Membership);
                MembershipPage.Run ();
              end;

            Rec."Business Flow Type"::ADD_NAMED_MEMBER :
              MembershipManagement.AddMemberAndCard (true, MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);

            Rec."Business Flow Type"::ADD_ANONYMOUS_MEMBER :
              MembershipManagement.AddAnonymousMember (MemberInfoCapture, MemberInfoCapture.Quantity);

            Rec."Business Flow Type"::REPLACE_CARD :
              begin
                MembershipManagement.BlockMemberCard (MembershipManagement.GetCardEntryNoFromExtCardNo (MemberInfoCapture."Replace External Card No."), true);
                MembershipManagement.IssueMemberCard (true, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
              end;

            Rec."Business Flow Type"::ADD_CARD :
              MembershipManagement.IssueMemberCard (true, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
          end;
          //+MM1.22 [287080]

        end;
    end;
}

