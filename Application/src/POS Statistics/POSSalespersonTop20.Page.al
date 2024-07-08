page 6059869 "NPR POS Salesperson Top 20"
{
    PageType = List;
    Caption = 'Salesperson Top 20';
    UsageCategory = None;
    SourceTable = "NPR POS Salesperson St Buffer";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                field(FromDate; FromDate)
                {
                    Caption = 'From Date';
                    ToolTip = 'Specifies the value of the From Date';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        POSStatisticsMgt.FillSalePersonTop20(Rec, FromDate, ToDate);
                        CurrPage.Update(false);
                    end;
                }
                field(ToDate; ToDate)
                {
                    Caption = 'To Date';
                    ToolTip = 'Specifies the value of the To Date';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        POSStatisticsMgt.FillSalePersonTop20(Rec, FromDate, ToDate);
                        CurrPage.Update(false);
                    end;
                }
            }

            repeater(Salepeople)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Sales (LCY)"; Rec."Sales (LCY)")
                {
                    ToolTip = 'Specifies the value of the Sales (LCY)';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Amount';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the value of the Discount %';
                    ApplicationArea = NPRRetail;
                }
                field("Profit (LCY)"; Rec."Profit (LCY)")
                {
                    ToolTip = 'Specifies the value of the Profit (LCY)';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {
                    ToolTip = 'Specifies the value of the Profit %';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        FromDate := CalcDate('<-CY>', Today);
        ToDate := Today;
        POSStatisticsMgt.FillSalePersonTop20(Rec, FromDate, ToDate);
    end;

    var
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
        FromDate: Date;
        ToDate: Date;
}