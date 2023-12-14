page 6014473 "NPR Retail Journal Print"
{
    // NPR5.30/MMV /20170124 CASE 262533 Created page
    // NPR5.41/TS  /20180105 CASE 300893 Added s in Print
    Caption = 'Retail Journal Print';
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Journal Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity to Print"; Rec."Quantity to Print")
                {

                    ToolTip = 'Specifies the value of the Quantity to Print field';
                    ApplicationArea = NPRRetail;
                }
                field(Print; Print)
                {

                    Caption = 'Print';
                    ToolTip = 'Specifies the value of the Print field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        LabelManagement.ToggleLine(RecRef);
                    end;
                }
                field(Barcode; Rec.Barcode)
                {

                    ToolTip = 'Specifies the value of the Barcode field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Price Incl. Vat"; Rec."Discount Price Incl. Vat")
                {

                    Caption = 'Unit Price';
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor Item No."; Rec."Vend Item No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Invert Selection action';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Executes the Price Label action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PrintSelection("NPR Report Selection Type"::"Price Label".AsInteger());
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

                    ToolTip = 'Executes the Shelf Label action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PrintSelection("NPR Report Selection Type"::"Shelf Label".AsInteger());
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

                    ToolTip = 'Executes the Sign action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        PrintSelection("NPR Report Selection Type"::Sign.AsInteger());
                    end;
                }

                action(SelectAll)
                {
                    Caption = 'Select All Lines to Print';
                    Image = Check;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;

                    ToolTip = 'Executes the Print All Lines Action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        RecRef: RecordRef;
                    begin
                        if Rec.FindSet() then
                            repeat
                                RecRef.GetTable(Rec);
                                LabelManagement.ToggleLine(RecRef);
                            until Rec.Next() = 0;
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
        Print := LabelManagement.SelectionContains(RecRef);

    end;

    trigger OnDeleteRecord(): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        if LabelManagement.SelectionContains(RecRef) then
            LabelManagement.ToggleLine(RecRef);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Print := false;
    end;

    var
        Print: Boolean;
        LabelManagement: Codeunit "NPR Label Management";

    internal procedure InvertSelection()
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        LabelManagement.InvertAllLines(RecRef);
        CurrPage.Update(false);
    end;

    procedure PrintSelection(ReportType: Integer)
    begin
        LabelManagement.PrintSelection(ReportType);
    end;
}

