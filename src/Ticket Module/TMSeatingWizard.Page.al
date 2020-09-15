page 6151132 "NPR TM Seating Wizard"
{
    // TM1.45/TSA/20200122  CASE 322432-01 Transport TM1.45 - 22 January 2020

    Caption = 'Seating Wizard';
    PageType = Worksheet;
    SourceTable = "Integer";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Sections)
            {
                field(SelectedSectionCount; SelectedSectionCount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Selected Sections';
                    Editable = false;
                }
                field(SpanSections; SpanSections)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Numbering Spans Sections';
                }
            }
            group(Structure)
            {
                Caption = 'Structure';
                field(RowLabel; RowLabel)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Row Label';
                }
                field(Rows; Rows)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Rows to Create';
                }
                field(SeatLabel; SeatLabel)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Seat Label';
                }
                field(SeatsPerRow; SeatsPerRow)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Seats per Row';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                group(Row)
                {
                    Caption = 'Row';
                    field(RowStartNumber; RowStartNumber)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Start with Number (Row)';
                    }
                    field("SeatingSetup.""Row Numbering"""; SeatingSetup."Row Numbering")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Numbering (Row)';
                    }
                    field(RowNumberLayout; RowNumberLayout)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Section Numbering Layout';
                        OptionCaption = 'Across Sections,Section by Section';
                    }
                }
                group(Seat)
                {
                    Caption = 'Seat';
                    field(SeatStartNumber; SeatStartNumber)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Start with Number (Seat)';
                    }
                    field("SeatingSetup.""Seat Numbering"""; SeatingSetup."Seat Numbering")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Numbering (Seat)';
                    }
                    field(SeatingIncrement; SeatingIncrement)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Increment Style';
                        OptionCaption = 'Consecutive,Odd,Even';
                    }
                    field(ContinuousNumbering; ContinuousNumbering)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Continuous Numbering';
                    }
                }
            }
            group(Split)
            {
                field(SplitOption; SplitOption)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Horizontal,Vertical,Diagonal (Left to Right),Diagonal (Right to Left)';
                }
                field(SplitList; SplitList)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Split On';
                }
            }
        }
    }

    actions
    {
    }

    var
        SeatingSetup: Record "NPR TM Seating Setup";
        Rows: Integer;
        SeatsPerRow: Integer;
        RowStartNumber: Code[10];
        SeatStartNumber: Code[10];
        ContinuousNumbering: Boolean;
        RowLabel: Text[30];
        SeatLabel: Text[30];
        SeatingIncrement: Option CONSECUTIVE,ODD,EVEN;
        ShowStructure: Boolean;
        ShowNumbering: Boolean;
        RowNumberLayout: Option ACROSS,DOWN;
        SelectedSectionCount: Integer;
        SpanSections: Boolean;
        SplitList: Code[20];
        SplitOption: Option HORIZONTAL,VERTICAL,DIAGONAL_LR,DIAGONAL_RL;

    procedure SetSectionTabValues(pSectionCount: Integer; pSectionNames: Text)
    begin

        SelectedSectionCount := pSectionCount;
    end;

    procedure ShowStructureTab(Show: Boolean)
    begin

        ShowStructure := Show;
    end;

    procedure ShowNumberingTab(Show: Boolean)
    begin

        ShowNumbering := Show;
    end;

    procedure ShowSplitOption()
    begin
    end;

    procedure GetStructureOptions(var vNumberOfRows: Integer; var vRowLabel: Text[80]; var vNumberOfSeats: Integer; var vSeatLabel: Text[80])
    begin

        vNumberOfRows := Rows;
        vRowLabel := RowLabel;

        vNumberOfSeats := SeatsPerRow;
        vSeatLabel := SeatLabel;
    end;

    procedure GetNumberingOptions(var vRowNumberingOrder: Option; var vRowStartNumber: Code[10]; var vSeatNumberingOrder: Option; var vSeatStartNumber: Code[10]; var vContinuousSeatNumbering: Boolean; var vSeatingIncrement: Option; var vSpanSections: Boolean)
    begin

        vRowNumberingOrder := SeatingSetup."Row Numbering";
        vRowStartNumber := RowStartNumber;

        vSeatNumberingOrder := SeatingSetup."Seat Numbering";
        vSeatStartNumber := SeatStartNumber;

        vContinuousSeatNumbering := ContinuousNumbering;
        vSeatingIncrement := SeatingIncrement;

        vSpanSections := SpanSections;
    end;

    procedure GetSplitOptions(var vSplitOption: Option; var vSplitAtList: Code[20])
    begin

        vSplitAtList := SplitList;
        vSplitOption := SplitOption;
    end;
}

