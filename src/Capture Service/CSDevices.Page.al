page 6151384 "NPR CS Devices"
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created
    // NPR5.51/CLVA/20190830  CASE 365659 Page property Editable set to NO

    Caption = 'CS Devices';
    Editable = false;
    PageType = List;
    SourceTable = "NPR CS Devices";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Device Id"; "Device Id")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field(Heartbeat; Heartbeat)
                {
                    ApplicationArea = All;
                }
                field("Last Download Timestamp"; "Last Download Timestamp")
                {
                    ApplicationArea = All;
                }
                field("Current Download Timestamp"; "Current Download Timestamp")
                {
                    ApplicationArea = All;
                }
                field("Current Tag Count"; "Current Tag Count")
                {
                    ApplicationArea = All;
                }
                field("Refresh Item Catalog"; "Refresh Item Catalog")
                {
                    ApplicationArea = All;
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
                Caption = 'Clear Device Info';
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    CSHelperFunctions: Codeunit "NPR CS Helper Functions";
                begin
                    CSHelperFunctions.ClearDeviceInfo(Rec);
                end;
            }
        }
    }
}

