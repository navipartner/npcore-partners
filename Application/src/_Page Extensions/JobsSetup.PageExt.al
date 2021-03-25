pageextension 6014448 "NPR Jobs Setup" extends "Jobs Setup"
{
    layout
    {
        addafter(Numbering)
        {
            group("NPR Setup")
            {
                Caption = 'Events';
                group("NPR Auto. Setup")
                {
                    Caption = 'Auto. Setup';
                    field("NPR Auto. Create Job Task Line"; Rec."NPR Auto. Create Job Task Line")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Auto. Create Job Task Line field';
                    }
                    field("NPR Def. Job Task No."; Rec."NPR Def. Job Task No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Def. Job Task No. field';
                    }
                    field("NPR Def. Job Task Description"; Rec."NPR Def. Job Task Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Def. Job Task Description field';
                    }
                    field("NPR Post Event on Sales Inv. Post"; Rec."NPR Post Event on S.Inv. Post")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Post Event on S.Inv. Post field';
                    }
                }
                group("NPR Time Setup")
                {
                    Caption = 'Time Setup';
                    field("NPR Qty. Relates to Start/End Time"; Rec."NPR Qty. Rel. 2 Start/End Time")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Qty. Rel. 2 Start/End Time field';
                    }
                    field("NPR Time Calc. Unit of Measure"; Rec."NPR Time Calc. Unit of Measure")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NPR Time Calc. Unit of Measure field';
                    }
                }
                field("NPR Over Capacitate Resource"; Rec."NPR Over Capacitate Resource")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Over Capacitate Resource field';
                }
                field("NPR BlockEventDeletionValue"; Rec."NPR Block Event Deletion".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Block Event Deletion';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Block Event Deletion field';
                }
            }
        }
    }
    actions
    {

        addfirst(processing)
        {
            group("NPR Events")
            {
                Caption = 'Events';
                action("NPR SetStatusToBlockEventDelete")
                {
                    Caption = 'Set Status to Block Event Delete';
                    Image = Setup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set Status to Block Event Delete action';
                }
            }
        }
    }
}