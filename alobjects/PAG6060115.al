page 6060115 "TM Ticket Access Statistics"
{
    // NPR4.14/TSA/20150803/CASE214262 - Initial Version
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.07/TSA/20160126  CASE 232495 Transport T0005 - 26 January 2016
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.22/TSA/20170601  CASE 274464 (Touched) Changing the principal for recognizing last transaction aggregated
    // TM1.36/TSA /20180727 CASE 323024 Added Variant Code
    // TM1.39/TSA /20181102 CASE 334585 A control of type 'FlowFilter' is not allowed in a parent control of type 'Repeater'

    Caption = 'Ticket Access Statistics';
    Editable = false;
    PageType = List;
    SourceTable = "TM Ticket Access Statistics";
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Ticket Type";"Ticket Type")
                {
                }
                field("Admission Code";"Admission Code")
                {
                }
                field("Admission Date";"Admission Date")
                {
                }
                field("Admission Hour";"Admission Hour")
                {
                }
                field("Admission Count";"Admission Count")
                {
                }
                field("Admission Count (Neg)";"Admission Count (Neg)")
                {
                }
                field("Admission Count (Re-Entry)";"Admission Count (Re-Entry)")
                {
                }
                field("Generated Count (Pos)";"Generated Count (Pos)")
                {
                }
                field("Generated Count (Neg)";"Generated Count (Neg)")
                {
                }
                field("Sum Admission Count";"Sum Admission Count")
                {
                }
            }
        }
    }

    actions
    {
    }
}

