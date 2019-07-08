page 6059787 "Ticket Access Capacity List"
{
    Caption = 'Access Capacity';
    SourceTable = "Ticket Access Capacity Slots";

    layout
    {
        area(content)
        {
            field(TicketTypeFilter;TicketTypeFilter)
            {
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
            field(DateFilter;DateFilter)
            {
                Caption = 'Date';

                trigger OnValidate()
                begin

                    SetFilter("Access Date",DateFilter);
                    DateFilter := GetFilter("Access Date");
                    CurrPage.Update;
                end;
            }
            repeater(Control6150616)
            {
                ShowCaption = false;
                field("Ticket Type Code";"Ticket Type Code")
                {
                }
                field("Access Date";"Access Date")
                {
                }
                field("Access Start";"Access Start")
                {
                }
                field("Access End";"Access End")
                {
                }
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Quantity Reserved";"Quantity Reserved")
                {
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
          SetFilter("Ticket Type Code",TicketTypeFilter);
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

