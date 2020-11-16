page 6014491 "NPR Receipt Stats"
{
    // NPR4.16/JDH/20151019 CASE 225415 Recompiled to refresh field links to Register (fields have been rearranged)

    Caption = 'Receipt statistics';
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Period Name"; "Period Name")
                {
                    ApplicationArea = All;
                }
                field("Kassedata.""All Normal Sales in Audit Roll"""; Kassedata."All Normal Sales in Audit Roll")
                {
                    ApplicationArea = All;
                    Caption = 'Balance Due (LCY)';
                }
                field("Kassedata.""All Debit Sales in Audit Roll"""; Kassedata."All Debit Sales in Audit Roll")
                {
                    ApplicationArea = All;
                    Caption = 'Purchases (LCY)';
                }
                field("Kassedata.""Normal Sales in Audit Roll""+Kassedata.""Debit Sales in Audit Roll"""; Kassedata."Normal Sales in Audit Roll" + Kassedata."Debit Sales in Audit Roll")
                {
                    ApplicationArea = All;
                    Caption = 'Total';
                }
                field("Kassedata.""Attendance Count in Audit Roll""+Kassedata.""Item Count in Audit Roll Debit"""; Kassedata."Attendance Count in Audit Roll" + Kassedata."Item Count in Audit Roll Debit")
                {
                    ApplicationArea = All;
                    Caption = 'No. of servings';
                }
            }
            field(PeriodType; PeriodType)
            {
                ApplicationArea = All;
                Caption = 'Select a Period';

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

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin

        SetDateFilter;
        Kassedata.CalcFields("All Normal Sales in Audit Roll", "All Debit Sales in Audit Roll", "Attendance Count in Audit Roll",
          "Item Count in Audit Roll Debit");
    end;

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
        AmountType: Option "Net Change","Balance at Date";
        PeriodType: Option Day,Week,Month,Quarter,Year;
        Kassedata: Record "NPR Register";

    procedure Set(var NewVend: Record "NPR Register"; NewVendPeriodLength: Integer; NewAmountType: Option "Net Change","Balance at Date"; var NewKassedata: Record "NPR Register")
    begin
        Kassedata.Copy(NewKassedata);
        VendPeriodLength := NewVendPeriodLength;
        AmountType := NewAmountType;
        CurrPage.Update(false);
    end;

    local procedure ShowVendEntries()
    begin
        /*SetDateFilter;
        VendLedgEntry.RESET;
        VendLedgEntry.SETCURRENTKEY("Vendor No.","Posting Date");
        VendLedgEntry.SETRANGE("Vendor No.",Vend."No.");
        VendLedgEntry.SETFILTER("Posting Date",Vend.GETFILTER("Date Filter"));
        VendLedgEntry.SETFILTER("Global Dimension 1 Code",Vend.GETFILTER("Global Dimension 1 Filter"));
        VendLedgEntry.SETFILTER("Global Dimension 2 Code",Vend.GETFILTER("Global Dimension 2 Filter"));
        FORM.RUN(0,VendLedgEntry);
         */

    end;

    local procedure ShowVendEntriesDue()
    begin
        /*SetDateFilter;
        VendLedgEntry.RESET;
        VendLedgEntry.SETCURRENTKEY("Vendor No.",Open,Positive,"Due Date");
        VendLedgEntry.SETRANGE("Vendor No.",Vend."No.");
        VendLedgEntry.SETRANGE(Open,TRUE);
        VendLedgEntry.SETFILTER("Due Date",Vend.GETFILTER("Date Filter"));
        VendLedgEntry.SETFILTER("Global Dimension 1 Code",Vend.GETFILTER("Global Dimension 1 Filter"));
        VendLedgEntry.SETFILTER("Global Dimension 2 Code",Vend.GETFILTER("Global Dimension 2 Filter"));
        FORM.RUN(0,VendLedgEntry);
         */

    end;

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then
            Kassedata.SetRange("Date Filter", "Period Start", "Period End")
        else
            Kassedata.SetRange("Date Filter", 0D, "Period End");
    end;
}

