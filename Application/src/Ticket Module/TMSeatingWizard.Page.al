page 6151132 "NPR TM Seating Wizard"
{
    Extensible = False;
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
                    ToolTip = 'Specifies the value of the Selected Sections field';
                }
                field(SpanSections; SpanSections)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Numbering Spans Sections';
                    ToolTip = 'Specifies the value of the Numbering Spans Sections field';
                }
            }
            group(Structure)
            {
                Caption = 'Structure';
                field(RowLabel; RowLabel)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Row Label';
                    ToolTip = 'Specifies the value of the Row Label field';
                }
                field(Rows; Rows)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Rows to Create';
                    ToolTip = 'Specifies the value of the Rows to Create field';
                }
                field(SeatLabel; SeatLabel)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Seat Label';
                    ToolTip = 'Specifies the value of the Seat Label field';
                }
                field(SeatsPerRow; SeatsPerRow)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Seats per Row';
                    ToolTip = 'Specifies the value of the Seats per Row field';
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
                        ToolTip = 'Specifies the value of the Start with Number (Row) field';
                    }
                    field("Row Numbering"; SeatingSetup."Row Numbering")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Numbering (Row)';
                        ToolTip = 'Specifies the value of the Numbering (Row) field';
                    }
                    field(RowNumberLayout; RowNumberLayout)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Section Numbering Layout';
                        OptionCaption = 'Across Sections,Section by Section';
                        ToolTip = 'Specifies the value of the Section Numbering Layout field';
                    }
                }
                group(Seat)
                {
                    Caption = 'Seat';
                    field(SeatStartNumber; SeatStartNumber)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Start with Number (Seat)';
                        ToolTip = 'Specifies the value of the Start with Number (Seat) field';
                    }
                    field("Seat Numbering"; SeatingSetup."Seat Numbering")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Numbering (Seat)';
                        ToolTip = 'Specifies the value of the Numbering (Seat) field';
                    }
                    field(SeatingIncrement; SeatingIncrement)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Increment Style';
                        OptionCaption = 'Consecutive,Odd,Even';
                        ToolTip = 'Specifies the value of the Increment Style field';
                    }
                    field(ContinuousNumbering; ContinuousNumbering)
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        Caption = 'Continuous Numbering';
                        ToolTip = 'Specifies the value of the Continuous Numbering field';
                    }
                }
            }
            group(Split)
            {
                field(SplitOption; SplitOption)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Horizontal,Vertical,Diagonal (Left to Right),Diagonal (Right to Left)';
                    OptionCaption = 'HORIZONTAL,VERTICAL,DIAGONAL_LR,DIAGONAL_RL';
                    ToolTip = 'Specifies the value of the Horizontal,Vertical,Diagonal (Left to Right),Diagonal (Right to Left) field';
                }
                field(SplitList; SplitList)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Split On';
                    ToolTip = 'Specifies the value of the Split On field';
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

    end;

    procedure ShowNumberingTab(Show: Boolean)
    begin

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

