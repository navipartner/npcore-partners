page 6059787 "NPR Ticket AccessCapacity List"
{
    UsageCategory = None;
    Caption = 'Access Capacity';
    SourceTable = "NPR Ticket Access Cap. Slots";

    layout
    {
        area(content)
        {
            field(TicketTypeFilter; TicketTypeFilter)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Type';
                ToolTip = 'Specifies the value of the Type field';

                trigger OnLookup(var Text: Text): Boolean
                begin

                    TicketManagement.LookUpTicketType(TicketTypeFilter);
                    SetTicketTypeFilter;
                end;

                trigger OnValidate()
                begin

                    SetTicketTypeFilter;
                end;
            }
            field(DateFilter; DateFilter)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Date';
                ToolTip = 'Specifies the value of the Date field';

                trigger OnValidate()
                begin

                    SetFilter("Access Date", DateFilter);
                    DateFilter := GetFilter("Access Date");
                    CurrPage.Update;
                end;
            }
            repeater(Control6150616)
            {
                ShowCaption = false;
                field("Ticket Type Code"; "Ticket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                }
                field("Access Date"; "Access Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Access Date field';
                }
                field("Access Start"; "Access Start")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Access Time field';
                }
                field("Access End"; "Access End")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Access End field';
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Point Card - Issued Cards field';
                }
                field("Quantity Reserved"; "Quantity Reserved")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Access Reservatation field';
                }
            }
        }
    }

    actions
    {
    }

    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketAccessReservationMgt: Codeunit "NPR Ticket AccessReserv.Mgt";
        TicketTypeFilter: Code[20];
        DateFilter: Text[30];

    procedure SetTicketTypeFilter()
    begin
        if TicketTypeFilter <> '' then begin
            FilterGroup(2);
            SetFilter("Ticket Type Code", TicketTypeFilter);
            CurrPage.Update(false);
            FilterGroup(0);
        end else begin
            FilterGroup(2);
            SetRange("Ticket Type Code");
            CurrPage.Update(false);
            FilterGroup(0);
        end;
    end;
}

