page 6150989 "NPR CMTourBookingVisits"
{
    Extensible = false;
    Caption = 'Assign Times';
    PageType = List;
    SourceTable = "NPR CMTourBookingVisit";
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                ShowAsTree = true;
                TreeInitialState = ExpandAll;

                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The booking line, with the tickets of its package underneath.';
                    Editable = false;
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The item of the line or of the package ticket.';
                    Editable = false;
                }
                field(VisitDate; Rec.VisitDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The local visit date. Tickets follow the line until they get a visit of their own; clearing a ticket''s date makes it follow the line again.';

                    trigger OnValidate()
                    begin
                        SaveVisit();
                    end;
                }
                field(VisitTime; Rec.VisitTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The local visit time. Tickets follow the line until they get a visit of their own.';

                    trigger OnValidate()
                    begin
                        SaveVisit();
                    end;
                }
            }
        }
    }

    local procedure SaveVisit()
    begin
        _TourBookingMgt.SaveVisit(Rec);
        CurrPage.Update(true);
    end;

    internal procedure LoadLine(var OrderLine: Record "NPR CMOrderLine")
    begin
        _TourBookingMgt.LoadVisits(OrderLine, Rec);
    end;

    var
        _TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
}
