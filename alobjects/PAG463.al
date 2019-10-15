pageextension 6014442 pageextension6014442 extends "Jobs Setup" 
{
    // NPR5.29/TJ/20161014 CASE 248723 New tab Events with new fields
    // NPR5.32/TJ/20170525 CASE 275953 New field "Appointment Lasts Whole Day"
    // NPR5.34/TJ/20170728 CASE 277938 Removed fields "Calendar Template Code","Calendar Confirmed Category","Include Comments in Calendar",
    //                                 "Quote Email Template Code","Order Email Template Code","Cancel Email Template Code","Appointment Lasts Whole Day"
    // NPR5.38/TJ/20171027 CASE 285194 Removed entire group with organizer fields
    // NPR5.48/TJ/20181119 CASE 287903 New field "Post Event on Sales Inv. Post"
    layout
    {
        addafter(Numbering)
        {
            group(Events)
            {
                Caption = 'Events';
                group("Auto. Setup")
                {
                    Caption = 'Auto. Setup';
                    field("Auto. Create Job Task Line";"Auto. Create Job Task Line")
                    {
                    }
                    field("Def. Job Task No.";"Def. Job Task No.")
                    {
                    }
                    field("Def. Job Task Description";"Def. Job Task Description")
                    {
                    }
                    field("Post Event on Sales Inv. Post";"Post Event on Sales Inv. Post")
                    {
                    }
                }
                group("Time Setup")
                {
                    Caption = 'Time Setup';
                    field("Qty. Relates to Start/End Time";"Qty. Relates to Start/End Time")
                    {
                    }
                    field("Time Calc. Unit of Measure";"Time Calc. Unit of Measure")
                    {
                    }
                }
                field("Over Capacitate Resource";"Over Capacitate Resource")
                {
                }
            }
        }
    }
}

