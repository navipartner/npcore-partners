page 6059787 "Ticket Access Capacity List"
{
    Caption = 'Access Capacity';
    SourceTable = "Ticket Access Capacity Slots";

    layout
    {
        area(content)
        {
            field(TicketTypeFilter; TicketTypeFilter)
            {
                ApplicationArea = All;
                Caption = 'Type';

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
                ApplicationArea = All;
                Caption = 'Date';

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
                    ApplicationArea = All;
                }
                field("Access Date"; "Access Date")
                {
                    ApplicationArea = All;
                }
                field("Access Start"; "Access Start")
                {
                    ApplicationArea = All;
                }
                field("Access End"; "Access End")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity Reserved"; "Quantity Reserved")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
        TicketManagement: Codeunit "TM Ticket Management";
        TicketAccessReservationMgt: Codeunit "Ticket Access Reservation Mgt.";
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

