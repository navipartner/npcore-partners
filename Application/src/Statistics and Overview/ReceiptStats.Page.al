page 6014491 "NPR Receipt Stats"
{
    Caption = 'Receipt statistics';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Date;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Period Start"; "Period Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Start field';
                }
                field("Period Name"; "Period Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Name field';
                }
            }
            field(PeriodType; PeriodType)
            {
                ApplicationArea = All;
                Caption = 'Select a Period';
                ToolTip = 'Specifies the value of the Select a Period field';

                trigger OnValidate()
                begin
                    case PeriodType of
                        PeriodType::Day:
                            begin

                                PeriodType := PeriodType::Day;
                                VendPeriodLength := PeriodType::Day;
                                SetRange("Period Type", "Period Type"::Date);
                                CurrPage.Update(true);
                            end;
                        PeriodType::Week:
                            begin
                                PeriodType := PeriodType::Week;
                                VendPeriodLength := PeriodType::Week;
                                SetRange("Period Type", "Period Type"::Week);
                                CurrPage.Update(true);
                            end;

                        PeriodType::Month:
                            begin
                                VendPeriodLength := PeriodType::Month;
                                SetRange("Period Type", "Period Type"::Month);
                                CurrPage.Update(true);
                            end;
                        PeriodType::Quarter:
                            begin
                                PeriodType := PeriodType::Quarter;
                                VendPeriodLength := PeriodType::Quarter;
                                SetRange("Period Type", "Period Type"::Quarter);
                                CurrPage.Update(true);
                            end;

                        PeriodType::Year:
                            begin
                                PeriodType := PeriodType::Year;
                                VendPeriodLength := PeriodType;
                                SetRange("Period Type", "Period Type"::Year);
                                CurrPage.Update(true);
                            end;
                    end;
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin

        exit(PeriodFormMgt.FindDate(Which, Rec, VendPeriodLength));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin

        exit(PeriodFormMgt.NextDate(Steps, Rec, VendPeriodLength));
    end;

    trigger OnOpenPage()
    begin

        Reset;
    end;

    var
        PeriodFormMgt: Codeunit PeriodFormManagement;
        VendPeriodLength: Option Day,Week,Month,Quarter,Year,Period;
        PeriodType: Option Day,Week,Month,Quarter,Year;
}

