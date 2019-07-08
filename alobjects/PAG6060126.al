page 6060126 "MM Members"
{
    // TM1.00/TSA/20151215  CASE 228982 NaviPartner Ticket Management
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.17/TSA/20161227  CASE 262040 Added Suggested Membercount In Sales
    // MM1.18/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // NPR5.43/TSA/20170328  CASE 270067 Added register arrival button for member.
    // MM1.19/NPKNAV/20170331  CASE 270627 Transport MM1.19 - 31 March 2017
    // MM1.21/TSA /20170721 CASE 284653 Added button "Arrival Log"
    // MM1.22/TSA /20170905 CASE 289429 Removed Delete Member option from List Page, Removed Blocked Filter
    // MM1.24/TSA /20171115 CASE 296437 Bugfix
    // NPR5.43/TS  /20180626 CASE 320616 Added Field Contact No.
    // MM1.32/TSA/20180725  CASE 323333 Transport MM1.32 - 25 July 2018

    Caption = 'Members';
    CardPageID = "MM Member Card";
    DataCaptionExpression = "External Member No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "MM Member";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Member No.";"External Member No.")
                {
                }
                field("First Name";"First Name")
                {
                }
                field("Middle Name";"Middle Name")
                {
                }
                field("Last Name";"Last Name")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field(Gender;Gender)
                {
                }
                field(Birthday;Birthday)
                {
                }
                field("Contact No.";"Contact No.")
                {
                }
                field("E-Mail News Letter";"E-Mail News Letter")
                {
                }
                field("E-Mail Address";"E-Mail Address")
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field(Address;Address)
                {
                }
                field("Post Code Code";"Post Code Code")
                {
                }
                field(City;City)
                {
                }
                field(Country;Country)
                {
                }
                field("Display Name";"Display Name")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Register Arrival")
            {
                Caption = 'Register Arrival';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MemberWebService: Codeunit "MM Member WebService";
                    ResponseMessage: Text;
                begin
                    //-MM1.19 [270067]
                    //-MM1.24 [296437]
                    if (not MemberWebService.MemberRegisterArrival ("External Member No.", '', 'RTC-CLIENT', ResponseMessage)) then
                      Error (ResponseMessage);

                    Message (ResponseMessage);
                    //+MM1.19 [270067]
                end;
            }
        }
        area(navigation)
        {
            action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Member Arrival Log";
                RunPageLink = "External Member No."=FIELD("External Member No.");
            }
        }
    }
}

