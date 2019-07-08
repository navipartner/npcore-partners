page 6151384 "CS Devices"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created

    Caption = 'CS Devices';
    PageType = List;
    SourceTable = "CS Devices";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Device Id";"Device Id")
                {
                }
                field(Created;Created)
                {
                }
                field(Heartbeat;Heartbeat)
                {
                }
                field("Last Download Timestamp";"Last Download Timestamp")
                {
                }
                field("Current Download Timestamp";"Current Download Timestamp")
                {
                }
                field("Current Tag Count";"Current Tag Count")
                {
                }
                field("Refresh Item Catalog";"Refresh Item Catalog")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Clear Device Info")
            {

                trigger OnAction()
                var
                    CSHelperFunctions: Codeunit "CS Helper Functions";
                begin
                    CSHelperFunctions.ClearDeviceInfo(Rec);
                end;
            }
        }
    }
}

