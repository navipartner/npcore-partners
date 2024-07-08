page 6059861 "NPR POS Single Sale Statistics"
{
    Extensible = false;
    PageType = Card;
    Caption = 'Single Sale Statistics';
    UsageCategory = None;
    SourceTable = "NPR POS Single Stats Buffer";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Filter';

                field("Entry No."; EntryNo)
                {
                    Caption = 'Entry No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies Entry No.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        POSEntry: Record "NPR POS Entry";
                    begin
                        POSEntry.FilterGroup(2);
                        POSEntry.SetRange("POS Unit No.", Rec."POS Unit No.");
                        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
                        POSEntry.FilterGroup(0);

                        if Page.RunModal(Page::"NPR POS Entry List", POSEntry) = Action::LookupOK then begin
                            EntryNo := POSEntry."Entry No.";
                            SetFilters();
                        end;
                    end;
                }
            }
            group(ContentValues)
            {
                Editable = false;
                Caption = 'Content';


                grid(FixedContent)
                {
                    group(Header)
                    {
                        ShowCaption = false;

                        field("POS Unit No."; Rec."POS Unit No.")
                        {
                            ToolTip = 'Specifies the value of the POS Unit No.';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Document No."; Rec."Document No.")
                        {
                            ToolTip = 'Specifies the value of the Document No.';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                    }
                    group(Values)
                    {
                        ShowCaption = false;
                        field("Sales Amount (Actual)"; Rec."Sales Amount")
                        {
                            ToolTip = 'Specifies the value of the Sales Amount (Actual)';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Cost Amount (Actual)"; Rec."Cost Amount")
                        {
                            ToolTip = 'Specifies the value of the Cost Amount (Actual)';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Profit %"; Rec."Profit %")
                        {
                            ToolTip = 'Specifies the value of the Profit %';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Discount Amount"; Rec."Discount Amount")
                        {
                            Caption = 'Disc. Amt Excl. VAT';
                            ToolTip = 'Specifies the value of the Disc. Amt Excl. VAT field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Tax Amount"; Rec."Tax Amount")
                        {
                            ToolTip = 'Specifies the value of the Tax Amount field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Favorable';

                            trigger OnDrillDown()
                            begin
                                TaxDetail();
                            end;
                        }
                        field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                        {
                            ToolTip = 'Specifies the value of the Amount Incl. Tax field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Sales Quantity"; Rec."Sales Quantity")
                        {

                            DecimalPlaces = 0 : 2;
                            ToolTip = 'Specifies the value of the Sales Quantity field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Return Sales Quantity"; Rec."Return Sales Quantity")
                        {
                            DecimalPlaces = 0 : 2;
                            ToolTip = 'Specifies the value of the Return Sales Quantity field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                    }
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(SaleLines)
            {
                Caption = 'Sale Lines';
                Image = AllLines;

                ToolTip = 'View a list of Sale Lines.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSSalesLine: Record "NPR POS Entry Sales Line";
                begin
                    POSSalesLine.Reset();
                    POSSalesLine.SetRange("POS Entry No.", Rec."Entry No.");
                    Page.Run(0, POSSalesLine);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        EntryNo := Rec."Entry No.";
    end;

    local procedure SetFilters()
    var
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetLoadFields("Document No.", "POS Unit No.", "Discount Amount", "Tax Amount", "Amount Incl. Tax", "Sales Quantity", "Return Sales Quantity");
        if POSEntry.Get(EntryNo) then begin
            Rec.Delete();
            POSStatisticsMgt.FillSingleStatsBuffer(Rec, POSEntry);
            CurrPage.Update(false);
        end;
    end;

    local procedure TaxDetail()
    var
        TaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        TaxAmountLine.Reset();
        TaxAmountLine.SetRange("POS Entry No.", Rec."Entry No.");
        Page.Run(0, TaxAmountLine);
    end;

    var
        EntryNo: Integer;
}