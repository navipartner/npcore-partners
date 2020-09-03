pageextension 6014448 "NPR Jobs Setup" extends "Jobs Setup"
{
    // NPR5.29/TJ/20161014 CASE 248723 New tab Events with new fields
    // NPR5.32/TJ/20170525 CASE 275953 New field "Appointment Lasts Whole Day"
    // NPR5.34/TJ/20170728 CASE 277938 Removed fields "Calendar Template Code","Calendar Confirmed Category","Include Comments in Calendar",
    //                                 "Quote Email Template Code","Order Email Template Code","Cancel Email Template Code","Appointment Lasts Whole Day"
    // NPR5.38/TJ/20171027 CASE 285194 Removed entire group with organizer fields
    // NPR5.48/TJ/20181119 CASE 287903 New field "Post Event on Sales Inv. Post"
    // NPR5.53/TJ/20200109 CASE 346821 New field "Block Event Deletion"
    //                                 New action SetStatusToBlockEventDelete
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
                    field("NPR Auto. Create Job Task Line"; "NPR Auto. Create Job Task Line")
                    {
                        ApplicationArea = All;
                    }
                    field("NPR Def. Job Task No."; "NPR Def. Job Task No.")
                    {
                        ApplicationArea = All;
                    }
                    field("NPR Def. Job Task Description"; "NPR Def. Job Task Description")
                    {
                        ApplicationArea = All;
                    }
                    field("NPR Post Event on Sales Inv. Post"; "NPR Post Event on S.Inv. Post")
                    {
                        ApplicationArea = All;
                    }
                }
                group("NPR Time Setup")
                {
                    Caption = 'Time Setup';
                    field("NPR Qty. Relates to Start/End Time"; "NPR Qty. Rel. 2 Start/End Time")
                    {
                        ApplicationArea = All;
                    }
                    field("NPR Time Calc. Unit of Measure"; "NPR Time Calc. Unit of Measure")
                    {
                        ApplicationArea = All;
                    }
                }
                field("NPR Over Capacitate Resource"; "NPR Over Capacitate Resource")
                {
                    ApplicationArea = All;
                }
                field("NPR BlockEventDeletionValue"; "NPR Block Event Deletion".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Block Event Deletion';
                    Editable = false;
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
                }
            }
        }
    }
}

