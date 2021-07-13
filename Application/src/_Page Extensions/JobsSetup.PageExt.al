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

                        ToolTip = 'Specifies the value of the NPR Auto. Create Job Task Line field';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Def. Job Task No."; Rec."NPR Def. Job Task No.")
                    {

                        ToolTip = 'Specifies the value of the NPR Def. Job Task No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Def. Job Task Description"; Rec."NPR Def. Job Task Description")
                    {

                        ToolTip = 'Specifies the value of the NPR Def. Job Task Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Post Event on Sales Inv. Post"; Rec."NPR Post Event on S.Inv. Post")
                    {

                        ToolTip = 'Specifies the value of the NPR Post Event on S.Inv. Post field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("NPR Time Setup")
                {
                    Caption = 'Time Setup';
                    field("NPR Qty. Relates to Start/End Time"; Rec."NPR Qty. Rel. 2 Start/End Time")
                    {

                        ToolTip = 'Specifies the value of the NPR Qty. Rel. 2 Start/End Time field';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Time Calc. Unit of Measure"; Rec."NPR Time Calc. Unit of Measure")
                    {

                        ToolTip = 'Specifies the value of the NPR Time Calc. Unit of Measure field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("NPR Over Capacitate Resource"; Rec."NPR Over Capacitate Resource")
                {

                    ToolTip = 'Specifies the value of the NPR Over Capacitate Resource field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR BlockEventDeletionValue"; Rec."NPR Block Event Deletion".HasValue)
                {

                    Caption = 'Block Event Deletion';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Block Event Deletion field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Set Status to Block Event Delete action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}