page 6014468 "NPR Sales Ticket Statistics"
{
    // NPR700.000    2201.13   TS : Added to replace Period Button which were previously on the forms.
    // NPR4.10/MMV/20150611 CASE 215921 Added code from latest 6.2 release
    // NPR4.12/MMV/20150618 CASE 215921 Added filters now that they aren't hardcoded in the table function
    //                                  Fixed bug on field Debitsale OnDrillDown
    // NPR4.16/JDH/20151019 CASE 225415 Recompiled to refresh field links to Register (fields have been rearranged)
    // NPR5.31/JLK /20170326  CASE 269893 Correct filters for calculation of No. of Exp field

    Caption = 'Sales Ticket Statistics';
    PageType = List;
    SourceTable = Date;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Period Start"; Rec."Period Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Start field';
                }
                field("Period Name"; Rec."Period Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Name field';
                }

                field(totalCount; totalCount)
                {
                    ApplicationArea = All;
                    Caption = 'Number of Exp.';
                    ToolTip = 'Specifies the value of the Number of Exp. field';
                }
                field(CalculatedAverage; CalcAverage())
                {
                    ApplicationArea = All;
                    Caption = 'Stay Expedition';
                    ToolTip = 'Specifies the value of the Stay Expedition field';
                }
            }
            group(Control6150623)
            {
                ShowCaption = false;
                field(Dim1Filter; Dim1Filter)
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,1';
                    Caption = 'Dept. Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                    ToolTip = 'Specifies the value of the Dept. Code field';
                }
                field(Dim2Filter; Dim2Filter)
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,2';
                    Caption = 'Project Code';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
                    ToolTip = 'Specifies the value of the Project Code field';
                }
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = All;
                    Caption = 'Period Type';
                    OptionCaption = 'Day,Week,Month,Year';
                    ToolTip = 'Specifies the value of the Period Type field';

                    trigger OnValidate()
                    begin
                        //+TS
                        case PeriodType of
                            PeriodType::Day:
                                begin

                                    VendPeriodLength := VendPeriodLength::Day;
                                    CurrPage.Update();

                                end;
                            PeriodType::Week:
                                begin

                                    VendPeriodLength := VendPeriodLength::Week;
                                    CurrPage.Update();

                                end;

                            PeriodType::Month:
                                begin

                                    VendPeriodLength := VendPeriodLength::Month;
                                    CurrPage.Update();

                                end;
                            PeriodType::Year:
                                begin

                                    VendPeriodLength := VendPeriodLength::Year;
                                    CurrPage.Update();

                                end;
                        end;
                        //-TS
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnAfterGetRecord()
    begin

        SetDateFilter();
        SetDimensionFilters();
        CalcAverage();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin

        exit(PeriodFormMgt.FindDate(Which, Rec, VendPeriodLength));
    end;

    trigger OnInit()
    begin

        VendPeriodLength := VendPeriodLength::Day;
        Dim1Filter := '';
        Dim2Filter := '';
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
        AmountType: Option "Net Change","Balance at Date";
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        PeriodType: Option Day,Week,Month,Year;
        TotalCount: Decimal;
        POSEntry: Record "NPR POS Entry";

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then
            POSEntry.SetRange("Posting Date", Rec."Period Start", Rec."Period End")
        else
            POSEntry.SetRange("Posting Date", 0D, Rec."Period End");
    end;

    procedure CalcAverage() Result: Decimal
    var
        totalAmount: Decimal;
    begin
        POSEntry.CalcSums("Amount Excl. Tax", "Amount Incl. Tax");
        totalAmount := POSEntry."Amount Excl. Tax";
        totalCount := POSEntry.Count();

        if totalCount <> 0 then
            Result := TotalAmount / TotalCount
        else
            Result := 0;
    end;

    procedure SetDimensionFilters()
    begin
        if Dim1Filter <> '' then
            POSEntry.SetRange("Shortcut Dimension 1 Code", Dim1Filter)
        else
            POSEntry.SetRange("Shortcut Dimension 1 Code");

        if Dim2Filter <> '' then
            POSEntry.SetFilter("Shortcut Dimension 2 Code", Dim2Filter)
        else
            POSEntry.SetRange("Shortcut Dimension 2 Code");
    end;
}

