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
                    ToolTip = 'Specifies internal unique Id of the seating';
                    ApplicationArea = NPRRetail;
                }
                field("Seating No."; Rec."Seating No.")
                {
                    ToolTip = 'Specifies a user friendly id of the seating (table number)';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the value of the Seating Location field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocking Reason"; Rec."Blocking Reason")
                {
                    ToolTip = 'Specifies the value of the Blocking Reason field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Capasity Tab")
            {
                Caption = 'Capasity';
                field("Fixed Capasity"; Rec."Fixed Capasity")
                {
                    ToolTip = 'Specifies the value of the Fixed Capasity field';
                    ApplicationArea = NPRRetail;
                }
                field(Capacity; Rec.Capacity)
                {
                    ToolTip = 'Specifies the value of the Capacity field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(StatusGr)
            {
                Caption = 'Status';
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Status field';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Status Description FF");
                    end;
                }
                field("Status Description FF"; Rec."Status Description FF")
                {
                    Editable = false;
                    DrillDown = false;
                    ToolTip = 'Specifies the value of the Status Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Current Acvtivity")
            {
                Caption = 'Current Acvtivity';
                field("Current Waiter Pad FF"; Rec."Current Waiter Pad FF")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Current Waiter Pad field';
                    ApplicationArea = NPRRetail;
                }
                field("Multiple Waiter Pad FF"; Rec."Multiple Waiter Pad FF")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Multiple Waiter Pad field';
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
