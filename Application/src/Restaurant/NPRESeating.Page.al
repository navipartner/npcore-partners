page 6150665 "NPR NPRE Seating"
{
    Extensible = False;
    Caption = 'Seating';
    PageType = Card;
    SourceTable = "NPR NPRE Seating";
    PopulateAllFields = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this seating.';
                    ApplicationArea = NPRRetail;
                }
                field("Seating No."; Rec."Seating No.")
                {
                    ToolTip = 'Specifies a user friendly id of the seating (table number).';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the seating.';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the location this seating is created at.';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies if the seating is blocked. Waiter pads cannot be created for blocked locations.';
                    ApplicationArea = NPRRetail;
                }
                field("Blocking Reason"; Rec."Blocking Reason")
                {
                    ToolTip = 'Specifies a text describing the reason of seating blocking.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Capasity Tab")
            {
                Caption = 'Capasity';
                field("Fixed Capasity"; Rec."Fixed Capasity")
                {
                    ToolTip = 'Specifies if the seating has a fixed capacity.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field(Capacity; Rec.Capacity)
                {
                    ToolTip = 'Specifies the current capacity of the table, that is the number of guests, which actually can be seated at the table without rearranging/borrowing chairs from other seatings.';
                    ApplicationArea = NPRRetail;
                }
                field("Min Party Size"; Rec."Min Party Size")
                {
                    ToolTip = 'Specifies the minimal number of guests allowed for the table.';
                    ApplicationArea = NPRRetail;
                }
                field("Max Party Size"; Rec."Max Party Size")
                {
                    ToolTip = 'Specifies the maximal number of guests that potentially can be seated at the table, given there are chairs available for borrowing at other tables.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(StatusGr)
            {
                Caption = 'Status';
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the current status of the seating.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Status Description FF");
                    end;
                }
                field("Status Description FF"; Rec."Status Description FF")
                {
                    Editable = false;
                    DrillDown = false;
                    ToolTip = 'Specifies a description of the current status of the seating.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Current Acvtivity")
            {
                Caption = 'Current Acvtivity';
                field("Current Waiter Pad FF"; Rec."Current Waiter Pad FF")
                {
                    Editable = false;
                    ToolTip = 'Specifies the number of the first waiter pad currently assigned to the seating.';
                    ApplicationArea = NPRRetail;
                }
                field("Multiple Waiter Pad FF"; Rec."Multiple Waiter Pad FF")
                {
                    Editable = false;
                    ToolTip = 'Specifies the number of waiter pads currently assigned to the seating.';
                    ApplicationArea = NPRRetail;
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
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(6150665),
                                  "No." = FIELD(Code);
                    ShortCutKey = 'Shift+Ctrl+D';

                    ToolTip = 'Executes the Dimensions action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
