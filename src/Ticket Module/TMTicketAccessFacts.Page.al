page 6060114 "NPR TM Ticket Access Facts"
{
    // NPR4.14/TSA/20150803/CASE214262 - Initial Version
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions

    Caption = 'Ticket Access Facts';
    PageType = List;
    SourceTable = "NPR TM Ticket Access Fact";
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Fact Name"; "Fact Name")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                }
                field("Fact Code"; "Fact Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Block; Block)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
    }

    procedure GetSelectionFilter(): Code[250]
    var
        Fact: Record "NPR TM Ticket Access Fact";
        FirstFact: Code[30];
        LastFact: Code[30];
        SelectionFilter: Code[250];
        FactCount: Integer;
        More: Boolean;
    begin
        // EXIT (GETFILTER ("Fact Code"));

        CurrPage.SetSelectionFilter(Fact);
        FactCount := Fact.Count;

        if (FactCount > 0) then begin
            Fact.Find('-');

            while (FactCount > 0) do begin
                FactCount := FactCount - 1;
                Fact.MarkedOnly(false);
                FirstFact := Fact."Fact Code";
                LastFact := FirstFact;
                More := (FactCount > 0);
                while More do begin
                    if Fact.Next = 0 then begin
                        More := false;
                    end else begin
                        if not Fact.Mark then begin
                            More := false;
                        end else begin
                            LastFact := Fact."Fact Code";
                            FactCount := FactCount - 1;
                            if FactCount = 0 then
                                More := false;
                        end;
                    end;
                end;

                if SelectionFilter <> '' then
                    SelectionFilter := SelectionFilter + '|';
                if FirstFact = LastFact then
                    SelectionFilter := SelectionFilter + FirstFact
                else
                    SelectionFilter := SelectionFilter + FirstFact + '..' + LastFact;
                if FactCount > 0 then begin
                    Fact.MarkedOnly(true);
                    Fact.Next;
                end;
            end;

        end;

        exit(SelectionFilter);
    end;

    procedure SetSelection(var TicketFact: Record "NPR TM Ticket Access Fact")
    begin
        CurrPage.SetSelectionFilter(TicketFact);
    end;
}

