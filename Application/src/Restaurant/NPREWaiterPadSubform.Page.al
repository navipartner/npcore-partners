page 6150661 "NPR NPRE Waiter Pad Subform"
{
    Caption = 'Lines';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Waiter Pad Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LineIsMarked; LineIsMarked)
                {
                    ApplicationArea = All;
                    Caption = 'Select';
                    ToolTip = 'Specifies the value of the Select field';

                    trigger OnValidate()
                    begin
                        Rec.Mark(not Rec.Mark);
                    end;
                }
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Billed Quantity"; Rec."Billed Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Billed Quantity field';
                }
                field("Sale Type"; Rec."Sale Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Type field';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Order No. from Web"; Rec."Order No. from Web")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Order No. from Web field';
                }
                field("Order Line No. from Web"; Rec."Order Line No. from Web")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Order Line No. from Web field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Discount Code"; Rec."Discount Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Code field';
                }
                field("Allow Invoice Discount"; Rec."Allow Invoice Discount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Allow Invoice Discount field';
                }
                field("Allow Line Discount"; Rec."Allow Line Discount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Allow Line Discount field';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount field';
                }
                field("Invoice Discount Amount"; Rec."Invoice Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Invoice Discount Amount field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount Excl. VAT field';
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field';
                }
                field("Line Status"; Rec."Line Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Status field';
                }
                field("Line Status Description"; Rec."Line Status Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Status Description field';
                }
                field(AssignedFlowStatuses; Rec.AssignedFlowStatusesAsString(FlowStatus."Status Object"::WaiterPadLineMealFlow))
                {
                    ApplicationArea = All;
                    Caption = 'Serving Steps';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Serving Steps field';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    end;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsString())
                {
                    ApplicationArea = All;
                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowPrintCategories();
                    end;
                }
                field("Kitchen Order Sent"; Rec."Kitchen Order Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kitchen Order Sent field';
                }
                field("Serving Requested"; Rec."Serving Requested")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Requested field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Change Quantiy")
            {
                Enabled = false;
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Change Quantiy action';
                Image = ChangeTo;

                trigger OnAction()
                begin
                    Message('Qty');
                end;
            }
            action("Delete Line")
            {
                Enabled = false;
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Delete Line action';
                Image = DeleteRow;

                trigger OnAction()
                begin
                    Message('DL');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LineIsMarked := Rec.Mark;
    end;

    var
        FlowStatus: Record "NPR NPRE Flow Status";
        LineIsMarked: Boolean;

    procedure GetSelection(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Copy(Rec);
    end;

    procedure ClearMarkedLines()
    begin
        Rec.ClearMarks;
    end;
}