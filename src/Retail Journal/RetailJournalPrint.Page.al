page 6014473 "NPR Retail Journal Print"
{
    // NPR5.30/MMV /20170124 CASE 262533 Created page
    // NPR5.41/TS  /20180105 CASE 300893 Added s in Print

    Caption = 'Retail Journal Print';
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "NPR Retail Journal Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Quantity to Print"; "Quantity to Print")
                {
                    ApplicationArea = All;
                }
                field(Print; Print)
                {
                    ApplicationArea = All;
                    Caption = 'Print';

                    trigger OnValidate()
                    var
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                    end;
                }
                field(Barcode; Barcode)
                {
                    ApplicationArea = All;
                }
                field("Discount Price Incl. Vat"; "Discount Price Incl. Vat")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Price';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
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
                    ApplicationArea=All;

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
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
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
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
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
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        ReportSelectionRetail: Record "NPR Report Selection Retail";
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
        LabelLibrary: Codeunit "NPR Label Library";

    procedure InvertSelection()
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
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

