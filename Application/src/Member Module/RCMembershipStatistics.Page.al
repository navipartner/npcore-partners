page 6060031 "NPR RC Membership Statistics"
{
    Caption = 'Membership Statistics';
    Extensible = False;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR RC Mem. Stat. Cues";

    layout
    {
        area(content)
        {
            cuegroup("Membership Statistics")
            {
                Caption = 'Membership Statistics';
                field("Active Members"; GetDecimalValueFromIntegerValue(Rec."Active Members"))
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Active Members field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    Caption = 'Active';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }
                field("First Time Members"; GetDecimalValueFromIntegerValue(Rec."First Time Members"))
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the First Time Members field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    Caption = 'First Time';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }
                field("First Time Members (%)"; Rec."First Time Members (%)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the First Time Members (%) field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>%';
                    Caption = 'First Time (%)';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }
                field("Recurring Members"; GetDecimalValueFromIntegerValue(Rec."Recurring Members"))
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Recurring Members field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    Caption = 'Recurring';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }

                field("Recurring Members (%)"; Rec."Recurring Members (%)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Recurring Members (%) field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>%';
                    Caption = 'Recurring (%)';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }
                field("Future Timeslot"; GetDecimalValueFromIntegerValue(Rec."Future Timeslot"))
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = Rec."Future Timeslot" > 0;
                    ToolTip = 'Specifies the value of the Future Timeslot field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    Caption = 'Future';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }
                field("Future Timeslot (%)"; Rec."Future Timeslot (%)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = Rec."Future Timeslot" > 0;
                    ToolTip = 'Specifies the value of the Future Timeslot (%) field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>%';
                    Caption = 'Future (%)';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }
                field("No. of. Members compared LY"; Rec."No. of. Members compared LY")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Compared LY (%)';
                    ToolTip = 'Specifies the value of the No. of. Members compared LY (%) field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>%';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }

                field("No. of. Members expire CM"; GetDecimalValueFromIntegerValue(Rec."No. of. Members expire CM"))
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Expire CM';
                    ToolTip = 'Specifies the value of the No. of. Members expire CM field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';
                    Visible = Rec."No. of. Members expire CM" > 0;
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }

                field("No. of. Members expire CM (%)"; Rec."No. of. Members expire CM (%)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Expire CM (%)';
                    Visible = Rec."No. of. Members expire CM" > 0;
                    ToolTip = 'Specifies the value of the No. of. Members expire CM field';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>%';
                    trigger OnDrillDown()
                    var
                    begin
                        Rec.ShowStatisticsRecord();
                    end;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Executes the Set Up Cues action';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                    CuesAndKpis: Codeunit "Cues And KPIs";
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalculateCues();
    end;

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    procedure GetDecimalValueFromIntegerValue(IntegerValue: Integer): Decimal
    begin
        exit(IntegerValue);
    end;

}

