page 6150664 "NPRE Seating List"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.36/ANEN /20170918 CASE 290639 Adding column seating location

    Caption = 'Seating List';
    CardPageID = "NPRE Seating";
    Editable = false;
    PageType = List;
    SourceTable = "NPRE Seating";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Status;Status)
                {
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Seating Location";"Seating Location")
                {
                }
                field(Capacity;Capacity)
                {
                }
                field("Fixed Capasity";"Fixed Capasity")
                {
                }
                field("Current Waiter Pad FF";"Current Waiter Pad FF")
                {
                }
                field("Current Waiter Pad Description";"Current Waiter Pad Description")
                {
                }
                field("Multiple Waiter Pad FF";"Multiple Waiter Pad FF")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        UpdateCurrentWaiterPadDescription;
    end;
}

