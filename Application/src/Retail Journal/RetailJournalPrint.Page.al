page 6014473 "NPR Retail Journal Print"
{
    // NPR5.30/MMV /20170124 CASE 262533 Created page
    // NPR5.41/TS  /20180105 CASE 300893 Added s in Print

    Caption = 'Retail Journal Print';
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Retail Journal Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Quantity to Print"; Rec."Quantity to Print")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity to Print field';
                }
                field(Print; Print)
                {
                    ApplicationArea = All;
                    Caption = 'Print';
                    ToolTip = 'Specifies the value of the Print field';

                    trigger OnValidate()
                    var
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        LabelLibrary.ToggleLine(RecRef);
                    end;
                }
                field(Barcode; Rec.Barcode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode field';
                }
                field("Discount Price Incl. Vat"; Rec."Discount Price Incl. Vat")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Price';
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
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
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Invert Selection action';

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
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Price Label action';

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
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Shelf Label action';

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
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sign action';

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

