page 6150661 "NPR NPRE Waiter Pad Subform"
{
    Extensible = False;
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

                    Caption = 'Select';
                    ToolTip = 'Specifies the value of the Select field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.Mark(not Rec.Mark());
                    end;
                }
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date"; Rec."Start Date")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Time"; Rec."Start Time")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Billed Quantity"; Rec."Billed Quantity")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Billed Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Type"; Rec."Sale Type")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sale Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Order No. from Web"; Rec."Order No. from Web")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Order No. from Web field';
                    ApplicationArea = NPRRetail;
                }
                field("Order Line No. from Web"; Rec."Order Line No. from Web")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Order Line No. from Web field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Code"; Rec."Discount Code")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Line Discount"; Rec."Allow Line Discount")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Allow Line Discount field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount Excl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Status"; Rec."Line Status")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Status Description"; Rec."Line Status Description")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Status Description field';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedFlowStatuses; Rec.AssignedFlowStatusesAsString(FlowStatus."Status Object"::WaiterPadLineMealFlow))
                {

                    Caption = 'Serving Steps';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Serving Steps field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    end;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsString())
                {

                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowPrintCategories();
                    end;
                }
                field("Kitchen Order Sent"; Rec."Kitchen Order Sent")
                {

                    ToolTip = 'Specifies the value of the Kitchen Order Sent field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Requested"; Rec."Serving Requested")
                {

                    ToolTip = 'Specifies the value of the Serving Requested field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Change Quantiy action';
                Image = ChangeTo;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Message('Qty');
                end;
            }
            action("Delete Line")
            {
                Enabled = false;
                Visible = false;

                ToolTip = 'Executes the Delete Line action';
                Image = DeleteRow;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Message('DL');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LineIsMarked := Rec.Mark();
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
        Rec.ClearMarks();
    end;
}
