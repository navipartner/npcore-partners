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
                OptionCaption = 'Day,Week,Month,Quarter,Year';
                ToolTip = 'Specifies the value of the Select a Period field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                begin
                    case PeriodType of
                        PeriodType::Day:
                            begin

                                PeriodType := PeriodType::Day;
                                VendPeriodLength := PeriodType::Day;
                                Rec.SetRange("Period Type", Rec."Period Type"::Date);
                                CurrPage.Update(true);
                            end;
                        PeriodType::Week:
                            begin
                                PeriodType := PeriodType::Week;
                                VendPeriodLength := PeriodType::Week;
                                Rec.SetRange("Period Type", Rec."Period Type"::Week);
                                CurrPage.Update(true);
                            end;

                        PeriodType::Month:
                            begin
                                VendPeriodLength := PeriodType::Month;
                                Rec.SetRange("Period Type", Rec."Period Type"::Month);
                                CurrPage.Update(true);
                            end;
                        PeriodType::Quarter:
                            begin
                                PeriodType := PeriodType::Quarter;
                                VendPeriodLength := PeriodType::Quarter;
                                Rec.SetRange("Period Type", Rec."Period Type"::Quarter);
                                CurrPage.Update(true);
                            end;

                        PeriodType::Year:
                            begin
                                PeriodType := PeriodType::Year;
                                VendPeriodLength := PeriodType;
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

        exit(PeriodFormMgt.FindDate(CopyStr(Which, 1, 3), Rec, VendPeriodLength));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin

        exit(PeriodFormMgt.NextDate(Steps, Rec, VendPeriodLength));
    end;

    trigger OnOpenPage()
    begin

        Rec.Reset();
    end;

    var
        PeriodFormMgt: Codeunit PeriodFormManagement;
        VendPeriodLength: Option Day,Week,Month,Quarter,Year,Period;
        PeriodType: Option Day,Week,Month,Quarter,Year;
}

