page 6150664 "NPR NPRE Seating List"
{
    Extensible = False;
    Caption = 'Seating List';
    ContextSensitiveHelpPage = 'docs/entertainment/restaurant/explanation/seating_layout/';
    CardPageID = "NPR NPRE Seating";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Seating";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the current status of the seating.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this seating.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field("Seating No."; Rec."Seating No.")
                {
                    ToolTip = 'Specifies a user friendly id of the seating (table number).';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the seating.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies if the seating is blocked. Waiter pads cannot be created for blocked locations.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the location this seating is created at.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field(Capacity; Rec.Capacity)
                {
                    ToolTip = 'Specifies the current capacity of the table, that is the number of guests, which actually can be seated at the table without rearranging/borrowing chairs from other seatings.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field("Min Party Size"; Rec."Min Party Size")
                {
                    ToolTip = 'Specifies the minimal number of guests allowed for the table.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    StyleExpr = ColorStyle;
                }
                field("Max Party Size"; Rec."Max Party Size")
                {
                    ToolTip = 'Specifies the maximal number of guests that potentially can be seated at the table, given there are chairs available for borrowing at other tables.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    StyleExpr = ColorStyle;
                }
                field("Fixed Capasity"; Rec."Fixed Capasity")
                {
                    ToolTip = 'Specifies if the seating has a fixed capacity.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field("Current Waiter Pad FF"; Rec."Current Waiter Pad FF")
                {
                    ToolTip = 'Specifies the number of the first waiter pad currently assigned to the seating.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field("Current Waiter Pad Description"; Rec."Current Waiter Pad Description")
                {
                    ToolTip = 'Specifies the description of the first waiter pad currently assigned to the seating.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
                field("Multiple Waiter Pad FF"; Rec."Multiple Waiter Pad FF")
                {
                    ToolTip = 'Specifies the number of waiter pads currently assigned to the seating.';
                    ApplicationArea = NPRRetail;
                    StyleExpr = ColorStyle;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Seating)
            {
                Caption = 'Seating';
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(6150665),
                                      "No." = FIELD(Code);
                        ShortCutKey = 'Shift+Ctrl+D';
                        ToolTip = 'Executes the Dimensions-Single action';
                        ApplicationArea = NPRRetail;
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'Executes the Dimensions-&Multiple action';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            NPRESeating: Record "NPR NPRE Seating";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(NPRESeating);
                            DefaultDimMultiple.SetMultiRecord(NPRESeating, Rec.FieldNo(Code));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.UpdateCurrentWaiterPadDescription();
        SetLineColor();
    end;

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields("Current Waiter Pad FF");
    end;

    var
        CalledFromPosAction: Boolean;
        ColorStyle: Text;

    procedure SetCalledFromPOSAction(NewCalledFromPOSAction: Boolean)
    begin
        CalledFromPosAction := NewCalledFromPOSAction;
    end;

    local procedure SetLineColor()
    begin
        if not CalledFromPosAction then
            exit;

        IF Rec."Current Waiter Pad FF" = '' then
            ColorStyle := 'Subordinate'
        else
            ColorStyle := 'Strong';
    end;
}
