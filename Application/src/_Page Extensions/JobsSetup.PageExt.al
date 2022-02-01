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

                        ToolTip = 'Specifies whether Job Task Lines will be automatically created.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Def. Job Task No."; Rec."NPR Def. Job Task No.")
                    {

                        ToolTip = 'Specifies Default Job Task No to be used when automatically creating the Task Line.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Def. Job Task Description"; Rec."NPR Def. Job Task Description")
                    {

                        ToolTip = 'Specifies Default Job Task Description to be used when automatically creating the Task Line.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Post Event on Sales Inv. Post"; Rec."NPR Post Event on S.Inv. Post")
                    {

                        ToolTip = 'Specifies whether to allow posting from Sales Invoices to impact inventory only or both inventory and jobs.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("NPR Time Setup")
                {
                    Caption = 'Time Setup';
                    field("NPR Qty. Relates to Start/End Time"; Rec."NPR Qty. Rel. 2 Start/End Time")
                    {

                        ToolTip = 'Specifies the value of the quantity related to Start/End Time.';
                        ApplicationArea = NPRRetail;
                    }
                    field("NPR Time Calc. Unit of Measure"; Rec."NPR Time Calc. Unit of Measure")
                    {

                        ToolTip = 'Specifies the unit of measure used when calculating time.';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("NPR Over Capacitate Resource"; Rec."NPR Over Capacitate Resource")
                {

                    ToolTip = 'Specifies if the task allocation can be exceeded, or not reach the maximum capacity.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR BlockEventDeletionValue"; Rec."NPR Block Event Deletion".HasValue)
                {

                    Caption = 'Block Event Deletion';
                    Editable = false;
                    ToolTip = 'Display the Block Event Deletion.';
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

                    ToolTip = 'Open a page in which you can choose between the following options: planning, quote, order, completed, postponed, etc.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()

                    var
                        EventManagement: Codeunit "NPR Event Management";
                    begin
                        EventManagement.SetStatusToBlockEventDelete(Rec);
                    end;
                }
            }
        }
    }
}