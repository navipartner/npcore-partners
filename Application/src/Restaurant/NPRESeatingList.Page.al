page 6150664 "NPR NPRE Seating List"
{
    Caption = 'Seating List';
    CardPageID = "NPR NPRE Seating";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Seating";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Location field';
                }
                field(Capacity; Rec.Capacity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Capacity field';
                }
                field("Fixed Capasity"; Rec."Fixed Capasity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Capasity field';
                }
                field("Current Waiter Pad FF"; Rec."Current Waiter Pad FF")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Waiter Pad field';
                }
                field("Current Waiter Pad Description"; Rec."Current Waiter Pad Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Waiter Pad Description field';
                }
                field("Multiple Waiter Pad FF"; Rec."Multiple Waiter Pad FF")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Multiple Waiter Pad field';
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
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dimensions-Single action';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dimensions-&Multiple action';

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
        Rec.UpdateCurrentWaiterPadDescription;
    end;
}