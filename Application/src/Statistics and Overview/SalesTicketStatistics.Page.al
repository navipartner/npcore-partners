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
                field("Kassedata.""All Normal Sales in Audit Roll"""; Kassedata."All Normal Sales in Audit Roll")
                {
                    ApplicationArea = All;
                    Caption = 'Balance Due (LCY)';
                    ToolTip = 'Specifies the value of the Balance Due (LCY) field';

                    trigger OnDrillDown()
                    var
                        AuditRoll: Record "NPR Audit Roll";
                    begin

                        AuditRoll.SetRange("Sale Date", "Period Start", "Period End");
                        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
                        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
                        Clear(AuditRollForm);
                        AuditRollForm.SetExtFilters(true);
                        AuditRollForm.SetTableView(AuditRoll);
                        AuditRollForm.RunModal;
                    end;
                }
                field("Kassedata.""All Debit Sales in Audit Roll"""; Kassedata."All Debit Sales in Audit Roll")
                {
                    ApplicationArea = All;
                    Caption = 'Purchases (LCY)';
                    ToolTip = 'Specifies the value of the Purchases (LCY) field';

                    trigger OnDrillDown()
                    var
                        AuditRoll: Record "NPR Audit Roll";
                    begin

                        AuditRoll.SetRange("Sale Date", "Period Start", "Period End");
                        //-NPR4.12
                        //AuditRoll.SETRANGE( Type, AuditRoll.Type::"Debit Sale" );
                        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::"Debit Sale");
                        //+NPR4.12
                        Clear(AuditRollForm);
                        AuditRollForm.SetExtFilters(true);
                        AuditRollForm.SetTableView(AuditRoll);
                        AuditRollForm.RunModal;
                    end;
                }
                field("Kassedata.""All Normal Sales in Audit Roll""+Kassedata.""All Debit Sales in Audit Roll"""; Kassedata."All Normal Sales in Audit Roll" + Kassedata."All Debit Sales in Audit Roll")
                {
                    ApplicationArea = All;
                    Caption = 'Total';
                    ToolTip = 'Specifies the value of the Total field';
                }
                field(totalCount; totalCount)
                {
                    ApplicationArea = All;
                    Caption = 'Number of Exp.';
                    ToolTip = 'Specifies the value of the Number of Exp. field';
                }
                field(CalculatedAverage; CalcAverage)
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

                                    Tidsvalg := 1;
                                    VendPeriodLength := VendPeriodLength::Day;
                                    CurrPage.Update;

                                end;
                            PeriodType::Week:
                                begin

                                    Tidsvalg := 7;
                                    VendPeriodLength := VendPeriodLength::Week;
                                    CurrPage.Update;

                                end;

                            PeriodType::Month:
                                begin

                                    Tidsvalg := 31;
                                    VendPeriodLength := VendPeriodLength::Month;
                                    CurrPage.Update;

                                end;
                            PeriodType::Year:
                                begin

                                    Tidsvalg := 12;
                                    VendPeriodLength := VendPeriodLength::Year;
                                    CurrPage.Update;

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

        SetDateFilter;
        SetDimensionFilters;
        //-NPR4.10
        //Kassedata.CALCFIELDS("All Normal Sales in Audit Roll","All Debit Sales in Audit Roll","All Count in Audit Roll",
        //  "All Item in Audit Roll Debit");
        Kassedata.CalcFields("All Normal Sales in Audit Roll", "All Debit Sales in Audit Roll");

        CalcAverage();
        //+NPR4.10
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin

        exit(PeriodFormMgt.FindDate(Which, Rec, VendPeriodLength));
    end;

    trigger OnInit()
    begin

        Tidsvalg := 1;
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
        Reset;
    end;

    var
        PeriodFormMgt: Codeunit PeriodFormManagement;
        AuditRollForm: Page "NPR Audit Roll";
        VendPeriodLength: Option Day,Week,Month,Quarter,Year,Period;
        AmountType: Option "Net Change","Balance at Date";
        Kassedata: Record "NPR Register";
        Tidsvalg: Integer;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        PeriodType: Option Day,Week,Month,Year;
        AuditRoll: Record "NPR Audit Roll";
        totalCount: Decimal;

    procedure Set(var NewVend: Record "NPR Register"; NewVendPeriodLength: Integer; NewAmountType: Option "Net Change","Balance at Date"; var NewKassedata: Record "NPR Register")
    begin
        Kassedata.Copy(NewKassedata);
        VendPeriodLength := NewVendPeriodLength;
        AmountType := NewAmountType;
        //CurrForm.UPDATE(FALSE);
        CurrPage.Update(false);
    end;

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then
            Kassedata.SetRange("Date Filter", "Period Start", "Period End")
        else
            Kassedata.SetRange("Date Filter", 0D, "Period End");

        //-NPR4.10
        if AmountType = AmountType::"Net Change" then
            AuditRoll.SetRange("Sale Date", "Period Start", "Period End")
        else
            AuditRoll.SetRange("Sale Date", 0D, "Period End");
        //+NPR4.10
    end;

    procedure CalcAverage() "Average": Decimal
    var
        totalAmount: Decimal;
    begin

        //-NPR4.10
        //totalCount := Kassedata."All Count in Audit Roll";
        //-NPR4.12
        //-NPR5.31
        // AuditRoll.SETFILTER("Sale Type",'%1|%2|%3|%4',
        //                                  AuditRoll."Sale Type"::Salg,
        //                                  AuditRoll."Sale Type"::Udbetaling,
        //                                  AuditRoll."Sale Type"::Indbetaling,
        //                                  AuditRoll."Sale Type"::Debetsalg);
        AuditRoll.SetFilter("Sale Type", '%1|%2', AuditRoll."Sale Type"::Sale, AuditRoll."Sale Type"::"Debit Sale");
        //+NPR5.31
        totalCount := AuditRoll.GetNoOfSales();
        AuditRoll.SetRange("Sale Type");
        //+NPR4.12
        totalAmount := Kassedata."All Normal Sales in Audit Roll";
        //+NPR4.10

        if totalCount <> 0 then
            Average := totalAmount / totalCount
        else
            Average := 0;
    end;

    procedure SetDimensionFilters()
    begin
        if Dim1Filter <> '' then
            Kassedata.SetRange("Global Dimension 1 Filter", Dim1Filter)
        else
            Kassedata.SetRange("Global Dimension 1 Filter");

        if Dim2Filter <> '' then
            Kassedata.SetFilter("Global Dimension 2 Filter", Dim2Filter)
        else
            Kassedata.SetRange("Global Dimension 2 Filter");

        //-NPR4.10
        if Dim1Filter <> '' then
            AuditRoll.SetRange("Shortcut Dimension 1 Code", Dim1Filter)
        else
            AuditRoll.SetRange("Shortcut Dimension 1 Code");

        if Dim2Filter <> '' then
            AuditRoll.SetFilter("Shortcut Dimension 2 Code", Dim2Filter)
        else
            AuditRoll.SetRange("Shortcut Dimension 2 Code");
        //+NPR4.10
    end;
}

