page 6151585 "NPR Event Statistics"
{
    Caption = 'Event Statistics';
    Editable = false;
    LinksAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Job;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                fixed(Control1903895301)
                {
                    ShowCaption = false;
                    group(Category)
                    {
                        Caption = 'Category';
                        Editable = false;
                        field(PriceLCYText; PriceLCYText)
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the PriceLCYText field';
                        }
                        field(ScheduleText; ScheduleText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ScheduleText field';
                        }
                        field(UsageText; UsageText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the UsageText field';
                        }
                        field(ContractText; ContractText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ContractText field';
                        }
                        field(InvoicedText; InvoicedText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the InvoicedText field';
                        }
                        field(CostLCYText; CostLCYText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the CostLCYText field';
                        }
                        field(Control6014410; ScheduleText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ScheduleText field';
                        }
                        field(Control6014409; UsageText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the UsageText field';
                        }
                        field(Control6014408; ContractText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ContractText field';
                        }
                        field(Control6014407; InvoicedText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the InvoicedText field';
                        }
                        field(ProfitLCYText; ProfitLCYText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the ProfitLCYText field';
                        }
                        field(Control6014415; ScheduleText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ScheduleText field';
                        }
                        field(Control6014414; UsageText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the UsageText field';
                        }
                        field(Control6014413; ContractText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ContractText field';
                        }
                        field(Control6014412; InvoicedText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the InvoicedText field';
                        }
                        field(ProfitPctLCYText; ProfitPctLCYText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the ProfitPctLCYText field';
                        }
                        field(Control6014420; ScheduleText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ScheduleText field';
                        }
                        field(Control6014419; UsageText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the UsageText field';
                        }
                        field(Control6014418; ContractText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ContractText field';
                        }
                        field(Control6014417; InvoicedText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the InvoicedText field';
                        }
                    }
                    group(Resource)
                    {
                        Caption = 'Resource';
                        field(Text000; Text000)
                        {
                            ApplicationArea = All;
                            Caption = 'Price LCY';
                            Style = Strong;
                            StyleExpr = TRUE;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Price LCY field';
                        }
                        field(SchedulePriceLCY; PL[1])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsagePriceLCY; PL[5])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractPriceLCY; PL[9])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedPriceLCY; PL[13])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field("Cost LCY"; Text000)
                        {
                            ApplicationArea = All;
                            Caption = 'Cost LCY';
                            Style = Strong;
                            StyleExpr = TRUE;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Cost LCY field';
                        }
                        field(ScheduleCostLCY; CL[1])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(1, true);
                            end;
                        }
                        field(UsageCostLCY; CL[5])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(1, true);
                            end;
                        }
                        field(ContractCostLCY; CL[9])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(1, false);
                            end;
                        }
                        field(InvoicedCostLCY; CL[13])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(1, false);
                            end;
                        }
                        field("Profit LCY"; Text000)
                        {
                            ApplicationArea = All;
                            Caption = 'Profit LCY';
                            Visible = false;
                            ToolTip = 'Specifies the value of the Profit LCY field';
                        }
                        field(ScheduleProfitLCY; PL[1] - CL[1])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitLCY; PL[5] - CL[5])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitLCY; PL[9] - CL[9])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitLCY; PL[13] - CL[13])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field("Profit % LCY"; Text000)
                        {
                            ApplicationArea = All;
                            Caption = 'Profit % LCY';
                            Visible = false;
                            ToolTip = 'Specifies the value of the Profit % LCY field';
                        }
                        field(ScheduleProfitPctLCY; CalculateProfitPct(PL[1], CL[1]))
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitPctLCY; CalculateProfitPct(PL[5], CL[5]))
                        {
                            ApplicationArea = All;
                            Caption = 'Usage';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitPctLCY; CalculateProfitPct(PL[9], CL[9]))
                        {
                            ApplicationArea = All;
                            Caption = 'Contract';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitPctLCY; CalculateProfitPct(PL[13], CL[13]))
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                    }
                    group(Item)
                    {
                        Caption = 'Item';
                        field(Control5; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(SchedulePriceLCYItem; PL[2])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Price LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Price LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsagePriceLCYItem; PL[6])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Price LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Price LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractPriceLCYItem; PL[10])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Price LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Price LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedPriceLCYItem; PL[14])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Price LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Price LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control129; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleCostLCYItem; CL[2])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Cost LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Cost LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(1, true);
                            end;
                        }
                        field(UsageCostLCYItem; CL[6])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Cost LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Cost LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(1, true);
                            end;
                        }
                        field(ContractCostLCYItem; CL[10])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Cost LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Cost LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(1, false);
                            end;
                        }
                        field(InvoicedCostLCYItem; CL[14])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Cost LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Cost LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(1, false);
                            end;
                        }
                        field(Control148; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitLCYItem; PL[2] - CL[2])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitLCYItem; PL[6] - CL[6])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitLCYItem; PL[10] - CL[10])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitLCYItem; PL[14] - CL[14])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control6014430; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitPctLCYItem; CalculateProfitPct(PL[2], CL[2]))
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit % LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit % LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitPctLCYItem; CalculateProfitPct(PL[6], CL[6]))
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit % LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit % LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitPctLCYItem; CalculateProfitPct(PL[10], CL[10]))
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit % LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit % LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitPctLCYItem; CalculateProfitPct(PL[14], CL[14]))
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit % LCY (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit % LCY (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                    }
                    group("G/L Account")
                    {
                        Caption = 'G/L Account';
                        field(Control6; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(SchedulePriceLCYGLAcc; PL[3])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Price LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Price LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsagePriceLCYGLAcc; PL[7])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Price LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Price LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractPriceLCYGLAcc; PL[11])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Price LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Price LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedPriceLCYGLAcc; PL[15])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Price LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Price LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control145; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleCostLCYGLAcc; CL[3])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Cost LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Cost LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(1, true);
                            end;
                        }
                        field(UsageCostLCYGLAcc; CL[7])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Cost LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Cost LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(1, true);
                            end;
                        }
                        field(ContractCostLCYGLAcc; CL[11])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Cost LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Cost LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(1, false);
                            end;
                        }
                        field(InvoicedCostLCYGLAcc; CL[15])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Cost LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Cost LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(1, false);
                            end;
                        }
                        field(Control149; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitLCYGLAcc; PL[3] - CL[3])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitLCYGLAcc; PL[7] - CL[7])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitLCYGLAcc; PL[11] - CL[11])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitLCYGLAcc; PL[15] - CL[15])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control6014435; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitPctLCYGLAcc; CalculateProfitPct(PL[3], CL[3]))
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit % LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit % LCY (G/L Acc.) field';

                            trigger OnAssistEdit()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitPctLCYGLAcc; CalculateProfitPct(PL[7], CL[7]))
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit % LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit % LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitPctLCYGLAcc; CalculateProfitPct(PL[11], CL[11]))
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit % LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit % LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitPctLCYGLAcc; CalculateProfitPct(PL[15], CL[15]))
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit % LCY (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit % LCY (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                    }
                    group(Total)
                    {
                        Caption = 'Total';
                        field(Control88; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(SchedulePriceLCYTotal; PL[4])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Price LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Price LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsagePriceLCYTotal; PL[8])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Price LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Price LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractPriceLCYTotal; PL[12])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Price LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Price LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedPriceLCYTotal; PL[16])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Price LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Price LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control146; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleCostLCYTotal; CL[4])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Cost LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Cost LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(1, true);
                            end;
                        }
                        field(UsageCostLCYTotal; CL[8])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Cost LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Cost LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(1, true);
                            end;
                        }
                        field(ContractCostLCYTotal; CL[12])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Cost LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Cost LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(1, false);
                            end;
                        }
                        field(InvoicedCostLCYTotal; CL[16])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Cost LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Cost LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(1, false);
                            end;
                        }
                        field(Control150; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitLCYTotal; PL[4] - CL[4])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitLCYTotal; PL[8] - CL[8])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitLCYTotal; PL[12] - CL[12])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitLCYTotal; PL[16] - CL[16])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control6014440; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitPctLCYTotal; CalculateProfitPct(PL[4], CL[4]))
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit % LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit % LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitPctLCYTotal; CalculateProfitPct(PL[8], CL[8]))
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit % LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit % LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitPctLCYTotal; CalculateProfitPct(PL[12], CL[12]))
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit % LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit % LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitPctLCYTotal; CalculateProfitPct(PL[16], CL[16]))
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit % LCY (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit % LCY (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                    }
                }
            }
            group(Currency)
            {
                Caption = 'Currency';
                fixed(Control1904230801)
                {
                    ShowCaption = false;
                    group(Control6014461)
                    {
                        Caption = 'Category';
                        Editable = false;
                        field(PriceText; PriceText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the PriceText field';
                        }
                        field(Control6014459; ScheduleText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ScheduleText field';
                        }
                        field(Control6014458; UsageText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the UsageText field';
                        }
                        field(Control6014457; ContractText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ContractText field';
                        }
                        field(Control6014456; InvoicedText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the InvoicedText field';
                        }
                        field(CostText; CostText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the CostText field';
                        }
                        field(Control6014454; ScheduleText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ScheduleText field';
                        }
                        field(Control6014453; UsageText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the UsageText field';
                        }
                        field(Control6014452; ContractText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ContractText field';
                        }
                        field(Control6014451; InvoicedText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the InvoicedText field';
                        }
                        field(ProfitText; ProfitText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the ProfitText field';
                        }
                        field(Control6014449; ScheduleText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ScheduleText field';
                        }
                        field(Control6014448; UsageText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the UsageText field';
                        }
                        field(Control6014447; ContractText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ContractText field';
                        }
                        field(Control6014446; InvoicedText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the InvoicedText field';
                        }
                        field(ProfitPcttext; ProfitPcttext)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Strong;
                            StyleExpr = TRUE;
                            ToolTip = 'Specifies the value of the ProfitPcttext field';
                        }
                        field(Control6014444; ScheduleText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ScheduleText field';
                        }
                        field(Control6014443; UsageText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the UsageText field';
                        }
                        field(Control6014442; ContractText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the ContractText field';
                        }
                        field(Control6014441; InvoicedText)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the InvoicedText field';
                        }
                    }
                    group(Control1903193001)
                    {
                        Caption = 'Resource';
                        field(Price; Text000)
                        {
                            ApplicationArea = All;
                            Caption = 'Price';
                            Visible = false;
                            ToolTip = 'Specifies the value of the Price field';
                        }
                        field(SchedulePrice; P[1])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, true);
                            end;
                        }
                        field(UsagePrice; P[5])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(4, true);
                            end;
                        }
                        field(ContractPrice; P[9])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, false);
                            end;
                        }
                        field(InvoicedPrice; P[13])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(4, false);
                            end;
                        }
                        field(Cost; Text000)
                        {
                            ApplicationArea = All;
                            Caption = 'Cost';
                            Visible = false;
                            ToolTip = 'Specifies the value of the Cost field';
                        }
                        field(ScheduleCost; C[1])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(2, true);
                            end;
                        }
                        field(UsageCost; C[5])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(2, true);
                            end;
                        }
                        field(ContractCost; C[9])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(2, false);
                            end;
                        }
                        field(InvoicedCost; C[13])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(2, false);
                            end;
                        }
                        field(Profit; Text000)
                        {
                            ApplicationArea = All;
                            Caption = 'Profit';
                            Visible = false;
                            ToolTip = 'Specifies the value of the Profit field';
                        }
                        field(ScheduleProfit; P[1] - C[1])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, true);
                            end;
                        }
                        field(UsageProfit; P[5] - C[5])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfit; P[9] - C[9])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, false);
                            end;
                        }
                        field(InvoicedProfit; P[13] - C[13])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field("Profit %"; Text000)
                        {
                            ApplicationArea = All;
                            Caption = 'Profit %';
                            Visible = false;
                            ToolTip = 'Specifies the value of the Profit % field';
                        }
                        field(ScheduleProfitPct; CalculateProfitPct(P[1], C[1]))
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitPct; CalculateProfitPct(P[5], C[5]))
                        {
                            ApplicationArea = All;
                            Caption = 'Usage';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitPct; CalculateProfitPct(P[9], C[9]))
                        {
                            ApplicationArea = All;
                            Caption = 'Contract';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitPct; CalculateProfitPct(P[13], C[13]))
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                    }
                    group(Control1904522201)
                    {
                        Caption = 'Item';
                        field(Control152; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(SchedulePriceItem; P[2])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Price (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Price (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, true);
                            end;
                        }
                        field(UsagePriceItem; P[6])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Price (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Price (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(4, true);
                            end;
                        }
                        field(ContractPriceItem; P[10])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Price (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Price (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, false);
                            end;
                        }
                        field(InvoicedPriceItem; P[14])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Price (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Price (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(4, false);
                            end;
                        }
                        field(Control156; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleCostItem; C[2])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Cost (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Cost (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(2, true);
                            end;
                        }
                        field(UsageCostItem; C[6])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Cost (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Cost (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(2, true);
                            end;
                        }
                        field(ContractCostItem; C[10])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Cost (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Cost (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(2, false);
                            end;
                        }
                        field(InvoicedCostItem; C[14])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Cost (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Cost (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(2, false);
                            end;
                        }
                        field(Control160; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitItem; P[2] - C[2])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, true);
                            end;
                        }
                        field(UsageProfitItem; P[6] - C[6])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitItem; P[10] - C[10])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, false);
                            end;
                        }
                        field(InvoicedProfitItem; P[14] - C[14])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control6014471; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitPctItem; CalculateProfitPct(P[2], C[2]))
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit % (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit % (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitPctItem; CalculateProfitPct(P[6], C[6]))
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit % (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit % (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitPctItem; CalculateProfitPct(P[10], C[10]))
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit % (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit % (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitPctItem; CalculateProfitPct(P[14], C[14]))
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit % (Item)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit % (Item) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                    }
                    group(Control1904320401)
                    {
                        Caption = 'G/L Account';
                        field(Control153; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(SchedulePriceGLAcc; P[3])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Price (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Price (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, true);
                            end;
                        }
                        field(UsagePriceGLAcc; P[7])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Price (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Price (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(4, true);
                            end;
                        }
                        field(ContractPriceGLAcc; P[11])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Price (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Price (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, false);
                            end;
                        }
                        field(InvoicedPriceGLAcc; P[15])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Price (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Price (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(4, false);
                            end;
                        }
                        field(Control157; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleCostGLAcc; C[3])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Cost (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Cost (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(2, true);
                            end;
                        }
                        field(UsageCostGLAcc; C[7])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Cost (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Cost (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(2, true);
                            end;
                        }
                        field(ContractCostGLAcc; C[11])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Cost (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Cost (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(2, false);
                            end;
                        }
                        field(InvoicedCostGLAcc; C[15])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Cost (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Cost (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(2, false);
                            end;
                        }
                        field(Control161; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitGLAcc; P[3] - C[3])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, true);
                            end;
                        }
                        field(UsageProfitGLAcc; P[7] - C[7])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitGLAcc; P[11] - C[11])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, false);
                            end;
                        }
                        field(InvoicedProfitGLAcc; P[15] - C[15])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control6014476; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitPctGLAcc; CalculateProfitPct(P[3], C[3]))
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit % (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit % (G/L Acc.) field';

                            trigger OnAssistEdit()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitPctGLAcc; CalculateProfitPct(P[7], C[7]))
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit % (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit % (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitPctGLAcc; CalculateProfitPct(P[11], C[11]))
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit % (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit % (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitPctGLAcc; CalculateProfitPct(P[15], C[15]))
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit % (G/L Acc.)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit % (G/L Acc.) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                    }
                    group(Control1905314101)
                    {
                        Caption = 'Total';
                        field(Control154; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(SchedulePriceTotal; P[4])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Price (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Price (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, true);
                            end;
                        }
                        field(UsagePriceTotal; P[8])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Price (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Price (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(4, true);
                            end;
                        }
                        field(ContractPriceTotal; P[12])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Price (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Price (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, false);
                            end;
                        }
                        field(InvoicedPriceTotal; P[16])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Price (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Price (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(4, false);
                            end;
                        }
                        field(Control158; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleCostTotal; C[4])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Cost (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Cost (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(2, true);
                            end;
                        }
                        field(UsageCostTotal; C[8])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Cost (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Cost (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(2, true);
                            end;
                        }
                        field(ContractCostTotal; C[12])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Cost (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Cost (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(2, false);
                            end;
                        }
                        field(InvoicedCostTotal; C[16])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Cost (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Cost (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(2, false);
                            end;
                        }
                        field(Control162; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitTotal; P[4] - C[4])
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, true);
                            end;
                        }
                        field(UsageProfitTotal; P[8] - C[8])
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitTotal; P[12] - C[12])
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(4, false);
                            end;
                        }
                        field(InvoicedProfitTotal; P[16] - C[16])
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                        field(Control6014481; Text000)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Visible = false;
                            ToolTip = 'Specifies the value of the Text000 field';
                        }
                        field(ScheduleProfitPctTotal; CalculateProfitPct(P[4], C[4]))
                        {
                            ApplicationArea = All;
                            Caption = 'Schedule Profit % (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Schedule Profit % (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, true);
                            end;
                        }
                        field(UsageProfitPctTotal; CalculateProfitPct(P[8], C[8]))
                        {
                            ApplicationArea = All;
                            Caption = 'Usage Profit % (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Usage Profit % (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, true);
                            end;
                        }
                        field(ContractProfitPctTotal; CalculateProfitPct(P[12], C[12]))
                        {
                            ApplicationArea = All;
                            Caption = 'Contract Profit % (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Contract Profit % (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowPlanningLine(3, false);
                            end;
                        }
                        field(InvoicedProfitPctTotal; CalculateProfitPct(P[16], C[16]))
                        {
                            ApplicationArea = All;
                            Caption = 'Invoiced Profit % (Total)';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Invoiced Profit % (Total) field';

                            trigger OnDrillDown()
                            begin
                                JobCalcStatistics.ShowLedgEntry(3, false);
                            end;
                        }
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(JobCalcStatistics);
        JobCalcStatistics.JobCalculateCommonFilters(Rec);
        JobCalcStatistics.CalculateAmounts();
        JobCalcStatistics.GetLCYCostAmounts(CL);
        JobCalcStatistics.GetLCYPriceAmounts(PL);
        JobCalcStatistics.GetCostAmounts(C);
        JobCalcStatistics.GetPriceAmounts(P);
    end;

    var
        JobCalcStatistics: Codeunit "Job Calculate Statistics";
        CL: array[16] of Decimal;
        PL: array[16] of Decimal;
        P: array[16] of Decimal;
        C: array[16] of Decimal;
        Text000: Label 'Placeholder';
        PriceLCYText: Label 'Price LCY';
        ScheduleText: Label 'Schedule';
        UsageText: Label 'Usage';
        ContractText: Label 'Contract';
        InvoicedText: Label 'Invoiced';
        CostLCYText: Label 'Cost LCY';
        ProfitLCYText: Label 'Profit LCY';
        ProfitPctLCYText: Label 'Profit % LCY';
        PriceText: Label 'Price';
        CostText: Label 'Cost';
        ProfitText: Label 'Profit';
        ProfitPcttext: Label 'Profit %';

    local procedure CalculateProfitPct(PriceAmount: Decimal; CostAmount: Decimal): Decimal
    begin
        if PriceAmount = 0 then
            exit(0);
        exit(((PriceAmount - CostAmount) / PriceAmount) * 100);
    end;
}

