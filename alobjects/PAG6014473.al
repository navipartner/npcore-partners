page 6014473 "Retail Journal Print"
{
    // NPR5.30/MMV /20170124 CASE 262533 Created page
    // NPR5.41/TS  /20180105 CASE 300893 Added s in Print

    Caption = 'Retail Journal Print';
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Retail Journal Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Quantity to Print";"Quantity to Print")
                {
                }
                field(Print;Print)
                {
                    Caption = 'Print';

                    trigger OnValidate()
                    var
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                    end;
                }
                field(Barcode;Barcode)
                {
                }
                field("Discount Price Incl. Vat";"Discount Price Incl. Vat")
                {
                    Caption = 'Unit Price';
                }
                field("Vendor No.";"Vendor No.")
                {
                    Visible = false;
                }
                field("Vendor Item No.";"Vendor Item No.")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Prints)
            {
                action("Invert Selection")
                {
                    Caption = 'Invert Selection';
                    Image = Change;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        InvertSelection();
                    end;
                }
                action(PriceLabel)
                {
                    Caption = 'Price Label';
                    Image = BinLedger;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        PrintSelection(ReportSelectionRetail."Report Type"::"Price Label");
                    end;
                }
                action(ShelfLabel)
                {
                    Caption = 'Shelf Label';
                    Image = BinContent;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        PrintSelection(ReportSelectionRetail."Report Type"::"Shelf Label");
                    end;
                }
                action(Sign)
                {
                    Caption = 'Sign';
                    Image = Bin;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "Report Selection Retail";
                    begin
                        PrintSelection(ReportSelectionRetail."Report Type"::Sign);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        Print := LabelLibrary.SelectionContains(RecRef);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        if LabelLibrary.SelectionContains(RecRef) then
          LabelLibrary.ToggleLine(RecRef);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Print := false;
    end;

    var
        Print: Boolean;
        LabelLibrary: Codeunit "Label Library";

    procedure InvertSelection()
    var
        RetailJournalLine: Record "Retail Journal Line";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        LabelLibrary.InvertAllLines(RecRef);
        CurrPage.Update(false);
    end;

    procedure PrintSelection(ReportType: Integer)
    begin
        LabelLibrary.PrintSelection(ReportType);
    end;
}

