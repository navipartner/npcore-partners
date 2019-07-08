page 6184500 "CleanCash Setup List"
{
    // NPR4.21/JHL/20160302 CASE 222417 page created to manage the setup of CleanCash
    // NPR5.29/JHL/20161027 CASE 256695 Added field "Hosted CleanCash Register No."
    // NPR5.31/JHL/20170223 CASE 256695 Added field "Run Local"

    Caption = 'CleanCash Setup List';
    PageType = List;
    SourceTable = "CleanCash Setup";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Register;Register)
                {
                }
                field("Connection String";"Connection String")
                {
                }
                field("Run Local";"Run Local")
                {
                }
                field("Organization ID";"Organization ID")
                {
                }
                field("CleanCash Register No.";"CleanCash Register No.")
                {
                }
                field("Last Z Report Time";"Last Z Report Time")
                {
                }
                field("Multi Organization ID Per POS";"Multi Organization ID Per POS")
                {
                }
                field(Training;Training)
                {
                }
                field("Show Error Message";"Show Error Message")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }
}

