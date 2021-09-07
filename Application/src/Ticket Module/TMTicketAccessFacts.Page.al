page 6060114 "NPR TM Ticket Access Facts"
{
    Caption = 'Ticket Access Facts';
    PageType = List;
    SourceTable = "NPR TM Ticket Access Fact";
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Fact Name"; Rec."Fact Name")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Fact Name field';
                }
                field("Fact Code"; Rec."Fact Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Fact Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Block; Rec.Block)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Block field';
                }
            }
        }
    }

    actions
    {
    }

    procedure GetSelectionFilter(): Text
    var
        Fact: Record "NPR TM Ticket Access Fact";
        FirstFact: Code[30];
        LastFact: Code[30];
        SelectionFilter: Text;
        FactCount: Integer;
        More: Boolean;
    begin

        CurrPage.SetSelectionFilter(Fact);
        FactCount := Fact.Count();

        if (FactCount > 0) then begin
            Fact.Find('-');

            while (FactCount > 0) do begin
                FactCount := FactCount - 1;
                Fact.MarkedOnly(false);
                FirstFact := Fact."Fact Code";
                LastFact := FirstFact;
                More := (FactCount > 0);
                while More do begin
                    if Fact.Next() = 0 then begin
                        More := false;
                    end else begin
                        if not Fact.Mark() then begin
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
                    Fact.Next();
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

