page 6151250 "NPR Retail Enter. Act - Ticket"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Issued Tickets"; IssuedTicketsCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issued Tickets field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Issued Tickets';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket List");
                    end;
                }
                field("Ticket Requests"; TicketRequestsCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Requests field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Ticket Requests';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Request");
                    end;
                }
                field("Ticket Types"; TicketTypesCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Type field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Ticket Types';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Type");
                    end;
                }
                field("Ticket Admission BOM"; TicketAdmissionBOMCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket BOM field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Ticket BOM';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket BOM");
                    end;
                }
                field("Ticket Schedules"; TicketSchedulesCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Schedules field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Ticket Schedules';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Schedules");
                    end;
                }
                field("Ticket Admissions"; TicketAdmissionsCount)
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Admissions";
                    ToolTip = 'Specifies the value of the Ticket Admissions field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Ticket Admissions';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Admissions");
                    end;
                }
            }
            cuegroup(Members)
            {
                Caption = 'Members';
                field(Control6; MembersCount)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Members field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Members';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR MM Members");
                    end;
                }
                field(Memberships; MembershipsCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Memberships field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Memberships';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR MM Memberships");
                    end;
                }
                field(Membercards; MembercardsCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membercards field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Member Cards';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR MM Member Card List");
                    end;
                }
            }

            cuegroup(Master)
            {
                Caption = 'Master';
                field(Items; ItemCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Items field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Items';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Item List");
                    end;
                }

                field(Contacts; ContactCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contacts field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Contacts';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Contact List");
                    end;

                }
                field(Customers; CustomerCount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customers field';
                    DecimalPlaces = 0 : 0;
                    Caption = 'Customers';
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Customer List");
                    end;
                }



            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.CalcFields("Issued Tickets", "Ticket Requests", "Ticket Types", "Ticket Admission BOM", "Ticket Schedules", "Ticket Admissions");
        IssuedTicketsCount := Rec."Issued Tickets";
        TicketRequestsCount := Rec."Ticket Requests";
        TicketTypesCount := Rec."Ticket Types";
        TicketAdmissionBOMCount := Rec."Ticket Admission BOM";
        TicketSchedulesCount := Rec."Ticket Schedules";
        TicketAdmissionsCount := Rec."Ticket Admissions";
        Rec.CalcFields(Members, Memberships, Membercards);
        MembersCount := Rec.Members;
        MembershipsCount := Rec.Memberships;
        MembercardsCount := Rec.Membercards;
        Rec.CalcFields(Items, Contacts, Customers);
        ItemCount := Rec.Items;
        ContactCount := Rec.Contacts;
        CustomerCount := Rec.Customers;
    end;

    var

        IssuedTicketsCount, TicketRequestsCount, TicketTypesCount, TicketAdmissionBOMCount, TicketSchedulesCount, TicketAdmissionsCount : Decimal;
        MembersCount, MembershipsCount, MembercardsCount : Decimal;
        ItemCount, CustomerCount, ContactCount : Decimal;


}

