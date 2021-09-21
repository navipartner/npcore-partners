page 6014491 "NPR Receipt Stats"
{
    Caption = 'Receipt statistics';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = Date;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Period Start"; Rec."Period Start")
                {

                    ToolTip = 'Specifies the value of the Period Start field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Name"; Rec."Period Name")
                {

                    ToolTip = 'Specifies the value of the Period Name field';
                    ApplicationArea = NPRRetail;
                }
            }
            field(PeriodType; PeriodType)
            {

                Caption = 'Select a Period';
#if BC17 or BC18
                OptionCaption = 'Day,Week,Month,Quarter,Year';
#endif
                ToolTip = 'Specifies the value of the Select a Period field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    case PeriodType of
                        PeriodType::Day:
                            begin
                                VendPeriodLength := VendPeriodLength::Day;
                                Rec.SetRange("Period Type", Rec."Period Type"::Date);
                                CurrPage.Update(true);
                            end;
                        PeriodType::Week:
                            begin
                                VendPeriodLength := VendPeriodLength::Week;
                                Rec.SetRange("Period Type", Rec."Period Type"::Week);
                                CurrPage.Update(true);
                            end;

                        PeriodType::Month:
                            begin
                                VendPeriodLength := VendPeriodLength::Month;
                                Rec.SetRange("Period Type", Rec."Period Type"::Month);
                                CurrPage.Update(true);
                            end;
                        PeriodType::Quarter:
                            begin
                                VendPeriodLength := VendPeriodLength::Quarter;
                                Rec.SetRange("Period Type", Rec."Period Type"::Quarter);
                                CurrPage.Update(true);
                            end;

                        PeriodType::Year:
                            begin
                                VendPeriodLength := VendPeriodLength::Year;
                                Rec.SetRange("Period Type", Rec."Period Type"::Year);
                                CurrPage.Update(true);
                            end;
                    end;
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
#if BC17 or BC18
        exit(PeriodFormMgt.FindDate(CopyStr(Which, 1, 3), Rec, VendPeriodLength));
#else
        exit(PeriodPageMgt.FindDate(CopyStr(Which, 1, 3), Rec, VendPeriodLength));
#endif
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
#if BC17 or BC18
        exit(PeriodFormMgt.NextDate(Steps, Rec, VendPeriodLength));
#else
        exit(PeriodPageMgt.NextDate(Steps, Rec, VendPeriodLength));
#endif
    end;

    trigger OnOpenPage()
    begin

        Rec.Reset();
    end;

    var
#if BC17 or BC18
        PeriodFormMgt: Codeunit PeriodFormManagement;
        VendPeriodLength: Option Day,Week,Month,Quarter,Year,Period;
#else
        PeriodPageMgt: Codeunit PeriodPageManagement;
        VendPeriodLength: Enum "Analysis Period Type";
#endif
        PeriodType: Option Day,Week,Month,Quarter,Year;
}

